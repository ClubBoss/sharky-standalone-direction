import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _returnLoopStreakKey = 'return_loop_streak';
const _returnLoopLastActiveKey = 'return_loop_last_active_ymd';
const _returnLoopDailyHandDateKey = 'return_loop_daily_hand_date';
const _returnLoopDailyHandIndexKey = 'return_loop_daily_hand_index';
const _dailyHandPoolSize = 30;

class ReturnLoopServiceV1 {
  ReturnLoopServiceV1._();

  static final instance = ReturnLoopServiceV1._();

  DateTime Function() _clock = DateTime.now;

  int _currentStreak = 0;
  int _dailyHandIndex = 0;

  int get currentStreak => _currentStreak;
  int get todayDailyHandIndex => _dailyHandIndex;

  Future<void> updateOnAppOpenOrProgressMapShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = _clock();
    final today = _localYmd(now);
    final yesterday = _localYmd(now.subtract(const Duration(days: 1)));
    final lastActive = prefs.getString(_returnLoopLastActiveKey);
    if (lastActive == today) {
      // No change to streak.
    } else {
      if (lastActive == yesterday) {
        _currentStreak = prefs.getInt(_returnLoopStreakKey) ?? 0;
        _currentStreak++;
      } else {
        _currentStreak = 1;
      }
      await prefs.setInt(_returnLoopStreakKey, _currentStreak);
      await prefs.setString(_returnLoopLastActiveKey, today);
    }
    _currentStreak = prefs.getInt(_returnLoopStreakKey) ?? _currentStreak;

    final storedDate = prefs.getString(_returnLoopDailyHandDateKey);
    if (storedDate == today) {
      _dailyHandIndex =
          prefs.getInt(_returnLoopDailyHandIndexKey) ??
          _computeDailyHandIndex(today);
    } else {
      _dailyHandIndex = _computeDailyHandIndex(today);
      await prefs.setString(_returnLoopDailyHandDateKey, today);
      await prefs.setInt(_returnLoopDailyHandIndexKey, _dailyHandIndex);
    }
  }

  int _computeDailyHandIndex(String dayKey) {
    final hash = _stableHash(dayKey);
    return hash % _dailyHandPoolSize;
  }

  int _stableHash(String value) {
    const offset = 0x811c9dc5;
    const prime = 0x01000193;
    var hash = offset;
    final bytes = utf8.encode(value);
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }

  String _localYmd(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  @visibleForTesting
  int stableHashFor(String value) => _stableHash(value);

  @visibleForTesting
  int dailyHandIndexFor(String dayKey) => _computeDailyHandIndex(dayKey);

  @visibleForTesting
  void overrideClock(DateTime Function() clockFn) {
    _clock = clockFn;
  }

  @visibleForTesting
  void resetForTesting() {
    _clock = DateTime.now;
    _currentStreak = 0;
    _dailyHandIndex = 0;
  }
}
