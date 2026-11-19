import 'dart:async';

/// Local observer for legacy session events used by contract tests.
class Telemetry {
  static TelemetryLogHandler? _overrideHandler;

  static void overrideLogHandler(TelemetryLogHandler? handler) {
    _overrideHandler = handler;
  }

  static Future<void> logEvent(
    String name, [
    Map<String, dynamic>? props,
  ]) async {
    final override = _overrideHandler;
    if (override != null) {
      await override(name, props);
    }
  }
}

typedef TelemetryLogHandler =
    FutureOr<void> Function(String name, Map<String, dynamic>? props);
