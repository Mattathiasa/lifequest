import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/progression/domain/xp_rules.dart';

void main() {
  group('XpRules', () {
    group('need', () {
      test('level 1 requires 250 XP', () {
        expect(XpRules.need(1), 250);
      });

      test('level 12 requires 3000 XP', () {
        expect(XpRules.need(12), 3000);
      });

      test('level 25 requires 6250 XP', () {
        expect(XpRules.need(25), 6250);
      });
    });

    group('reward', () {
      test('easy balanced = 50', () {
        expect(
          XpRules.reward(QuestDifficulty.easy, DifficultyMode.balanced),
          50,
        );
      });

      test('medium balanced = 150', () {
        expect(
          XpRules.reward(QuestDifficulty.medium, DifficultyMode.balanced),
          150,
        );
      });

      test('hard balanced = 280', () {
        expect(
          XpRules.reward(QuestDifficulty.hard, DifficultyMode.balanced),
          280,
        );
      });

      test('epic balanced = 500', () {
        expect(
          XpRules.reward(QuestDifficulty.epic, DifficultyMode.balanced),
          500,
        );
      });

      test('easy casual (×1.5) rounds to 80', () {
        // 50 * 1.5 = 75, rounds to nearest 10 → 80
        expect(XpRules.reward(QuestDifficulty.easy, DifficultyMode.casual), 80);
      });

      test('hard casual (×1.5) rounds to 420', () {
        // 280 * 1.5 = 420, already multiple of 10
        expect(
          XpRules.reward(QuestDifficulty.hard, DifficultyMode.casual),
          420,
        );
      });

      test('epic hardcore (×0.7) rounds to 350', () {
        // 500 * 0.7 = 350, already multiple of 10
        expect(
          XpRules.reward(QuestDifficulty.epic, DifficultyMode.hardcore),
          350,
        );
      });

      test('medium hardcore (×0.7) rounds to 110', () {
        // 150 * 0.7 = 105, rounds to nearest 10 → 100
        expect(
          XpRules.reward(QuestDifficulty.medium, DifficultyMode.hardcore),
          110,
        );
      });
    });

    group('levelProgress', () {
      test('0 XP at level 12 = 0%', () {
        expect(XpRules.levelProgress(12, 0), 0.0);
      });

      test('1500 XP at level 12 (need 3000) = 50%', () {
        expect(XpRules.levelProgress(12, 1500), 0.5);
      });

      test('3000 XP at level 12 is clamped to 1.0', () {
        expect(XpRules.levelProgress(12, 3000), 1.0);
      });
    });

    group('filledTicks', () {
      test('0 XP = 0 filled ticks', () {
        expect(XpRules.filledTicks(12, 0, segments: 20), 0);
      });

      test('half XP = 10 filled ticks', () {
        expect(XpRules.filledTicks(12, 1500, segments: 20), 10);
      });

      test('full XP = 20 filled ticks', () {
        expect(XpRules.filledTicks(12, 3000, segments: 20), 20);
      });
    });

    group('award', () {
      test('awards XP within same level', () {
        final result = XpRules.award(
          level: 12,
          xpIntoLevel: 1000,
          lifetimeXp: 30000,
          amount: 500,
        );

        expect(result.level, 12);
        expect(result.xpIntoLevel, 1500);
        expect(result.lifetimeXp, 30500);
        expect(result.levelsGained, 0);
        expect(result.leveledUp, false);
      });

      test('awards XP that crosses exactly one level', () {
        // Level 12 needs 3000. Have 2800, award 200 → exactly 3000 → level 13, 0 XP
        final result = XpRules.award(
          level: 12,
          xpIntoLevel: 2800,
          lifetimeXp: 30000,
          amount: 200,
        );

        expect(result.level, 13);
        expect(result.xpIntoLevel, 0);
        expect(result.levelsGained, 1);
        expect(result.previousLevel, 12);
        expect(result.leveledUp, true);
      });

      test('awards XP that crosses one level with remainder', () {
        // Level 12 needs 3000. Have 2900, award 300 → crosses to 13, 200 XP into 13
        final result = XpRules.award(
          level: 12,
          xpIntoLevel: 2900,
          lifetimeXp: 30000,
          amount: 300,
        );

        expect(result.level, 13);
        expect(result.xpIntoLevel, 200);
        expect(result.levelsGained, 1);
        expect(result.leveledUp, true);
      });

      test('THE INTERESTING CASE: one award crosses multiple levels', () {
        // Level 12, 0 XP in. Award 10000.
        // Level 12→13 needs 3000. Remaining: 7000.
        // Level 13→14 needs 3250. Remaining: 3750.
        // Level 14→15 needs 3500. Remaining: 250.
        // Level 15→16 needs 3750. Can't afford. Stop.
        final result = XpRules.award(
          level: 12,
          xpIntoLevel: 0,
          lifetimeXp: 30000,
          amount: 10000,
        );

        expect(result.level, 15);
        expect(result.xpIntoLevel, 250);
        expect(result.levelsGained, 3);
        expect(result.previousLevel, 12);
        expect(result.leveledUp, true);
      });

      test('award of 0 does nothing', () {
        final result = XpRules.award(
          level: 12,
          xpIntoLevel: 1500,
          lifetimeXp: 30000,
          amount: 0,
        );

        expect(result.level, 12);
        expect(result.xpIntoLevel, 1500);
        expect(result.levelsGained, 0);
      });
    });
  });

  group('QuestDifficulty', () {
    test('numeral maps correctly', () {
      expect(QuestDifficulty.easy.numeral, 'I');
      expect(QuestDifficulty.medium.numeral, 'II');
      expect(QuestDifficulty.hard.numeral, 'III');
      expect(QuestDifficulty.epic.numeral, 'IV');
    });

    test('label maps correctly', () {
      expect(QuestDifficulty.easy.label, 'Easy');
      expect(QuestDifficulty.medium.label, 'Medium');
      expect(QuestDifficulty.hard.label, 'Hard');
      expect(QuestDifficulty.epic.label, 'Epic');
    });
  });

  group('DifficultyMode', () {
    test('multiplier values', () {
      expect(DifficultyMode.casual.multiplier, 1.5);
      expect(DifficultyMode.balanced.multiplier, 1.0);
      expect(DifficultyMode.hardcore.multiplier, 0.7);
    });
  });

  group('dayClearBonus', () {
    test('is 250', () {
      expect(XpRules.dayClearBonus, 250);
    });
  });
}
