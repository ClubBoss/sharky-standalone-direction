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

  // Serialize permission prompts, lifecycle refreshes and privacy deletion.
  static Future<void> _pending = Future<void>.value();
  static final enabled = ValueNotifier(false);
  static var _schedule = Act0PracticeReminderScheduleV1.none;

  static Future<bool> sync(Act0PracticeReminderScheduleV1 schedule) {
    _schedule = schedule;
    return _request('sync');
  }

  static Future<bool> setEnabled(bool enabled) =>
      _request('setEnabled', enabled);

  static Future<bool> _request(String method, [bool? argument]) {
    if (!isSupported) return Future<bool>.value(false);
    final next = _pending.then((_) async {
      final value =
          await _channel.invokeMethod<bool>(method, {
            'enabled': argument,
            'schedule': _schedule.name,
          }) ??
          false;
      enabled.value = value;
      return value;
    });
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }
}
