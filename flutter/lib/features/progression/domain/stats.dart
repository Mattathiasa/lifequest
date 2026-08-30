import '../../quests/domain/quest.dart';
import 'completion_event.dart';

/// Pure aggregate functions over the completion history. Kept Flutter-free so
/// they can be unit-tested directly; every Progress/Character number derives
/// from these.
abstract final class GameStats {
  static int questsDone(List<CompletionEvent> history) => history.length;

  static bool nightOwl(List<CompletionEvent> history) =>
      history.any((e) => e.at.hour >= 22 || e.at.hour < 5);

  /// XP summed per day for the last 7 days, oldest first.
  static List<int> weeklyXp(List<CompletionEvent> history, DateTime now) {
    final today = _day(now);
    return [
      for (var d = 6; d >= 0; d--)
        history
            .where((e) => _sameDay(e.at, today.subtract(Duration(days: d))))
            .fold<int>(0, (sum, e) => sum + e.xp),
    ];
  }

  /// Weekday initials aligned with [weeklyXp] (oldest first).
  static List<String> weekdayLabels(DateTime now) {
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = _day(now);
    return [
      for (var d = 6; d >= 0; d--)
        names[today.subtract(Duration(days: d)).weekday - 1],
    ];
  }

  /// Completion counts per day for the last [days] days, oldest first.
  static List<int> dailyCounts(
    List<CompletionEvent> history,
    DateTime now, {
    int days = 42,
  }) {
    final today = _day(now);
    return [
      for (var d = days - 1; d >= 0; d--)
        history
            .where((e) => _sameDay(e.at, today.subtract(Duration(days: d))))
            .length,
    ];
  }

  static Map<QuestCategory, int> xpByCategory(List<CompletionEvent> history) {
    final map = <QuestCategory, int>{};
    for (final e in history) {
      map[e.category] = (map[e.category] ?? 0) + e.xp;
    }
    return map;
  }

  /// Days within the last 7 that had at least [threshold] completions — a proxy
  /// for "cleared the trail" (Perfect Week).
  static int perfectWeekDays(
    List<CompletionEvent> history,
    DateTime now, {
    int threshold = 4,
  }) => dailyCounts(history, now, days: 7).where((c) => c >= threshold).length;

  /// Percentage of the last 7 days with at least one completion.
  static int weekActiveRate(List<CompletionEvent> history, DateTime now) {
    final active = dailyCounts(
      history,
      now,
      days: 7,
    ).where((c) => c > 0).length;
    return (active / 7 * 100).round();
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
