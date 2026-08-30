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

  Quest copyWith({
    String? code,
    String? name,
    String? desc,
    QuestCategory? category,
    QuestDifficulty? difficulty,
    String? time,
    String? due,
    QuestSchedule? schedule,
    bool? done,
  }) {
    return Quest(
      id: id,
      code: code ?? this.code,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      time: time ?? this.time,
      due: due ?? this.due,
      schedule: schedule ?? this.schedule,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'desc': desc,
    'category': category.name,
    'difficulty': difficulty.name,
    'time': time,
    'due': due,
    'schedule': schedule.name,
    'done': done,
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: (json['id'] as num).toInt(),
    code: json['code'] as String,
    name: json['name'] as String,
    desc: json['desc'] as String,
    category: QuestCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => QuestCategory.productivity,
    ),
    difficulty: QuestDifficulty.values.firstWhere(
      (d) => d.name == json['difficulty'],
      orElse: () => QuestDifficulty.medium,
    ),
    time: json['time'] as String,
    due: json['due'] as String,
    schedule: QuestSchedule.values.firstWhere(
      (s) => s.name == json['schedule'],
      orElse: () => QuestSchedule.today,
    ),
    done: json['done'] as bool? ?? false,
  );
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
