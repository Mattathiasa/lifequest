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
import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';
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
  Widget build(BuildContext context) {
    final timerState = ref.watch(focusTimerProvider);
    final quest = widget.quest;
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
                      'Complete · +${quest.xp}',
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

  void _complete(Quest quest) async {
    final focusCtrl = ref.read(focusTimerProvider.notifier);
    final progCtrl = ref.read(progressionProvider.notifier);

    final completedQuest = focusCtrl.complete();
    if (completedQuest == null) return;

    if (mounted) Navigator.of(context).pop();

    final xp = XpRules.reward(
      completedQuest.difficulty,
      DifficultyMode.balanced,
    );
    await ref.read(questListProvider.notifier).complete(completedQuest.id);

    progCtrl.showFlash(xp: xp, name: completedQuest.name);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final result = progCtrl.award(xp);
      if (result.leveledUp) {
        Future.delayed(Motion.levelUpDelay, () {
          if (!mounted) return;
          progCtrl.showLevelUp(result.previousLevel);
        });
      }
    });
  }

  int _parseTimeToSeconds(String time) {
    final cleaned = time.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 300;
    final minutes = int.tryParse(cleaned) ?? 5;
    return minutes * 60;
  }
}
