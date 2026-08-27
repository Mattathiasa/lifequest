import '../../quests/domain/quest.dart';

/// The seven character attributes. Values are 0–100.
enum Attribute {
  strength,
  intellect,
  discipline,
  health,
  creativity,
  social,
  focus;

  String get label => switch (this) {
    Attribute.strength => 'STRENGTH',
    Attribute.intellect => 'INTELLECT',
    Attribute.discipline => 'DISCIPLINE',
    Attribute.health => 'HEALTH',
    Attribute.creativity => 'CREATIVITY',
    Attribute.social => 'SOCIAL',
    Attribute.focus => 'FOCUS',
  };
}

/// Immutable snapshot of the seven attribute values.
class Attributes {
  const Attributes(this.values);

  final Map<Attribute, int> values;

  /// The starting values from the spec.
  static const seed = Attributes({
    Attribute.strength: 64,
    Attribute.intellect: 81,
    Attribute.discipline: 88,
    Attribute.health: 72,
    Attribute.creativity: 57,
    Attribute.social: 43,
    Attribute.focus: 76,
  });

  int operator [](Attribute a) => values[a] ?? 0;

  /// Returns a new snapshot with [deltas] added, clamped to 0–100.
  Attributes applyDeltas(Map<Attribute, int> deltas) {
    final next = Map<Attribute, int>.from(values);
    deltas.forEach((k, v) => next[k] = ((next[k] ?? 0) + v).clamp(0, 100));
    return Attributes(next);
  }

  Map<String, int> toJson() => {
    for (final e in values.entries) e.key.name: e.value,
  };

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes({
    for (final a in Attribute.values)
      a: (json[a.name] as num?)?.toInt() ?? Attributes.seed[a],
  });
}

/// How completing a quest of each category grows attributes (spec: quest
/// category drives attribute gains).
Map<Attribute, int> attributeDeltasFor(
  QuestCategory category,
) => switch (category) {
  QuestCategory.health => {Attribute.health: 2},
  QuestCategory.learning => {Attribute.intellect: 2},
  QuestCategory.productivity => {Attribute.focus: 2, Attribute.discipline: 1},
  QuestCategory.social => {Attribute.social: 2},
  QuestCategory.finance => {Attribute.discipline: 2},
  QuestCategory.mindfulness => {Attribute.discipline: 1, Attribute.focus: 1},
};
