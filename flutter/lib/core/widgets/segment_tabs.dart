import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../utils/haptics.dart';

/// Horizontal segment tabs (TODAY / UPCOMING / RECURRING / COMPLETED).
class SegmentTabs extends StatelessWidget {
  const SegmentTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    this.onTap,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(tabs.length, (i) {
            final isActive = i == activeIndex;
            return GestureDetector(
              onTap: () {
                AppHaptics.selection();
                onTap?.call(i);
              },
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < tabs.length - 1 ? Gap.sm : 0,
                ),
                child: Text(
                  tabs[i].toUpperCase(),
                  style: AppType.metaLabel.copyWith(
                    color: isActive ? AppColors.textPrimary : AppColors.muted,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: Gap.sm),
        // Underline
        AnimatedAlign(
          duration: const Duration(milliseconds: 230),
          alignment: Alignment(
            -1 + (2 * activeIndex / (tabs.length - 1).clamp(1, 999)),
            0,
          ),
          child: Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}
