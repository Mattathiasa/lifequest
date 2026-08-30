import '../../progression/domain/xp_rules.dart';

/// Persisted user settings — set during onboarding, editable in Profile.
class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.difficultyMode = DifficultyMode.balanced,
    this.displayName = 'Adventurer',
    this.notificationsEnabled = false,
    this.reminderHour = 20,
    this.reminderMinute = 0,
  });

  final bool onboarded;
  final DifficultyMode difficultyMode;
  final String displayName;
  final bool notificationsEnabled;
  final int reminderHour;
  final int reminderMinute;

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
  }) {
    return AppSettings(
      onboarded: onboarded ?? this.onboarded,
      difficultyMode: difficultyMode ?? this.difficultyMode,
      displayName: displayName ?? this.displayName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}
