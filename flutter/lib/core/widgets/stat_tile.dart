import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Single stat column (STREAK · 14 days, TODAY · 72%, etc).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppType.value.copyWith(color: color ?? AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppType.metaLabel),
      ],
    );
  }
}
