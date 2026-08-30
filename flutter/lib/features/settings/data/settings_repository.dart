import 'package:shared_preferences/shared_preferences.dart';

import '../../progression/domain/xp_rules.dart';
import '../domain/app_settings.dart';

/// Persistence boundary for [AppSettings]. Firebase can implement this later
/// without touching presentation.
abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

/// [SharedPreferences]-backed implementation.
class PrefsSettingsRepository implements SettingsRepository {
  static const _kOnboarded = 'onboarded';
  static const _kDifficulty = 'difficultyMode';
  static const _kName = 'displayName';
  static const _kNotificationsEnabled = 'notificationsEnabled';
  static const _kReminderHour = 'reminderHour';
  static const _kReminderMinute = 'reminderMinute';
  static const _kThemeMode = 'themeMode';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName =
        prefs.getString(_kDifficulty) ?? DifficultyMode.balanced.name;
    final themeModeName = prefs.getString(_kThemeMode) ?? AppThemeMode.dark.name;
    return AppSettings(
      onboarded: prefs.getBool(_kOnboarded) ?? false,
      difficultyMode: DifficultyMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => DifficultyMode.balanced,
      ),
      displayName: prefs.getString(_kName) ?? 'Adventurer',
      notificationsEnabled: prefs.getBool(_kNotificationsEnabled) ?? false,
      reminderHour: prefs.getInt(_kReminderHour) ?? 20,
      reminderMinute: prefs.getInt(_kReminderMinute) ?? 0,
      themeMode: AppThemeMode.values.firstWhere(
        (m) => m.name == themeModeName,
        orElse: () => AppThemeMode.dark,
      ),
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, settings.onboarded);
    await prefs.setString(_kDifficulty, settings.difficultyMode.name);
    await prefs.setString(_kName, settings.displayName);
    await prefs.setBool(_kNotificationsEnabled, settings.notificationsEnabled);
    await prefs.setInt(_kReminderHour, settings.reminderHour);
    await prefs.setInt(_kReminderMinute, settings.reminderMinute);
    await prefs.setString(_kThemeMode, settings.themeMode.name);
  }
}
