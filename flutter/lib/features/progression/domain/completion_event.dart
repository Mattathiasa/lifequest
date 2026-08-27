import '../../quests/domain/quest.dart';

/// A single logged quest completion — the raw material for every aggregate
/// (weekly XP, heatmap, XP-by-category, achievements, day-clear streaks).
class CompletionEvent {
  const CompletionEvent({
    required this.questId,
    required this.category,
    required this.xp,
    required this.at,
  });

  final int questId;
  final QuestCategory category;
  final int xp;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'questId': questId,
    'category': category.name,
    'xp': xp,
    'at': at.toIso8601String(),
  };

  factory CompletionEvent.fromJson(Map<String, dynamic> json) =>
      CompletionEvent(
        questId: (json['questId'] as num).toInt(),
        category: QuestCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => QuestCategory.productivity,
        ),
        xp: (json['xp'] as num).toInt(),
        at: DateTime.parse(json['at'] as String),
      );
}
