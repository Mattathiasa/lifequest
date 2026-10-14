import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/progress/application/coach_advice_provider.dart';
import 'package:lifequest/features/progression/domain/attributes.dart';

void main() {
  // Helper: Attributes with all values at [value]
  Attributes flat(int value) =>
      Attributes({for (final a in Attribute.values) a: value});

  // Helper: Attributes with one specific attribute set lower
  Attributes withLow(Attribute weak, {int weakVal = 40, int otherVal = 80}) =>
      Attributes({
        for (final a in Attribute.values) a: a == weak ? weakVal : otherVal,
      });

  group('deriveCoachAdvice', () {
    test('returns WELCOME when totalXp is 0', () {
      final advice = deriveCoachAdvice(
        attributes: flat(70),
        dailyCounts: List.filled(42, 0),
        streak: 0,
        totalXp: 0,
      );
      expect(advice.tag, 'WELCOME');
    });

    test('returns ON FIRE for streak >= 7', () {
      final advice = deriveCoachAdvice(
        attributes: flat(70),
        dailyCounts: List.filled(42, 3),
        streak: 10,
        totalXp: 500,
      );
      expect(advice.tag, 'ON FIRE');
      expect(advice.headline, contains('10'));
    });

    test('streak = 6 does NOT trigger ON FIRE', () {
      final advice = deriveCoachAdvice(
        attributes: flat(70),
        dailyCounts: List.filled(42, 3),
        streak: 6,
        totalXp: 500,
      );
      expect(advice.tag, isNot('ON FIRE'));
    });

    test('returns CONSISTENCY for low completion rate', () {
      // Only 5 of 42 days active = ~12%
      final counts = List.filled(42, 0)
        ..[0] = 2
        ..[5] = 1
        ..[10] = 3
        ..[20] = 1
        ..[30] = 2;
      final advice = deriveCoachAdvice(
        attributes: flat(70),
        dailyCounts: counts,
        streak: 0,
        totalXp: 300,
      );
      expect(advice.tag, 'CONSISTENCY');
    });

    test('returns low HEALTH advice when Health is weakest', () {
      final advice = deriveCoachAdvice(
        attributes: withLow(Attribute.health),
        dailyCounts: List.filled(42, 3),
        streak: 3,
        totalXp: 500,
      );
      expect(advice.tag, 'LOW HEALTH');
    });

    test('returns low FOCUS advice when Focus is weakest', () {
      final advice = deriveCoachAdvice(
        attributes: withLow(Attribute.focus),
        dailyCounts: List.filled(42, 3),
        streak: 3,
        totalXp: 500,
      );
      expect(advice.tag, 'LOW FOCUS');
    });

    test('returns low SOCIAL advice when Social is weakest', () {
      final advice = deriveCoachAdvice(
        attributes: withLow(Attribute.social),
        dailyCounts: List.filled(42, 3),
        streak: 3,
        totalXp: 500,
      );
      expect(advice.tag, 'LOW SOCIAL');
    });

    test('returns low DISCIPLINE advice when Discipline is weakest', () {
      final advice = deriveCoachAdvice(
        attributes: withLow(Attribute.discipline),
        dailyCounts: List.filled(42, 3),
        streak: 3,
        totalXp: 500,
      );
      expect(advice.tag, 'LOW DISCIPLINE');
    });

    test('returns THRIVING when all attributes >= 70 and streak < 7', () {
      final advice = deriveCoachAdvice(
        attributes: flat(75),
        dailyCounts: List.filled(42, 3),
        streak: 5,
        totalXp: 800,
      );
      expect(advice.tag, 'THRIVING');
    });

    test('each advice has non-empty tag, headline, body, and icon', () {
      final scenarios = [
        deriveCoachAdvice(
          attributes: flat(70),
          dailyCounts: List.filled(42, 0),
          streak: 0,
          totalXp: 0,
        ),
        deriveCoachAdvice(
          attributes: flat(70),
          dailyCounts: List.filled(42, 3),
          streak: 8,
          totalXp: 500,
        ),
        deriveCoachAdvice(
          attributes: withLow(Attribute.intellect),
          dailyCounts: List.filled(42, 3),
          streak: 2,
          totalXp: 400,
        ),
      ];
      for (final advice in scenarios) {
        expect(advice.tag.isNotEmpty, true, reason: 'tag is empty');
        expect(advice.headline.isNotEmpty, true, reason: 'headline is empty');
        expect(advice.body.isNotEmpty, true, reason: 'body is empty');
        expect(advice.icon.isNotEmpty, true, reason: 'icon is empty');
      }
    });
  });
}
