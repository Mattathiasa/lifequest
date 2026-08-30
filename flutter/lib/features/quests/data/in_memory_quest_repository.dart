import '../../progression/domain/xp_rules.dart';
import '../domain/quest.dart';
import '../domain/quest_repository.dart';

/// In-memory quest repository seeded with the prototype's exact 11 quests.
///
/// Firebase implements [QuestRepository] later; this won't touch a widget.
class InMemoryQuestRepository implements QuestRepository {
  final List<Quest> _quests = [
    Quest(
      id: 1,
      code: 'MOV',
      name: 'Morning Workout',
      desc: '30 minutes, anything that raises your heart rate.',
      category: QuestCategory.health,
      difficulty: QuestDifficulty.medium,
      time: '30 min',
      due: '8:00 AM',
      schedule: QuestSchedule.today,
      done: true,
    ),
    Quest(
      id: 2,
      code: 'HYD',
      name: 'Drink 2L Water',
      desc: 'Spread across the day, not all at once.',
      category: QuestCategory.health,
      difficulty: QuestDifficulty.easy,
      time: 'all day',
      due: 'Today',
      schedule: QuestSchedule.today,
      done: true,
    ),
    Quest(
      id: 3,
      code: 'FOC',
      name: 'Deep Work Block',
      desc: 'One task, no tabs, no phone. Sixty minutes.',
      category: QuestCategory.productivity,
      difficulty: QuestDifficulty.hard,
      time: '60 min',
      due: '11:00 AM',
      schedule: QuestSchedule.today,
      done: false,
    ),
    Quest(
      id: 4,
      code: 'STU',
      name: 'Study Session',
      desc: 'Flutter architecture — repository pattern chapter.',
      category: QuestCategory.learning,
      difficulty: QuestDifficulty.medium,
      time: '60 min',
      due: '7:00 PM',
      schedule: QuestSchedule.today,
      done: false,
    ),
    Quest(
      id: 5,
      code: 'MED',
      name: 'Meditation',
      desc: 'Ten minutes, eyes closed, breath only.',
      category: QuestCategory.mindfulness,
      difficulty: QuestDifficulty.easy,
      time: '10 min',
      due: '9:30 PM',
      schedule: QuestSchedule.today,
      done: false,
    ),
    Quest(
      id: 6,
      code: 'RST',
      name: 'Sleep before 11 PM',
      desc: 'Protect tomorrow morning.',
      category: QuestCategory.health,
      difficulty: QuestDifficulty.easy,
      time: '—',
      due: '11:00 PM',
      schedule: QuestSchedule.today,
      done: false,
    ),
    Quest(
      id: 7,
      code: 'RUN',
      name: 'Run 5 KM',
      desc: 'Long run, easy pace, no watch anxiety.',
      category: QuestCategory.health,
      difficulty: QuestDifficulty.medium,
      time: '30–45 min',
      due: 'Tomorrow',
      schedule: QuestSchedule.upcoming,
      done: false,
    ),
    Quest(
      id: 8,
      code: 'FIN',
      name: 'Review Budget',
      desc: 'Categorise last month and set one limit.',
      category: QuestCategory.finance,
      difficulty: QuestDifficulty.medium,
      time: '25 min',
      due: 'Fri',
      schedule: QuestSchedule.upcoming,
      done: false,
    ),
    Quest(
      id: 9,
      code: 'SHP',
      name: 'Ship Side Project',
      desc: 'Deploy the first public version.',
      category: QuestCategory.productivity,
      difficulty: QuestDifficulty.epic,
      time: '3 h',
      due: 'Sun',
      schedule: QuestSchedule.upcoming,
      done: false,
    ),
    Quest(
      id: 10,
      code: 'CAL',
      name: 'Call a Friend',
      desc: 'Someone you have not spoken to in a while.',
      category: QuestCategory.social,
      difficulty: QuestDifficulty.easy,
      time: '20 min',
      due: 'Daily',
      schedule: QuestSchedule.recurring,
      done: false,
    ),
    Quest(
      id: 11,
      code: 'RED',
      name: 'Read 20 Pages',
      desc: 'Every night, before the screen wins.',
      category: QuestCategory.learning,
      difficulty: QuestDifficulty.easy,
      time: '20 min',
      due: 'Daily',
      schedule: QuestSchedule.recurring,
      done: false,
    ),
  ];

  @override
  Future<List<Quest>> getAll() async => List.unmodifiable(_quests);

  @override
  Future<void> complete(int questId) async {
    final idx = _quests.indexWhere((q) => q.id == questId);
    if (idx != -1) _quests[idx] = _quests[idx].copyWith(done: true);
  }

  @override
  Future<void> add(Quest quest) async {
    _quests.insert(0, quest);
  }

  @override
  Future<void> update(Quest quest) async {
    final idx = _quests.indexWhere((q) => q.id == quest.id);
    if (idx != -1) _quests[idx] = quest;
  }

  @override
  Future<void> delete(int questId) async {
    _quests.removeWhere((q) => q.id == questId);
  }
}
