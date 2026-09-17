import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../progression/domain/xp_rules.dart';
import '../domain/quest.dart';

/// One AI-suggested quest before it becomes a real [Quest].
class GeneratedQuest {
  const GeneratedQuest({
    required this.code,
    required this.name,
    required this.category,
    required this.difficulty,
  });

  final String code;
  final String name;
  final QuestCategory category;
  final QuestDifficulty difficulty;
}

/// A goal the user typed, plus what came back.
class GenerationResult {
  const GenerationResult({required this.prompt, required this.quests});

  final String prompt;
  final List<GeneratedQuest> quests;
}

/// Contract for turning a one-line goal into a short quest chain.
abstract interface class QuestGenerator {
  Future<GenerationResult> generate(String goal);
}

/// Deterministic local generator — the always-available fallback. Builds a
/// sensible starter chain from the words the user typed, themed by the
/// category keywords it recognizes.
class LocalQuestGenerator implements QuestGenerator {
  const LocalQuestGenerator();

  @override
  Future<GenerationResult> generate(String goal) async {
    final cat = _categoryFor(goal);
    final subject = _subject(goal);
    final quests = switch (cat) {
      QuestCategory.health => [
        const GeneratedQuest(
          code: 'HYD',
          name: 'Drink 2L water',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.easy,
        ),
        GeneratedQuest(
          code: 'MOV',
          name: 'Move 20 minutes for $subject',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.medium,
        ),
        const GeneratedQuest(
          code: 'SLP',
          name: 'Lights out by 11',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.easy,
        ),
        GeneratedQuest(
          code: 'EAT',
          name: 'Cook a real meal for $subject',
          category: QuestCategory.health,
          difficulty: QuestDifficulty.medium,
        ),
      ],
      QuestCategory.learning => [
        GeneratedQuest(
          code: 'STU',
          name: 'Study $subject · 25 min',
          category: QuestCategory.learning,
          difficulty: QuestDifficulty.medium,
        ),
        const GeneratedQuest(
          code: 'NOT',
          name: 'Summarize what you learned',
          category: QuestCategory.learning,
          difficulty: QuestDifficulty.easy,
        ),
        GeneratedQuest(
          code: 'PRC',
          name: 'Practice $subject · one exercise',
          category: QuestCategory.learning,
          difficulty: QuestDifficulty.medium,
        ),
        const GeneratedQuest(
          code: 'SHR',
          name: 'Teach it to someone',
          category: QuestCategory.learning,
          difficulty: QuestDifficulty.hard,
        ),
      ],
      QuestCategory.finance => [
        const GeneratedQuest(
          code: 'LOG',
          name: 'Log every expense today',
          category: QuestCategory.finance,
          difficulty: QuestDifficulty.easy,
        ),
        const GeneratedQuest(
          code: 'BGT',
          name: 'Set one weekly budget limit',
          category: QuestCategory.finance,
          difficulty: QuestDifficulty.medium,
        ),
        GeneratedQuest(
          code: 'SAV',
          name: 'Move a small amount to savings',
          category: QuestCategory.finance,
          difficulty: QuestDifficulty.easy,
        ),
        GeneratedQuest(
          code: 'REV',
          name: 'Review subscriptions for $subject',
          category: QuestCategory.finance,
          difficulty: QuestDifficulty.medium,
        ),
      ],
      QuestCategory.social => [
        GeneratedQuest(
          code: 'CAL',
          name: 'Reach out about $subject',
          category: QuestCategory.social,
          difficulty: QuestDifficulty.easy,
        ),
        const GeneratedQuest(
          code: 'PLN',
          name: 'Plan one social plan this week',
          category: QuestCategory.social,
          difficulty: QuestDifficulty.medium,
        ),
        const GeneratedQuest(
          code: 'LSN',
          name: 'Fully listen in one conversation',
          category: QuestCategory.social,
          difficulty: QuestDifficulty.easy,
        ),
        const GeneratedQuest(
          code: 'THX',
          name: 'Thank someone specifically',
          category: QuestCategory.social,
          difficulty: QuestDifficulty.easy,
        ),
      ],
      QuestCategory.mindfulness => [
        const GeneratedQuest(
          code: 'MED',
          name: 'Meditate 10 minutes',
          category: QuestCategory.mindfulness,
          difficulty: QuestDifficulty.easy,
        ),
        GeneratedQuest(
          code: 'JRN',
          name: 'Journal about $subject',
          category: QuestCategory.mindfulness,
          difficulty: QuestDifficulty.easy,
        ),
        const GeneratedQuest(
          code: 'WLK',
          name: 'Walk without your phone',
          category: QuestCategory.mindfulness,
          difficulty: QuestDifficulty.medium,
        ),
        const GeneratedQuest(
          code: 'SCR',
          name: 'Screen-free last hour',
          category: QuestCategory.mindfulness,
          difficulty: QuestDifficulty.hard,
        ),
      ],
      QuestCategory.productivity => [
        GeneratedQuest(
          code: 'DEP',
          name: 'Deep work on $subject · 60 min',
          category: QuestCategory.productivity,
          difficulty: QuestDifficulty.hard,
        ),
        GeneratedQuest(
          code: 'BRK',
          name: 'Break $subject into 3 steps',
          category: QuestCategory.productivity,
          difficulty: QuestDifficulty.easy,
        ),
        GeneratedQuest(
          code: 'STP',
          name: 'One visible step on $subject',
          category: QuestCategory.productivity,
          difficulty: QuestDifficulty.medium,
        ),
        const GeneratedQuest(
          code: 'CLN',
          name: 'Clear the decks · inbox zero',
          category: QuestCategory.productivity,
          difficulty: QuestDifficulty.easy,
        ),
      ],
    };
    return GenerationResult(prompt: goal, quests: quests);
  }

  static QuestCategory _categoryFor(String goal) {
    final g = goal.toLowerCase();
    bool any(List<String> words) => words.any(g.contains);
    if (any([
      'run',
      'gym',
      'weight',
      'health',
      'fit',
      'sleep',
      'water',
      'eat',
    ])) {
      return QuestCategory.health;
    }
    if (any(['learn', 'study', 'read', 'course', 'language', 'exam', 'book'])) {
      return QuestCategory.learning;
    }
    if (any(['save', 'budget', 'money', 'spend', 'invest', 'debt'])) {
      return QuestCategory.finance;
    }
    if (any(['friend', 'family', 'call', 'date', 'social', 'partner'])) {
      return QuestCategory.social;
    }
    if (any(['calm', 'stress', 'anxiet', 'meditat', 'mindful', 'journal'])) {
      return QuestCategory.mindfulness;
    }
    return QuestCategory.productivity;
  }

  static String _subject(String goal) {
    final cleaned = goal.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length <= 40) return cleaned.toLowerCase();
    return '${cleaned.substring(0, 40).trim().toLowerCase()}…';
  }
}

/// Settings for the remote generator (persisted via the settings sheet).
class RemoteAiConfig {
  const RemoteAiConfig({
    this.apiKey = '',
    this.baseUrl = 'https://api.openai.com/v1',
    this.model = 'gpt-4o-mini',
  });

  final String apiKey;
  final String baseUrl;
  final String model;

  bool get isEnabled => apiKey.isNotEmpty;

  static const _kKey = 'ai.apiKey';
  static const _kBase = 'ai.baseUrl';
  static const _kModel = 'ai.model';

  static Future<RemoteAiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    return RemoteAiConfig(
      apiKey: prefs.getString(_kKey) ?? '',
      baseUrl: prefs.getString(_kBase) ?? 'https://api.openai.com/v1',
      model: prefs.getString(_kModel) ?? 'gpt-4o-mini',
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, apiKey);
    await prefs.setString(_kBase, baseUrl);
    await prefs.setString(_kModel, model);
  }
}

/// Calls any OpenAI-compatible chat-completions endpoint (OpenAI, OpenRouter,
/// Groq, Together, a self-hosted gateway, …) and parses a strict JSON quest
/// list out of the reply. Falls back to [LocalQuestGenerator] on any failure.
class RemoteQuestGenerator implements QuestGenerator {
  RemoteQuestGenerator({required this.config, this.client});

  final RemoteAiConfig config;
  final http.Client? client;

  static const _local = LocalQuestGenerator();

  @override
  Future<GenerationResult> generate(String goal) async {
    if (!config.isEnabled) return _local.generate(goal);
    try {
      return await _remote(goal);
    } catch (_) {
      return _local.generate(goal);
    }
  }

  Future<GenerationResult> _remote(String goal) async {
    final uri = Uri.parse(
      '${config.baseUrl.endsWith('/') ? config.baseUrl.substring(0, config.baseUrl.length - 1) : config.baseUrl}'
      '/chat/completions',
    );
    final response = await (client ?? http.Client()).post(
      uri,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': config.model,
        'temperature': 0.7,
        'messages': [
          {
            'role': 'system',
            'content':
                'You design habit quests for a real-life RPG app. Reply with '
                'ONLY a JSON array of exactly 4 objects, each with keys '
                '"name" (short imperative quest, max 6 words), "category" '
                '(one of health, learning, productivity, social, finance, '
                'mindfulness), "difficulty" (one of easy, medium, hard, '
                'epic). No prose, no markdown.',
          },
          {'role': 'user', 'content': goal},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('AI HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        ((body['choices'] as List).first as Map)['message']['content']
            as String;
    return GenerationResult(prompt: goal, quests: _parse(content, goal));
  }

  /// Visible for tests.
  static List<GeneratedQuest> parse(String content) => _parse(content, 'goal');

  static List<GeneratedQuest> _parse(String content, String goal) {
    // Tolerate markdown fences.
    var text = content.trim();
    if (text.startsWith('```')) {
      text = text
          .replaceFirst(RegExp(r'^```[a-z]*\n?'), '')
          .replaceFirst(RegExp(r'```\s*$'), '');
    }
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('no JSON array in AI reply');
    }
    final list = jsonDecode(text.substring(start, end + 1)) as List;
    final quests = <GeneratedQuest>[];
    for (final item in list) {
      if (item is! Map) continue;
      final name = (item['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;
      final catName = (item['category'] as String?) ?? 'productivity';
      final diffName = (item['difficulty'] as String?) ?? 'medium';
      quests.add(
        GeneratedQuest(
          code: _codeFor(name),
          name: name,
          category:
              QuestCategory.values
                  .where((c) => c.name == catName)
                  .firstOrNull ??
              QuestCategory.productivity,
          difficulty:
              QuestDifficulty.values
                  .where((d) => d.name == diffName)
                  .firstOrNull ??
              QuestDifficulty.medium,
        ),
      );
    }
    if (quests.isEmpty) {
      throw const FormatException('AI reply had no quests');
    }
    return quests.take(4).toList();
  }

  static String _codeFor(String name) {
    final letters = name.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    if (letters.length >= 3) return letters.substring(0, 3);
    return letters.padRight(3, 'X');
  }
}

/// The active generator. Reads the remote config once per call; when no key
/// is set it is the deterministic local generator.
final questGeneratorProvider = FutureProvider<QuestGenerator>((ref) async {
  final config = await RemoteAiConfig.load();
  return RemoteQuestGenerator(config: config);
});
