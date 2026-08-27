import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../quests/domain/quest.dart';
import '../domain/attributes.dart';
import '../domain/completion_event.dart';
import '../domain/progression_state.dart';

/// The full persisted game state.
class GameSnapshot {
  const GameSnapshot({
    required this.progression,
    required this.attributes,
    required this.history,
  });

  final ProgressionState progression;
  final Attributes attributes;
  final List<CompletionEvent> history;
}

/// Persistence boundary for game state. Firebase implements this later.
abstract interface class ProgressionRepository {
  Future<GameSnapshot> load();
  Future<void> save(GameSnapshot snapshot);
}

/// [SharedPreferences]-backed game state, seeded on first run so the mid-game
/// character (level 12, streak 14) has a plausible history behind it.
class PrefsProgressionRepository implements ProgressionRepository {
  static const _kProgression = 'game.progression';
  static const _kAttributes = 'game.attributes';
  static const _kHistory = 'game.history';

  @override
  Future<GameSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_kProgression)) {
      final seed = _seed();
      await save(seed);
      return seed;
    }
    return GameSnapshot(
      progression: ProgressionState.fromJson(
        jsonDecode(prefs.getString(_kProgression)!) as Map<String, dynamic>,
      ),
      attributes: Attributes.fromJson(
        jsonDecode(prefs.getString(_kAttributes) ?? '{}')
            as Map<String, dynamic>,
      ),
      history: ((jsonDecode(prefs.getString(_kHistory) ?? '[]')) as List)
          .map((e) => CompletionEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> save(GameSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kProgression,
      jsonEncode(snapshot.progression.toJson()),
    );
    await prefs.setString(
      _kAttributes,
      jsonEncode(snapshot.attributes.toJson()),
    );
    await prefs.setString(
      _kHistory,
      jsonEncode(snapshot.history.map((e) => e.toJson()).toList()),
    );
  }

  /// First-run seed: defaults plus ~90 backdated completions over six weeks so
  /// the Progress charts and achievement counters aren't empty.
  GameSnapshot _seed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return GameSnapshot(
      progression: ProgressionState(
        lastClearedDay: today.subtract(const Duration(days: 1)),
      ),
      attributes: Attributes.seed,
      history: seedHistory(today),
    );
  }
}

/// Deterministic six-week seed history matching the spec's category mix.
List<CompletionEvent> seedHistory(DateTime today) {
  // Weighted category bag (~ Health 35 / Learning 20 / Productivity 20 /
  // Mindfulness 15 / Social 5 / Finance 5 %).
  const bag = <QuestCategory>[
    QuestCategory.health,
    QuestCategory.health,
    QuestCategory.health,
    QuestCategory.health,
    QuestCategory.health,
    QuestCategory.health,
    QuestCategory.health,
    QuestCategory.learning,
    QuestCategory.learning,
    QuestCategory.learning,
    QuestCategory.learning,
    QuestCategory.productivity,
    QuestCategory.productivity,
    QuestCategory.productivity,
    QuestCategory.productivity,
    QuestCategory.mindfulness,
    QuestCategory.mindfulness,
    QuestCategory.mindfulness,
    QuestCategory.social,
    QuestCategory.finance,
  ];
  const perDay = [2, 2, 3, 1, 2, 2, 3]; // by weekday index
  const xpCycle = [150, 50, 280, 150, 150, 280, 50];

  final events = <CompletionEvent>[];
  var i = 0;
  for (var dayOffset = 41; dayOffset >= 0; dayOffset--) {
    final date = today.subtract(Duration(days: dayOffset));
    final count = perDay[dayOffset % perDay.length];
    for (var j = 0; j < count; j++) {
      // One late-night completion three days ago earns Night Owl.
      final hour = (dayOffset == 3 && j == 0) ? 23 : 9 + (j * 4) % 11;
      events.add(
        CompletionEvent(
          questId: -1,
          category: bag[i % bag.length],
          xp: xpCycle[i % xpCycle.length],
          at: DateTime(date.year, date.month, date.day, hour),
        ),
      );
      i++;
    }
  }
  return events;
}
