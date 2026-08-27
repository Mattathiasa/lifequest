import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/xp_tick_bar.dart';
import '../../../core/widgets/category_chip.dart';
import '../../progression/application/progression_controller.dart';
import '../../settings/application/settings_controller.dart';

/// Skill tree node data from the prototype.
class SkillNode {
  const SkillNode({
    required this.name,
    required this.state,
    required this.requirement,
    required this.description,
    required this.benefit,
    required this.xpCost,
  });

  final String name;
  final String state; // Mastered, Unlocked, Available, Locked
  final String requirement;
  final String description;
  final String benefit;
  final String xpCost;
}

/// Skill branch data from the prototype.
const _skillTree = <String, List<SkillNode>>{
  'Health': [
    SkillNode(
      name: 'Beginner',
      state: 'Mastered',
      requirement: '5 quests',
      description: 'You showed up. The first week is the hard one.',
      benefit: '+1 HEALTH per quest',
      xpCost: '0 XP',
    ),
    SkillNode(
      name: 'Consistent',
      state: 'Unlocked',
      requirement: '25 quests',
      description: 'Health quests four days a week, for a month.',
      benefit: '+2 HEALTH per quest',
      xpCost: '1,200 XP',
    ),
    SkillNode(
      name: 'Athlete',
      state: 'Available',
      requirement: '60 quests',
      description: 'Sustain hard training quests for eight weeks.',
      benefit: 'Unlocks epic training chains',
      xpCost: '3,400 XP',
    ),
    SkillNode(
      name: 'Elite',
      state: 'Locked',
      requirement: '150 quests',
      description: 'Needs Athlete plus a 100-day streak.',
      benefit: '+5 HEALTH · Elite title',
      xpCost: '9,000 XP',
    ),
  ],
  'Knowledge': [
    SkillNode(
      name: 'Curious',
      state: 'Mastered',
      requirement: '5 quests',
      description: 'First study sessions logged.',
      benefit: '+1 INTELLECT',
      xpCost: '0 XP',
    ),
    SkillNode(
      name: 'Student',
      state: 'Unlocked',
      requirement: '30 quests',
      description: 'A month of daily learning.',
      benefit: '+2 INTELLECT',
      xpCost: '1,500 XP',
    ),
    SkillNode(
      name: 'Practitioner',
      state: 'Available',
      requirement: '80 quests',
      description: 'Ship something you learned — projects count double.',
      benefit: 'Unlocks project chains',
      xpCost: '4,000 XP',
    ),
    SkillNode(
      name: 'Expert',
      state: 'Locked',
      requirement: '200 quests',
      description: 'Teach the thing you learned.',
      benefit: '+5 INTELLECT · Scholar',
      xpCost: '12,000 XP',
    ),
  ],
  'Career': [
    SkillNode(
      name: 'Focused',
      state: 'Unlocked',
      requirement: '10 quests',
      description: 'Deep-work blocks five days running.',
      benefit: '+1 FOCUS',
      xpCost: '600 XP',
    ),
    SkillNode(
      name: 'Operator',
      state: 'Available',
      requirement: '40 quests',
      description: 'Plan the week before it starts, four weeks straight.',
      benefit: 'Weekly planning slot',
      xpCost: '2,600 XP',
    ),
    SkillNode(
      name: 'Lead',
      state: 'Locked',
      requirement: '100 quests',
      description: 'Mentoring and delegation quests unlock here.',
      benefit: '+3 SOCIAL · +3 FOCUS',
      xpCost: '7,500 XP',
    ),
    SkillNode(
      name: 'Founder',
      state: 'Locked',
      requirement: '250 quests',
      description: 'The long game.',
      benefit: 'Legendary title',
      xpCost: '18,000 XP',
    ),
  ],
  'Finance': [
    SkillNode(
      name: 'Tracker',
      state: 'Unlocked',
      requirement: '8 quests',
      description: 'Log spending for two weeks.',
      benefit: '+1 DISCIPLINE',
      xpCost: '400 XP',
    ),
    SkillNode(
      name: 'Saver',
      state: 'Available',
      requirement: '30 quests',
      description: 'Hit a monthly savings target three times.',
      benefit: 'Unlocks goal vault',
      xpCost: '2,000 XP',
    ),
    SkillNode(
      name: 'Investor',
      state: 'Locked',
      requirement: '75 quests',
      description: 'Automate, then review quarterly.',
      benefit: '+3 DISCIPLINE',
      xpCost: '6,000 XP',
    ),
    SkillNode(
      name: 'Free',
      state: 'Locked',
      requirement: '200 quests',
      description: 'Runway measured in years.',
      benefit: 'Legendary title',
      xpCost: '20,000 XP',
    ),
  ],
  'Bonds': [
    SkillNode(
      name: 'Present',
      state: 'Unlocked',
      requirement: '6 quests',
      description: 'Phone away, people first.',
      benefit: '+1 SOCIAL',
      xpCost: '300 XP',
    ),
    SkillNode(
      name: 'Connector',
      state: 'Available',
      requirement: '25 quests',
      description: 'Reach out weekly for two months.',
      benefit: 'Unlocks shared quests',
      xpCost: '1,800 XP',
    ),
    SkillNode(
      name: 'Anchor',
      state: 'Locked',
      requirement: '70 quests',
      description: 'Be the person others rely on.',
      benefit: '+3 SOCIAL',
      xpCost: '5,500 XP',
    ),
    SkillNode(
      name: 'Community',
      state: 'Locked',
      requirement: '160 quests',
      description: 'Build something with other people.',
      benefit: 'Legendary title',
      xpCost: '14,000 XP',
    ),
  ],
  'Craft': [
    SkillNode(
      name: 'Maker',
      state: 'Unlocked',
      requirement: '6 quests',
      description: 'Finish small things, often.',
      benefit: '+1 CREATIVITY',
      xpCost: '350 XP',
    ),
    SkillNode(
      name: 'Craftsman',
      state: 'Available',
      requirement: '28 quests',
      description: 'A daily practice, thirty days.',
      benefit: 'Unlocks portfolio quests',
      xpCost: '1,900 XP',
    ),
    SkillNode(
      name: 'Author',
      state: 'Locked',
      requirement: '80 quests',
      description: 'Publish the work.',
      benefit: '+3 CREATIVITY',
      xpCost: '6,200 XP',
    ),
    SkillNode(
      name: 'Visionary',
      state: 'Locked',
      requirement: '180 quests',
      description: 'A body of work.',
      benefit: 'Legendary title',
      xpCost: '16,000 XP',
    ),
  ],
  'Mind': [
    SkillNode(
      name: 'Still',
      state: 'Mastered',
      requirement: '7 quests',
      description: 'A week of sitting with your own head.',
      benefit: '+1 DISCIPLINE',
      xpCost: '0 XP',
    ),
    SkillNode(
      name: 'Grounded',
      state: 'Unlocked',
      requirement: '30 quests',
      description: 'Daily meditation for a month.',
      benefit: '+2 DISCIPLINE',
      xpCost: '1,400 XP',
    ),
    SkillNode(
      name: 'Centered',
      state: 'Available',
      requirement: '75 quests',
      description: 'Longer sits plus one full detox day.',
      benefit: 'Unlocks retreat adventure',
      xpCost: '3,800 XP',
    ),
    SkillNode(
      name: 'Serene',
      state: 'Locked',
      requirement: '180 quests',
      description: 'Equanimity under real pressure.',
      benefit: '+5 DISCIPLINE',
      xpCost: '13,000 XP',
    ),
  ],
};

const _attributes = [
  ('STRENGTH', 64),
  ('INTELLECT', 81),
  ('DISCIPLINE', 88),
  ('HEALTH', 72),
  ('CREATIVITY', 57),
  ('SOCIAL', 43),
  ('FOCUS', 76),
];

const _achievements = [
  ('7 Day Streak', 'Earned Apr 2', true),
  ('First Level Up', 'Earned Mar 8', true),
  ('Quest Hunter', '68 / 100', false),
  ('Night Owl', 'Earned Jun 19', true),
  ('Perfect Week', '5 / 7 days', false),
  ('Level 25', 'Locked', false),
];

class CharacterPage extends ConsumerStatefulWidget {
  const CharacterPage({super.key});

  @override
  ConsumerState<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends ConsumerState<CharacterPage> {
  String _skillBranch = 'Health';
  int _selectedNode = 0;

  static const _branches = [
    'Health',
    'Knowledge',
    'Career',
    'Finance',
    'Bonds',
    'Craft',
    'Mind',
  ];

  @override
  Widget build(BuildContext context) {
    final prog = ref.watch(progressionStateProvider);
    final initials = ref.watch(initialsProvider);
    final nodes = _skillTree[_skillBranch] ?? [];
    final selectedNode = _selectedNode < nodes.length
        ? nodes[_selectedNode]
        : null;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screen),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.gutter),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: Gap.md),

                  // Identity row
                  Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroCard,
                          borderRadius: BorderRadius.circular(Radii.hero),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: Text(
                          initials,
                          style: AppType.heroLevel.copyWith(
                            color: AppColors.accent,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: Gap.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CLASS · SCHOLAR', style: AppType.metaLabel),
                            const SizedBox(height: 2),
                            Text(
                              'Disciplined Adventurer',
                              style: AppType.sheetTitle,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'LVL ${prog.level} · ${Formatters.thousands(prog.lifetimeXp)} LIFETIME XP',
                              style: AppType.eyebrow,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.xl),

                  // Section: Attributes
                  Text('Attributes', style: AppType.sectionTitle),
                  const SizedBox(height: Gap.md),

                  ..._attributes.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AttributeRow(
                        label: a.$1,
                        value: a.$2,
                        filled: (a.$2 / 5).round(),
                      ),
                    ),
                  ),

                  const SizedBox(height: Gap.xl),

                  // Section: Skill Branches
                  Text('Skill Branches', style: AppType.sectionTitle),
                  const SizedBox(height: Gap.md),

                  // Branch chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _branches.length,
                      separatorBuilder: (_, child) =>
                          const SizedBox(width: Gap.xs),
                      itemBuilder: (_, i) {
                        final branch = _branches[i];
                        final selected = branch == _skillBranch;
                        return CategoryChip(
                          label: branch,
                          selected: selected,
                          onTap: () => setState(() {
                            _skillBranch = branch;
                            _selectedNode = 0;
                          }),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Nodes row
                  Row(
                    children: List.generate(nodes.length, (i) {
                      final node = nodes[i];
                      final isSelected = i == _selectedNode;
                      final stateColor = _nodeStateColor(node.state);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedNode = i),
                          child: Container(
                            margin: EdgeInsets.only(
                              right: i < nodes.length - 1 ? 8 : 0,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(
                                Radii.trailCard,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.border,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Node circle
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: stateColor.$1,
                                    border: Border.all(color: stateColor.$2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    stateColor.$3,
                                    style: TextStyle(
                                      color: stateColor.$4,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  node.name,
                                  style: AppType.bodySmall.copyWith(
                                    color: node.state == 'Locked'
                                        ? AppColors.muted
                                        : AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  node.state.toUpperCase(),
                                  style: AppType.microLabel,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Node detail panel
                  if (selectedNode != null) ...[
                    const SizedBox(height: Gap.md),
                    _NodeDetailPanel(node: selectedNode),
                  ],

                  const SizedBox(height: Gap.xl),

                  // Section: Achievements
                  Text('Achievements', style: AppType.sectionTitle),
                  const SizedBox(height: Gap.md),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.8,
                    children: _achievements.map((a) {
                      final earned = a.$3;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: earned ? AppColors.accentSurface : null,
                          borderRadius: BorderRadius.circular(Radii.trailCard),
                          border: Border.all(
                            color: earned
                                ? AppColors.accentBorder
                                : AppColors.trackInactive,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  earned ? '✦' : '—',
                                  style: TextStyle(
                                    color: earned
                                        ? AppColors.accent
                                        : AppColors.muted,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    a.$1,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: earned
                                          ? AppColors.textPrimary
                                          : AppColors.muted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(a.$2, style: AppType.microLabel),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 100), // bottom nav clearance
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns (fill, border, glyph, textColor) for a skill node state.
  (Color, Color, String, Color) _nodeStateColor(
    String state,
  ) => switch (state) {
    'Mastered' => (AppColors.accent, AppColors.accent, '✦', AppColors.canvas),
    'Unlocked' => (
      AppColors.accentTrack,
      AppColors.accent,
      '●',
      AppColors.accent,
    ),
    'Available' => (Colors.transparent, AppColors.slate, '○', AppColors.slate),
    _ => (Colors.transparent, AppColors.trackInactive, '—', AppColors.muted),
  };
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.label,
    required this.value,
    required this.filled,
  });

  final String label;
  final int value;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 74, child: Text(label, style: AppType.metaLabel)),
        Expanded(
          child: XpTickBar(
            filled: filled,
            segments: 20,
            gap: 2,
            height: 8,
            radius: 1,
          ),
        ),
        const SizedBox(width: Gap.sm),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            style: AppType.value,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _NodeDetailPanel extends StatelessWidget {
  const _NodeDetailPanel({required this.node});

  final SkillNode node;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroCard,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: AppColors.accentBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(node.name, style: AppType.cardTitle),
              const SizedBox(width: Gap.sm),
              Text(node.state.toUpperCase(), style: AppType.eyebrow),
            ],
          ),
          const SizedBox(height: Gap.sm),
          Text(node.description, style: AppType.body),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              // Benefit pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  node.benefit,
                  style: AppType.metaLabel.copyWith(color: AppColors.accent),
                ),
              ),
              const SizedBox(width: Gap.sm),
              // Requirement pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${node.requirement} · ${node.xpCost}',
                  style: AppType.metaLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
