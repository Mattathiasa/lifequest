/// Immutable snapshot of the player's progression.
class ProgressionState {
  const ProgressionState({
    this.level = 12,
    this.xpIntoLevel = 2450,
    this.lifetimeXp = 34120,
    this.streak = 14,
    this.recordStreak = 31,
    this.lastClearedDay,
    this.firstLevelUp = true,
  });

  final int level;
  final int xpIntoLevel;
  final int lifetimeXp;
  final int streak;

  /// Best streak ever reached — drives Progress "RECORD".
  final int recordStreak;

  /// The calendar day the trail was last fully cleared (for streak continuity
  /// and to make the day-clear bonus idempotent per day).
  final DateTime? lastClearedDay;

  /// Whether the player has ever levelled up (First Level Up achievement).
  final bool firstLevelUp;

  ProgressionState copyWith({
    int? level,
    int? xpIntoLevel,
    int? lifetimeXp,
    int? streak,
    int? recordStreak,
    DateTime? lastClearedDay,
    bool? firstLevelUp,
  }) {
    return ProgressionState(
      level: level ?? this.level,
      xpIntoLevel: xpIntoLevel ?? this.xpIntoLevel,
      lifetimeXp: lifetimeXp ?? this.lifetimeXp,
      streak: streak ?? this.streak,
      recordStreak: recordStreak ?? this.recordStreak,
      lastClearedDay: lastClearedDay ?? this.lastClearedDay,
      firstLevelUp: firstLevelUp ?? this.firstLevelUp,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'xpIntoLevel': xpIntoLevel,
    'lifetimeXp': lifetimeXp,
    'streak': streak,
    'recordStreak': recordStreak,
    'lastClearedDay': lastClearedDay?.toIso8601String(),
    'firstLevelUp': firstLevelUp,
  };

  factory ProgressionState.fromJson(Map<String, dynamic> json) =>
      ProgressionState(
        level: (json['level'] as num?)?.toInt() ?? 12,
        xpIntoLevel: (json['xpIntoLevel'] as num?)?.toInt() ?? 2450,
        lifetimeXp: (json['lifetimeXp'] as num?)?.toInt() ?? 34120,
        streak: (json['streak'] as num?)?.toInt() ?? 14,
        recordStreak: (json['recordStreak'] as num?)?.toInt() ?? 31,
        lastClearedDay: json['lastClearedDay'] == null
            ? null
            : DateTime.tryParse(json['lastClearedDay'] as String),
        firstLevelUp: json['firstLevelUp'] as bool? ?? true,
      );
}
