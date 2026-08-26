import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Two families only: Sora for anything sentence-case, DM Mono for anything
/// uppercase. If a style you need is missing, derive it — do not add a family.
abstract final class AppType {
  static TextStyle _sora(
    double size,
    FontWeight weight, {
    double? height,
    double? spacing,
    Color? color,
  }) => GoogleFonts.sora(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: spacing,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle _mono(
    double size,
    FontWeight weight, {
    double spacing = 1.2,
    Color? color,
  }) => GoogleFonts.dmMono(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: spacing,
    color: color ?? AppColors.slate,
  );

  // Display / numerals
  static TextStyle get timer => _sora(
    66,
    FontWeight.w600,
    height: 1,
    spacing: -1.98,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  static TextStyle get levelUpNumber =>
      _sora(76, FontWeight.w700, height: 1, spacing: -2.28);
  static TextStyle get xpFlash =>
      _sora(42, FontWeight.w700, height: 1, color: AppColors.accent);
  static TextStyle get heroLevel =>
      _sora(34, FontWeight.w700, height: 1, spacing: -.68);

  // Titles
  static TextStyle get screenTitle => _sora(24, FontWeight.w600, height: 1.2);
  static TextStyle get sheetTitle => _sora(21, FontWeight.w600, height: 1.3);
  static TextStyle get headline => _sora(19, FontWeight.w600, height: 1.35);
  static TextStyle get sectionTitle => _sora(13, FontWeight.w600, height: 1);

  // Cards
  static TextStyle get cardTitle => _sora(15, FontWeight.w500, height: 1.25);
  static TextStyle get trailTitle => _sora(14, FontWeight.w500, height: 1.25);
  static TextStyle get value => _sora(13, FontWeight.w600, height: 1);
  static TextStyle get statValue => _sora(22, FontWeight.w600, height: 1);

  // Body
  static TextStyle get body =>
      _sora(13, FontWeight.w300, height: 1.55, color: AppColors.slate);
  static TextStyle get bodySmall =>
      _sora(12.5, FontWeight.w300, height: 1.5, color: AppColors.slate);

  // Actions
  static TextStyle get buttonPrimary =>
      _sora(13.5, FontWeight.w600, height: 1, color: AppColors.canvas);
  static TextStyle get buttonSecondary => _sora(12, FontWeight.w600, height: 1);
  static TextStyle get navLabel => _sora(10.5, FontWeight.w400, height: 1);
  static TextStyle get navLabelActive =>
      _sora(10.5, FontWeight.w600, height: 1);

  // Mono
  static TextStyle get eyebrow =>
      _mono(10, FontWeight.w400, spacing: 1.8, color: AppColors.accent);
  static TextStyle get metaLabel => _mono(9.5, FontWeight.w400, spacing: 1.1);
  static TextStyle get microLabel =>
      _mono(8.5, FontWeight.w400, spacing: .9, color: AppColors.muted);
  static TextStyle get code => _mono(10, FontWeight.w500, spacing: .6);

  static TextTheme get textTheme => TextTheme(
    displayLarge: levelUpNumber,
    headlineLarge: screenTitle,
    headlineMedium: sheetTitle,
    headlineSmall: headline,
    titleMedium: cardTitle,
    titleSmall: sectionTitle,
    bodyMedium: body,
    bodySmall: bodySmall,
    labelLarge: buttonSecondary,
    labelMedium: metaLabel,
    labelSmall: microLabel,
  );
}
