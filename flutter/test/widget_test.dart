import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifequest/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Pumps a few frames so the async settings load resolves. We can't use
  /// pumpAndSettle — the live-node halo and side-quest blob animate forever.
  Future<void> boot(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LifeQuestApp()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets('shows onboarding on first run', (tester) async {
    SharedPreferences.setMockInitialValues({}); // onboarded == false
    await boot(tester);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('LEVEL'), findsNothing);
  });

  testWidgets('Trail renders once onboarded (360dp)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'difficultyMode': 'balanced',
      'displayName': 'Matt Abraham',
    });
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await boot(tester);

    expect(find.text('LEVEL'), findsOneWidget);
    expect(find.textContaining('Matt'), findsWidgets);
  });

  testWidgets('Trail renders once onboarded (440dp)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'difficultyMode': 'balanced',
      'displayName': 'Matt Abraham',
    });
    tester.view.physicalSize = const Size(440 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await boot(tester);

    expect(find.text('LEVEL'), findsOneWidget);
  });
}
