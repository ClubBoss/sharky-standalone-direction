import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'xp_history_service.dart';

/// Service for scheduling local notifications to remind users to earn XP.
///
/// Features:
/// - Daily reminder at 20:00 if no XP earned today
/// - Weekly reminder on Sunday at 18:00 if no XP earned this week (Mon-Sun)
/// - Automatically cancels reminders if XP is earned
/// - Timezone-aware scheduling
class XpNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int _dailyReminderId = 1001;
  static const int _weeklyReminderId = 1002;

  /// Initialize the notification plugin.
  /// Call this once at app startup.
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  /// Request notification permissions (iOS).
  static Future<bool> requestPermissions() async {
    if (await _notifications
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false) {
      return true;
    }

    if (await _notifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false) {
      return true;
    }

    return false;
  }

  /// Schedule a daily reminder at 20:00 if no XP earned today.
  /// Cancels existing reminder if XP > 0.
  static Future<void> scheduleDailyReminderIfNeeded() async {
    final historyService = XpHistoryService();
    final history = await historyService.getHistory();

    // Check if any XP earned today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int todayXp = 0;
    for (final event in history) {
      final eventDate = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      if (eventDate == today) {
        todayXp += event.amount;
      }
    }

    if (todayXp > 0) {
      // User earned XP today, cancel reminder
      await _notifications.cancel(_dailyReminderId);
      return;
    }

    // Schedule reminder for 20:00 today (or tomorrow if past 20:00)
    var scheduledTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (scheduledTime.isBefore(now)) {
      // Already past 20:00, schedule for tomorrow
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: _dailyReminderId,
      title: 'Заработайте XP сегодня',
      body: 'Вы сегодня не заработали XP — возвращайтесь и потренируйтесь!',
      scheduledTime: scheduledTime,
    );
  }

  /// Schedule a weekly reminder on Sunday at 18:00 if no XP earned this week.
  /// Cancels existing reminder if XP > 0.
  static Future<void> scheduleWeeklyReminderIfNeeded() async {
    final historyService = XpHistoryService();
    final history = await historyService.getHistory();

    // Get Monday of current week
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: weekday - 1));
    final mondayNormalized = DateTime(monday.year, monday.month, monday.day);

    // Sum XP from Monday to now
    int weekXp = 0;
    for (final event in history) {
      final eventDate = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      if (!eventDate.isBefore(mondayNormalized)) {
        weekXp += event.amount;
      }
    }

    if (weekXp > 0) {
      // User earned XP this week, cancel reminder
      await _notifications.cancel(_weeklyReminderId);
      return;
    }

    // Schedule reminder for Sunday at 18:00
    final daysUntilSunday = 7 - weekday; // 0 if today is Sunday
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      18,
      0,
    ).add(Duration(days: daysUntilSunday));

    // If it's Sunday and past 18:00, schedule for next Sunday
    if (weekday == 7 && now.hour >= 18) {
      scheduledTime = scheduledTime.add(const Duration(days: 7));
    }

    await _scheduleNotification(
      id: _weeklyReminderId,
      title: 'Цель недели: XP',
      body:
          'Неделя почти закончилась, а у вас 0 XP. Попробуйте выполнить хотя бы одну тренировку.',
      scheduledTime: scheduledTime,
    );
  }

  /// Cancel all XP-related reminders.
  static Future<void> cancelAllXpReminders() async {
    await _notifications.cancel(_dailyReminderId);
    await _notifications.cancel(_weeklyReminderId);
  }

  /// Internal: Schedule a notification at a specific time.
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'xp_reminders',
      'XP Reminders',
      channelDescription: 'Напоминания о заработке XP',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Silently fail if scheduling fails (e.g., permissions denied)
      // In production, you might want to log this
    }
  }
}
