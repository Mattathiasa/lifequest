import 'quest.dart';

/// Abstract interface for quest data.
///
/// Cloud sync implements this around a local store; presentation never
/// touches a data source directly.
abstract class QuestRepository {
  /// All quests.
  Future<List<Quest>> getAll();

  /// Mark a quest as done.
  Future<void> complete(int questId);

  /// Add a new quest.
  Future<void> add(Quest quest);

  /// Update an existing quest.
  Future<void> update(Quest quest);

  /// Delete a quest by id.
  Future<void> delete(int questId);

  /// JSON snapshot of every quest — the cloud-sync payload.
  Future<List<Map<String, dynamic>>> exportJson();

  /// Replace the whole store from a cloud-sync payload.
  Future<void> replaceAllJson(List<Map<String, dynamic>> items);
}
