import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifequest/core/theme/app_theme.dart';
import 'package:lifequest/features/profile/presentation/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfilePage', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('displays "Profile" header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('displays lifetime XP stat', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find LIFETIME XP text
      expect(find.text('LIFETIME XP'), findsOneWidget);
    });

    testWidgets('displays settings rows', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find settings items
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Difficulty'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('displays streak freeze section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should find streak freeze related text
      expect(find.text('Streak Freezes'), findsOneWidget);
    });
  });
}
