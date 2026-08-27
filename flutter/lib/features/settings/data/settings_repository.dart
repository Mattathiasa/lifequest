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

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName =
        prefs.getString(_kDifficulty) ?? DifficultyMode.balanced.name;
    return AppSettings(
      onboarded: prefs.getBool(_kOnboarded) ?? false,
      difficultyMode: DifficultyMode.values.firstWhere(
        (m) => m.name == modeName,
        orElse: () => DifficultyMode.balanced,
      ),
      displayName: prefs.getString(_kName) ?? 'Adventurer',
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, settings.onboarded);
    await prefs.setString(_kDifficulty, settings.difficultyMode.name);
    await prefs.setString(_kName, settings.displayName);
  }
}
