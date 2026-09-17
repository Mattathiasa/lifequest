import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest/features/quests/application/quest_generator.dart';
import 'package:lifequest/features/quests/domain/quest.dart';
import 'package:lifequest/features/progression/domain/xp_rules.dart';

void main() {
  group('LocalQuestGenerator', () {
    const generator = LocalQuestGenerator();

    test('returns exactly four quests for any goal', () async {
      final result = await generator.generate('I want to become healthier');
      expect(result.quests, hasLength(4));
      expect(result.prompt, 'I want to become healthier');
    });

    test('routes health keywords to health quests', () async {
      final result = await generator.generate('run a marathon');
      expect(
        result.quests.every((q) => q.category == QuestCategory.health),
        isTrue,
      );
    });

    test('routes money keywords to finance quests', () async {
      final result = await generator.generate('save more money');
      expect(
        result.quests.every((q) => q.category == QuestCategory.finance),
        isTrue,
      );
    });

    test('unknown goals default to productivity quests', () async {
      final result = await generator.generate('launch my side project');
      expect(
        result.quests.every((q) => q.category == QuestCategory.productivity),
        isTrue,
      );
    });

    test('codes are always three letters', () async {
      final result = await generator.generate('something completely random');
      for (final q in result.quests) {
        expect(q.code, matches(RegExp(r'^[A-Z]{3}$')));
      }
    });
  });

  group('RemoteQuestGenerator', () {
    test('with no key configured, falls back to local generation', () async {
      final generator = RemoteQuestGenerator(
        config: const RemoteAiConfig(apiKey: ''),
      );
      final result = await generator.generate('learn guitar');
      expect(result.quests, hasLength(4));
      expect(
        result.quests.every((q) => q.category == QuestCategory.learning),
        isTrue,
      );
    });

    test('parses a fenced JSON reply', () {
      final parsed = RemoteQuestGenerator.parse('''
Here you go:
```json
[
  {"name": "Run 5 KM", "category": "health", "difficulty": "medium"},
  {"name": "Drink water", "category": "health", "difficulty": "easy"},
  {"name": "Sleep by 11", "category": "health", "difficulty": "easy"},
  {"name": "Stretch", "category": "health", "difficulty": "easy"}
]
```
''');
      expect(parsed, hasLength(4));
      expect(parsed.first.name, 'Run 5 KM');
      expect(parsed.first.category, QuestCategory.health);
      expect(parsed.first.difficulty, QuestDifficulty.medium);
      expect(parsed.first.code, 'RUN');
    });

    test('throws on a reply without a JSON array', () {
      expect(
        () => RemoteQuestGenerator.parse('Sorry, I cannot help with that.'),
        throwsFormatException,
      );
    });

    test('drops entries with no name', () {
      final parsed = RemoteQuestGenerator.parse('''
[
  {"category": "health", "difficulty": "easy"},
  {"name": "Real quest", "category": "health", "difficulty": "easy"}
]
''');
      expect(parsed, hasLength(1));
      expect(parsed.single.name, 'Real quest');
    });
  });
}
