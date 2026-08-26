import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The 32×32 circular node on the trail.
///
/// States: cleared (accent fill + ✓), live (accent border + index + halo),
/// ahead (slate border + muted index).
class TrailNode extends StatefulWidget {
  const TrailNode({
    super.key,
    required this.label,
    required this.state, // 'cleared', 'live', 'ahead'
  });

  final String label;
  final String state;

  @override
  State<TrailNode> createState() => _TrailNodeState();
}

class _TrailNodeState extends State<TrailNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _haloCtrl;

  @override
  void initState() {
    super.initState();
    _haloCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.state == 'live') _haloCtrl.repeat();
  }

  @override
  void didUpdateWidget(covariant TrailNode old) {
    super.didUpdateWidget(old);
    if (widget.state == 'live' && !_haloCtrl.isAnimating) {
      _haloCtrl.repeat();
    } else if (widget.state != 'live' && _haloCtrl.isAnimating) {
      _haloCtrl.stop();
      _haloCtrl.reset();
    }
  }

  @override
  void dispose() {
    _haloCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    final borderW = 2.0;

    final (bg, border, textColor, glyph) = switch (widget.state) {
      'cleared' => (AppColors.accent, AppColors.accent, AppColors.canvas, '✓'),
      'live' => (
        AppColors.accentTrack,
        AppColors.accent,
        AppColors.accent,
        widget.label,
      ),
      _ => (
        Colors.transparent,
        AppColors.borderStrong,
        AppColors.muted,
        widget.label,
      ),
    };

    Widget node = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: borderW),
      ),
      alignment: Alignment.center,
      child: glyph == '✓'
          ? Icon(Icons.check, size: 16, color: textColor, weight: 400)
          : Text(
              glyph,
              style: AppType.code.copyWith(color: textColor, fontSize: 10),
            ),
    );

    if (widget.state == 'live') {
      node = AnimatedBuilder(
        animation: _haloCtrl,
        builder: (_, child) {
          final t = _haloCtrl.value;
          // Halo grows from 0 to 14px spread at 35% accent.
          final spread = t * 14.0;
          final alpha = (1 - t) * 0.35;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: alpha),
                  blurRadius: spread,
                  spreadRadius: spread * 0.2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: node,
      );
    }

    return node;
  }
}
