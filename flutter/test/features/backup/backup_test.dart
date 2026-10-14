import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lifequest/features/backup/domain/backup_data.dart';
import 'package:lifequest/features/progression/domain/attributes.dart';
import 'package:lifequest/features/progression/domain/completion_event.dart';
import 'package:lifequest/features/progression/domain/progression_state.dart';
import 'package:lifequest/features/progression/domain/xp_rules.dart';
import 'package:lifequest/features/quests/domain/quest.dart';
import 'package:lifequest/features/settings/domain/app_settings.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BackupData serialization', () {
    test('round-trips full backup payload', () {
      final now = DateTime(2026, 10, 14, 20, 0);
      final backup = BackupData(
        version: 1,
        exportedAt: now,
        progression: const ProgressionState(
          level: 15,
          xpIntoLevel: 1200,
          lifetimeXp: 45000,
          streak: 20,
          recordStreak: 25,
          streakFreezes: 3,
        ),
        attributes: const Attributes({
          Attribute.strength: 80,
          Attribute.intellect: 85,
          Attribute.discipline: 90,
          Attribute.health: 75,
          Attribute.creativity: 60,
          Attribute.social: 50,
          Attribute.focus: 88,
        }),
        history: [
          CompletionEvent(
            questId: 1,
            category: QuestCategory.health,
            xp: 150,
            at: now.subtract(const Duration(hours: 2)),
          ),
        ],
        quests: const [
          Quest(
            id: 1,
            code: 'RUN',
            name: 'Morning Run',
            desc: 'Run 5km',
            category: QuestCategory.health,
            difficulty: QuestDifficulty.medium,
            time: '30m',
            due: 'Today',
            schedule: QuestSchedule.today,
            done: true,
          ),
        ],
        settings: const AppSettings(
          displayName: 'Test Champion',
          difficultyMode: DifficultyMode.hardcore,
          hapticsEnabled: false,
          soundEnabled: true,
        ),
      );

      final jsonString = backup.toFormattedJson();
      final restored = BackupData.fromJsonString(jsonString);

      expect(restored.version, 1);
      expect(restored.progression.level, 15);
      expect(restored.progression.streak, 20);
      expect(restored.attributes[Attribute.intellect], 85);
      expect(restored.history.length, 1);
      expect(restored.history.first.xp, 150);
      expect(restored.quests.length, 1);
      expect(restored.quests.first.code, 'RUN');
      expect(restored.settings.displayName, 'Test Champion');
      expect(restored.settings.difficultyMode, DifficultyMode.hardcore);
      expect(restored.settings.hapticsEnabled, isFalse);
    });

    test('throws on malformed JSON string', () {
      expect(
        () => BackupData.fromJsonString('not json at all'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when root is not a JSON object', () {
      expect(
        () => BackupData.fromJsonString('[1, 2, 3]'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
