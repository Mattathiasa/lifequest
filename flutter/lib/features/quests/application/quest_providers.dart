import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_quest_repository.dart';
import '../domain/quest.dart';
import '../domain/quest_repository.dart';

/// The quest repository — in-memory for now, Firebase later.
final questRepositoryProvider = Provider<QuestRepository>(
  (_) => InMemoryQuestRepository(),
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
}

final questListProvider = NotifierProvider<QuestListNotifier, List<Quest>>(
  QuestListNotifier.new,
);
