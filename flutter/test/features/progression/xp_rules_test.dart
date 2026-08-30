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

      test('level 100 requires 25000 XP', () {
        expect(XpRules.need(100), 25000);
      });

      test('need scales linearly with level', () {
        for (var level = 1; level <= 20; level++) {
          expect(XpRules.need(level), 250 * level);
        }
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
        // 150 * 0.7 = 105, rounds to nearest 10 → 110
        expect(
          XpRules.reward(QuestDifficulty.medium, DifficultyMode.hardcore),
          110,
        );
      });

      test('all difficulty/mode combinations produce multiples of 10', () {
        for (final diff in QuestDifficulty.values) {
          for (final mode in DifficultyMode.values) {
            final reward = XpRules.reward(diff, mode);
            expect(reward % 10, 0, reason: '$diff $mode produced $reward');
          }
        }
      });

      test('casual always gives more than balanced', () {
        for (final diff in QuestDifficulty.values) {
          final casual = XpRules.reward(diff, DifficultyMode.casual);
          final balanced = XpRules.reward(diff, DifficultyMode.balanced);
          expect(casual, greaterThan(balanced));
        }
      });

      test('hardcore always gives less than balanced', () {
        for (final diff in QuestDifficulty.values) {
          final hardcore = XpRules.reward(diff, DifficultyMode.hardcore);
          final balanced = XpRules.reward(diff, DifficultyMode.balanced);
          expect(hardcore, lessThan(balanced));
        }
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

      test('more than needed is clamped to 1.0', () {
        expect(XpRules.levelProgress(12, 5000), 1.0);
      });

      test('negative XP is clamped to 0.0', () {
        expect(XpRules.levelProgress(12, -100), 0.0);
      });

      test('works for level 1', () {
        expect(XpRules.levelProgress(1, 125), 0.5);
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

      test('custom segment count works', () {
        expect(XpRules.filledTicks(12, 1500, segments: 10), 5);
        expect(XpRules.filledTicks(12, 1500, segments: 30), 15);
      });

      test('rounds to nearest tick', () {
        // 1/3 of 3000 = 1000 XP → 1000/3000 * 20 = 6.67 → rounds to 7
        expect(XpRules.filledTicks(12, 1000, segments: 20), 7);
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

      test('massive award can cross many levels', () {
        // Award 50000 XP at level 1 with 0 XP
        final result = XpRules.award(
          level: 1,
          xpIntoLevel: 0,
          lifetimeXp: 0,
          amount: 50000,
        );

        // Level 1→2: 250, remaining 49750
        // Level 2→3: 500, remaining 49250
        // Level 3→4: 750, remaining 48500
        // ... continues until can't afford next level
        expect(result.level, greaterThan(1));
        expect(result.levelsGained, greaterThan(0));
        expect(result.leveledUp, true);
        expect(result.lifetimeXp, 50000);
      });

      test('award at level boundary with exact amount', () {
        // Level 1 needs 250. Have 0, award 250 → exactly level 2
        final result = XpRules.award(
          level: 1,
          xpIntoLevel: 0,
          lifetimeXp: 0,
          amount: 250,
        );

        expect(result.level, 2);
        expect(result.xpIntoLevel, 0);
        expect(result.levelsGained, 1);
      });

      test('award carries remainder correctly across levels', () {
        // Level 10, 2000 XP in (need 2500). Award 3000.
        // Level 10→11 needs 500 more. Award covers it with 2500 remaining.
        // Level 11→12 needs 2750. Award covers it with -250? No...
        // Let me recalculate:
        // Start: level 10, 2000 XP
        // Add 3000: total 5000
        // Need for level 10: 2500. After level up: 5000-2500=2500, now level 11
        // Need for level 11: 2750. After level up: 2500-2750 = not enough
        // So: level 11, 2500 XP into level
        final result = XpRules.award(
          level: 10,
          xpIntoLevel: 2000,
          lifetimeXp: 25000,
          amount: 3000,
        );

        expect(result.level, 11);
        expect(result.xpIntoLevel, 2500);
        expect(result.levelsGained, 1);
        expect(result.lifetimeXp, 28000);
      });

      test('lifetime XP always increases by award amount', () {
        final result = XpRules.award(
          level: 5,
          xpIntoLevel: 100,
          lifetimeXp: 1000,
          amount: 500,
        );

        expect(result.lifetimeXp, 1500);
      });

      test('previousLevel is always the starting level', () {
        final result = XpRules.award(
          level: 20,
          xpIntoLevel: 0,
          lifetimeXp: 50000,
          amount: 10000,
        );

        expect(result.previousLevel, 20);
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

    test('baseXp values are correct', () {
      expect(QuestDifficulty.easy.baseXp, 50);
      expect(QuestDifficulty.medium.baseXp, 150);
      expect(QuestDifficulty.hard.baseXp, 280);
      expect(QuestDifficulty.epic.baseXp, 500);
    });
  });

  group('DifficultyMode', () {
    test('multiplier values', () {
      expect(DifficultyMode.casual.multiplier, 1.5);
      expect(DifficultyMode.balanced.multiplier, 1.0);
      expect(DifficultyMode.hardcore.multiplier, 0.7);
    });

    test('label values', () {
      expect(DifficultyMode.casual.label, 'Casual');
      expect(DifficultyMode.balanced.label, 'Balanced');
      expect(DifficultyMode.hardcore.label, 'Hardcore');
    });

    test('blurb values are non-empty', () {
      for (final mode in DifficultyMode.values) {
        expect(mode.blurb, isNotEmpty);
      }
    });
  });

  group('dayClearBonus', () {
    test('is 250', () {
      expect(XpRules.dayClearBonus, 250);
    });
  });

  group('ProgressionResult', () {
    test('leveledUp is true when levelsGained > 0', () {
      const result = ProgressionResult(
        level: 13,
        xpIntoLevel: 0,
        lifetimeXp: 30000,
        levelsGained: 1,
        previousLevel: 12,
      );
      expect(result.leveledUp, true);
    });

    test('leveledUp is false when levelsGained == 0', () {
      const result = ProgressionResult(
        level: 12,
        xpIntoLevel: 500,
        lifetimeXp: 30500,
        levelsGained: 0,
        previousLevel: 12,
      );
      expect(result.leveledUp, false);
    });
  });
}
