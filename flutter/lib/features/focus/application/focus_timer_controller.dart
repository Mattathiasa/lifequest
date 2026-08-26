import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progression/domain/xp_rules.dart';
import '../../quests/domain/quest.dart';

/// Timer controller for focus sessions.
///
/// Ticks every second, cancels on dispose / close / complete (CLAUDE.md rule).
class FocusTimerController extends Notifier<FocusTimerState> {
  Timer? _timer;

  @override
  FocusTimerState build() {
    ref.onDispose(_cancelTimer);
    return const FocusTimerState();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Open the sheet for a quest at 00:00, not running.
  void open(Quest quest) {
    _cancelTimer();
    state = FocusTimerState(
      quest: quest,
      elapsed: 0,
      running: false,
      status: FocusStatus.ready,
    );
  }

  /// Start the timer.
  void start() {
    if (state.quest == null || _timer != null) return;
    state = state.copyWith(running: true, status: FocusStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsed: state.elapsed + 1);
    });
  }

  /// Pause the timer.
  void pause() {
    _cancelTimer();
    state = state.copyWith(running: false, status: FocusStatus.paused);
  }

  /// Resume from paused.
  void resume() {
    if (state.quest == null) return;
    state = state.copyWith(running: true, status: FocusStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsed: state.elapsed + 1);
    });
  }

  /// Complete the session — cancel timer, return the quest.
  Quest? complete() {
    final quest = state.quest;
    _cancelTimer();
    state = const FocusTimerState();
    return quest;
  }

  /// Close without completing — cancel timer.
  void close() {
    _cancelTimer();
    state = const FocusTimerState();
  }
}

enum FocusStatus { ready, running, paused }

class FocusTimerState {
  const FocusTimerState({
    this.quest,
    this.elapsed = 0,
    this.running = false,
    this.status = FocusStatus.ready,
  });

  final Quest? quest;
  final int elapsed;
  final bool running;
  final FocusStatus status;

  FocusTimerState copyWith({
    Quest? quest,
    int? elapsed,
    bool? running,
    FocusStatus? status,
  }) {
    return FocusTimerState(
      quest: quest ?? this.quest,
      elapsed: elapsed ?? this.elapsed,
      running: running ?? this.running,
      status: status ?? this.status,
    );
  }

  /// XP to show for this quest (based on difficulty).
  int get xp => quest != null
      ? XpRules.reward(quest!.difficulty, DifficultyMode.balanced)
      : 0;
}

final focusTimerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(
      FocusTimerController.new,
    );
