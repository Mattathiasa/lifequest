import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quest.dart';
import '../domain/quest_repository.dart';
import 'in_memory_quest_repository.dart';

/// [SharedPreferences]-backed quests: seeded from [InMemoryQuestRepository] on
/// first run, then persisted (done-state + additions survive restarts). On a
/// new calendar day, today/recurring quests reset to not-done for a fresh trail.
///
/// Same [QuestRepository] interface Firebase will implement later.
class PrefsQuestRepository implements QuestRepository {
  static const _kQuests = 'quests.v1';
  static const _kLastDay = 'quests.lastDay';

  Future<List<Quest>> _read(SharedPreferences prefs) async {
    final raw = prefs.getString(_kQuests);
    if (raw == null) {
      final seed = await InMemoryQuestRepository().getAll();
      await _write(prefs, seed);
      await prefs.setString(_kLastDay, _dayKey(DateTime.now()));
      return seed;
    }
    return (jsonDecode(raw) as List)
        .map((e) => Quest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _write(SharedPreferences prefs, List<Quest> quests) => prefs
      .setString(_kQuests, jsonEncode(quests.map((q) => q.toJson()).toList()));

  @override
  Future<List<Quest>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    var quests = await _read(prefs);
    final today = _dayKey(DateTime.now());
    if (prefs.getString(_kLastDay) != today) {
      quests = [
        for (final q in quests)
          (q.done &&
                  (q.schedule == QuestSchedule.today ||
                      q.schedule == QuestSchedule.recurring))
              ? q.copyWith(done: false)
              : q,
      ];
      await _write(prefs, quests);
      await prefs.setString(_kLastDay, today);
    }
    return List.unmodifiable(quests);
  }

  @override
  Future<void> complete(int questId) async {
    final prefs = await SharedPreferences.getInstance();
    final quests = await _read(prefs);
    await _write(prefs, [
      for (final q in quests) q.id == questId ? q.copyWith(done: true) : q,
    ]);
  }

  @override
  Future<void> add(Quest quest) async {
    final prefs = await SharedPreferences.getInstance();
    final quests = await _read(prefs);
    await _write(prefs, [quest, ...quests]);
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
