import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

/// Minimal telemetry wrapper around Sentry.
///
/// Planned events to wire:
/// - session_start
/// - session_end
/// - answer_correct
/// - answer_wrong
/// - answer_skip
/// - replay_errors
class Telemetry {
  static bool _enabled = false;
  static TelemetryLogHandler? _overrideHandler;

  static void overrideLogHandler(TelemetryLogHandler? handler) {
    _overrideHandler = handler;
  }

  static Future<void> init({String? dsn}) async {
    if (dsn == null || dsn.isEmpty) return;
    try {
      await SentryFlutter.init((o) => o.dsn = dsn);
      _enabled = true;
    } catch (_) {
      _enabled = false;
    }
  }

  static Future<void> logEvent(
    String name, [
    Map<String, dynamic>? props,
  ]) async {
    final override = _overrideHandler;
    if (override != null) {
      await override(name, props);
      return;
    }
    if (!_enabled) return;
    try {
      await Sentry.captureMessage(
        name,
        withScope: (scope) {
          props?.forEach((key, value) {
            scope.setContexts(key, value);
          });
        },
      );
    } catch (_) {}
  }

  static Future<void> logError(Object error, StackTrace stack) async {
    if (!_enabled) return;
    try {
      await Sentry.captureException(error, stackTrace: stack);
    } catch (_) {}
  }
}

typedef TelemetryLogHandler =
    FutureOr<void> Function(String name, Map<String, dynamic>? props);
