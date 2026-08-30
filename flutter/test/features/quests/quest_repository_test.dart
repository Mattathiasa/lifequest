import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/progression/domain/xp_rules.dart';
import 'package:lifequest/features/quests/data/in_memory_quest_repository.dart';
import 'package:lifequest/features/quests/domain/quest.dart';

void main() {
  group('InMemoryQuestRepository', () {
    late InMemoryQuestRepository repository;

    setUp(() {
      repository = InMemoryQuestRepository();
    });

    test('getAll returns seeded quests', () async {
      final quests = await repository.getAll();

      expect(quests, isNotEmpty);
      expect(quests.length, 11);
    });

    test('getAll returns unmodifiable list', () async {
      final quests = await repository.getAll();

      expect(
        () => quests.add(const Quest(
          id: 99,
          code: 'TST',
          name: 'Test',
          desc: 'Test quest',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.easy,
          time: '10 min',
          due: 'Today',
          schedule: QuestSchedule.today,
        )),
        throwsUnsupportedError,
      );
    });

    test('complete marks quest as done', () async {
      await repository.complete(1);
      final quests = await repository.getAll();

      final quest = quests.firstWhere((q) => q.id == 1);
      expect(quest.done, true);
    });

    test('complete does nothing for non-existent quest', () async {
      await repository.complete(999);
      final quests = await repository.getAll();

      // All quests should remain unchanged
      expect(quests.where((q) => q.done).length, 2);
    });

    test('add inserts quest at beginning', () async {
      final newQuest = Quest(
        id: 100,
        code: 'NEW',
        name: 'New Quest',
        desc: 'A new quest',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.easy,
        time: '10 min',
        due: 'Today',
        schedule: QuestSchedule.today,
      );

      await repository.add(newQuest);
      final quests = await repository.getAll();

      expect(quests.first.id, 100);
      expect(quests.length, 12);
    });

    test('update modifies existing quest', () async {
      final quests = await repository.getAll();
      final original = quests.first;

      final updated = original.copyWith(name: 'Updated Name');
      await repository.update(updated);

      final newQuests = await repository.getAll();
      final found = newQuests.firstWhere((q) => q.id == original.id);

      expect(found.name, 'Updated Name');
    });

    test('delete removes quest', () async {
      await repository.delete(1);
      final quests = await repository.getAll();

      expect(quests.where((q) => q.id == 1), isEmpty);
      expect(quests.length, 10);
    });

    test('delete does nothing for non-existent quest', () async {
      await repository.delete(999);
      final quests = await repository.getAll();

      expect(quests.length, 11);
    });

    test('quests have correct initial done state', () async {
      final quests = await repository.getAll();

      // First two quests are done in seed data
      expect(quests.where((q) => q.done).length, 2);
      expect(quests.firstWhere((q) => q.id == 1).done, true);
      expect(quests.firstWhere((q) => q.id == 2).done, true);
    });

    test('quest categories are correctly assigned', () async {
      final quests = await repository.getAll();

      final healthQuests = quests.where(
        (q) => q.category == QuestCategory.health,
      );
      expect(healthQuests.length, greaterThan(0));
    });

    test('quest difficulties are correctly assigned', () async {
      final quests = await repository.getAll();

      final easyQuests = quests.where(
        (q) => q.difficulty == QuestDifficulty.easy,
      );
      final mediumQuests = quests.where(
        (q) => q.difficulty == QuestDifficulty.medium,
      );
      final hardQuests = quests.where(
        (q) => q.difficulty == QuestDifficulty.hard,
      );
      final epicQuests = quests.where(
        (q) => q.difficulty == QuestDifficulty.epic,
      );

      expect(easyQuests.length, greaterThan(0));
      expect(mediumQuests.length, greaterThan(0));
      expect(hardQuests.length, greaterThan(0));
      expect(epicQuests.length, greaterThan(0));
    });
  });

  group('Quest', () {
    test('copyWith preserves unchanged fields', () {
      const original = Quest(
        id: 1,
        code: 'TST',
        name: 'Test Quest',
        desc: 'Description',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.medium,
        time: '30 min',
        due: 'Today',
        schedule: QuestSchedule.today,
        done: false,
      );

      final updated = original.copyWith(done: true);

      expect(updated.id, 1);
      expect(updated.code, 'TST');
      expect(updated.name, 'Test Quest');
      expect(updated.done, true);
    });

    test('toJson and fromJson roundtrip', () {
      const original = Quest(
        id: 1,
        code: 'TST',
        name: 'Test Quest',
        desc: 'Description',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.medium,
        time: '30 min',
        due: 'Today',
        schedule: QuestSchedule.today,
        done: false,
      );

      final json = original.toJson();
      final restored = Quest.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.code, original.code);
      expect(restored.name, original.name);
      expect(restored.category, original.category);
      expect(restored.difficulty, original.difficulty);
    });

    test('fromJson handles unknown category gracefully', () {
      final json = {
        'id': 1,
        'code': 'TST',
        'name': 'Test',
        'desc': 'Desc',
        'category': 'unknown',
        'difficulty': 'medium',
        'time': '10 min',
        'due': 'Today',
        'schedule': 'today',
      };

      final quest = Quest.fromJson(json);
      expect(quest.category, QuestCategory.productivity);
    });

    test('fromJson handles unknown difficulty gracefully', () {
      final json = {
        'id': 1,
        'code': 'TST',
        'name': 'Test',
        'desc': 'Desc',
        'category': 'health',
        'difficulty': 'unknown',
        'time': '10 min',
        'due': 'Today',
        'schedule': 'today',
      };

      final quest = Quest.fromJson(json);
      expect(quest.difficulty, QuestDifficulty.medium);
    });

    test('QuestCategory labels are correct', () {
      expect(QuestCategory.health.label, 'Health');
      expect(QuestCategory.learning.label, 'Learning');
      expect(QuestCategory.productivity.label, 'Productivity');
      expect(QuestCategory.social.label, 'Social');
      expect(QuestCategory.finance.label, 'Finance');
      expect(QuestCategory.mindfulness.label, 'Mindfulness');
    });

    test('QuestSchedule enum values exist', () {
      expect(QuestSchedule.values.length, 3);
      expect(QuestSchedule.today.name, 'today');
      expect(QuestSchedule.upcoming.name, 'upcoming');
      expect(QuestSchedule.recurring.name, 'recurring');
    });
  });
}
