import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/core/theme/app_theme.dart';
import 'package:lifequest/features/character/presentation/character_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('CharacterPage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const CharacterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CharacterPage), findsOneWidget);
    });

    testWidgets('displays character identity section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const CharacterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find CLASS text
      expect(find.textContaining('CLASS'), findsOneWidget);
    });

    testWidgets('displays attributes section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const CharacterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find attribute labels
      expect(find.text('STRENGTH'), findsOneWidget);
      expect(find.text('INTELLECT'), findsOneWidget);
      expect(find.text('DISCIPLINE'), findsOneWidget);
    });

    testWidgets('displays level and XP information', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const CharacterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find LVL text
      expect(find.textContaining('LVL'), findsOneWidget);
    });
  });
}
