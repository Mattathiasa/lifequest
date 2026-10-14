import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/progression/domain/xp_rules.dart';
import 'package:lifequest/features/quests/domain/quest.dart';
import 'package:lifequest/features/quests/domain/quest_template.dart';

void main() {
  group('QuestTemplate', () {
    const template = QuestTemplate(
      id: 'test_tpl',
      name: 'Morning Stretch',
      desc: 'Full-body stretch to wake up muscles.',
      category: QuestCategory.health,
      difficulty: QuestDifficulty.easy,
      time: '10 min',
      due: 'Today',
      schedule: QuestSchedule.recurring,
      code: 'FLX',
    );

    test('toQuest uses the supplied id', () {
      final quest = template.toQuest(42);
      expect(quest.id, 42);
    });

    test('toQuest copies all fields correctly', () {
      final quest = template.toQuest(1);
      expect(quest.name, template.name);
      expect(quest.desc, template.desc);
      expect(quest.code, template.code);
      expect(quest.category, template.category);
      expect(quest.difficulty, template.difficulty);
      expect(quest.time, template.time);
      expect(quest.due, template.due);
      expect(quest.schedule, template.schedule);
    });

    test('toQuest produces done: false by default', () {
      final quest = template.toQuest(1);
      expect(quest.done, false);
    });
  });

  group('QuestPack', () {
    test('Morning Launch has 3 templates', () {
      expect(QuestPacks.morningLaunch.templates.length, 3);
    });

    test('Deep Work Sprint has 3 templates', () {
      expect(QuestPacks.deepWorkSprint.templates.length, 3);
    });

    test('Physical Vitality has 3 templates', () {
      expect(QuestPacks.physicalVitality.templates.length, 3);
    });

    test('Mindful Reset has 3 templates', () {
      expect(QuestPacks.mindfulReset.templates.length, 3);
    });

    test('Financial Hygiene has 3 templates', () {
      expect(QuestPacks.financialHygiene.templates.length, 3);
    });

    test('all packs list has 5 entries', () {
      expect(QuestPacks.all.length, 5);
    });

    test('totalXp is the sum of all template XP rewards', () {
      final pack = QuestPacks.morningLaunch;
      final expectedXp = pack.templates.fold<int>(
        0,
        (sum, t) => sum + t.toQuest(0).xp,
      );
      expect(pack.totalXp, expectedXp);
    });

    test('every pack has a unique id', () {
      final ids = QuestPacks.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every template within a pack has a unique id', () {
      for (final pack in QuestPacks.all) {
        final templateIds = pack.templates.map((t) => t.id).toList();
        expect(
          templateIds.toSet().length,
          templateIds.length,
          reason: 'Pack "${pack.name}" has duplicate template ids',
        );
      }
    });

    test('no template has an empty code', () {
      for (final pack in QuestPacks.all) {
        for (final template in pack.templates) {
          expect(
            template.code.isNotEmpty,
            true,
            reason: '"${template.name}" has an empty code',
          );
        }
      }
    });

    test('each pack has a non-empty name, description, and emoji', () {
      for (final pack in QuestPacks.all) {
        expect(pack.name.isNotEmpty, true);
        expect(pack.description.isNotEmpty, true);
        expect(pack.emoji.isNotEmpty, true);
      }
    });
  });

  group('QuestPacks global template id uniqueness', () {
    test('all template ids across all packs are unique', () {
      final allIds = QuestPacks.all
          .expand((p) => p.templates)
          .map((t) => t.id)
          .toList();
      expect(allIds.toSet().length, allIds.length);
    });
  });
}
