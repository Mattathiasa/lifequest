import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Empty-state placeholder for tabs with no content.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title = 'Your adventure is waiting',
    this.message =
        'Nothing queued here yet. Add a quest and it lands on today\'s trail.',
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.hero),
        border: Border.all(
          color: AppColors.trackInactive,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accent-outlined ✦ tile
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: const Text(
              '✦',
              style: TextStyle(color: AppColors.accent, fontSize: 18),
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text(title, style: AppType.headline),
          const SizedBox(height: Gap.sm),
          Text(message, style: AppType.body, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: Gap.xl),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(Radii.button),
                ),
                child: Text(actionLabel!, style: AppType.buttonPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
