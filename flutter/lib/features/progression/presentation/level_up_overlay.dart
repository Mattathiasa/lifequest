import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';

/// Full-bleed level-up overlay: dark-to-olive scrim, old → new level,
/// "Your character has grown stronger.", new branch pill.
/// Queued 1400ms after XP award, visible 2600ms. Medium haptic.
class LevelUpOverlay extends StatefulWidget {
  const LevelUpOverlay({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.onDismiss,
  });

  final int oldLevel;
  final int newLevel;
  final VoidCallback onDismiss;

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    AppHaptics.levelUp();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDismiss();
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xF505070A), Color(0xF51A2210)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Eyebrow
              Text(
                'LEVEL UP',
                style: AppType.eyebrow.copyWith(letterSpacing: 3),
              ),
              const SizedBox(height: Gap.xl),
              // Old level → New level
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.oldLevel}',
                    style: AppType.timer.copyWith(
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                      color: AppColors.slate,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Gap.md),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: AppColors.slate,
                    ),
                  ),
                  Text('${widget.newLevel}', style: AppType.levelUpNumber),
                ],
              ),
              const SizedBox(height: Gap.lg),
              // Description
              Text(
                'Your character has grown stronger.',
                style: AppType.body.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: Gap.xl),
              // New branch pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(color: AppColors.accent, fontSize: 12),
                    ),
                    const SizedBox(width: Gap.xs),
                    Text(
                      'New branch unlocked · Focus',
                      style: AppType.metaLabel.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
