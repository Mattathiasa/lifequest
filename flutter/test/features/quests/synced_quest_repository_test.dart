import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/quests/data/prefs_quest_repository.dart';
import 'package:lifequest/features/quests/data/synced_quest_repository.dart';
import 'package:lifequest/features/quests/domain/quest.dart';
import 'package:lifequest/features/progression/domain/xp_rules.dart';
import 'package:lifequest/features/sync/application/sync_controller.dart';
import 'package:lifequest/features/sync/data/fake_cloud_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

Quest quest(int id, {bool done = false}) => Quest(
  id: id,
  code: 'TST',
  name: 'Test quest $id',
  desc: 'desc',
  category: QuestCategory.health,
  difficulty: QuestDifficulty.easy,
  time: '10 min',
  due: 'Today',
  schedule: QuestSchedule.today,
  done: done,
);

Future<(FakeCloudGateway, SyncedQuestRepository, SyncController)>
makeHarness() async {
  final gateway = FakeCloudGateway();
  final container = ProviderContainer(
    overrides: [cloudGatewayProvider.overrideWithValue(gateway)],
  );
  addTearDown(container.dispose);
  final sync = container.read(syncProvider.notifier);
  final repo = SyncedQuestRepository(local: PrefsQuestRepository(), sync: sync);
  await sync.connect();
  return (gateway, repo, sync);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('local writes mirror to the gateway', () async {
    final (gateway, repo, sync) = await makeHarness();
    await repo.add(quest(42));
    // The fire-and-forget flush resolves on the next microtasks.
    await Future<void>.delayed(Duration.zero);
    await sync.flushQueued();

    expect(gateway.docs['quests'], isNotNull);
    final items = gateway.docs['quests']!.data['items'] as List;
    expect(items.any((e) => (e as Map)['id'] == 42), isTrue);
  });

  test('older remote snapshot does not clobber newer local writes', () async {
    final (_, repo, _) = await makeHarness();
    // Local write now (updatedAt = now).
    await repo.add(quest(1));

    // A remote snapshot stamped an hour ago must be ignored.
    final hourAgo = DateTime.now()
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    await repo.applyRemote({
      'updatedAt': hourAgo,
      'items': <Map<String, dynamic>>[],
    });

    final quests = await PrefsQuestRepository().getAll();
    expect(quests.any((q) => q.id == 1), isTrue);
  });

  test('newer remote snapshot replaces the local store', () async {
    final (_, repo, _) = await makeHarness();
    // Seed the local store first (writes an updatedAt).
    await repo.add(quest(1));

    // Remote snapshot stamped in the future must win.
    final soon = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
    await repo.applyRemote({
      'updatedAt': soon,
      'items': [quest(99).toJson()],
    });

    final quests = await PrefsQuestRepository().getAll();
    expect(quests.any((q) => q.id == 99), isTrue);
    expect(quests.any((q) => q.id == 1), isFalse);
  });
}
