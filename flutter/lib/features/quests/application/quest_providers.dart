import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sync/application/sync_controller.dart';
import '../../sync/domain/sync_models.dart';
import '../data/prefs_quest_repository.dart';
import '../data/synced_quest_repository.dart';
import '../domain/quest.dart';
import '../domain/quest_repository.dart';

/// The quest repository — local-first with cloud sync; the cloud gateway
/// lives behind the same interface.
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  final local = PrefsQuestRepository();
  final sync = ref.watch(syncProvider.notifier);
  final repo = SyncedQuestRepository(local: local, sync: sync);
  // Register for pull-on-connect: apply the remote store, then reload the
  // notifier state so open screens reflect the merge immediately.
  sync.registerStore(questsStoreKey, (data) async {
    await repo.applyRemote(data);
    await ref.read(questListProvider.notifier).load();
  });
  return repo;
});

/// State holder for the list of quests with loading and error states.
class QuestListNotifier extends Notifier<List<Quest>> {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  List<Quest> build() => [];

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    // Trigger rebuild to show loading state
    state = List.from(state);

    try {
      final repo = ref.read(questRepositoryProvider);
      state = await repo.getAll();
    } catch (e) {
      _error = 'Failed to load quests. Pull to refresh.';
    } finally {
      _isLoading = false;
      // Trigger rebuild to hide loading state
      state = List.from(state);
    }
  }

  /// Reload from the repository (used after a cloud pull replaces the store).
  Future<void> reload() => load();

  Future<void> complete(int questId) async {
    final repo = ref.read(questRepositoryProvider);
    await repo.complete(questId);
    state = [
      for (final q in state) q.id == questId ? q.copyWith(done: true) : q,
    ];
  }

  Future<void> add(Quest quest) async {
    final repo = ref.read(questRepositoryProvider);
    await repo.add(quest);
    state = [quest, ...state];
  }

  Future<void> delete(int questId) async {
    final repo = ref.read(questRepositoryProvider);
    await repo.delete(questId);
    state = [
      for (final q in state)
        if (q.id != questId) q,
    ];
  }

  Future<void> update(Quest quest) async {
    final repo = ref.read(questRepositoryProvider);
    await repo.update(quest);
    state = [
      for (final q in state)
        if (q.id == quest.id) quest else q,
    ];
  }
}

final questListProvider = NotifierProvider<QuestListNotifier, List<Quest>>(
  QuestListNotifier.new,
);
