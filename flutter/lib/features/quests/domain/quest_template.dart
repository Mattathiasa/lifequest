import '../../progression/domain/xp_rules.dart';
import '../domain/quest.dart';

/// A pre-built quest descriptor used by the templates library.
///
/// Templates are immutable value objects; they are converted into concrete
/// [Quest]s at import time so each user copy gets its own unique id.
class QuestTemplate {
  const QuestTemplate({
    required this.id,
    required this.name,
    required this.desc,
    required this.category,
    required this.difficulty,
    required this.time,
    required this.due,
    required this.schedule,
    required this.code,
  });

  final String id;
  final String name;
  final String desc;
  final QuestCategory category;
  final QuestDifficulty difficulty;
  final String time;
  final String due;
  final QuestSchedule schedule;
  final String code;

  /// Convert to a [Quest] using the supplied unique [id].
  Quest toQuest(int id) => Quest(
    id: id,
    code: code,
    name: name,
    desc: desc,
    category: category,
    difficulty: difficulty,
    time: time,
    due: due,
    schedule: schedule,
  );
}

/// A named collection of related [QuestTemplate]s.
class QuestPack {
  const QuestPack({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.templates,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final List<QuestTemplate> templates;

  int get totalXp => templates.fold<int>(0, (sum, t) => sum + t.toQuest(0).xp);
}

/// Curated starter packs available in the templates library.
abstract final class QuestPacks {
  static const morningLaunch = QuestPack(
    id: 'morning_launch',
    name: 'Morning Launch',
    description: 'Kickstart your day with clarity and energy.',
    emoji: '🌅',
    templates: [
      QuestTemplate(
        id: 'ml_hydrate',
        name: 'Hydrate & Sunlight',
        desc: 'Drink 500ml water and step outside for 5 min of natural light.',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.easy,
        time: '5 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'HLT',
      ),
      QuestTemplate(
        id: 'ml_stretch',
        name: 'Morning Stretch',
        desc:
            'Full-body stretch routine to wake up muscles and improve posture.',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.easy,
        time: '10 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'FLX',
      ),
      QuestTemplate(
        id: 'ml_top3',
        name: 'Plan Top 3 Quests',
        desc: 'Write the three most important tasks you will finish today.',
        category: QuestCategory.productivity,
        difficulty: QuestDifficulty.easy,
        time: '5 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'PLN',
      ),
    ],
  );

  static const deepWorkSprint = QuestPack(
    id: 'deep_work_sprint',
    name: 'Deep Work Sprint',
    description: 'Maximise focus and clear your most important work.',
    emoji: '⚡',
    templates: [
      QuestTemplate(
        id: 'dw_focus',
        name: '90-Min Focus Block',
        desc: 'Phone-off, notifications silenced — pure deep work on one task.',
        category: QuestCategory.productivity,
        difficulty: QuestDifficulty.hard,
        time: '90 min',
        due: 'Today',
        schedule: QuestSchedule.today,
        code: 'FCS',
      ),
      QuestTemplate(
        id: 'dw_inbox',
        name: 'Clear Inbox Zero',
        desc: 'Process every email: archive, respond, or delegate until empty.',
        category: QuestCategory.productivity,
        difficulty: QuestDifficulty.medium,
        time: '30 min',
        due: 'Today',
        schedule: QuestSchedule.today,
        code: 'CLZ',
      ),
      QuestTemplate(
        id: 'dw_review',
        name: 'Code / Project Review',
        desc:
            'Review a pull request or project deliverable with full attention.',
        category: QuestCategory.learning,
        difficulty: QuestDifficulty.medium,
        time: '45 min',
        due: 'Today',
        schedule: QuestSchedule.today,
        code: 'REV',
      ),
    ],
  );

  static const physicalVitality = QuestPack(
    id: 'physical_vitality',
    name: 'Physical Vitality',
    description: 'Build strength, endurance, and daily movement habits.',
    emoji: '💪',
    templates: [
      QuestTemplate(
        id: 'pv_run',
        name: '5K Run / Cardio',
        desc:
            'Complete a 5K run or 30-min cardio session at moderate intensity.',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.hard,
        time: '35 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'RUN',
      ),
      QuestTemplate(
        id: 'pv_strength',
        name: 'Strength Training',
        desc:
            'Full resistance session: compound lifts or bodyweight progressions.',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.hard,
        time: '50 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'STR',
      ),
      QuestTemplate(
        id: 'pv_walk',
        name: '10K Steps Walk',
        desc: 'Accumulate 10,000 steps through the day — split sessions count.',
        category: QuestCategory.health,
        difficulty: QuestDifficulty.medium,
        time: '80 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'WLK',
      ),
    ],
  );

  static const mindfulReset = QuestPack(
    id: 'mindful_reset',
    name: 'Mindful Reset',
    description: 'Restore calm, reflect, and protect your mental energy.',
    emoji: '🧘',
    templates: [
      QuestTemplate(
        id: 'mr_breathwork',
        name: '15-Min Breathwork',
        desc:
            'Box breathing or guided meditation — fully offline, eyes closed.',
        category: QuestCategory.mindfulness,
        difficulty: QuestDifficulty.easy,
        time: '15 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'MED',
      ),
      QuestTemplate(
        id: 'mr_sunset',
        name: 'Digital Sunset after 9 PM',
        desc: 'No screens after 21:00 — read, stretch, or wind-down instead.',
        category: QuestCategory.mindfulness,
        difficulty: QuestDifficulty.medium,
        time: '—',
        due: 'Tonight',
        schedule: QuestSchedule.recurring,
        code: 'SNT',
      ),
      QuestTemplate(
        id: 'mr_journal',
        name: 'Journal Reflections',
        desc: 'Write three wins, one lesson, and tomorrows single priority.',
        category: QuestCategory.mindfulness,
        difficulty: QuestDifficulty.easy,
        time: '10 min',
        due: 'Tonight',
        schedule: QuestSchedule.recurring,
        code: 'JRN',
      ),
    ],
  );

  static const financialHygiene = QuestPack(
    id: 'financial_hygiene',
    name: 'Financial Hygiene',
    description: 'Stay on top of spending, saving, and wealth building.',
    emoji: '💰',
    templates: [
      QuestTemplate(
        id: 'fh_budget',
        name: 'Weekly Budget Audit',
        desc:
            'Compare actual vs planned spend across every category this week.',
        category: QuestCategory.finance,
        difficulty: QuestDifficulty.medium,
        time: '20 min',
        due: 'This week',
        schedule: QuestSchedule.recurring,
        code: 'BDT',
      ),
      QuestTemplate(
        id: 'fh_expenses',
        name: 'Log All Expenses',
        desc: 'Enter every transaction from today into your tracking system.',
        category: QuestCategory.finance,
        difficulty: QuestDifficulty.easy,
        time: '5 min',
        due: 'Today',
        schedule: QuestSchedule.recurring,
        code: 'EXP',
      ),
      QuestTemplate(
        id: 'fh_invest',
        name: 'Review Investments',
        desc: 'Check portfolio allocation and rebalance or add to positions.',
        category: QuestCategory.finance,
        difficulty: QuestDifficulty.medium,
        time: '20 min',
        due: 'This week',
        schedule: QuestSchedule.recurring,
        code: 'INV',
      ),
    ],
  );

  /// All packs in display order.
  static const all = <QuestPack>[
    morningLaunch,
    deepWorkSprint,
    physicalVitality,
    mindfulReset,
    financialHygiene,
  ];
}
