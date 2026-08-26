/// Progression rules, exactly as the approved prototype behaves.
///
/// Kept free of Flutter imports so it can be unit-tested directly.
library;

enum QuestDifficulty { easy, medium, hard, epic }

extension QuestDifficultyX on QuestDifficulty {
  /// Base reward before the difficulty-mode multiplier.
  int get baseXp => switch (this) {
    QuestDifficulty.easy => 50,
    QuestDifficulty.medium => 150,
    QuestDifficulty.hard => 280,
    QuestDifficulty.epic => 500,
  };

  /// Numeral shown on quest cards.
  String get numeral => switch (this) {
    QuestDifficulty.easy => 'I',
    QuestDifficulty.medium => 'II',
    QuestDifficulty.hard => 'III',
    QuestDifficulty.epic => 'IV',
  };

  String get label => switch (this) {
    QuestDifficulty.easy => 'Easy',
    QuestDifficulty.medium => 'Medium',
    QuestDifficulty.hard => 'Hard',
    QuestDifficulty.epic => 'Epic',
  };
}

/// Chosen during onboarding, changeable in settings.
enum DifficultyMode { casual, balanced, hardcore }

extension DifficultyModeX on DifficultyMode {
  double get multiplier => switch (this) {
    DifficultyMode.casual => 1.5,
    DifficultyMode.balanced => 1.0,
    DifficultyMode.hardcore => 0.7,
  };
}

/// Result of awarding XP: the new position plus how many levels were crossed.
class ProgressionResult {
  const ProgressionResult({
    required this.level,
    required this.xpIntoLevel,
    required this.lifetimeXp,
    required this.levelsGained,
    required this.previousLevel,
  });

  final int level;
  final int xpIntoLevel;
  final int lifetimeXp;
  final int levelsGained;
  final int previousLevel;

  bool get leveledUp => levelsGained > 0;
}

abstract final class XpRules {
  /// Bonus for clearing every quest scheduled for the day.
  static const dayClearBonus = 250;

  /// XP required to advance *from* [level] to the next one.
  /// Level 12 → 13 costs 3,000 XP.
  static int need(int level) => 250 * level;

  /// Reward for a quest, rounded to the nearest 10 so numbers stay readable.
  static int reward(QuestDifficulty difficulty, DifficultyMode mode) {
    final raw = difficulty.baseXp * mode.multiplier;
    return (raw / 10).round() * 10;
  }

  /// Fraction of the current level completed, 0..1 — drives the 20-tick XP bar.
  static double levelProgress(int level, int xpIntoLevel) =>
      (xpIntoLevel / need(level)).clamp(0, 1);

  /// Filled segments for a tick bar of [segments] steps.
  static int filledTicks(int level, int xpIntoLevel, {int segments = 20}) =>
      (levelProgress(level, xpIntoLevel) * segments).round();

  /// A single award can cross more than one level; the remainder carries over.
  static ProgressionResult award({
    required int level,
    required int xpIntoLevel,
    required int lifetimeXp,
    required int amount,
  }) {
    assert(amount >= 0, 'XP awards are never negative');
    var nextLevel = level;
    var xp = xpIntoLevel + amount;
    while (xp >= need(nextLevel)) {
      xp -= need(nextLevel);
      nextLevel++;
    }
    return ProgressionResult(
      level: nextLevel,
      xpIntoLevel: xp,
      lifetimeXp: lifetimeXp + amount,
      levelsGained: nextLevel - level,
      previousLevel: level,
    );
  }
}
