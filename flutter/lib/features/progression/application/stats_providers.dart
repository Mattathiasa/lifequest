import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/achievements.dart';
import '../domain/stats.dart';
import 'progression_controller.dart';

/// Total quests completed (seeded history + this session).
final questsDoneProvider = Provider<int>(
  (ref) => GameStats.questsDone(ref.watch(historyProvider)),
);

/// Percentage of the last 7 days with any completion — Trail "THIS WEEK".
final weekActiveRateProvider = Provider<int>(
  (ref) => GameStats.weekActiveRate(ref.watch(historyProvider), DateTime.now()),
);

/// The six achievements evaluated from real play counters.
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final history = ref.watch(historyProvider);
  final prog = ref.watch(progressionStateProvider);
  final now = DateTime.now();
  return buildAchievements(
    AchievementStats(
      streak: prog.streak,
      questsDone: GameStats.questsDone(history),
      level: prog.level,
      perfectWeekDays: GameStats.perfectWeekDays(history, now),
      firstLevelUp: prog.firstLevelUp,
      nightOwl: GameStats.nightOwl(history),
    ),
  );
});

/// Number of earned achievements — the "BADGES" count.
final earnedBadgeCountProvider = Provider<int>(
  (ref) => ref.watch(achievementsProvider).where((a) => a.earned).length,
);
