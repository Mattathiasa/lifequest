/// A single achievement's computed display state.
class Achievement {
  const Achievement(this.name, this.earned, this.hint);

  final String name;
  final bool earned;

  /// "Earned" when unlocked, otherwise a progress hint (e.g. "68 / 100").
  final String hint;
}

/// The counters the six achievements are evaluated against.
class AchievementStats {
  const AchievementStats({
    required this.streak,
    required this.questsDone,
    required this.level,
    required this.perfectWeekDays,
    required this.firstLevelUp,
    required this.nightOwl,
  });

  final int streak;
  final int questsDone;
  final int level;
  final int perfectWeekDays;
  final bool firstLevelUp;
  final bool nightOwl;
}

/// The spec's six achievements, evaluated from real play counters.
List<Achievement> buildAchievements(AchievementStats s) => [
  Achievement(
    '7 Day Streak',
    s.streak >= 7,
    s.streak >= 7 ? 'Earned' : '${s.streak} / 7 days',
  ),
  Achievement(
    'First Level Up',
    s.firstLevelUp,
    s.firstLevelUp ? 'Earned' : 'Level up once',
  ),
  Achievement(
    'Quest Hunter',
    s.questsDone >= 100,
    s.questsDone >= 100 ? 'Earned' : '${s.questsDone} / 100',
  ),
  Achievement(
    'Night Owl',
    s.nightOwl,
    s.nightOwl ? 'Earned' : 'Finish after 10 PM',
  ),
  Achievement(
    'Perfect Week',
    s.perfectWeekDays >= 7,
    s.perfectWeekDays >= 7 ? 'Earned' : '${s.perfectWeekDays} / 7 days',
  ),
  Achievement(
    'Level 25',
    s.level >= 25,
    s.level >= 25 ? 'Earned' : 'Lvl ${s.level} / 25',
  ),
];
