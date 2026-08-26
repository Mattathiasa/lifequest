import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Bottom-sheet chrome: grab handle, scrim, slide-up animation.
///
/// Wraps [child] in a styled bottom sheet with:
/// - 34 top radius
/// - sheet gradient background
/// - 38×4 grab handle
/// - scrim at canvas 86% with blur
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Pad.sheetTop),
            // Grab handle
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.faint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Gap.lg),
            Flexible(
              child: Padding(
                padding:
                    padding ??
                    const EdgeInsets.symmetric(horizontal: Pad.sheetH),
                child: child,
              ),
            ),
            SizedBox(height: Pad.sheetBottom),
          ],
        ),
      ),
    );
  }
}

/// Shows a [GlassSheet] as a modal bottom sheet with scrim + blur.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: AppColors.canvas.withValues(alpha: 0.86),
    transitionDuration: const Duration(milliseconds: 340),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: const Cubic(0.22, 1, 0.36, 1),
      );
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
    pageBuilder: (ctx, anim, secondary) =>
        Align(alignment: Alignment.bottomCenter, child: builder(ctx)),
  );
}
