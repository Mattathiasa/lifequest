import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progression/domain/xp_rules.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => PrefsSettingsRepository(),
);

/// Loads and persists [AppSettings]. The app gates onboarding on this.
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.read(settingsRepositoryProvider).load();

  AppSettings get _current => state.valueOrNull ?? const AppSettings();

  Future<void> _update(AppSettings next) async {
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }

  /// Finish onboarding with the chosen difficulty and name.
  Future<void> completeOnboarding({
    required DifficultyMode difficulty,
    required String name,
  }) async {
    final trimmed = name.trim();
    await _update(
      _current.copyWith(
        onboarded: true,
        difficultyMode: difficulty,
        displayName: trimmed.isEmpty ? 'Adventurer' : trimmed,
      ),
    );
  }

  Future<void> setDifficulty(DifficultyMode mode) =>
      _update(_current.copyWith(difficultyMode: mode));

  Future<void> setDisplayName(String name) {
    final trimmed = name.trim();
    return _update(
      _current.copyWith(displayName: trimmed.isEmpty ? 'Adventurer' : trimmed),
    );
  }

  /// Send the user back through onboarding (keeps difficulty/name as defaults).
  Future<void> replayOnboarding() =>
      _update(_current.copyWith(onboarded: false));

  /// Toggle notifications on/off.
  Future<void> toggleNotifications(bool enabled) async {
    await _update(_current.copyWith(notificationsEnabled: enabled));
  }

  /// Set the reminder time.
  Future<void> setReminderTime(int hour, int minute) async {
    await _update(_current.copyWith(reminderHour: hour, reminderMinute: minute));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// The chosen difficulty mode — drives XP rewards everywhere. Defaults to
/// balanced while settings are still loading.
final difficultyModeProvider = Provider<DifficultyMode>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.difficultyMode ??
      DifficultyMode.balanced;
});

/// The player's display name (defaults while loading).
final displayNameProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.displayName ?? 'Adventurer';
});

/// The player's avatar initials.
final initialsProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).valueOrNull?.initials ?? 'A';
});
