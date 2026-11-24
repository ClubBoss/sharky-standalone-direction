import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum Act0PracticeReminderScheduleV1 { none, nextEvening, tomorrowEvening }

/// The iOS scheduler owns permission and the one pending local reminder.
abstract final class Act0PracticeReminderV1 {
  static const _channel = MethodChannel(
    'com.clubboss.sharky/practice_reminder_v1',
  );

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  // Serialize scheduler calls. Keep a queue tail only while work is in flight.
  static Future<void>? _pending;
  static final enabled = ValueNotifier(false);
  static var _schedule = Act0PracticeReminderScheduleV1.none;

  static Future<bool> sync(Act0PracticeReminderScheduleV1 schedule) {
    _schedule = schedule;
    return _request('sync');
  }

  static Future<bool> setEnabled(bool enabled) =>
      _request('setEnabled', enabled);

  static Future<bool> permissionDenied() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('permissionDenied') ?? false;
  }

  static Future<bool> _request(String method, [bool? argument]) {
    if (!isSupported) return Future<bool>.value(false);
    final pending = _pending;
    Future<bool> invoke() async {
      final value =
          await _channel.invokeMethod<bool>(method, {
            'enabled': argument,
            'schedule': _schedule.name,
          }) ??
          false;
      enabled.value = value;
      return value;
    }

    final next = pending == null ? invoke() : pending.then((_) => invoke());
    late final Future<void> tail;
    void release() {
      if (identical(_pending, tail)) _pending = null;
    }

    tail = next.then<void>(
      (_) => release(),
      onError: (Object _, StackTrace _) => release(),
    );
    _pending = tail;
    return next;
  }
}
