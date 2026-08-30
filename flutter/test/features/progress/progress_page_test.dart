import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/core/theme/app_theme.dart';
import 'package:lifequest/features/progress/presentation/progress_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProgressPage), findsOneWidget);
    });

    testWidgets('displays "Progress" header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('displays streak information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find STREAK text
      expect(find.text('STREAK'), findsOneWidget);
    });

    testWidgets('displays record streak', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find RECORD text
      expect(find.text('RECORD'), findsOneWidget);
    });

    testWidgets('displays weekly XP section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find WEEKLY XP text
      expect(find.text('WEEKLY XP'), findsOneWidget);
    });

    testWidgets('displays consistency heatmap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find CONSISTENCY text
      expect(find.text('CONSISTENCY'), findsOneWidget);
    });

    testWidgets('displays XP breakdown section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProgressPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find WHERE YOUR XP GOES text
      expect(find.text('WHERE YOUR XP GOES'), findsOneWidget);
    });
  });
}
