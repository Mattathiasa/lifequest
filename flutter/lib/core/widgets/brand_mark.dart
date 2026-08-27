import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The LifeQuest brand mark — the "LQ" monogram tile (mirrors the launcher
/// icon), optionally stacked with the "LIFEQUEST" wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64, this.wordmark = false});

  final double size;
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.accentBorder, width: 1.5),
      ),
      child: Text(
        'LQ',
        style: AppType.code.copyWith(
          color: AppColors.accent,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!wordmark) return tile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        SizedBox(height: size * 0.22),
        Text(
          'LIFEQUEST',
          style: AppType.metaLabel.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            letterSpacing: 3.2,
          ),
        ),
      ],
    );
  }
}
