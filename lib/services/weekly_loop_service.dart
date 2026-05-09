import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pedantic/pedantic.dart'; // Added for unawaited

class WeeklyLoopService {
  WeeklyLoopService._privateConstructor();

  static final WeeklyLoopService instance =
      WeeklyLoopService._privateConstructor();

  static const _historyKey = 'weekly_loop_history';

  Future<void> addLoopCompletion(DateTime when) async {
    unawaited(
      SharedPreferences.getInstance().then((prefs) {
        final history = prefs.getStringList(_historyKey) ?? [];
        final isoWeek = _getIsoWeek(when);

        history.add(isoWeek);
        prefs.setStringList(_historyKey, history);
      }),
    );
  }

  Future<int> getCompletionsCountThisWeek() async =>
      SharedPreferences.getInstance().then((prefs) {
        final history = prefs.getStringList(_historyKey) ?? [];
        final currentWeek = _getIsoWeek(DateTime.now().toUtc());

        return history.where((week) => week == currentWeek).length;
      });

  Future<void> clearAll() async {
    unawaited(
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove(_historyKey);
      }),
    );
  }

  Future<Map<String, int>> getLoopStats() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    final totalThisWeek = await getCompletionsCountThisWeek();
    final streak = _calculateStreak(history);
    return {'currentStreak': streak, 'totalThisWeek': totalThisWeek};
  }

  String _getIsoWeek(DateTime date) {
    final weekYear = DateFormat('yyyy-ww').format(date);
    return weekYear;
  }

  int _calculateStreak(List<String> history) {
    if (history.isEmpty) return 0;
    final seenWeeks = history.toSet();
    var streak = 0;
    var cursor = DateTime.now().toUtc();
    while (true) {
      final week = _getIsoWeek(cursor);
      if (!seenWeeks.contains(week)) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 7));
    }
    return streak;
  }
}
