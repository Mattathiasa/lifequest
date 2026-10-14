import 'package:flutter/material.dart';

import '../../progression/domain/xp_rules.dart';
import '../../quests/domain/quest.dart';

/// Theme mode options.
enum AppThemeMode {
  dark,
  light,
  system;

  String get label => switch (this) {
    AppThemeMode.dark => 'Dark',
    AppThemeMode.light => 'Light',
    AppThemeMode.system => 'System',
  };

  ThemeMode get themeMode => switch (this) {
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.system => ThemeMode.system,
  };
}

/// Persisted user settings — set during onboarding, editable in Profile.
class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.difficultyMode = DifficultyMode.balanced,
    this.displayName = 'Adventurer',
    this.notificationsEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
    this.themeMode = AppThemeMode.dark,
    this.focusGoals = const [],
    this.hapticsEnabled = true,
    this.soundEnabled = true,
  });

  final bool onboarded;
  final DifficultyMode difficultyMode;
  final String displayName;
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;
  final AppThemeMode themeMode;
  final List<QuestCategory> focusGoals;
  final bool hapticsEnabled;
  final bool soundEnabled;

  /// One- or two-letter avatar initials derived from [displayName].
  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Formatted reminder time string.
  String get reminderTimeString {
    final hour = reminderHour.toString().padLeft(2, '0');
    final minute = reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  AppSettings copyWith({
    bool? onboarded,
    DifficultyMode? difficultyMode,
    String? displayName,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
    AppThemeMode? themeMode,
    List<QuestCategory>? focusGoals,
    bool? hapticsEnabled,
    bool? soundEnabled,
  }) {
    return AppSettings(
      onboarded: onboarded ?? this.onboarded,
      difficultyMode: difficultyMode ?? this.difficultyMode,
      displayName: displayName ?? this.displayName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      themeMode: themeMode ?? this.themeMode,
      focusGoals: focusGoals ?? this.focusGoals,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'onboarded': onboarded,
    'difficultyMode': difficultyMode.name,
    'displayName': displayName,
    'notificationsEnabled': notificationsEnabled,
    'reminderHour': reminderHour,
    'reminderMinute': reminderMinute,
    'themeMode': themeMode.name,
    'focusGoals': focusGoals.map((g) => g.name).toList(),
    'hapticsEnabled': hapticsEnabled,
    'soundEnabled': soundEnabled,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final modeName = json['difficultyMode'] as String?;
    final themeName = json['themeMode'] as String?;
    final goalsRaw = json['focusGoals'] as List?;

    return AppSettings(
      onboarded: json['onboarded'] as bool? ?? false,
      difficultyMode: DifficultyMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => DifficultyMode.balanced,
      ),
      displayName: json['displayName'] as String? ?? 'Adventurer',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 20,
      reminderMinute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
      themeMode: AppThemeMode.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => AppThemeMode.dark,
      ),
      focusGoals: goalsRaw != null
          ? goalsRaw
                .map(
                  (g) => QuestCategory.values.firstWhere(
                    (c) => c.name == g,
                    orElse: () => QuestCategory.productivity,
                  ),
                )
                .toList()
          : const [],
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
    );
  }
}
