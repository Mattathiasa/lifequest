import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs_quest_repository.dart';
import '../domain/quest.dart';
import '../domain/quest_repository.dart';

/// The quest repository — locally persisted; Firebase later behind the same
/// interface.
final questRepositoryProvider = Provider<QuestRepository>(
  (_) => PrefsQuestRepository(),
);

/// State holder for the list of quests.
class QuestListNotifier extends Notifier<List<Quest>> {
  @override
  List<Quest> build() => [];

  Future<void> load() async {
    final repo = ref.read(questRepositoryProvider);
    state = await repo.getAll();
  }

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
    state = [for (final q in state) if (q.id != questId) q];
  }

  Future<void> update(Quest quest) async {
    final repo = ref.read(questRepositoryProvider);
    await repo.update(quest);
    state = [for (final q in state) if (q.id == quest.id) quest else q];
  }
}

final questListProvider = NotifierProvider<QuestListNotifier, List<Quest>>(
  QuestListNotifier.new,
);
