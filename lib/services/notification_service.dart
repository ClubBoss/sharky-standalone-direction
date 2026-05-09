import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationPermissionStatus { granted, denied, undetermined }

class NotificationService {
  NotificationService._();

  static const _permissionKey = 'notification_permission_status';
  static final NotificationService instance = NotificationService._();

  /// Initializes the notification infrastructure.
  static Future<void> init() => instance._init();

  Future<void> _init() async {
    // Stubbed for legacy compatibility; real implementation lives in native layer.
  }

  /// Schedules a raw notification entry.
  static Future<void> schedule({
    required int id,
    required DateTime when,
    String? title,
    String? body,
  }) => instance._schedule(id: id, when: when, title: title, body: body);

  Future<void> _schedule({
    required int id,
    required DateTime when,
    String? title,
    String? body,
  }) async {
    log(
      '[NotificationService] schedule (stub) id=$id at ${when.toIso8601String()} '
      'title=${title ?? '-'} body=${body ?? '-'}',
    );
  }

  /// Cancels a notification by identifier.
  static Future<void> cancel(int id) => instance._cancel(id);

  Future<void> _cancel(int id) async {
    log('[NotificationService] cancel (stub) id=$id');
  }

  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_permissionKey);
    switch (value) {
      case 'granted':
        return NotificationPermissionStatus.granted;
      case 'denied':
        return NotificationPermissionStatus.denied;
      default:
        return NotificationPermissionStatus.undetermined;
    }
  }

  Future<NotificationPermissionStatus> requestPermission() async {
    final prefs = await SharedPreferences.getInstance();
    // MVP: always grant and log
    log('[NotificationService] Permission granted (stub)');
    await prefs.setString(_permissionKey, 'granted');
    return NotificationPermissionStatus.granted;
  }

  Future<void> setDenied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_permissionKey, 'denied');
  }

  Future<void> _scheduleDailyReminder({DateTime? now}) async {
    final status = await getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) return;
    final time = now ?? DateTime.now();
    log(
      '[NotificationService] Scheduling 21:00 reminder for ${time.toIso8601String()} (stub)',
    );
  }

  static Future<void> scheduleDailyReminder(
    BuildContext? context, {
    DateTime? now,
  }) => instance._scheduleDailyReminder(now: now);

  Future<void> openSettings() async {
    log('[NotificationService] Opening system settings (stub)');
  }

  Future<void> scheduleReviewReminder() async {
    final status = await getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) return;
    log('[NotificationService] Scheduling review reminder for +24h (stub)');
  }

  static Future<void> scheduleDailyProgress(BuildContext? context) =>
      instance._scheduleDailyProgress(context);

  Future<void> _scheduleDailyProgress(BuildContext? context) async {
    final status = await getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) return;
    log('[NotificationService] Scheduling daily progress notification (stub)');
  }

  static void startRecommendedPackTask(BuildContext? context) =>
      instance._startRecommendedPackTask(context);

  void _startRecommendedPackTask(BuildContext? context) {
    log('[NotificationService] startRecommendedPackTask (stub)');
  }

  // Legacy API shims (stubs) — TODO(legacy-cleanup): remove when callers are updated
  static Future<TimeOfDay> getReminderTime(BuildContext? context) async {
    // Default to 20:00 if not set
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour') ?? 20;
    final minute = prefs.getInt('reminder_minute') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Future<void> updateReminderTime(
    BuildContext? context,
    TimeOfDay time,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    log(
      '[NotificationService] updateReminderTime (stub) => ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
    );
  }
}
