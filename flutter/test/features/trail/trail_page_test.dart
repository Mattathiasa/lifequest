import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/core/theme/app_theme.dart';
import 'package:lifequest/features/trail/presentation/trail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('TrailPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TrailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find the trail page content
      expect(find.byType(TrailPage), findsOneWidget);
    });

    testWidgets('displays greeting based on time of day', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TrailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find some greeting text (Good morning/afternoon/evening)
      final greetingFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data?.contains('Good morning') == true ||
             widget.data?.contains('Good afternoon') == true ||
             widget.data?.contains('Good evening') == true),
      );
      expect(greetingFinder, findsOneWidget);
    });

    testWidgets('displays "Today\'s trail" section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TrailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Today's trail"), findsOneWidget);
    });

    testWidgets('displays hero level card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TrailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find LEVEL text
      expect(find.text('LEVEL'), findsOneWidget);
    });

    testWidgets('displays streak information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TrailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find STREAK text
      expect(find.text('STREAK'), findsOneWidget);
    });

    testWidgets('displays side quest card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const TrailPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find SIDE QUEST text
      expect(find.text('SIDE QUEST'), findsOneWidget);
    });
  });
}
