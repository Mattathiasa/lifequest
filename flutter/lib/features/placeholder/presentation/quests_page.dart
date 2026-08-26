import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/segment_tabs.dart';
import '../../focus/presentation/focus_run_sheet.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';
import 'create_quest_sheet.dart';

/// Quest board page — full backlog, filterable, with new-quest creation.
class QuestsPage extends ConsumerStatefulWidget {
  const QuestsPage({super.key});

  @override
  ConsumerState<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends ConsumerState<QuestsPage> {
  int _tabIndex = 0;
  String _category = 'All';

  static const _tabs = ['Today', 'Upcoming', 'Recurring', 'Completed'];
  static const _categories = [
    'All',
    'Health',
    'Learning',
    'Productivity',
    'Social',
    'Finance',
    'Mindfulness',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questListProvider);
    final activeCount = quests.where((q) => !q.done).length;

    // Filter quests
    final tab = _tabs[_tabIndex];
    final filtered = quests.where((q) {
      final scheduleMatch = switch (tab) {
        'Today' => q.schedule == QuestSchedule.today && !q.done,
        'Upcoming' => q.schedule == QuestSchedule.upcoming && !q.done,
        'Recurring' => q.schedule == QuestSchedule.recurring && !q.done,
        'Completed' => q.done,
        _ => true,
      };
      final catMatch = _category == 'All' || q.category.label == _category;
      return scheduleMatch && catMatch;
    }).toList();

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

                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Text('Quest board', style: AppType.screenTitle),
                      ),
                      Text(
                        '$activeCount ACTIVE · ${_category.toUpperCase()}',
                        style: AppType.metaLabel,
                      ),
                      const SizedBox(width: Gap.md),
                      GestureDetector(
                        onTap: () => _openCreateSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(Radii.iconTile),
                          ),
                          child: Text('New', style: AppType.buttonPrimary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.lg),

                  // Segment tabs
                  SegmentTabs(
                    tabs: _tabs,
                    activeIndex: _tabIndex,
                    onTap: (i) => setState(() => _tabIndex = i),
                  ),

                  const SizedBox(height: Gap.md),

                  // Category chips (horizontal scroll)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, s) => const SizedBox(width: Gap.xs),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        return CategoryChip(
                          label: cat,
                          selected: _category == cat,
                          onTap: () => setState(() => _category = cat),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: Gap.lg),

                  // Quest list or empty state
                  if (filtered.isEmpty)
                    EmptyState(
                      actionLabel: 'Create quest',
                      onAction: () => _openCreateSheet(context),
                    )
                  else
                    ...filtered.map(
                      (q) =>
                          _BoardQuestCard(quest: q, onTap: () => _openQuest(q)),
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

  void _openQuest(Quest quest) {
    showFocusSheet(context, quest: quest, autoStart: false);
  }

  void _openCreateSheet(BuildContext context) {
    showCreateQuestSheet(context);
  }
}

class _BoardQuestCard extends StatelessWidget {
  const _BoardQuestCard({required this.quest, required this.onTap});

  final Quest quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDone = quest.done;
    final diffColor = AppColors.difficulty[quest.difficulty.index];

    return GestureDetector(
      onTap: isDone ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Gap.sm),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Opacity(
          opacity: isDone ? 0.5 : 1.0,
          child: Row(
            children: [
              // Code tile
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceIcon,
                  borderRadius: BorderRadius.circular(Radii.iconTile),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Text(
                  quest.code,
                  style: AppType.code.copyWith(color: diffColor),
                ),
              ),
              const SizedBox(width: Gap.lg),
              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.name,
                      style: AppType.cardTitle.copyWith(
                        color: isDone ? AppColors.muted : AppColors.textPrimary,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quest.desc,
                      style: AppType.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quest.difficulty.numeral} ${quest.difficulty.label.toUpperCase()} · ${quest.time} · ${quest.due}',
                      style: AppType.metaLabel.copyWith(color: AppColors.faint),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.sm),
              // XP
              Text(
                '+${quest.xp}',
                style: AppType.value.copyWith(
                  color: isDone ? AppColors.muted : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
