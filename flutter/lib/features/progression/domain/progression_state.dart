/// Immutable snapshot of the player's progression.
class ProgressionState {
  const ProgressionState({
    this.level = 12,
    this.xpIntoLevel = 2450,
    this.lifetimeXp = 34120,
    this.streak = 14,
  });

  final int level;
  final int xpIntoLevel;
  final int lifetimeXp;
  final int streak;

  ProgressionState copyWith({
    int? level,
    int? xpIntoLevel,
    int? lifetimeXp,
    int? streak,
  }) {
    return ProgressionState(
      level: level ?? this.level,
      xpIntoLevel: xpIntoLevel ?? this.xpIntoLevel,
      lifetimeXp: lifetimeXp ?? this.lifetimeXp,
      streak: streak ?? this.streak,
    );
  }
}
