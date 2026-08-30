import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/core/theme/app_theme.dart';
import 'package:lifequest/features/progression/application/progression_controller.dart';
import 'package:lifequest/features/progression/domain/progression_state.dart';
import 'package:lifequest/features/quests/application/quest_providers.dart';
import 'package:lifequest/features/settings/application/settings_controller.dart';
import 'package:lifequest/features/settings/domain/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sets up SharedPreferences for testing.
Future<void> setupSharedPreferences() async {
  SharedPreferences.setMockInitialValues({});
}

/// Creates a testable wrapper widget with all necessary providers.
Widget createTestableApp({
  required Widget child,
  ProgressionState? progressionState,
  AppSettings? settings,
}) {
  return ProviderScope(
    overrides: [
      if (progressionState != null)
        progressionStateProvider.overrideWithValue(progressionState),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: child,
    ),
  );
}

/// Mock progression state for testing.
const mockProgressionState = ProgressionState(
  level: 12,
  xpIntoLevel: 2450,
  lifetimeXp: 34120,
  streak: 14,
  recordStreak: 31,
  streakFreezes: 1,
);

/// Helper to pump a widget with providers.
Future<void> pumpWidgetWithProviders(
  WidgetTester tester, {
  required Widget child,
  ProgressionState? progressionState,
}) async {
  await tester.pumpWidget(
    createTestableApp(
      child: child,
      progressionState: progressionState ?? mockProgressionState,
    ),
  );
  await tester.pumpAndSettle();
}
