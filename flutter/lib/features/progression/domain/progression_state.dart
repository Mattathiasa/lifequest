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
    this.streakFreezes = 1,
    this.lastStreakFreezeUsed,
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

  /// Number of streak freezes available (protects streak if you miss a day).
  final int streakFreezes;

  /// The last time a streak freeze was used (to prevent double-use).
  final DateTime? lastStreakFreezeUsed;

  /// Whether a streak freeze can be used today.
  bool get canUseStreakFreeze {
    if (streakFreezes <= 0) return false;
    if (lastStreakFreezeUsed == null) return true;
    final now = DateTime.now();
    final lastUsed = lastStreakFreezeUsed!;
    return !(lastUsed.year == now.year && lastUsed.month == now.month && lastUsed.day == now.day);
  }

  ProgressionState copyWith({
    int? level,
    int? xpIntoLevel,
    int? lifetimeXp,
    int? streak,
    int? recordStreak,
    DateTime? lastClearedDay,
    bool? firstLevelUp,
    int? streakFreezes,
    DateTime? lastStreakFreezeUsed,
  }) {
    return ProgressionState(
      level: level ?? this.level,
      xpIntoLevel: xpIntoLevel ?? this.xpIntoLevel,
      lifetimeXp: lifetimeXp ?? this.lifetimeXp,
      streak: streak ?? this.streak,
      recordStreak: recordStreak ?? this.recordStreak,
      lastClearedDay: lastClearedDay ?? this.lastClearedDay,
      firstLevelUp: firstLevelUp ?? this.firstLevelUp,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      lastStreakFreezeUsed: lastStreakFreezeUsed ?? this.lastStreakFreezeUsed,
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
    'streakFreezes': streakFreezes,
    'lastStreakFreezeUsed': lastStreakFreezeUsed?.toIso8601String(),
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
        streakFreezes: (json['streakFreezes'] as num?)?.toInt() ?? 1,
        lastStreakFreezeUsed: json['lastStreakFreezeUsed'] == null
            ? null
            : DateTime.tryParse(json['lastStreakFreezeUsed'] as String),
      );
}
