import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/session_log_service.dart';
import '../widgets/booster_activation_popup.dart';
import 'booster_service.dart';

class SessionStreakStats {
  final int currentStreak;
  final int longestStreak;
  final int totalDaysActive;

  const SessionStreakStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDaysActive,
  });
}

/// Represents a historical streak milestone achievement.
class StreakMilestoneHistoryEntry {
  final int days;
  final DateTime achievedAt;

  const StreakMilestoneHistoryEntry({
    required this.days,
    required this.achievedAt,
  });
}

class StreakTrackerService {
  StreakTrackerService({SessionLogService? logService})
    : _logService = logService ?? SessionLogService.instance;

  static final StreakTrackerService instance = StreakTrackerService();

  final SessionLogService _logService;

  static const String _lastFreezeDateKey = 'streak_last_freeze_date';
  static const int _freezeCooldownDays = 7;

  SharedPreferences? _prefs;
  static const String _boosterLastStreakKey = 'booster_last_streak_offered';

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SessionStreakStats> compute({List<SessionLogEntry>? override}) async {
    final logs = override ?? await _logService.getLogs();
    final uniqueDays = <DateTime>{};
    for (final log in logs) {
      uniqueDays.add(
        DateTime(log.startTime.year, log.startTime.month, log.startTime.day),
      );
    }
    if (uniqueDays.isEmpty) {
      return const SessionStreakStats(
        currentStreak: 0,
        longestStreak: 0,
        totalDaysActive: 0,
      );
    }
    final days = uniqueDays.toList()..sort((a, b) => a.compareTo(b));
    var current = 1;
    var longest = 1;
    for (var i = 1; i < days.length; i++) {
      final prev = days[i - 1];
      final diff = days[i].difference(prev).inDays;
      if (diff == 1) {
        current += 1;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    var ongoing = 1;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    final lastDay = days.last;
    final diffLast = todayDay.difference(lastDay).inDays;
    if (diffLast == 0) {
      ongoing = current;
    } else if (diffLast == 1) {
      ongoing = current;
    } else {
      ongoing = 0;
    }
    return SessionStreakStats(
      currentStreak: ongoing,
      longestStreak: longest,
      totalDaysActive: days.length,
    );
  }

  Future<int> getCurrentStreak() async {
    final stats = await compute();
    return stats.currentStreak;
  }

  Future<void> checkAndHandleStreakBreak([BuildContext? context]) async {
    await compute();
  }

  Future<void> markActiveToday([BuildContext? context]) async {
    await checkAndHandleStreakBreak(context);
    await checkStreakMilestoneAndOfferBooster();
  }

  /// Check for streak milestone and offer a booster once per milestone level.
  Future<void> checkStreakMilestoneAndOfferBooster() async {
    final current = await getCurrentStreak();
    if (current < 7) return; // milestone at 7+
    await _ensurePrefs();
    final lastOfferedFor = _prefs?.getInt(_boosterLastStreakKey) ?? 0;
    if (lastOfferedFor >= current) return; // already offered for this or higher

    // Offer booster and record
    unawaited(
      BoosterActivationPopup.show(
        type: BoosterType.study,
        source: BoosterRewardSource.streak,
      ),
    );
    await _prefs?.setInt(_boosterLastStreakKey, current);
  }

  /// Get the date of the last freeze, or null if never used.
  Future<DateTime?> getLastFreezeDate() async {
    await _ensurePrefs();
    final timestamp = _prefs?.getInt(_lastFreezeDateKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if freeze is available (cooldown passed and streak requirements met).
  Future<bool> isFreezeAvailable() async {
    final currentStreak = await getCurrentStreak();
    if (currentStreak <= 1) return false; // Need streak > 1

    // Check if session already completed today
    final hasSessionToday = await _hasSessionToday();
    if (hasSessionToday) return false; // Already completed today

    // Check cooldown (7 days since last freeze)
    final lastFreeze = await getLastFreezeDate();
    if (lastFreeze == null) return true; // Never used before

    final now = DateTime.now();
    final daysSinceFreeze = now.difference(lastFreeze).inDays;
    return daysSinceFreeze >= _freezeCooldownDays;
  }

  /// Check if there's a session logged today.
  Future<bool> _hasSessionToday() async {
    final logs = await _logService.getLogs();
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    for (final log in logs) {
      final logDay = DateTime(
        log.startTime.year,
        log.startTime.month,
        log.startTime.day,
      );
      if (logDay.isAtSameMomentAs(todayDay)) {
        return true;
      }
    }
    return false;
  }

  /// Use freeze to preserve streak (if available).
  /// Returns true if freeze was applied, false if unavailable.
  Future<bool> freezeIfAvailable() async {
    final available = await isFreezeAvailable();
    if (!available) return false;

    // Record freeze date
    await _ensurePrefs();
    final now = DateTime.now();
    await _prefs?.setInt(_lastFreezeDateKey, now.millisecondsSinceEpoch);

    // Create a dummy session entry for today to maintain streak
    await _logService.addLog(
      SessionLogEntry(
        startTime: now,
        durationMinutes: 0,
        xpEarned: 0,
        tags: const ['freeze'],
      ),
    );

    return true;
  }

  /// For testing: reset freeze cooldown.
  Future<void> resetFreeze() async {
    await _ensurePrefs();
    await _prefs?.remove(_lastFreezeDateKey);
  }

  Future<List<StreakMilestoneHistoryEntry>> getStreakMilestoneHistory() async {
    // TODO: Connect to real streak milestone history storage.
    return const [];
  }
}
