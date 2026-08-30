import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/navigation/nav_providers.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/segment_tabs.dart';
import '../../focus/presentation/focus_run_sheet.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';
import '../../settings/application/settings_controller.dart';
import 'create_quest_sheet.dart';

/// Quest board page — full backlog, filterable, with new-quest creation.
class QuestsPage extends ConsumerStatefulWidget {
  const QuestsPage({super.key});

  @override
  ConsumerState<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends ConsumerState<QuestsPage> {
  String _category = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

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
    final questNotifier = ref.watch(questListProvider.notifier);
    final mode = ref.watch(difficultyModeProvider);
    final tabIndex = ref.watch(boardTabProvider);
    final activeCount = quests.where((q) => !q.done).length;
    final isLoading = questNotifier.isLoading;
    final error = questNotifier.error;

    // Filter quests
    final tab = _tabs[tabIndex];
    final filtered = quests.where((q) {
      final scheduleMatch = switch (tab) {
        'Today' => q.schedule == QuestSchedule.today && !q.done,
        'Upcoming' => q.schedule == QuestSchedule.upcoming && !q.done,
        'Recurring' => q.schedule == QuestSchedule.recurring && !q.done,
        'Completed' => q.done,
        _ => true,
      };
      final catMatch = _category == 'All' || q.category.label == _category;
      final searchMatch = _searchQuery.isEmpty ||
          q.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          q.desc.toLowerCase().contains(_searchQuery.toLowerCase());
      return scheduleMatch && catMatch && searchMatch;
    }).toList();

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screen),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.accent,
          backgroundColor: AppColors.surface,
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
                    activeIndex: tabIndex,
                    onTap: (i) => ref.read(boardTabProvider.notifier).state = i,
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

                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(Radii.input),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppType.body.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search quests...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.muted,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: AppColors.muted,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Loading state
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    )

                  // Error state
                  else if (error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Radii.card),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: Text(
                              error,
                              style: AppType.body.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    )

                  // Quest list or empty state
                  else if (filtered.isEmpty)
                    EmptyState(
                      actionLabel: 'Create quest',
                      onAction: () => _openCreateSheet(context),
                    )
                  else
                    ...filtered.map(
                      (q) => _BoardQuestCard(
                        quest: q,
                        mode: mode,
                        onTap: () => _openQuest(q),
                        onEdit: () => _openEditSheet(q),
                        onDelete: () => _confirmDelete(q),
                      ),
                    ),

                  const SizedBox(height: 100), // bottom nav clearance
                ],
              ),
            ),
          ],
        ),
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

  void _openEditSheet(Quest quest) {
    showCreateQuestSheet(context, quest: quest);
  }

  Future<void> _refresh() async {
    await ref.read(questListProvider.notifier).load();
  }

  void _confirmDelete(Quest quest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sheetTop,
        title: Text('Delete quest?', style: AppType.screenTitle),
        content: Text(
          'This will permanently remove "${quest.name}".',
          style: AppType.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppType.buttonSecondary),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(questListProvider.notifier).delete(quest.id);
            },
            child: Text(
              'Delete',
              style: AppType.buttonSecondary.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardQuestCard extends StatelessWidget {
  const _BoardQuestCard({
    required this.quest,
    required this.mode,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Quest quest;
  final DifficultyMode mode;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDone = quest.done;
    final diffColor = AppColors.difficulty[quest.difficulty.index];
    final reward = XpRules.reward(quest.difficulty, mode);

    return GestureDetector(
      onTap: isDone ? null : onTap,
      onLongPress: isDone ? null : onDelete,
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
              // XP + action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+$reward',
                    style: AppType.value.copyWith(
                      color: isDone ? AppColors.muted : AppColors.accent,
                    ),
                  ),
                  if (!isDone) ...[
                    const SizedBox(width: Gap.sm),
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: Gap.xs),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
