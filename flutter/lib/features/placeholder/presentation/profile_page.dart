import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../progression/application/progression_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
                          'MA',
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
                            Text('Matt Abraham', style: AppType.sheetTitle),
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
                          hint: 'Balanced',
                        ),
                        _SettingsRow(
                          icon: Icons.lock_outline,
                          name: 'Privacy',
                          hint: 'Data & security',
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.name,
    required this.hint,
    this.showDivider = true,
  });

  final IconData icon;
  final String name;
  final String hint;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
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
