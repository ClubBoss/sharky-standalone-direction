import 'dart:developer';

import 'package:meta/meta.dart';

import '../services/session_log_service.dart';
import '../services/notification_service.dart';

const _reviewTags = {'theory', 'review'};

class ReviewReminderService {
  ReviewReminderService({
    SessionLogService? logService,
    Future<NotificationPermissionStatus> Function()? getPermissionStatus,
    Future<void> Function()? scheduleReviewNotification,
  }) : _logService = logService ?? SessionLogService.instance,
       _getPermissionStatus =
           getPermissionStatus ??
           NotificationService.instance.getPermissionStatus,
       _scheduleReviewNotification =
           scheduleReviewNotification ??
           NotificationService.instance.scheduleReviewReminder;

  final SessionLogService _logService;
  final Future<NotificationPermissionStatus> Function() _getPermissionStatus;
  final Future<void> Function() _scheduleReviewNotification;

  @visibleForTesting
  DateTime Function() nowProvider = DateTime.now;

  Future<bool> shouldPromptReview({
    Duration window = const Duration(hours: 48),
  }) async {
    final logs = await _logProvider();
    final cutoff = nowProvider().toUtc().subtract(window);
    final count = logs.where((entry) {
      if (entry.startTime.toUtc().isBefore(cutoff)) return false;
      return entry.tags.any((tag) => _reviewTags.contains(tag.toLowerCase()));
    }).length;
    return count >= 2;
  }

  Future<void> scheduleReviewNotification() async {
    final status = await _getPermissionStatus();
    if (status != NotificationPermissionStatus.granted) return;
    log('[ReviewReminder] Scheduling review reminder for +24h (stub)');
    await _scheduleReviewNotification();
  }

  Future<List<SessionLogEntry>> _logProvider() async => _logService.getLogs();
}
