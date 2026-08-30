import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/progression/domain/progression_state.dart';

void main() {
  group('ProgressionState', () {
    test('default values are correct', () {
      const state = ProgressionState();

      expect(state.level, 12);
      expect(state.xpIntoLevel, 2450);
      expect(state.lifetimeXp, 34120);
      expect(state.streak, 14);
      expect(state.recordStreak, 31);
      expect(state.streakFreezes, 1);
      expect(state.firstLevelUp, true);
    });

    test('copyWith preserves unchanged fields', () {
      const original = ProgressionState(
        level: 15,
        xpIntoLevel: 1000,
        lifetimeXp: 50000,
        streak: 7,
        recordStreak: 10,
        streakFreezes: 2,
      );

      final updated = original.copyWith(level: 16);

      expect(updated.level, 16);
      expect(updated.xpIntoLevel, 1000);
      expect(updated.lifetimeXp, 50000);
      expect(updated.streak, 7);
      expect(updated.recordStreak, 10);
      expect(updated.streakFreezes, 2);
    });

    test('canUseStreakFreeze returns true when freezes > 0 and not used today', () {
      const state = ProgressionState(
        streakFreezes: 1,
        lastStreakFreezeUsed: null,
      );

      expect(state.canUseStreakFreeze, true);
    });

    test('canUseStreakFreeze returns false when freezes = 0', () {
      const state = ProgressionState(
        streakFreezes: 0,
      );

      expect(state.canUseStreakFreeze, false);
    });

    test('toJson and fromJson roundtrip', () {
      const original = ProgressionState(
        level: 15,
        xpIntoLevel: 1000,
        lifetimeXp: 50000,
        streak: 7,
        recordStreak: 10,
        streakFreezes: 2,
        firstLevelUp: true,
      );

      final json = original.toJson();
      final restored = ProgressionState.fromJson(json);

      expect(restored.level, original.level);
      expect(restored.xpIntoLevel, original.xpIntoLevel);
      expect(restored.lifetimeXp, original.lifetimeXp);
      expect(restored.streak, original.streak);
      expect(restored.recordStreak, original.recordStreak);
      expect(restored.streakFreezes, original.streakFreezes);
      expect(restored.firstLevelUp, original.firstLevelUp);
    });

    test('fromJson handles missing fields gracefully', () {
      final json = <String, dynamic>{};
      final state = ProgressionState.fromJson(json);

      expect(state.level, 12);
      expect(state.xpIntoLevel, 2450);
      expect(state.streakFreezes, 1);
    });
  });
}
