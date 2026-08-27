import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../progression/application/progression_controller.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog = ref.watch(progressionStateProvider);

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
                          value: '86%',
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
                        child: _StatPanel(value: '31', label: 'RECORD'),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.xl),

                  // Weekly XP panel
                  _PanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('4,180 TOTAL', style: AppType.eyebrow),
                        const SizedBox(height: Gap.md),
                        const _WeeklyXpChart(),
                      ],
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Consistency heatmap
                  _PanelCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _ConsistencyGrid(),
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
                        _XpBreakdown(
                          label: 'Health',
                          pct: 38,
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 10),
                        _XpBreakdown(
                          label: 'Learning',
                          pct: 22,
                          color: AppColors.accent.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 10),
                        _XpBreakdown(
                          label: 'Productivity',
                          pct: 19,
                          color: AppColors.slate,
                        ),
                        const SizedBox(height: 10),
                        _XpBreakdown(
                          label: 'Mindfulness',
                          pct: 13,
                          color: AppColors.slate.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 10),
                        _XpBreakdown(
                          label: 'Social',
                          pct: 8,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Gap.md),

                  // Coach card
                  Container(
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
                          'Your health quests are carrying the load. Try adding one Social quest this week to round things out.',
                          style: AppType.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
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
  const _WeeklyXpChart();

  static const _data = [420, 610, 380, 720, 540, 910, 600];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxVal = _data.reduce((a, b) => a > b ? a : b);
    final bestIdx = _data.indexOf(maxVal);

    return Column(
      children: [
        // Bars
        SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final h = (_data[i] / maxVal) * 112;
              final isBest = i == bestIdx;
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
            final isBest = i == bestIdx;
            return Expanded(
              child: Text(
                _days[i],
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
  const _ConsistencyGrid();

  // 14 columns × 3 rows, with random-ish intensity for mock data
  static const _intensities = [
    [
      0.0,
      0.75,
      0.15,
      1.0,
      0.75,
      0.0,
      0.15,
      1.0,
      0.75,
      0.15,
      0.0,
      1.0,
      0.75,
      0.15,
    ],
    [
      0.15,
      1.0,
      0.75,
      0.0,
      0.15,
      1.0,
      0.75,
      0.15,
      0.0,
      1.0,
      0.75,
      0.15,
      0.0,
      0.75,
    ],
    [
      0.75,
      0.15,
      0.0,
      0.75,
      1.0,
      0.15,
      0.0,
      0.75,
      1.0,
      0.15,
      0.0,
      0.75,
      1.0,
      0.15,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _intensities.map((row) {
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
