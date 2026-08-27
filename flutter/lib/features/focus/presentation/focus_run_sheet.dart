import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/xp_tick_bar.dart';
import '../../progression/application/progression_controller.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/domain/quest.dart';
import '../../settings/application/settings_controller.dart';
import '../application/focus_timer_controller.dart';

/// Opens the focus run sheet as a modal bottom sheet.
void showFocusSheet(
  BuildContext context, {
  required Quest quest,
  bool autoStart = false,
}) {
  showGlassSheet(
    context,
    builder: (_) => _FocusRunSheetContent(quest: quest, autoStart: autoStart),
  );
}

class _FocusRunSheetContent extends ConsumerStatefulWidget {
  const _FocusRunSheetContent({required this.quest, required this.autoStart});

  final Quest quest;
  final bool autoStart;

  @override
  ConsumerState<_FocusRunSheetContent> createState() =>
      _FocusRunSheetContentState();
}

class _FocusRunSheetContentState extends ConsumerState<_FocusRunSheetContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(focusTimerProvider.notifier).open(widget.quest);
      if (widget.autoStart) {
        ref.read(focusTimerProvider.notifier).start();
      }
    });
  }

  @override
  void dispose() {
    // Dismissing the sheet (scrim tap, back, or complete) resets the timer so
    // it never keeps ticking in the background. Safe to call twice.
    ref.read(focusTimerProvider.notifier).close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(focusTimerProvider);
    final mode = ref.watch(difficultyModeProvider);
    final quest = widget.quest;
    final reward = XpRules.reward(quest.difficulty, mode);
    final category = quest.category.uppercase;
    final diffLabel = quest.difficulty.numeral;
    final meta =
        '$category · $diffLabel ${quest.difficulty.label} · ${quest.time}';

    // Timer segment bar: 24 segments
    final estimatedSeconds = _parseTimeToSeconds(quest.time);
    final timerPct = estimatedSeconds > 0
        ? (timerState.elapsed / estimatedSeconds).clamp(0.0, 1.0)
        : 0.0;
    final filledSegments = (timerPct * 24).round();

    final statusText = switch (timerState.status) {
      FocusStatus.ready => 'READY WHEN YOU ARE',
      FocusStatus.running => 'FOCUS RUNNING',
      FocusStatus.paused => 'PAUSED',
    };

    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(meta.toUpperCase(), style: AppType.metaLabel),
          const SizedBox(height: Gap.md),
          Text(quest.name, style: AppType.sheetTitle),
          const SizedBox(height: Gap.sm),
          Text(quest.desc, style: AppType.body),
          const SizedBox(height: Gap.xl),
          Text(Formatters.mmss(timerState.elapsed), style: AppType.timer),
          const SizedBox(height: Gap.xs),
          Text(statusText, style: AppType.metaLabel),
          const SizedBox(height: Gap.lg),
          XpTickBar(filled: filledSegments, segments: 24, height: 4, gap: 2),
          const SizedBox(height: Gap.xl),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final ctrl = ref.read(focusTimerProvider.notifier);
                    if (timerState.status == FocusStatus.ready ||
                        timerState.status == FocusStatus.paused) {
                      timerState.status == FocusStatus.ready
                          ? ctrl.start()
                          : ctrl.resume();
                    } else {
                      ctrl.pause();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.button),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: Text(switch (timerState.status) {
                      FocusStatus.ready => 'Start',
                      FocusStatus.running => 'Pause',
                      FocusStatus.paused => 'Resume',
                    }, style: AppType.buttonSecondary),
                  ),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => _complete(quest),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(Radii.button),
                    ),
                    child: Text(
                      'Complete · +$reward',
                      style: AppType.buttonPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _complete(Quest quest) {
    final completedQuest = ref.read(focusTimerProvider.notifier).complete();
    if (completedQuest == null) return;
    Navigator.of(context).pop();
    // The controller owns the flash → XP → level-up sequence; it keeps running
    // after this sheet closes.
    ref.read(progressionProvider.notifier).completeQuest(completedQuest);
  }

  int _parseTimeToSeconds(String time) {
    final cleaned = time.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 300;
    final minutes = int.tryParse(cleaned) ?? 5;
    return minutes * 60;
  }
}
