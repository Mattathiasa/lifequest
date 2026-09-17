import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quest.dart';
import '../domain/quest_repository.dart';
import '../../sync/application/sync_controller.dart';
import '../../sync/domain/sync_models.dart';

/// Wraps the local quest store with cloud sync: every local write is
/// mirrored to the cloud through [SyncController] (queued when offline), and
/// a remote snapshot can be applied over the local store.
class SyncedQuestRepository implements QuestRepository {
  SyncedQuestRepository({required this.local, required this.sync});

  final QuestRepository local;
  final SyncController sync;

  static const _kUpdatedAt = 'quests.updatedAt';

  @override
  Future<List<Quest>> getAll() => local.getAll();

  @override
  Future<void> complete(int questId) async {
    await local.complete(questId);
    await _push();
  }

  @override
  Future<void> add(Quest quest) async {
    await local.add(quest);
    await _push();
  }

  @override
  Future<void> update(Quest quest) async {
    await local.update(quest);
    await _push();
  }

  @override
  Future<void> delete(int questId) async {
    await local.delete(questId);
    await _push();
  }

  @override
  Future<List<Map<String, dynamic>>> exportJson() => local.exportJson();

  @override
  Future<void> replaceAllJson(List<Map<String, dynamic>> items) async {
    await local.replaceAllJson(items);
  }

  Future<void> _push() async {
    final updated = DateTime.now().toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUpdatedAt, updated);
    await sync.queuePush(questsStoreKey, {
      'items': await local.exportJson(),
      'updatedAt': updated,
    });
  }

  /// Called by the sync controller with the remote snapshot. Older snapshots
  /// never clobber newer local data (last-write-wins by [updatedAt]).
  Future<void> applyRemote(Map<String, dynamic> data) async {
    final remoteAt = DateTime.tryParse(data['updatedAt'] as String? ?? '');
    final prefs = await SharedPreferences.getInstance();
    final localAt = DateTime.tryParse(prefs.getString(_kUpdatedAt) ?? '');
    if (remoteAt != null && localAt != null && !remoteAt.isAfter(localAt)) {
      return;
    }
    final items = (data['items'] as List?) ?? const [];
    await replaceAllJson([
      for (final item in items) (item as Map).cast<String, dynamic>(),
    ]);
    if (remoteAt != null) {
      await prefs.setString(_kUpdatedAt, remoteAt.toIso8601String());
    }
  }
}
