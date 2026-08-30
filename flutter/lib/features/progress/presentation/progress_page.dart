import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../progression/application/progression_controller.dart';
import '../../progression/domain/stats.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog = ref.watch(progressionStateProvider);
    final history = ref.watch(historyProvider);
    final now = DateTime.now();

    // Compute real stats from history
    final weeklyXp = GameStats.weeklyXp(history, now);
    final totalWeeklyXp = weeklyXp.fold<int>(0, (sum, v) => sum + v);
    final dailyCounts = GameStats.dailyCounts(history, now, days: 42);
    final xpByCategory = GameStats.xpByCategory(history);
    final totalXp = xpByCategory.values.fold<int>(0, (sum, v) => sum + v);

    // Compute completion rate from daily counts (days with quests done)
    final daysActive = dailyCounts.where((c) => c > 0).length;
    final completionRate = daysActive > 0
        ? ((daysActive / dailyCounts.length) * 100).round()
        : 0;

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
                  Text('Progress', style: AppType.screenTitle),

                  const SizedBox(height: Gap.xl),

                  // Stat tiles row
                  Row(
                    children: [
                      Expanded(
                        child: _StatPanel(
                          value: '$completionRate%',
                          label: 'COMPLETION',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: _StatPanel(
                          value: '${prog.streak}',
                          label: 'STREAK',
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: _StatPanel(
                          value: '${prog.recordStreak}',
                          label: 'RECORD',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.xl),

                  // Weekly XP panel
                  _PanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Formatters.thousands(totalWeeklyXp)} TOTAL',
                          style: AppType.eyebrow,
                        ),
                        const SizedBox(height: Gap.md),
                        _WeeklyXpChart(data: weeklyXp),
                      ],
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Consistency heatmap
                  _PanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ConsistencyGrid(dailyCounts: dailyCounts),
                        const SizedBox(height: Gap.sm),
                        Text(
                          'LAST 6 WEEKS · LIME = QUESTS CLEARED',
                          style: AppType.microLabel,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Where your XP goes
                  _PanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WHERE YOUR XP GOES', style: AppType.eyebrow),
                        const SizedBox(height: Gap.md),
                        if (totalXp > 0) ...[
                          _XpBreakdown(
                            label: 'Health',
                            pct: _catPct(xpByCategory, 'health', totalXp),
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 10),
                          _XpBreakdown(
                            label: 'Learning',
                            pct: _catPct(xpByCategory, 'learning', totalXp),
                            color: AppColors.accent.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 10),
                          _XpBreakdown(
                            label: 'Productivity',
                            pct: _catPct(xpByCategory, 'productivity', totalXp),
                            color: AppColors.slate,
                          ),
                          const SizedBox(height: 10),
                          _XpBreakdown(
                            label: 'Mindfulness',
                            pct: _catPct(xpByCategory, 'mindfulness', totalXp),
                            color: AppColors.slate.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 10),
                          _XpBreakdown(
                            label: 'Social',
                            pct: _catPct(xpByCategory, 'social', totalXp),
                            color: AppColors.muted,
                          ),
                        ] else
                          Text(
                            'Complete quests to see your XP breakdown',
                            style: AppType.body,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Coach card
                  _CoachCard(
                    xpByCategory: xpByCategory,
                    totalXp: totalXp,
                    streak: prog.streak,
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

  int _catPct(Map<dynamic, int> xpByCategory, String category, int totalXp) {
    if (totalXp == 0) return 0;
    final key = xpByCategory.keys.firstWhere(
      (k) => k.name == category,
      orElse: () => xpByCategory.keys.first,
    );
    final catXp = xpByCategory[key] ?? 0;
    return totalXp > 0 ? ((catXp / totalXp) * 100).round() : 0;
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppType.statValue.copyWith(
              color: color ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppType.metaLabel),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _WeeklyXpChart extends StatelessWidget {
  const _WeeklyXpChart({required this.data});

  final List<int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((v) => v == 0)) {
      return SizedBox(
        height: 112,
        child: Center(
          child: Text(
            'No XP data yet',
            style: AppType.body,
          ),
        ),
      );
    }

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final bestIdx = data.indexOf(maxVal);
    final labels = GameStats.weekdayLabels(DateTime.now());

    return Column(
      children: [
        // Bars
        SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = maxVal > 0 ? (data[i] / maxVal) * 112 : 0.0;
              final isBest = i == bestIdx && data[i] > 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: h),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (_, v, child) => Container(
                      height: v,
                      decoration: BoxDecoration(
                        color: isBest
                            ? AppColors.accent
                            : AppColors.trackInactive,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: Gap.xs),
        // Day labels
        Row(
          children: List.generate(7, (i) {
            final isBest = i == bestIdx && data[i] > 0;
            return Expanded(
              child: Text(
                labels[i],
                style: AppType.metaLabel.copyWith(
                  color: isBest ? AppColors.accent : AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ConsistencyGrid extends StatelessWidget {
  const _ConsistencyGrid({required this.dailyCounts});

  final List<int> dailyCounts;

  @override
  Widget build(BuildContext context) {
    // Convert daily counts to intensity grid (14 columns × 3 rows)
    final intensities = <List<double>>[];
    for (var row = 0; row < 3; row++) {
      final rowData = <double>[];
      for (var col = 0; col < 14; col++) {
        final idx = row * 14 + col;
        if (idx < dailyCounts.length) {
          final count = dailyCounts[idx];
          // Map count to intensity: 0=none, 1-2=low, 3-4=medium, 5+=high
          final intensity = count == 0
              ? 0.0
              : count <= 2
                  ? 0.15
                  : count <= 4
                      ? 0.75
                      : 1.0;
          rowData.add(intensity);
        } else {
          rowData.add(0.0);
        }
      }
      intensities.add(rowData);
    }

    return Column(
      children: intensities.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: row.map((intensity) {
              return Expanded(
                child: Container(
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: intensity == 0
                        ? AppColors.surfaceIcon
                        : AppColors.accent.withValues(alpha: intensity),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _XpBreakdown extends StatelessWidget {
  const _XpBreakdown({
    required this.label,
    required this.pct,
    required this.color,
  });

  final String label;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppType.bodySmall),
            Text('$pct%', style: AppType.metaLabel),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (_, constraints) {
            return Container(
              height: 5,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.trackInactive,
                borderRadius: BorderRadius.circular(2.5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: pct / 100,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.xpByCategory,
    required this.totalXp,
    required this.streak,
  });

  final Map<dynamic, int> xpByCategory;
  final int totalXp;
  final int streak;

  @override
  Widget build(BuildContext context) {
    // Find the dominant category
    String dominantCategory = 'Health';
    int maxXP = 0;
    for (final entry in xpByCategory.entries) {
      if (entry.value > maxXP) {
        maxXP = entry.value;
        dominantCategory = entry.key.label;
      }
    }

    // Find the weakest category
    String weakestCategory = 'Social';
    int minXP = totalXp;
    for (final entry in xpByCategory.entries) {
      if (entry.value < minXP) {
        minXP = entry.value;
        weakestCategory = entry.key.label;
      }
    }

    // Generate coach message
    String message;
    if (totalXp == 0) {
      message =
          'Start completing quests to get personalized coaching recommendations.';
    } else if (dominantCategory == weakestCategory) {
      message =
          'Great focus on $dominantCategory! Try diversifying your quests to build well-rounded skills.';
    } else {
      message =
          'Your $dominantCategory quests are carrying the load. Try adding one $weakestCategory quest this week to round things out.';
    }

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
          Text('COACH', style: AppType.eyebrow),
          const SizedBox(height: Gap.sm),
          Text(
            message,
            style: AppType.body.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
