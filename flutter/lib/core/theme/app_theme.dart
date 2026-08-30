import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Light theme colors — complements the dark-first design.
abstract final class AppColorsLight {
  static const canvas = Color(0xFFF8F9FC);
  static const canvasTop = Color(0xFFEDF0F5);
  static const canvasMid = Color(0xFFF2F4F8);
  static const sheetTop = Color(0xFFFFFFFF);
  static const sheetBottom = Color(0xFFF5F6F9);
  static const textPrimary = Color(0xFF1A1D24);
  static const slate = Color(0xFF5A6578);
  static const muted = Color(0xFF8A93A5);
  static const faint = Color(0xFFBCC3D0);
  static const surface = Color(0xFFE8EBF0);
  static const surfaceRaised = Color(0xFFE0E3E9);
  static const surfaceIcon = Color(0xFFD5D9E1);
  static const border = Color(0xFFD0D5DD);
  static const borderStrong = Color(0xFFBCC3D0);
  static const borderHairline = Color(0xFFE0E3E9);
  static const trackInactive = Color(0xFFD0D5DD);
  static const accentSurface = Color(0xFFD4E81F);
  static const accentBorder = Color(0xFFA8C41C);
  static const accentTrack = Color(0xFFE8F5A0);
  static const error = Color(0xFFD94040);
}

/// Dark-first theme. Light mode is a later concern — the design is authored dark
/// and every surface is an alpha over [AppColors.canvas].
abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.canvas,
        primary: AppColors.accent,
        onPrimary: AppColors.canvas,
        secondary: AppColors.slate,
        onSurface: AppColors.textPrimary,
        error: AppColors.difficultyEpic,
      ),
      textTheme: AppType.textTheme,
      dividerTheme: DividerThemeData(
        color: AppColors.borderHairline,
        space: 1,
        thickness: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.canvas,
          textStyle: AppType.buttonPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.buttonLarge),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppType.buttonSecondary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: AppColors.slate.withValues(alpha: .30)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.button),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        hintStyle: AppType.body,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColorsLight.canvas,
      canvasColor: AppColorsLight.canvas,
      colorScheme: const ColorScheme.light(
        surface: AppColorsLight.canvas,
        primary: AppColors.accent,
        onPrimary: AppColorsLight.canvas,
        secondary: AppColorsLight.slate,
        onSurface: AppColorsLight.textPrimary,
        error: AppColorsLight.error,
      ),
      textTheme: AppType.textTheme,
      dividerTheme: DividerThemeData(
        color: AppColorsLight.borderHairline,
        space: 1,
        thickness: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColorsLight.canvas,
          textStyle: AppType.buttonPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.buttonLarge),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.textPrimary,
          textStyle: AppType.buttonSecondary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: AppColorsLight.slate.withValues(alpha: .30)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.button),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceRaised,
        hintStyle: AppType.body,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: BorderSide(color: AppColorsLight.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: BorderSide(color: AppColorsLight.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.input),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
