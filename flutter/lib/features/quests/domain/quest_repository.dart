import 'quest.dart';

/// Abstract interface for quest data.
///
/// Firebase will implement this; presentation never touches a data source
/// directly.
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
}
