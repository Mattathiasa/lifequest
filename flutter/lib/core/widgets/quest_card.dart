import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A quest card for the trail view.
///
/// Shows code tile, name, meta, XP, and optionally action buttons for the
/// live quest. Cleared quests render at reduced opacity with a strikethrough.
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.code,
    required this.name,
    required this.meta,
    required this.xpLabel,
    required this.state, // 'cleared', 'live', 'ahead'
    this.onStartFocus,
    this.onDone,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final String code;
  final String name;
  final String meta;
  final String xpLabel;
  final String state;
  final VoidCallback? onStartFocus;
  final VoidCallback? onDone;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isCleared = state == 'cleared';
    final isLive = state == 'live';

    return GestureDetector(
      onTap: isLive ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(Pad.trailCard),
        decoration: BoxDecoration(
          gradient: isLive ? AppColors.liveCard : null,
          color: isLive ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.trailCard),
          border: Border.all(
            color: isLive ? AppColors.accentBorder : AppColors.border,
          ),
        ),
        child: Opacity(
          opacity: isCleared ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Code tile
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceIcon,
                      borderRadius: BorderRadius.circular(Radii.iconTile),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: Text(
                      code,
                      style: AppType.code.copyWith(color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: Gap.lg),
                  // Name + meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppType.trailTitle.copyWith(
                            color: isCleared
                                ? AppColors.muted
                                : AppColors.textPrimary,
                            decoration: isCleared
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(meta.toUpperCase(), style: AppType.metaLabel),
                      ],
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  // XP + action buttons
                  if (onEdit != null || onDelete != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        if (onDelete != null)
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        const SizedBox(width: Gap.sm),
                      ],
                    )
                  else
                    Text(
                      xpLabel,
                      style: AppType.value.copyWith(
                        color: isCleared ? AppColors.muted : AppColors.accent,
                      ),
                    ),
                ],
              ),
              // Action buttons — live card only
              if (isLive && (onStartFocus != null || onDone != null)) ...[
                const SizedBox(height: Gap.md),
                Row(
                  children: [
                    if (onStartFocus != null)
                      Expanded(
                        child: GestureDetector(
                          onTap: onStartFocus,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(Radii.button),
                            ),
                            child: Text(
                              'Start focus',
                              style: AppType.buttonPrimary,
                            ),
                          ),
                        ),
                      ),
                    if (onStartFocus != null && onDone != null)
                      const SizedBox(width: Gap.sm),
                    if (onDone != null)
                      GestureDetector(
                        onTap: onDone,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Radii.button),
                            border: Border.all(color: AppColors.borderStrong),
                          ),
                          child: Text('Done', style: AppType.buttonSecondary),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
