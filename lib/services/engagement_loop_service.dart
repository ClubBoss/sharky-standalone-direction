import 'dart:async';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'xp_history_service.dart';
import 'notification_service.dart';
import 'firebase_lite_telemetry_service.dart';
import 'reward_economy_service.dart';

/// Manages user engagement mechanics: streaks, rewards, and daily habits.
///
/// Tracks daily XP activity, calculates streak lengths, triggers milestone
/// rewards (e.g., 5-day streak = bonus XP), and sends reminder notifications.
///
/// Usage:
/// ```dart
/// final engagement = EngagementLoopService.instance;
/// await engagement.init();
/// await engagement.checkDailyActivity();
/// final streak = await engagement.getCurrentStreak();
/// ```
class EngagementLoopService {
  EngagementLoopService._();

  static final EngagementLoopService instance = EngagementLoopService._();

  static const String _lastActivityKey = 'engagement_last_activity_date';
  static const String _currentStreakKey = 'engagement_current_streak';
  static const String _longestStreakKey = 'engagement_longest_streak';
  static const String _totalRewardsKey = 'engagement_total_rewards';

  // Reward thresholds: day count -> bonus XP
  static const Map<int, int> _streakMilestones = {
    3: 10, // 3-day streak: +10 XP
    5: 25, // 5-day streak: +25 XP
    7: 50, // 7-day streak: +50 XP
    14: 100, // 14-day streak: +100 XP
    30: 250, // 30-day streak: +250 XP
  };

  final XpHistoryService _xpHistory = XpHistoryService();

  /// Initialize the engagement service.
  Future<void> init() async {
    log('[EngagementLoopService] Initialized');
  }

  /// Check if user has activity today and update streak accordingly.
  ///
  /// Call this after any XP-earning action to maintain streak accuracy.
  /// Returns true if streak was updated, false if already marked today.
  Future<bool> checkDailyActivity() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = _dateKey(now);
    final lastActivityStr = prefs.getString(_lastActivityKey);

    // Already marked active today
    if (lastActivityStr == today) {
      return false;
    }

    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int newStreak = 1;

    if (lastActivityStr != null) {
      final lastDate = DateTime.parse(lastActivityStr);
      final daysSinceLast = now.difference(lastDate).inDays;

      if (daysSinceLast == 1) {
        // Consecutive day: increment streak
        newStreak = currentStreak + 1;
      } else if (daysSinceLast == 0) {
        // Same day (edge case): maintain streak
        newStreak = currentStreak;
      }
      // else: gap > 1 day, streak resets to 1
    }

    // Update streak and last activity
    await prefs.setString(_lastActivityKey, today);
    await prefs.setInt(_currentStreakKey, newStreak);

    // Update longest streak if applicable
    final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;
    if (newStreak > longestStreak) {
      await prefs.setInt(_longestStreakKey, newStreak);
    }

    // Emit telemetry
    FirebaseLiteTelemetryService.instance.logEvent(
      'streak_updated',
      params: {
        'current_streak': newStreak,
        'longest_streak': longestStreak,
        'date': today,
      },
    );

    // Check for milestone rewards
    await _checkMilestoneReward(newStreak);

    return true;
  }

  /// Get the current active streak (days with consecutive activity).
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Get the longest streak ever achieved.
  Future<int> getLongestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_longestStreakKey) ?? 0;
  }

  /// Get total rewards earned from streaks.
  Future<int> getTotalRewards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalRewardsKey) ?? 0;
  }

  /// Check if a streak milestone was reached and grant reward.
  Future<void> _checkMilestoneReward(int streak) async {
    if (!_streakMilestones.containsKey(streak)) return;

    final bonusXp = _streakMilestones[streak]!;
    final prefs = await SharedPreferences.getInstance();
    final totalRewards = prefs.getInt(_totalRewardsKey) ?? 0;

    // Award bonus XP via history
    await _xpHistory.addEvent(type: 'streak_milestone', amount: bonusXp);

    // Update total rewards counter
    await prefs.setInt(_totalRewardsKey, totalRewards + bonusXp);

    // Convert streak XP into chips for the reward economy.
    unawaited(
      RewardEconomyService.instance.earnChipsFromXp(
        bonusXp,
        reason: 'streak_milestone',
      ),
    );

    // Emit telemetry
    FirebaseLiteTelemetryService.instance.logEvent(
      'reward_unlocked',
      params: {
        'streak_length': streak,
        'bonus_xp': bonusXp,
        'total_rewards': totalRewards + bonusXp,
      },
    );

    log(
      '[EngagementLoopService] Milestone reward: $streak days = +$bonusXp XP',
    );
  }

  /// Send daily goal reminder notification.
  ///
  /// Schedules a notification at [scheduledTime] if permissions granted.
  Future<void> sendDailyGoalReminder({
    required DateTime scheduledTime,
    String? customMessage,
  }) async {
    final status = await NotificationService.instance.getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) {
      log('[EngagementLoopService] Notification permission not granted');
      return;
    }

    final title = 'Keep Your Streak Alive!';
    final body =
        customMessage ??
        'Complete a quick drill to maintain your ${await getCurrentStreak()}-day streak.';

    await NotificationService.schedule(
      id: 9001, // Unique ID for engagement reminders
      when: scheduledTime,
      title: title,
      body: body,
    );

    // Emit telemetry
    FirebaseLiteTelemetryService.instance.logEvent(
      'daily_goal_reminder_sent',
      params: {
        'scheduled_time': scheduledTime.toIso8601String(),
        'current_streak': await getCurrentStreak(),
      },
    );

    log(
      '[EngagementLoopService] Reminder scheduled for ${scheduledTime.toIso8601String()}',
    );
  }

  /// Cancel any pending daily goal reminders.
  Future<void> cancelDailyGoalReminder() async {
    await NotificationService.cancel(9001);
    log('[EngagementLoopService] Reminder cancelled');
  }

  /// Get daily XP total from history for a specific date.
  Future<int> getDailyXpTotal(DateTime date) async {
    final history = await _xpHistory.getHistory();
    final dateKey = _dateKey(date);

    int total = 0;
    for (final event in history) {
      if (_dateKey(event.timestamp) == dateKey) {
        total += event.amount;
      }
    }

    return total;
  }

  /// Check if user earned XP today.
  Future<bool> hasActivityToday() async {
    final today = await getDailyXpTotal(DateTime.now());
    return today > 0;
  }

  /// Reset engagement state (for testing or user account reset).
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActivityKey);
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_longestStreakKey);
    await prefs.remove(_totalRewardsKey);
    log('[EngagementLoopService] Reset complete');
  }

  /// Convert DateTime to date key (YYYY-MM-DD).
  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
