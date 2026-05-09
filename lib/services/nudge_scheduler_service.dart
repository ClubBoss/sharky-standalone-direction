import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'goal_orchestrator.dart';

/// Service for scheduling smart push notifications to boost retention.
/// Triggers reminders when daily goals are incomplete or after inactivity.
class NudgeSchedulerService {
  NudgeSchedulerService._();

  static final NudgeSchedulerService instance = NudgeSchedulerService._();

  static const String _keyLastLogin = 'nudge_last_login_date';
  static const String _keyLastSession = 'nudge_last_session_date';

  // Notification IDs
  static const int _dailyGoalReminderId = 1001;
  static const int _inactivityNudgeId = 1002;

  SharedPreferences? _prefs;

  /// Initialize the service.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Updates the last login timestamp to now.
  Future<void> updateLastLogin() async {
    await init();
    final now = DateTime.now().toIso8601String();
    await _prefs!.setString(_keyLastLogin, now);
    log('[NudgeSchedulerService] Updated last login: $now');
  }

  /// Updates the last session timestamp to now (call after completing a session).
  Future<void> updateLastSession() async {
    await init();
    final now = DateTime.now().toIso8601String();
    await _prefs!.setString(_keyLastSession, now);
    log('[NudgeSchedulerService] Updated last session: $now');
  }

  /// Returns the last login date, or null if never logged in.
  DateTime? getLastLogin() {
    final value = _prefs?.getString(_keyLastLogin);
    return value != null ? DateTime.tryParse(value) : null;
  }

  /// Returns the last session date, or null if no sessions completed.
  DateTime? getLastSession() {
    final value = _prefs?.getString(_keyLastSession);
    return value != null ? DateTime.tryParse(value) : null;
  }

  /// Returns true if daily goal reminder should be shown.
  /// Triggers when goal is not complete and it's within 2h of midnight.
  bool shouldShowDailyGoalReminder({DateTime? now}) {
    final current = now ?? DateTime.now();
    final midnight = DateTime(current.year, current.month, current.day + 1);
    final hoursUntilMidnight = midnight.difference(current).inHours;

    final goalCompleted = GoalOrchestrator.instance.dailyGoalService
        .isCompleted();
    return !goalCompleted && hoursUntilMidnight <= 2;
  }

  /// Returns true if inactivity nudge should be shown.
  /// Triggers when 3+ days have passed since last session.
  bool shouldShowInactivityNudge({DateTime? now}) {
    final lastSession = getLastSession();
    if (lastSession == null) return false;

    final current = now ?? DateTime.now();
    final daysSinceSession = current.difference(lastSession).inDays;
    return daysSinceSession >= 3;
  }

  /// Schedules a daily goal reminder for 2h before midnight (10pm).
  /// Only schedules if goal is not yet completed.
  Future<void> scheduleDailyGoalReminder({
    DateTime? now,
    String languageCode = 'en',
  }) async {
    await init();

    // Check permission
    final status = await NotificationService.instance.getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) {
      log(
        '[NudgeSchedulerService] Permission not granted, skipping daily goal reminder',
      );
      return;
    }

    // Check if goal already completed
    if (GoalOrchestrator.instance.dailyGoalService.isCompleted()) {
      log(
        '[NudgeSchedulerService] Daily goal already completed, skipping reminder',
      );
      return;
    }

    // Calculate reminder time (10pm today, or tomorrow if past 10pm)
    final current = now ?? DateTime.now();
    DateTime reminderTime = DateTime(
      current.year,
      current.month,
      current.day,
      22, // 10pm
      0,
    );

    // If already past 10pm, schedule for tomorrow
    if (current.isAfter(reminderTime)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    // Localized notification text
    final isRussian = languageCode.startsWith('ru');
    final title = isRussian
        ? '⏰ Цель дня истекает!'
        : '⏰ Daily goal expires soon!';
    final body = isRussian
        ? 'До сброса цели 2ч! Успей заработать +10 XP.'
        : 'Daily goal expires in 2h! +10 XP is within reach.';

    await NotificationService.schedule(
      id: _dailyGoalReminderId,
      when: reminderTime,
      title: title,
      body: body,
    );

    log(
      '[NudgeSchedulerService] Scheduled daily goal reminder for ${reminderTime.toIso8601String()}',
    );
  }

  /// Schedules an inactivity nudge if user hasn't been active for 3+ days.
  Future<void> scheduleInactivityNudge({
    DateTime? now,
    String languageCode = 'en',
  }) async {
    await init();

    // Check permission
    final status = await NotificationService.instance.getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) {
      log(
        '[NudgeSchedulerService] Permission not granted, skipping inactivity nudge',
      );
      return;
    }

    final lastSession = getLastSession();
    if (lastSession == null) {
      log(
        '[NudgeSchedulerService] No session history, skipping inactivity nudge',
      );
      return;
    }

    final current = now ?? DateTime.now();
    final daysSinceSession = current.difference(lastSession).inDays;

    if (daysSinceSession < 3) {
      log(
        '[NudgeSchedulerService] Last session was $daysSinceSession days ago, not scheduling nudge yet',
      );
      return;
    }

    // Schedule for 1 hour from now
    final nudgeTime = current.add(const Duration(hours: 1));

    // Localized notification text
    final isRussian = languageCode.startsWith('ru');
    final title = isRussian ? '🎯 Скучаем по тебе!' : '🎯 We miss you!';
    final body = isRussian
        ? 'Твои покерные навыки ждут! Вернись и заработай XP.'
        : 'Your poker skills are waiting! Come back and earn XP.';

    await NotificationService.schedule(
      id: _inactivityNudgeId,
      when: nudgeTime,
      title: title,
      body: body,
    );

    log(
      '[NudgeSchedulerService] Scheduled inactivity nudge for ${nudgeTime.toIso8601String()} (${daysSinceSession}d inactive)',
    );
  }

  /// Cancels the daily goal reminder.
  Future<void> cancelDailyGoalReminder() async {
    await NotificationService.cancel(_dailyGoalReminderId);
    log('[NudgeSchedulerService] Cancelled daily goal reminder');
  }

  /// Cancels the inactivity nudge.
  Future<void> cancelInactivityNudge() async {
    await NotificationService.cancel(_inactivityNudgeId);
    log('[NudgeSchedulerService] Cancelled inactivity nudge');
  }

  /// Reschedules all applicable reminders based on current state.
  Future<void> rescheduleAll({String languageCode = 'en'}) async {
    await init();
    await scheduleDailyGoalReminder(languageCode: languageCode);
    await scheduleInactivityNudge(languageCode: languageCode);
  }

  /// For testing: allows injection of SharedPreferences.
  void setPrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// For testing: resets initialization state.
  void resetForTesting() {
    _prefs = null;
  }
}
