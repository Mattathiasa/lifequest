import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progression/application/progression_controller.dart';
import '../../progression/domain/attributes.dart';
import '../../progression/domain/stats.dart';

/// A single coaching insight with a headline and an action prompt.
class CoachAdvice {
  const CoachAdvice({
    required this.headline,
    required this.body,
    required this.icon,
    required this.tag,
  });

  /// Short, punchy label shown as eyebrow (e.g. "LOW FOCUS").
  final String tag;

  /// Single emoji icon for the card.
  final String icon;

  /// Primary coaching sentence (sentence-case, max ~12 words).
  final String headline;

  /// Actionable follow-up (1–2 sentences, specific and encouraging).
  final String body;
}

/// Derives a [CoachAdvice] from the player's live stats.
///
/// Priority order:
/// 1. Brand-new player (no XP yet) → welcome prompt.
/// 2. Hot streak ≥ 7 → celebrate momentum.
/// 3. Completion rate ≤ 30 % → encourage consistency.
/// 4. Weakest attribute < 60 → targeted attribute advice.
/// 5. All attributes healthy → celebrate and prompt exploration.
CoachAdvice deriveCoachAdvice({
  required Attributes attributes,
  required List<int> dailyCounts,
  required int streak,
  required int totalXp,
}) {
  // 1. New player
  if (totalXp == 0) {
    return const CoachAdvice(
      tag: 'WELCOME',
      icon: '🗺',
      headline: 'Your adventure begins here.',
      body:
          'Complete your first quest to unlock personalized coaching and watch '
          'your attributes grow.',
    );
  }

  // 2. Hot streak
  if (streak >= 7) {
    return CoachAdvice(
      tag: 'ON FIRE',
      icon: '🔥',
      headline: '$streak-day streak — outstanding consistency.',
      body:
          'You\'re in a flow state. Push for a new personal record and consider '
          'adding one harder quest to your board today.',
    );
  }

  // Compute completion rate
  final daysActive = dailyCounts.where((c) => c > 0).length;
  final completionRate = dailyCounts.isNotEmpty
      ? daysActive / dailyCounts.length
      : 0.0;

  // 3. Low consistency
  if (completionRate <= 0.30 && dailyCounts.isNotEmpty) {
    return const CoachAdvice(
      tag: 'CONSISTENCY',
      icon: '📅',
      headline: 'Small wins, compounded daily.',
      body:
          'Try locking in just one quest every morning before checking your phone. '
          'Even easy quests count — momentum is everything.',
    );
  }

  // 4. Weakest attribute
  final weakest = _weakestAttribute(attributes);
  final advice = _attributeAdvice[weakest];
  if (advice != null && attributes[weakest] < 70) {
    return advice;
  }

  // 5. Everything is healthy
  return const CoachAdvice(
    tag: 'THRIVING',
    icon: '⭐',
    headline: 'Your attributes are well-balanced.',
    body:
        'Keep the streak alive and try an Epic-difficulty quest this week to '
        'push your limits and earn bonus XP.',
  );
}

Attribute _weakestAttribute(Attributes attributes) {
  Attribute weakest = Attribute.values.first;
  int minVal = 101;
  for (final attr in Attribute.values) {
    final val = attributes[attr];
    if (val < minVal) {
      minVal = val;
      weakest = attr;
    }
  }
  return weakest;
}

/// Maps each attribute to targeted, specific coaching copy.
const _attributeAdvice = <Attribute, CoachAdvice>{
  Attribute.health: CoachAdvice(
    tag: 'LOW HEALTH',
    icon: '❤️',
    headline: 'Your health attribute needs attention.',
    body:
        'Add one physical quest this week — a 20-minute walk counts. '
        'Completing Health quests raises this attribute directly.',
  ),
  Attribute.focus: CoachAdvice(
    tag: 'LOW FOCUS',
    icon: '🎯',
    headline: 'Your focus score could use a boost.',
    body:
        'Schedule a single 25-minute distraction-free work block today. '
        'Productivity and Mindfulness quests both build Focus.',
  ),
  Attribute.discipline: CoachAdvice(
    tag: 'LOW DISCIPLINE',
    icon: '⚙️',
    headline: 'Discipline is the foundation of every streak.',
    body:
        'Pick two recurring quests and commit to them for seven straight days. '
        'Finance and Mindfulness quests are great discipline builders.',
  ),
  Attribute.social: CoachAdvice(
    tag: 'LOW SOCIAL',
    icon: '🤝',
    headline: 'Your social attribute is lagging behind.',
    body:
        'Add a Social quest — even a 10-minute check-in call with a friend '
        'raises this stat and improves your overall well-being.',
  ),
  Attribute.strength: CoachAdvice(
    tag: 'LOW STRENGTH',
    icon: '💪',
    headline: 'Time to build some physical strength.',
    body:
        'Try adding a Strength Training or Cardio quest to your board. '
        'Health quests directly increase your Strength attribute.',
  ),
  Attribute.intellect: CoachAdvice(
    tag: 'LOW INTELLECT',
    icon: '🧠',
    headline: 'Feed your mind with a Learning quest.',
    body:
        'Read 20 pages, watch a tutorial, or take a course. Learning quests '
        'are the fastest way to grow your Intellect score.',
  ),
  Attribute.creativity: CoachAdvice(
    tag: 'LOW CREATIVITY',
    icon: '🎨',
    headline: 'Creativity needs space to grow.',
    body:
        'Block 30 minutes for an unstructured creative activity — sketch, '
        'write, brainstorm. There are no rules.',
  ),
};

/// Provider that computes the current [CoachAdvice] from live player data.
final coachAdviceProvider = Provider<CoachAdvice>((ref) {
  final prog = ref.watch(progressionStateProvider);
  final attrs = ref.watch(attributesProvider);
  final history = ref.watch(historyProvider);
  final now = DateTime.now();

  final dailyCounts = GameStats.dailyCounts(history, now, days: 42);
  final xpByCategory = GameStats.xpByCategory(history);
  final totalXp = xpByCategory.values.fold<int>(0, (sum, v) => sum + v);

  return deriveCoachAdvice(
    attributes: attrs,
    dailyCounts: dailyCounts,
    streak: prog.streak,
    totalXp: totalXp,
  );
});
