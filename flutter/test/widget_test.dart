import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifequest/app.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('Trail page renders at 360dp', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: LifeQuestApp()));
    await tester.pump();

    // Verify key elements render
    expect(find.textContaining('Matt'), findsWidgets);
    expect(find.text('LEVEL'), findsOneWidget);
  });

  testWidgets('Trail page renders at 440dp', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(440 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: LifeQuestApp()));
    await tester.pump();

    expect(find.textContaining('Matt'), findsWidgets);
    expect(find.text('LEVEL'), findsOneWidget);
  });
}
