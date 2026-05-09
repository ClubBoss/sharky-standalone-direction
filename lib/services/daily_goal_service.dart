import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking daily XP goals with local midnight reset.
class DailyGoalService {
  static final DailyGoalService instance = DailyGoalService._();

  DailyGoalService._();

  static const String _keyProgress = 'daily_goal_progress';
  static const String _keyDate = 'daily_goal_date';
  static const int defaultTarget = 10; // Default daily XP target

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Notifier for UI reactivity.
  final ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);

  /// Initialize the service (call before use).
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await resetIfNeeded();
    final progress = _prefs?.getInt(_keyProgress) ?? 0;
    progressNotifier.value = progress;
    _initialized = true;
  }

  /// Returns today's date as YYYY-MM-DD string.
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Resets progress if the date has changed (local midnight).
  Future<void> resetIfNeeded() async {
    if (_prefs == null) return;

    final storedDate = _prefs!.getString(_keyDate);
    final todayDate = _getTodayDateString();

    if (storedDate != todayDate) {
      // New day detected, reset progress
      await _prefs!.setInt(_keyProgress, 0);
      await _prefs!.setString(_keyDate, todayDate);
      progressNotifier.value = 0;
    }
  }

  /// Returns current progress towards today's goal.
  int getTodayProgress() => _prefs?.getInt(_keyProgress) ?? 0;

  /// Increments today's progress by the given XP amount.
  Future<void> increment(int xp) async {
    if (_prefs == null) return;
    await resetIfNeeded(); // Ensure we're on the current day

    final currentProgress = getTodayProgress();
    final newProgress = currentProgress + xp;
    await _prefs!.setInt(_keyProgress, newProgress);
    progressNotifier.value = newProgress;
  }

  /// Returns true if today's goal is completed.
  bool isCompleted({int target = defaultTarget}) =>
      getTodayProgress() >= target;

  /// Returns time until next reset (local midnight).
  Duration timeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// Formats time until reset as "Xh Ym".
  String formatTimeUntilReset() {
    final duration = timeUntilReset();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// For testing: allows injection of SharedPreferences.
  void setPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// For testing: resets initialization state.
  void resetForTesting() {
    _initialized = false;
    _prefs = null;
  }
}
