import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/quest_card.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../../core/widgets/trail_node.dart';
import '../../../core/widgets/xp_tick_bar.dart';
import '../../focus/presentation/focus_run_sheet.dart';
import '../../progression/application/progression_controller.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';
import '../../settings/application/settings_controller.dart';

/// Trail (Home) screen — "where am I in today's journey".
class TrailPage extends ConsumerStatefulWidget {
  const TrailPage({super.key});

  @override
  ConsumerState<TrailPage> createState() => _TrailPageState();
}

class _TrailPageState extends ConsumerState<TrailPage> {
  final bool _showDailyChallenge = true;
  bool _sideQuestAccepted = false;

  @override
  void initState() {
    super.initState();
    // Load quests after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questListProvider);
    final prog = ref.watch(progressionStateProvider);
    final mode = ref.watch(difficultyModeProvider);
    final displayName = ref.watch(displayNameProvider);
    final initials = ref.watch(initialsProvider);
    final firstName = displayName.split(RegExp(r'\s+')).first;

    final todayQuests = quests
        .where((q) => q.schedule == QuestSchedule.today)
        .toList();
    final clearedCount = todayQuests.where((q) => q.done).length;
    final totalCount = todayQuests.length;

    // Find the first undone quest (live quest)
    final liveIndex = todayQuests.indexWhere((q) => !q.done);
    final liveQuest = liveIndex != -1 ? todayQuests[liveIndex] : null;

    // Compute stats
    final pct = totalCount > 0 ? (clearedCount * 100 ~/ totalCount) : 0;
    final weekPct = 86; // Mock — real data from Progress later
    final need = XpRules.need(prog.level);
    final filledTicks = XpRules.filledTicks(prog.level, prog.xpIntoLevel);
    final xpToNext = need - prog.xpIntoLevel;

    // Greeting context
    final now = DateTime.now();
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final monthNames = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dateLine =
        '${dayNames[now.weekday - 1]} ${now.day} ${monthNames[now.month - 1]} · DAY ${prog.streak}';
    final greeting = _timeGreeting();
    final nextUp = liveQuest != null
        ? 'Next up: ${liveQuest.name.toLowerCase()}.'
        : 'Trail cleared. Rest is part of it.';

    // Trail gradient progress
    final trailPct = totalCount > 0 ? clearedCount / totalCount : 0.0;
    final lastCleared = prog.lastClearedDay;
    final claimedToday =
        lastCleared != null &&
        lastCleared.year == now.year &&
        lastCleared.month == now.month &&
        lastCleared.day == now.day;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screen),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.gutter,
              ).copyWith(bottom: 26),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: Gap.md),

                  // ── Greeting row ──
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateLine, style: AppType.metaLabel),
                            const SizedBox(height: 2),
                            Text(
                              '$greeting, $firstName',
                              style: AppType.screenTitle,
                            ),
                            const SizedBox(height: 2),
                            Text(nextUp, style: AppType.body),
                          ],
                        ),
                      ),
                      // Avatar tile
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131A24),
                          borderRadius: BorderRadius.circular(Radii.iconTile),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Text(
                          initials,
                          style: AppType.value.copyWith(
                            color: AppColors.accent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.xl),

                  // ── Hero level card ──
                  _HeroLevelCard(
                    level: prog.level,
                    xp: prog.xpIntoLevel,
                    need: need,
                    filledTicks: filledTicks,
                    xpToNext: xpToNext,
                    streak: prog.streak,
                    todayPct: pct,
                    weekPct: weekPct,
                  ),

                  const SizedBox(height: Gap.xl),

                  // ── Section head ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Today's trail",
                          style: AppType.sectionTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      Text(
                        '$clearedCount of $totalCount cleared',
                        style: AppType.metaLabel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.md),

                  // ── The trail ──
                  ...List.generate(todayQuests.length, (i) {
                    final q = todayQuests[i];
                    final state = q.done
                        ? 'cleared'
                        : (q == liveQuest ? 'live' : 'ahead');
                    final label = (i + 1).toString().padLeft(2, '0');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: Gap.md),
                      child: _TrailRow(
                        nodeLabel: label,
                        nodeState: state,
                        quest: q,
                        mode: mode,
                        isFirst: i == 0,
                        isLast: i == todayQuests.length - 1,
                        trailPct: trailPct,
                        index: i,
                        total: todayQuests.length,
                        onStartFocus: q == liveQuest
                            ? () => _openFocusSheet(q)
                            : null,
                        onDone: q == liveQuest ? () => _completeQuest(q) : null,
                        onTap: () => _openFocusSheet(q),
                      ),
                    );
                  }),

                  // ── Reward node ──
                  _RewardNode(
                    allCleared: totalCount > 0 && clearedCount == totalCount,
                    claimed: claimedToday,
                    streak: prog.streak,
                    remaining: totalCount - clearedCount,
                    onClaim:
                        totalCount > 0 &&
                            clearedCount == totalCount &&
                            !claimedToday
                        ? _claimDayBonus
                        : null,
                  ),

                  const SizedBox(height: Gap.lg),

                  // ── Side quest card ──
                  if (_showDailyChallenge)
                    _SideQuestCard(
                      accepted: _sideQuestAccepted,
                      onAccept: () => _acceptSideQuest(),
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

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openFocusSheet(Quest quest) {
    showFocusSheet(context, quest: quest, autoStart: false);
  }

  void _completeQuest(Quest quest) {
    ref.read(progressionProvider.notifier).completeQuest(quest);
  }

  void _claimDayBonus() {
    ref.read(progressionProvider.notifier).claimDayBonus();
  }

  void _acceptSideQuest() {
    setState(() => _sideQuestAccepted = true);
    ref.read(progressionProvider.notifier).acceptSideQuest();
  }
}

// ── Hero level card ──────────────────────────────────────────────────────────

class _HeroLevelCard extends StatelessWidget {
  const _HeroLevelCard({
    required this.level,
    required this.xp,
    required this.need,
    required this.filledTicks,
    required this.xpToNext,
    required this.streak,
    required this.todayPct,
    required this.weekPct,
  });

  final int level;
  final int xp;
  final int need;
  final int filledTicks;
  final int xpToNext;
  final int streak;
  final int todayPct;
  final int weekPct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Pad.cardLoose),
      decoration: BoxDecoration(
        gradient: AppColors.heroCard,
        borderRadius: BorderRadius.circular(Radii.hero),
        border: Border.all(color: AppColors.trackInactive),
      ),
      child: Column(
        children: [
          // Level row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$level', style: AppType.heroLevel),
              const SizedBox(width: Gap.xs),
              Text('LEVEL', style: AppType.metaLabel),
              const Spacer(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${Formatters.thousands(xp)} / ${Formatters.thousands(need)} XP',
                        style: AppType.value.copyWith(color: AppColors.accent),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.thousands(xpToNext)} XP to next',
                      style: AppType.metaLabel,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: Gap.md),

          // XP tick bar
          XpTickBar(filled: filledTicks, segments: 20),

          const SizedBox(height: Gap.md),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatTile(label: 'STREAK', value: '$streak days'),
              StatTile(
                label: 'TODAY',
                value: '$todayPct%',
                color: AppColors.accent,
              ),
              StatTile(label: 'THIS WEEK', value: '$weekPct%'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Trail row (node + card + rail) ──────────────────────────────────────────

class _TrailRow extends StatelessWidget {
  const _TrailRow({
    required this.nodeLabel,
    required this.nodeState,
    required this.quest,
    required this.mode,
    required this.isFirst,
    required this.isLast,
    required this.trailPct,
    required this.index,
    required this.total,
    this.onStartFocus,
    this.onDone,
    this.onTap,
  });

  final String nodeLabel;
  final String nodeState;
  final Quest quest;
  final DifficultyMode mode;
  final bool isFirst;
  final bool isLast;
  final double trailPct;
  final int index;
  final int total;
  final VoidCallback? onStartFocus;
  final VoidCallback? onDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = quest.category.uppercase;
    final meta = '$category · ${quest.time}';
    final xpLabel = '+${XpRules.reward(quest.difficulty, mode)}';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rail + node
          SizedBox(
            width: 51,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Rail
                if (!isFirst || !isLast)
                  Positioned(
                    top: 34,
                    bottom: isLast ? 52 : 0,
                    left: 24,
                    width: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.accent,
                            AppColors.accent,
                            AppColors.trackInactive,
                            AppColors.trackInactive,
                          ],
                          stops: [
                            0,
                            trailPct.clamp(0, 1),
                            trailPct.clamp(0, 1),
                            1,
                          ],
                        ),
                      ),
                    ),
                  ),
                // Node
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: TrailNode(label: nodeLabel, state: nodeState),
                ),
              ],
            ),
          ),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: QuestCard(
                code: quest.code,
                name: quest.name,
                meta: meta,
                xpLabel: xpLabel,
                state: nodeState,
                onStartFocus: onStartFocus,
                onDone: onDone,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reward node ─────────────────────────────────────────────────────────────

class _RewardNode extends StatelessWidget {
  const _RewardNode({
    required this.allCleared,
    required this.claimed,
    required this.streak,
    required this.remaining,
    this.onClaim,
  });

  final bool allCleared;
  final bool claimed;
  final int streak;
  final int remaining;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Node
          SizedBox(
            width: 51,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Dashed node
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: allCleared ? AppColors.accent : Colors.transparent,
                      border: Border.all(
                        color: allCleared
                            ? AppColors.accent
                            : AppColors.borderStrong,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '✦',
                      style: TextStyle(
                        color: allCleared ? AppColors.canvas : AppColors.slate,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card
          Expanded(
            child: GestureDetector(
              onTap: onClaim,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 7),
                padding: const EdgeInsets.all(Pad.trailCard),
                decoration: BoxDecoration(
                  color: allCleared ? AppColors.accentSurface : null,
                  borderRadius: BorderRadius.circular(Radii.trailCard),
                  border: Border.all(
                    color: allCleared
                        ? AppColors.accentBorder
                        : AppColors.trackInactive,
                    style: BorderStyle.solid,
                  ),
                ),
                child: allCleared
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            claimed
                                ? 'Day cleared · +250 bonus XP'
                                : 'Claim +250 bonus XP',
                            style: AppType.trailTitle.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            claimed
                                ? 'CLAIMED · STREAK EXTENDED TO $streak'
                                : 'TAP TO CLAIM',
                            style: AppType.metaLabel.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clear the trail for +250 XP',
                            style: AppType.trailTitle.copyWith(
                              color: AppColors.slate,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$remaining QUESTS REMAINING',
                            style: AppType.metaLabel,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Side quest card ─────────────────────────────────────────────────────────

class _SideQuestCard extends StatefulWidget {
  const _SideQuestCard({required this.accepted, required this.onAccept});

  final bool accepted;
  final VoidCallback? onAccept;

  @override
  State<_SideQuestCard> createState() => _SideQuestCardState();
}

class _SideQuestCardState extends State<_SideQuestCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _drift = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accepted = widget.accepted;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.hero),
      child: Container(
        padding: const EdgeInsets.all(Pad.cardLoose),
        decoration: BoxDecoration(
          gradient: AppColors.sideQuestCard,
          borderRadius: BorderRadius.circular(Radii.hero),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Drifting accent blob, top-right (±6px over 6s)
            Positioned(
              top: -34,
              right: -24,
              child: AnimatedBuilder(
                animation: _drift,
                builder: (_, _) => Transform.translate(
                  offset: Offset(0, _drift.value * 12 - 6),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withValues(alpha: 0.18),
                          AppColors.accent.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'SIDE QUEST · RARE',
                        style: AppType.eyebrow,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Gap.sm),
                    Text('expires 23:59', style: AppType.metaLabel),
                  ],
                ),
                const SizedBox(height: Gap.md),
                // Headline
                Text(
                  'Do the one thing you\'ve been avoiding.',
                  style: AppType.headline,
                ),
                const SizedBox(height: Gap.lg),
                // Footer
                Row(
                  children: [
                    Text(
                      '+300',
                      style: AppType.statValue.copyWith(
                        color: AppColors.accent,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: GestureDetector(
                        onTap: accepted ? null : widget.onAccept,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: accepted
                                ? Colors.transparent
                                : AppColors.accent,
                            borderRadius: BorderRadius.circular(Radii.button),
                            border: accepted
                                ? Border.all(color: AppColors.accent)
                                : null,
                          ),
                          child: Text(
                            accepted ? 'Accepted' : 'Accept',
                            style: AppType.buttonPrimary.copyWith(
                              color: accepted
                                  ? AppColors.accent
                                  : AppColors.canvas,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
