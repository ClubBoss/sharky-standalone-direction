import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import 'act0_practice_reminder_plan_v1.dart';
export 'act0_practice_reminder_plan_v1.dart';

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

  static String? _body;
  static const defaultTime = TimeOfDay(hour: 18, minute: 0);
  static final time = ValueNotifier(defaultTime);

  static Future<bool> sync(
    Act0PracticeReminderScheduleV1 schedule, {
    String? body,
  }) {
    _schedule = schedule;
    _body = body;
    return _enqueue('sync');
  }

  static Future<bool> setEnabled(bool enabled, {bool reset = false}) =>
      _enqueue('setEnabled', argument: enabled, reset: reset);

  static Future<bool> setTime(TimeOfDay value) =>
      _enqueue('setTime', selectedTime: value);

  /// Restore the native opt-in after a cold Flutter process start. This uses
  /// the same serialized tail as writes, so a late read cannot overtake a
  /// disable or reset already queued by the app.
  static Future<bool> refreshEnabled() => _enqueue('getEnabled');

  static Future<void> refreshTime() async {
    if (!isSupported) return;
    final value = await _channel.invokeMethod<Object>('getTime');
    if (value is List &&
        value.length == 2 &&
        value[0] is int &&
        value[1] is int) {
      final hour = value[0] as int;
      final minute = value[1] as int;
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
        time.value = TimeOfDay(hour: hour, minute: minute);
      }
    }
  }

  static Future<bool> permissionDenied() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('permissionDenied') ?? false;
  }

  static Future<bool> _enqueue(
    String method, {
    bool? argument,
    bool reset = false,
    TimeOfDay? selectedTime,
  }) {
    if (!isSupported) return Future<bool>.value(false);
    final pending = _pending;
    Future<bool> invoke() async {
      final value =
          await _channel.invokeMethod<bool>(method, {
            'enabled': argument,
            'schedule': _schedule.name,
            'body': _body,
            'reset': reset,
            if (selectedTime != null) 'hour': selectedTime.hour,
            if (selectedTime != null) 'minute': selectedTime.minute,
          }) ??
          false;
      enabled.value = value;
      if (reset) {
        _schedule = Act0PracticeReminderScheduleV1.none;
        _body = null;
        time.value = defaultTime;
      } else if (selectedTime != null) {
        time.value = selectedTime;
      }
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
