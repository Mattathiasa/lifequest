import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progression/application/progression_controller.dart';
import '../../progression/data/progression_repository.dart';
import '../../quests/application/quest_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/backup_data.dart';

/// Service coordinating game data export and restoration across repositories.
abstract final class BackupService {
  /// Builds a complete [BackupData] snapshot from live state and storage.
  static Future<BackupData> createBackup(WidgetRef ref) async {
    final progFull = ref.read(progressionProvider);
    final quests = await ref.read(questRepositoryProvider).getAll();
    final settings =
        ref.read(settingsProvider).valueOrNull ??
        await ref.read(settingsRepositoryProvider).load();

    return BackupData(
      version: 1,
      exportedAt: DateTime.now(),
      progression: progFull.progression,
      attributes: progFull.attributes,
      history: progFull.history,
      quests: quests,
      settings: settings,
    );
  }

  /// Restores game state, quests, and settings from a validated [BackupData].
  static Future<void> restoreBackup(WidgetRef ref, BackupData backup) async {
    final gameSnapshot = GameSnapshot(
      progression: backup.progression,
      attributes: backup.attributes,
      history: backup.history,
    );

    // 1. Save and apply progression snapshot
    await ref.read(progressionRepositoryProvider).save(gameSnapshot);
    ref.read(progressionProvider.notifier).replaceSnapshot(gameSnapshot);

    // 2. Save and reload quests
    final questJsonList = backup.quests.map((q) => q.toJson()).toList();
    await ref.read(questRepositoryProvider).replaceAllJson(questJsonList);
    await ref.read(questListProvider.notifier).load();

    // 3. Save and reload settings
    await ref.read(settingsRepositoryProvider).save(backup.settings);
    ref.invalidate(settingsProvider);
  }
}
