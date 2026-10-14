import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] keyed to LifeQuest actions.
abstract final class AppHaptics {
  /// Whether haptic feedback is globally enabled by user settings.
  static bool enabled = true;

  /// Quest complete — light tap.
  static Future<void> complete() {
    if (!enabled) return Future.value();
    return HapticFeedback.lightImpact();
  }

  /// Level-up — medium thud.
  static Future<void> levelUp() {
    if (!enabled) return Future.value();
    return HapticFeedback.mediumImpact();
  }

  /// Chip / tab / difficulty change.
  static Future<void> selection() {
    if (!enabled) return Future.value();
    return HapticFeedback.selectionClick();
  }
}
