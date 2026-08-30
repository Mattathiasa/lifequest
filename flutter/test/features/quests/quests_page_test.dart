import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/core/theme/app_theme.dart';
import 'package:lifequest/features/quests/presentation/quests_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('QuestsPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const QuestsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QuestsPage), findsOneWidget);
    });

    testWidgets('displays "Quest board" header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const QuestsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quest board'), findsOneWidget);
    });

    testWidgets('displays segment tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const QuestsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find all tab labels
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Recurring'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('displays category chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const QuestsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find category chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Productivity'), findsOneWidget);
    });

    testWidgets('displays "New" button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const QuestsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('displays active count', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const QuestsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find ACTIVE text
      expect(find.textContaining('ACTIVE'), findsOneWidget);
    });
  });
}
