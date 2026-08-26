import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/progression_state.dart';
import '../domain/xp_rules.dart';

/// State for overlay events — complete flash and level-up.
class OverlayState {
  const OverlayState({this.flash, this.levelUp});

  final ({int xp, String name})? flash;
  final int? levelUp; // previous level when level-up queued

  OverlayState copyWith({({int xp, String name})? flash, int? levelUp}) {
    return OverlayState(flash: flash, levelUp: levelUp);
  }
}

/// Combined state for progression + overlays.
class ProgressionFullState {
  const ProgressionFullState({
    this.progression = const ProgressionState(),
    this.overlay = const OverlayState(),
  });

  final ProgressionState progression;
  final OverlayState overlay;

  ProgressionFullState copyWith({
    ProgressionState? progression,
    OverlayState? overlay,
  }) {
    return ProgressionFullState(
      progression: progression ?? this.progression,
      overlay: overlay ?? this.overlay,
    );
  }
}

/// Drives progression: XP awarding, level-up detection, overlay events.
///
/// The shell watches [state.overlay] to decide when to show the complete and
/// level-up overlays.
class ProgressionController extends Notifier<ProgressionFullState> {
  @override
  ProgressionFullState build() => const ProgressionFullState();

  ProgressionState get progression => state.progression;
  OverlayState get overlay => state.overlay;

  /// Award [amount] XP. Returns the result for downstream use.
  ProgressionResult award(int amount) {
    final result = XpRules.award(
      level: progression.level,
      xpIntoLevel: progression.xpIntoLevel,
      lifetimeXp: progression.lifetimeXp,
      amount: amount,
    );

    state = state.copyWith(
      progression: progression.copyWith(
        level: result.level,
        xpIntoLevel: result.xpIntoLevel,
        lifetimeXp: result.lifetimeXp,
      ),
    );

    return result;
  }

  /// Show the quest-complete flash overlay.
  void showFlash({required int xp, required String name}) {
    state = state.copyWith(
      overlay: state.overlay.copyWith(flash: (xp: xp, name: name)),
    );
  }

  /// Clear the quest-complete flash.
  void clearFlash() {
    state = state.copyWith(overlay: state.overlay.copyWith(flash: null));
  }

  /// Queue the level-up overlay.
  void showLevelUp(int previousLevel) {
    state = state.copyWith(
      overlay: state.overlay.copyWith(levelUp: previousLevel),
    );
  }

  /// Clear the level-up overlay.
  void clearLevelUp() {
    state = state.copyWith(overlay: state.overlay.copyWith(levelUp: null));
  }
}

final progressionProvider =
    NotifierProvider<ProgressionController, ProgressionFullState>(
      ProgressionController.new,
    );

/// Convenience: the progression sub-state for direct watches.
final progressionStateProvider = Provider<ProgressionState>((ref) {
  return ref.watch(progressionProvider).progression;
});

/// Convenience: the overlay sub-state for direct watches.
final overlayProvider = Provider<OverlayState>((ref) {
  return ref.watch(progressionProvider).overlay;
});
