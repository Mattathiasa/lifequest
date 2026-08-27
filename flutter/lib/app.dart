import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'core/widgets/brand_mark.dart';
import 'features/onboarding/presentation/onboarding_flow.dart';
import 'features/settings/application/settings_controller.dart';

class LifeQuestApp extends ConsumerWidget {
  const LifeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'LifeQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: settings.when(
        data: (s) => s.onboarded ? const AppShell() : const OnboardingFlow(),
        loading: () => const _BrandSplash(),
        // Fail open — never trap the user on the splash if prefs can't load.
        error: (_, _) => const AppShell(),
      ),
    );
  }
}

/// Shown for the brief moment while persisted settings load at startup.
class _BrandSplash extends StatelessWidget {
  const _BrandSplash();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.canvas,
      child: Center(child: BrandMark(size: 88, wordmark: true)),
    );
  }
}
