import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Animated tick-bar used for XP display and the focus timer.
///
/// [filled] segments are accent; the rest are [AppColors.trackInactive].
/// Each segment animates independently when [animate] is true.
class XpTickBar extends StatelessWidget {
  const XpTickBar({
    super.key,
    required this.filled,
    this.segments = 20,
    this.gap = 3,
    this.height = 6,
    this.radius = 3,
    this.animate = true,
  });

  final int filled;
  final int segments;
  final double gap;
  final double height;
  final double radius;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = gap * (segments - 1);
        final tickWidth = segments > 0
            ? (constraints.maxWidth - totalGap) / segments
            : 0.0;

        return Row(
          children: List.generate(segments, (i) {
            final isFilled = i < filled;
            return Padding(
              padding: EdgeInsets.only(right: i < segments - 1 ? gap : 0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: isFilled ? 1 : 0),
                duration: animate
                    ? const Duration(milliseconds: 480)
                    : Duration.zero,
                curve: Curves.easeOut,
                builder: (_, t, child) => Container(
                  width: tickWidth > 0 ? tickWidth : 6,
                  height: height,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      AppColors.trackInactive,
                      AppColors.accent,
                      t,
                    ),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
