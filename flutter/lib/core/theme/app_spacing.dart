import 'package:flutter/animation.dart';

/// Spacing, radii and motion. Use the scale — do not interpolate between steps.
abstract final class Gap {
  static const xxs = 6.0;
  static const xs = 8.0;
  static const sm = 10.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 22.0;
  static const xxl = 26.0;

  /// Horizontal screen gutter.
  static const gutter = 24.0;
}

abstract final class Pad {
  static const trailCard = 13.0;
  static const card = 16.0;
  static const cardLoose = 18.0;
  static const panel = 20.0;
  static const sheetH = 24.0;
  static const sheetTop = 20.0;
  static const sheetBottom = 28.0;
}

abstract final class Radii {
  static const tick = 1.0;
  static const heat = 3.0;
  static const chip = 11.0;
  static const iconTile = 14.0;
  static const input = 16.0;
  static const button = 17.0;
  static const buttonLarge = 19.0;
  static const trailCard = 20.0;
  static const card = 22.0;
  static const panel = 24.0;
  static const hero = 26.0;
  static const sheet = 34.0;
  static const screen = 43.0;
}

abstract final class Motion {
  /// Bottom sheets: translateY(101%) → 0.
  static const sheet = Duration(milliseconds: 340);

  /// Overlay pop: scale(.9) → 1.
  static const pop = Duration(milliseconds: 420);

  /// Inline reveal: translateY(16) + fade.
  static const rise = Duration(milliseconds: 290);

  /// XP flight: up 110, scale .6, fade out. Starts after [flightDelay].
  static const flight = Duration(milliseconds: 1300);
  static const flightDelay = Duration(milliseconds: 300);

  /// Bars, ticks, rails.
  static const fill = Duration(milliseconds: 480);

  /// Hover / selection / color changes.
  static const state = Duration(milliseconds: 230);

  /// Live-node halo, one full pulse.
  static const halo = Duration(milliseconds: 2400);

  /// Quest-complete overlay lifetime.
  static const flashVisible = Duration(milliseconds: 1700);

  /// Level-up is queued after the XP award, then held.
  static const levelUpDelay = Duration(milliseconds: 1400);
  static const levelUpVisible = Duration(milliseconds: 2600);

  static const emphasized = Cubic(.22, 1, .36, 1);
  static const flightCurve = Cubic(.4, 0, .6, 1);
  static const standard = Curves.easeOut;
}
