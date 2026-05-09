// no dart:math needed

import 'package:shared_preferences/shared_preferences.dart';

import 'chips_wallet_service.dart';
import 'energy_service.dart';
import 'subscription_status_v1.dart';
import 'user_action_logger.dart';
import 'notification_service.dart';

/// EngagementNotifications manages v2 notification toggles and sending test pushes.
class EngagementNotifications {
  static const keyDailyEnabled = 'notif_daily_enabled';
  static const keyEnergyEnabled = 'notif_energy_enabled';
  static const keyWeeklyEnabled = 'notif_weekly_enabled';

  /// Returns a map of the three toggle states.
  static Future<Map<String, bool>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'daily': prefs.getBool(keyDailyEnabled) ?? true,
      'energy': prefs.getBool(keyEnergyEnabled) ?? true,
      'weekly': prefs.getBool(keyWeeklyEnabled) ?? true,
    };
  }

  /// Sends a test notification (stub) and logs telemetry.
  static Future<void> sendTestNotification() async {
    final when = DateTime.now().add(const Duration(seconds: 2));
    await NotificationService.schedule(
      id: 200,
      when: when,
      title: 'Test Notification',
      body: 'Hello from Engagement Tools',
    );
    await UserActionLogger.instance.logEvent({
      'event': 'user_notification_sent',
      'kind': 'test',
    });
  }
}

/// Types of daily challenges.
enum DailyChallengeType { winHands, earnXp, completePack }

class DailyChallenge {
  final DailyChallengeType type;
  final int goal;
  final int progress;
  final String label; // ASCII label for UI/dashboard
  const DailyChallenge({
    required this.type,
    required this.goal,
    required this.progress,
    required this.label,
  });
}

/// DailyChallengeEngine: generates and tracks one mission per day.
class DailyChallengeEngine {
  DailyChallengeEngine._();
  static final DailyChallengeEngine instance = DailyChallengeEngine._();

  static const _dateKey = 'daily_challenge_date';
  static const _progressKey = 'daily_challenge_progress';
  static const _goalKey = 'daily_challenge_goal';
  static const _typeKey = 'daily_challenge_type';

  Future<DailyChallenge> getTodayChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStr = prefs.getString(_dateKey);
    final DateTime? saved = dateStr != null ? DateTime.tryParse(dateStr) : null;

    int goal = prefs.getInt(_goalKey) ?? 0;
    int progress = prefs.getInt(_progressKey) ?? 0;
    int typeIndex = prefs.getInt(_typeKey) ?? -1;

    if (saved == null ||
        _isDifferentDay(saved, today) ||
        goal <= 0 ||
        typeIndex < 0) {
      final gen = _generateChallenge();
      goal = gen.goal;
      progress = 0;
      typeIndex = gen.type.index;
      await prefs.setString(_dateKey, today.toIso8601String());
      await prefs.setInt(_goalKey, goal);
      await prefs.setInt(_progressKey, progress);
      await prefs.setInt(_typeKey, typeIndex);
    }

    final type = DailyChallengeType.values[typeIndex];
    final label = _labelFor(type, goal);
    return DailyChallenge(
      type: type,
      goal: goal,
      progress: progress,
      label: label,
    );
  }

  /// Force-generate a fresh challenge for today (used by Dev Menu).
  Future<DailyChallenge> forceNewChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gen = _generateChallenge();
    await prefs.setString(_dateKey, today.toIso8601String());
    await prefs.setInt(_goalKey, gen.goal);
    await prefs.setInt(_progressKey, 0);
    await prefs.setInt(_typeKey, gen.type.index);
    return DailyChallenge(
      type: gen.type,
      goal: gen.goal,
      progress: 0,
      label: _labelFor(gen.type, gen.goal),
    );
  }

  /// Update progress by [delta] (defaults to +1 for event-based progress).
  Future<void> updateProgress({int delta = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = (prefs.getInt(_progressKey) ?? 0) + delta;
    await prefs.setInt(_progressKey, progress);
  }

  /// Completes the challenge if progress >= goal. Rewards chips and energy and logs telemetry.
  Future<bool> completeChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt(_goalKey) ?? 0;
    final progress = prefs.getInt(_progressKey) ?? 0;
    if (goal <= 0 || progress < goal) return false;

    // Reward: +100 chips
    await ChipsWalletService().addChips(100);
    // Reward: +1 energy if not premium
    final status = await SubscriptionServiceV1.getStatusV1();
    final isEntitled = status.isEntitled;
    if (!isEntitled) {
      await EnergyService().restoreEnergy(1);
    }

    await UserActionLogger.instance.logEvent({
      'event': 'challenge_completed',
      'goal': goal,
      'progress': progress,
    });

    // Reset progress to prevent re-claim
    await prefs.setInt(_progressKey, goal);
    return true;
  }

  bool _isDifferentDay(DateTime a, DateTime b) =>
      a.year != b.year || a.month != b.month || a.day != b.day;

  _Generated _generateChallenge() {
    // Rotate evenly between 3 types using day-of-year
    final day = int.parse(
      DateTime.now()
          .difference(DateTime(DateTime.now().year))
          .inDays
          .toString(),
    );
    final type = DailyChallengeType.values[day % 3];
    switch (type) {
      case DailyChallengeType.winHands:
        return _Generated(type, 3);
      case DailyChallengeType.earnXp:
        return _Generated(type, 500);
      case DailyChallengeType.completePack:
        return _Generated(type, 1);
    }
  }

  String _labelFor(DailyChallengeType type, int goal) {
    switch (type) {
      case DailyChallengeType.winHands:
        return 'Win $goal Hands';
      case DailyChallengeType.earnXp:
        return 'Earn $goal XP';
      case DailyChallengeType.completePack:
        return 'Complete $goal Pack';
    }
  }
}

class _Generated {
  final DailyChallengeType type;
  final int goal;
  _Generated(this.type, this.goal);
}

/// StreakTrackerV2: maintains current and best streak and last active date.
class StreakTrackerV2 {
  static const keyCurrent = 'streak_current';
  static const keyBest = 'streak_best';
  static const keyLast = 'streak_last_active';

  /// Computes and updates streak counters based on last_active and today.
  static Future<int> markActiveToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStr = prefs.getString(keyLast);
    final last = lastStr != null ? DateTime.tryParse(lastStr) : null;
    int current = prefs.getInt(keyCurrent) ?? 0;
    int best = prefs.getInt(keyBest) ?? 0;

    bool continued = false;
    if (last == null) {
      current = 1;
      continued = true;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // already active today
      } else if (diff == 1) {
        current += 1;
        continued = true;
      } else {
        current = 1; // reset
        continued = true; // starting a new streak
      }
    }

    best = current > best ? current : best;
    await prefs.setString(keyLast, today.toIso8601String());
    await prefs.setInt(keyCurrent, current);
    await prefs.setInt(keyBest, best);

    if (continued) {
      await UserActionLogger.instance.logEvent({
        'event': 'streak_continued',
        'current': current,
        'best': best,
      });
    }
    return current;
  }

  static Future<Map<String, int>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'current': prefs.getInt(keyCurrent) ?? 0,
      'best': prefs.getInt(keyBest) ?? 0,
    };
  }
}
