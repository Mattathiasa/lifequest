import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';

/// Full-screen quest-complete overlay: checkmark square, flying XP, name.
/// Auto-dismisses after 1700ms. Fires a light haptic on open.
class QuestCompleteOverlay extends StatefulWidget {
  const QuestCompleteOverlay({
    super.key,
    required this.xp,
    required this.name,
    required this.onDismiss,
  });

  final int xp;
  final String name;
  final VoidCallback onDismiss;

  @override
  State<QuestCompleteOverlay> createState() => _QuestCompleteOverlayState();
}

class _QuestCompleteOverlayState extends State<QuestCompleteOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    AppHaptics.complete();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
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
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accent square with checkmark
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                size: 40,
                color: AppColors.canvas,
                weight: 300,
              ),
            ),
            const SizedBox(height: Gap.lg),
            // QUEST COMPLETE
            Text('QUEST COMPLETE', style: AppType.eyebrow),
            const SizedBox(height: Gap.sm),
            // Flying XP value
            _FlyingXp(xp: widget.xp, animation: _ctrl),
            const SizedBox(height: Gap.sm),
            // Quest name
            Text(widget.name, style: AppType.body),
          ],
        ),
      ),
    );
  }
}

/// XP value that flies up 110px while scaling to 0.6 and fading.
/// Delayed by 300ms, duration 1300ms.
class _FlyingXp extends StatelessWidget {
  const _FlyingXp({required this.xp, required this.animation});

  final int xp;
  final AnimationController animation;

  @override
  Widget build(BuildContext context) {
    // 300ms delay, then 1300ms flight
    final delayed = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.176, 1.0, curve: Curves.ease),
      ),
    );

    return AnimatedBuilder(
      animation: delayed,
      builder: (_, child) {
        final t = delayed.value;
        // Translate up 110px, scale down to 0.6, fade out
        final offset = -110.0 * t;
        final scale = 1.0 - 0.4 * t;
        final opacity = (1.0 - t).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Text(
                '+${Formatters.thousands(xp)}',
                style: AppType.xpFlash,
              ),
            ),
          ),
        );
      },
    );
  }
}
