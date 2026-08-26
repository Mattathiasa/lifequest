import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] keyed to LifeQuest actions.
abstract final class AppHaptics {
  /// Quest complete — light tap.
  static Future<void> complete() => HapticFeedback.lightImpact();

  /// Level-up — medium thud.
  static Future<void> levelUp() => HapticFeedback.mediumImpact();

  /// Chip / tab / difficulty change.
  static Future<void> selection() => HapticFeedback.selectionClick();
}
