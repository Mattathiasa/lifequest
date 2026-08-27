import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifequest/features/progression/domain/xp_rules.dart';
import 'package:lifequest/features/settings/data/settings_repository.dart';
import 'package:lifequest/features/settings/domain/app_settings.dart';

void main() {
  group('PrefsSettingsRepository', () {
    test('defaults when nothing is stored', () async {
      SharedPreferences.setMockInitialValues({});
      final loaded = await PrefsSettingsRepository().load();
      expect(loaded.onboarded, isFalse);
      expect(loaded.difficultyMode, DifficultyMode.balanced);
      expect(loaded.displayName, 'Adventurer');
    });

    test('round-trips onboarded, difficulty and name', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = PrefsSettingsRepository();
      await repo.save(
        const AppSettings(
          onboarded: true,
          difficultyMode: DifficultyMode.hardcore,
          displayName: 'Ada Lovelace',
        ),
      );
      final again = await repo.load();
      expect(again.onboarded, isTrue);
      expect(again.difficultyMode, DifficultyMode.hardcore);
      expect(again.displayName, 'Ada Lovelace');
    });
  });

  group('AppSettings.initials', () {
    test('single name uses first two letters', () {
      expect(const AppSettings(displayName: 'Matt').initials, 'MA');
    });
    test('two names use both initials', () {
      expect(const AppSettings(displayName: 'Ada Lovelace').initials, 'AL');
    });
    test('blank name falls back to A', () {
      expect(const AppSettings(displayName: '   ').initials, 'A');
    });
  });

  group('difficulty mode scales rewards', () {
    test('casual > balanced > hardcore for the same quest', () {
      final casual = XpRules.reward(
        QuestDifficulty.hard,
        DifficultyMode.casual,
      );
      final balanced = XpRules.reward(
        QuestDifficulty.hard,
        DifficultyMode.balanced,
      );
      final hardcore = XpRules.reward(
        QuestDifficulty.hard,
        DifficultyMode.hardcore,
      );
      expect(casual, greaterThan(balanced));
      expect(balanced, greaterThan(hardcore));
    });
  });
}
