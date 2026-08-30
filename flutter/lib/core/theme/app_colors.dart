import 'package:flutter/material.dart';

/// LifeQuest color tokens — taken verbatim from the approved design.
/// Only `accent`, `canvas` and the text ramp are solid; every other surface is
/// slate or accent at an alpha, so the whole UI stays in three hues.
abstract final class AppColors {
  // Canvas
  static const canvas = Color(0xFF05070A);
  static const canvasTop = Color(0xFF0B1018);
  static const canvasMid = Color(0xFF070A0F);

  // Sheets
  static const sheetTop = Color(0xFF111823);
  static const sheetBottom = Color(0xFF080B11);

  // Accent — the single action color
  static const accent = Color(0xFFC7F022);
  static const accentPressed = Color(0xFFD9FF4F);

  // Text ramp
  static const textPrimary = Color(0xFFECF1F8);
  static const slate = Color(0xFF7789AB);
  static const muted = Color(0xFF4E5A70);
  static const faint = Color(0xFF2C3648);

  // Semantic
  static const error = Color(0xFFFF7A6B);

  // Difficulty
  static const difficultyEasy = slate;
  static const difficultyMedium = accent;
  static const difficultyHard = Color(0xFFE8B923);
  static const difficultyEpic = Color(0xFFFF7A6B);

  // Derived fills
  static final surface = slate.withValues(alpha: .05);
  static final surfaceRaised = slate.withValues(alpha: .07);
  static final surfaceIcon = slate.withValues(alpha: .10);
  static final border = slate.withValues(alpha: .14);
  static final borderStrong = slate.withValues(alpha: .20);
  static final borderHairline = slate.withValues(alpha: .10);
  static final trackInactive = slate.withValues(alpha: .16);
  static final accentSurface = accent.withValues(alpha: .08);
  static final accentBorder = accent.withValues(alpha: .30);
  static final accentTrack = accent.withValues(alpha: .14);

  // Gradients
  static final heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent.withValues(alpha: .09), slate.withValues(alpha: .05)],
  );
  static final liveCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent.withValues(alpha: .08), slate.withValues(alpha: .05)],
  );
  static const sideQuestCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2210), Color(0xFF0A0D12)],
    stops: [0, .7],
  );
  static const screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [canvasTop, canvasMid, canvas],
    stops: [0, .55, 1],
  );
  static const sheet = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sheetTop, sheetBottom],
  );

  /// Difficulty numeral colors, keyed by the enum's index (Easy → Epic).
  static const difficulty = <Color>[
    difficultyEasy,
    difficultyMedium,
    difficultyHard,
    difficultyEpic,
  ];
}
