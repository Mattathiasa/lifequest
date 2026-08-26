import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/empty_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screen),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Gap.md),
              Text('Profile', style: AppType.screenTitle),
              const Spacer(),
              const EmptyState(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
