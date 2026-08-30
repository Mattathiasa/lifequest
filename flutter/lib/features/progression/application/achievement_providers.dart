import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/achievements.dart';
import 'progression_controller.dart';
import '../../quests/application/quest_providers.dart';

/// Provides the current achievement stats computed from real gameplay data.
final achievementStatsProvider = Provider<AchievementStats>((ref) {
  final prog = ref.watch(progressionStateProvider);
  final quests = ref.watch(questListProvider);
  final history = ref.watch(historyProvider);

  // Count completed quests
  final questsDone = quests.where((q) => q.done).length;

  // Check for night owl (completed after 10 PM)
  final nightOwl = history.any((e) => e.at.hour >= 22);

  // Compute perfect week days (days with all quests completed)
  // For now, use streak as a proxy since we track lastClearedDay
  final perfectWeekDays = prog.streak;

  return AchievementStats(
    streak: prog.streak,
    questsDone: questsDone,
    level: prog.level,
    perfectWeekDays: perfectWeekDays,
    firstLevelUp: prog.firstLevelUp,
    nightOwl: nightOwl,
  );
});

/// Provides the list of achievements with current status.
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final stats = ref.watch(achievementStatsProvider);
  return buildAchievements(stats);
});

/// Provider for count of earned achievements.
final earnedAchievementsCountProvider = Provider<int>((ref) {
  final achievements = ref.watch(achievementsProvider);
  return achievements.where((a) => a.earned).length;
});
