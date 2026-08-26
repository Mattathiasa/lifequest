import '../../progression/domain/xp_rules.dart';

/// A single quest in the adventure.
class Quest {
  const Quest({
    required this.id,
    required this.code,
    required this.name,
    required this.desc,
    required this.category,
    required this.difficulty,
    required this.time,
    required this.due,
    required this.schedule,
    this.done = false,
  });

  final int id;
  final String code;
  final String name;
  final String desc;
  final QuestCategory category;
  final QuestDifficulty difficulty;
  final String time;
  final String due;
  final QuestSchedule schedule;
  final bool done;

  /// Computed XP reward for this quest (balanced mode).
  int get xp => XpRules.reward(difficulty, DifficultyMode.balanced);

  Quest copyWith({bool? done}) {
    return Quest(
      id: id,
      code: code,
      name: name,
      desc: desc,
      category: category,
      difficulty: difficulty,
      time: time,
      due: due,
      schedule: schedule,
      done: done ?? this.done,
    );
  }
}

enum QuestCategory {
  health,
  learning,
  productivity,
  social,
  finance,
  mindfulness;

  String get label => switch (this) {
    QuestCategory.health => 'Health',
    QuestCategory.learning => 'Learning',
    QuestCategory.productivity => 'Productivity',
    QuestCategory.social => 'Social',
    QuestCategory.finance => 'Finance',
    QuestCategory.mindfulness => 'Mindfulness',
  };

  String get uppercase => label.toUpperCase();
}

enum QuestSchedule { today, upcoming, recurring }
