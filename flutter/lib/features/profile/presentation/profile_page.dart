import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../progression/application/progression_controller.dart';
import '../../progression/domain/xp_rules.dart';
import '../../settings/application/settings_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog = ref.watch(progressionStateProvider);
    final displayName = ref.watch(displayNameProvider);
    final initials = ref.watch(initialsProvider);
    final mode = ref.watch(difficultyModeProvider);

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
                  Text('Profile', style: AppType.screenTitle),

                  const SizedBox(height: Gap.xl),

                  // Identity row
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroCard,
                          borderRadius: BorderRadius.circular(Radii.panel),
                          border: Border.all(color: AppColors.accentBorder),
                        ),
                        child: Text(
                          initials,
                          style: AppType.heroLevel.copyWith(
                            color: AppColors.accent,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: Gap.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: AppType.sheetTitle),
                            const SizedBox(height: 2),
                            Text('Disciplined Adventurer', style: AppType.body),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.xl),

                  // Stat tiles
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileStat(
                          value: Formatters.thousands(prog.lifetimeXp),
                          label: 'LIFETIME XP',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: _ProfileStat(value: '87', label: 'QUESTS DONE'),
                      ),
                      const SizedBox(width: Gap.sm),
                      Expanded(
                        child: _ProfileStat(value: '3', label: 'BADGES'),
                      ),
                    ],
                  ),

                  const SizedBox(height: Gap.md),

                  // Streak freeze section
                  _StreakFreezeCard(
                    freezes: prog.streakFreezes,
                    canUse: prog.canUseStreakFreeze,
                    streak: prog.streak,
                    onUseFreeze: () => ref.read(progressionProvider.notifier).useStreakFreeze(),
                    onBuyFreeze: () => _showBuyFreezeSheet(context, ref),
                  ),

                  const SizedBox(height: Gap.xl),

                  // Settings list
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(Radii.panel),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _SettingsRow(
                          icon: Icons.dark_mode_outlined,
                          name: 'Appearance',
                          hint: 'Dark mode, theme',
                        ),
                        _SettingsRow(
                          icon: Icons.notifications_outlined,
                          name: 'Notifications',
                          hint: 'Reminders, alerts',
                        ),
                        _SettingsRow(
                          icon: Icons.signal_cellular_alt,
                          name: 'Difficulty',
                          hint: mode.label,
                          onTap: () =>
                              _showDifficultyPicker(context, ref, mode),
                        ),
                        _SettingsRow(
                          icon: Icons.lock_outline,
                          name: 'Privacy',
                          hint: 'Data & security',
                        ),
                        _SettingsRow(
                          icon: Icons.replay,
                          name: 'Replay intro',
                          hint: 'Run onboarding again',
                          onTap: () => ref
                              .read(settingsProvider.notifier)
                              .replayOnboarding(),
                        ),
                        _SettingsRow(
                          icon: Icons.person_outline,
                          name: 'Account',
                          hint: 'Email, password',
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Gap.xl),

                  // Footer
                  Center(
                    child: Text(
                      'LIFEQUEST 1.0 · LEVEL UP YOUR REAL LIFE',
                      style: AppType.microLabel.copyWith(
                        color: AppColors.faint,
                      ),
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

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppType.value.copyWith(
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

class _StreakFreezeCard extends StatelessWidget {
  const _StreakFreezeCard({
    required this.freezes,
    required this.canUse,
    required this.streak,
    required this.onUseFreeze,
    required this.onBuyFreeze,
  });

  final int freezes;
  final bool canUse;
  final int streak;
  final VoidCallback onUseFreeze;
  final VoidCallback onBuyFreeze;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('❄️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: Gap.sm),
              Text('Streak Freezes', style: AppType.cardTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(Radii.iconTile),
                ),
                child: Text(
                  '$freezes',
                  style: AppType.value.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          Text(
            'Protect your $streak-day streak if you miss a day.',
            style: AppType.bodySmall.copyWith(color: AppColors.slate),
          ),
          const SizedBox(height: Gap.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: canUse ? onUseFreeze : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: canUse ? AppColors.accent : AppColors.trackInactive,
                      borderRadius: BorderRadius.circular(Radii.button),
                    ),
                    child: Text(
                      'Use freeze',
                      style: AppType.buttonPrimary.copyWith(
                        color: canUse ? AppColors.canvas : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: GestureDetector(
                  onTap: onBuyFreeze,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.button),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: Text('Get more', style: AppType.buttonSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.name,
    required this.hint,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String name;
  final String hint;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {},
            highlightColor: AppColors.accentSurface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: AppColors.slate),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppType.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(hint, style: AppType.body),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: AppColors.borderHairline,
            indent: 17,
            endIndent: 17,
          ),
      ],
    );
  }
}

/// Live difficulty picker — changing it re-computes every reward immediately.  void _showDifficultyPicker(
  BuildContext context,
  WidgetRef ref,
  DifficultyMode current,
) {
  showGlassSheet(
    context,
    builder: (_) => GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DIFFICULTY SETS THE REWARD', style: AppType.eyebrow),
          const SizedBox(height: Gap.md),
          ...DifficultyMode.values.map((m) {
            final selected = m == current;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                AppHaptics.selection();
                ref.read(settingsProvider.notifier).setDifficulty(m);
                Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: Gap.sm),
                padding: const EdgeInsets.all(Pad.card),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accentSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.input),
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: AppType.cardTitle.copyWith(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(m.blurb, style: AppType.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '×${m.multiplier}',
                      style: AppType.metaLabel.copyWith(
                        color: selected ? AppColors.accent : AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    ),
  );
}

void _showBuyFreezeSheet(BuildContext context, WidgetRef ref) {
  showGlassSheet(
    context,
    builder: (_) => GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STREAK FREEZES', style: AppType.eyebrow),
          const SizedBox(height: Gap.md),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: AppColors.accentBorder),
            ),
            child: Row(
              children: [
                const Text('❄️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Streak Freeze', style: AppType.cardTitle),
                      const SizedBox(height: 4),
                      Text(
                        'Protects your streak if you miss a day. Use it before midnight!',
                        style: AppType.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          GestureDetector(
            onTap: () {
              ref.read(progressionProvider.notifier).addStreakFreeze();
              Navigator.of(context).pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(Radii.buttonLarge),
              ),
              child: Text('Get a Freeze (+1)', style: AppType.buttonPrimary),
            ),
          ),
          const SizedBox(height: Gap.sm),
          Text(
            'Earn freezes by completing weekly challenges or purchase them.',
            style: AppType.bodySmall.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    ),
  );
}
