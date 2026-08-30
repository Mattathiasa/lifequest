import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';
import '../../settings/application/settings_controller.dart';
import '../data/progression_repository.dart';
import '../domain/attributes.dart';
import '../domain/completion_event.dart';
import '../domain/progression_state.dart';
import '../domain/xp_rules.dart';

/// Sentinel so [OverlayState.copyWith] can tell "leave unchanged" apart from
/// "set to null" — both `flash` and `levelUp` use `null` as a real value.
const Object _unset = Object();

/// State for overlay events — complete flash and level-up.
class OverlayState {
  const OverlayState({this.flash, this.levelUp});

  final ({int xp, String name})? flash;
  final int? levelUp; // previous level when level-up queued

  OverlayState copyWith({Object? flash = _unset, Object? levelUp = _unset}) {
    return OverlayState(
      flash: identical(flash, _unset)
          ? this.flash
          : flash as ({int xp, String name})?,
      levelUp: identical(levelUp, _unset) ? this.levelUp : levelUp as int?,
    );
  }
}

/// Combined game state: progression, attributes, completion history, overlays.
class ProgressionFullState {
  const ProgressionFullState({
    this.progression = const ProgressionState(),
    this.attributes = Attributes.seed,
    this.history = const [],
    this.overlay = const OverlayState(),
  });

  final ProgressionState progression;
  final Attributes attributes;
  final List<CompletionEvent> history;
  final OverlayState overlay;

  ProgressionFullState copyWith({
    ProgressionState? progression,
    Attributes? attributes,
    List<CompletionEvent>? history,
    OverlayState? overlay,
  }) {
    return ProgressionFullState(
      progression: progression ?? this.progression,
      attributes: attributes ?? this.attributes,
      history: history ?? this.history,
      overlay: overlay ?? this.overlay,
    );
  }
}

/// Owns the whole completion pipeline: marking quests done, awarding XP,
/// growing attributes, logging history, updating the streak, and firing the
/// complete/level-up overlays — then persisting. Trail, Focus and the side
/// quest all route through here.
class ProgressionController extends Notifier<ProgressionFullState> {
  Timer? _awardTimer;
  Timer? _levelUpTimer;

  @override
  ProgressionFullState build() {
    ref.onDispose(() {
      _awardTimer?.cancel();
      _levelUpTimer?.cancel();
    });
    _load();
    return const ProgressionFullState();
  }

  ProgressionState get progression => state.progression;
  OverlayState get overlay => state.overlay;

  ProgressionRepository get _repo => ref.read(progressionRepositoryProvider);

  Future<void> _load() async {
    final snap = await _repo.load();
    state = state.copyWith(
      progression: snap.progression,
      attributes: snap.attributes,
      history: snap.history,
    );
  }

  void _persist() {
    _repo.save(
      GameSnapshot(
        progression: state.progression,
        attributes: state.attributes,
        history: state.history,
      ),
    );
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Complete a quest: mark done, flash, then award XP + grow attributes + log.
  Future<void> completeQuest(Quest quest) async {
    if (quest.done) return;
    final xp = XpRules.reward(
      quest.difficulty,
      ref.read(difficultyModeProvider),
    );
    await ref.read(questListProvider.notifier).complete(quest.id);
    showFlash(xp: xp, name: quest.name);
    _scheduleAward(xp, category: quest.category, questId: quest.id);
  }

  /// Claim the day-clear bonus. Idempotent per day; extends the streak (and
  /// resets it if a day was missed, unless a streak freeze is used).
  void claimDayBonus() {
    final p = state.progression;
    final now = DateTime.now();
    if (p.lastClearedDay != null && _sameDay(p.lastClearedDay!, now)) return;
    
    // Check if we can continue the streak
    final yesterday = now.subtract(const Duration(days: 1));
    final continues =
        p.lastClearedDay != null &&
        (_sameDay(p.lastClearedDay!, yesterday) ||
         _sameDay(p.lastClearedDay!, now.subtract(const Duration(days: 2))));
    
    // If streak would break and we have a freeze, use it
    final streakWouldBreak = !continues && p.streak > 0;
    final useFreeze = streakWouldBreak && p.canUseStreakFreeze;
    
    final streak = (continues || useFreeze) ? p.streak + 1 : 1;
    state = state.copyWith(
      progression: p.copyWith(
        streak: streak,
        recordStreak: streak > p.recordStreak ? streak : p.recordStreak,
        lastClearedDay: now,
        streakFreezes: useFreeze ? p.streakFreezes - 1 : p.streakFreezes,
        lastStreakFreezeUsed: useFreeze ? now : p.lastStreakFreezeUsed,
      ),
    );
    _persist();
    
    if (useFreeze) {
      showFlash(xp: XpRules.dayClearBonus, name: 'Streak freeze used!');
    } else {
      showFlash(xp: XpRules.dayClearBonus, name: 'Day cleared');
    }
    _scheduleAward(XpRules.dayClearBonus);
  }

  /// Use a streak freeze to protect today's streak.
  void useStreakFreeze() {
    final p = state.progression;
    if (!p.canUseStreakFreeze) return;
    
    final now = DateTime.now();
    state = state.copyWith(
      progression: p.copyWith(
        streakFreezes: p.streakFreezes - 1,
        lastStreakFreezeUsed: now,
      ),
    );
    _persist();
    showFlash(xp: 0, name: 'Streak freeze activated');
  }

  /// Add a streak freeze (e.g., from purchase or reward).
  void addStreakFreeze() {
    final p = state.progression;
    state = state.copyWith(
      progression: p.copyWith(
        streakFreezes: p.streakFreezes + 1,
      ),
    );
    _persist();
  }

  /// Accept the side quest — a flat XP reward through the same sequence.
  void acceptSideQuest() {
    showFlash(xp: 300, name: 'Side quest');
    _scheduleAward(300);
  }

  // ── Overlay plumbing (watched by the app shell) ───────────────────────────

  void showFlash({required int xp, required String name}) {
    state = state.copyWith(
      overlay: state.overlay.copyWith(flash: (xp: xp, name: name)),
    );
  }

  void clearFlash() =>
      state = state.copyWith(overlay: state.overlay.copyWith(flash: null));

  void showLevelUp(int previousLevel) => state = state.copyWith(
    overlay: state.overlay.copyWith(levelUp: previousLevel),
  );

  void clearLevelUp() =>
      state = state.copyWith(overlay: state.overlay.copyWith(levelUp: null));

  // ── Internals ─────────────────────────────────────────────────────────────

  /// Awards [xp] after a short beat (so the flash reads first). When a
  /// [category] is given it also grows attributes and logs a completion event.
  void _scheduleAward(int xp, {QuestCategory? category, int? questId}) {
    _awardTimer?.cancel();
    _awardTimer = Timer(const Duration(milliseconds: 300), () {
      final p = state.progression;
      final result = XpRules.award(
        level: p.level,
        xpIntoLevel: p.xpIntoLevel,
        lifetimeXp: p.lifetimeXp,
        amount: xp,
      );
      final leveled = result.levelsGained > 0;
      state = state.copyWith(
        progression: p.copyWith(
          level: result.level,
          xpIntoLevel: result.xpIntoLevel,
          lifetimeXp: result.lifetimeXp,
          firstLevelUp: p.firstLevelUp || leveled,
        ),
        attributes: category != null
            ? state.attributes.applyDeltas(attributeDeltasFor(category))
            : state.attributes,
        history: category != null
            ? [
                ...state.history,
                CompletionEvent(
                  questId: questId ?? -1,
                  category: category,
                  xp: xp,
                  at: DateTime.now(),
                ),
              ]
            : state.history,
      );
      _persist();
      if (leveled) {
        // Queue the level-up after the complete overlay has had its moment.
        _levelUpTimer?.cancel();
        _levelUpTimer = Timer(
          const Duration(milliseconds: 1400),
          () => showLevelUp(result.previousLevel),
        );
      }
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

final progressionRepositoryProvider = Provider<ProgressionRepository>(
  (_) => PrefsProgressionRepository(),
);

final progressionProvider =
    NotifierProvider<ProgressionController, ProgressionFullState>(
      ProgressionController.new,
    );

/// The progression sub-state for direct watches.
final progressionStateProvider = Provider<ProgressionState>(
  (ref) => ref.watch(progressionProvider).progression,
);

/// The overlay sub-state for direct watches.
final overlayProvider = Provider<OverlayState>(
  (ref) => ref.watch(progressionProvider).overlay,
);

/// The current attribute values.
final attributesProvider = Provider<Attributes>(
  (ref) => ref.watch(progressionProvider).attributes,
);

/// The full completion history.
final historyProvider = Provider<List<CompletionEvent>>(
  (ref) => ref.watch(progressionProvider).history,
);
