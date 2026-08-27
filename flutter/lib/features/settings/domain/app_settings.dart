import '../../progression/domain/xp_rules.dart';

/// Persisted user settings — set during onboarding, editable in Profile.
class AppSettings {
  const AppSettings({
    this.onboarded = false,
    this.difficultyMode = DifficultyMode.balanced,
    this.displayName = 'Adventurer',
  });

  final bool onboarded;
  final DifficultyMode difficultyMode;
  final String displayName;

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

  AppSettings copyWith({
    bool? onboarded,
    DifficultyMode? difficultyMode,
    String? displayName,
  }) {
    return AppSettings(
      onboarded: onboarded ?? this.onboarded,
      difficultyMode: difficultyMode ?? this.difficultyMode,
      displayName: displayName ?? this.displayName,
    );
  }
}
