import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

class FirebaseLiteTelemetryService {
  FirebaseLiteTelemetryService._();

  static final FirebaseLiteTelemetryService instance =
      FirebaseLiteTelemetryService._();

  static const int _maxQueueSize = 200;

  final Queue<_TelemetryEvent> _queue = Queue<_TelemetryEvent>();
  FirebaseAnalytics? _analytics;
  bool _initialized = false;
  Timer? _retryTimer;

  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized && _analytics != null) {
      return;
    }
    _initialized = true;
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics?.setAnalyticsCollectionEnabled(true);
      await _flushQueue();
    } catch (e, st) {
      _analytics = null;
      debugPrint('FirebaseLiteTelemetryService.init skipped: $e');
      _scheduleRetry();
      if (kDebugMode) {
        debugPrintStack(
          label: 'FirebaseLiteTelemetryService init stack',
          stackTrace: st,
        );
      }
    }
  }

  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    final event = _TelemetryEvent(_sanitizeName(name), _sanitizeParams(params));
    if (!await _dispatch(event)) {
      _enqueue(event);
    }
  }

  Future<void> logAiDecision(Map<String, Object?> payload) async {
    await logEvent('analytics_telemetry_ai_decision_logged', params: payload);
  }

  Future<void> logPerformanceMetrics(Map<String, Object?> payload) async {
    await logEvent('performance_metrics_logged', params: payload);
  }

  Future<void> logSessionStart() async {
    await logEvent('session_start');
  }

  Future<void> logSessionEnd({
    Duration? duration,
    int? actions,
    bool completed = true,
  }) async {
    await logEvent(
      'session_end',
      params: <String, Object?>{
        if (duration != null) 'duration_ms': duration.inMilliseconds,
        if (actions != null) 'actions': actions,
        'completed': completed,
      },
    );
  }

  Future<void> logSettingChange(String key, Object? value) async {
    await logEvent(
      'setting_change',
      params: <String, Object?>{
        'key': key,
        if (value != null) 'value': value.toString(),
      },
    );
  }

  Future<bool> _dispatch(_TelemetryEvent event) async {
    if (_analytics == null) {
      return false;
    }
    try {
      await _analytics!.logEvent(
        name: event.name,
        parameters: event.parameters,
      );
      return true;
    } catch (e) {
      debugPrint('FirebaseLiteTelemetryService.logEvent failed: $e');
      _scheduleRetry();
      return false;
    }
  }

  Future<void> _flushQueue() async {
    if (_analytics == null || _queue.isEmpty) {
      return;
    }
    final pending = List<_TelemetryEvent>.of(_queue);
    _queue.clear();
    for (final event in pending) {
      final ok = await _dispatch(event);
      if (!ok) {
        _enqueue(event);
        break;
      }
    }
  }

  void _enqueue(_TelemetryEvent event) {
    if (_queue.length >= _maxQueueSize) {
      _queue.removeFirst();
    }
    _queue.addLast(event);
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 15), () {
      _retryTimer = null;
      unawaited(init());
    });
  }

  Map<String, Object> _sanitizeParams(Map<String, Object?>? params) {
    if (params == null || params.isEmpty) {
      return const <String, Object>{};
    }
    final sanitized = <String, Object>{};
    params.forEach((key, value) {
      final cleanKey = _sanitizeKey(key);
      if (cleanKey == null) {
        return;
      }
      if (value == null) {
        return;
      }
      if (value is num || value is bool || value is String) {
        sanitized[cleanKey] = value is String ? value.trim() : value;
      } else {
        sanitized[cleanKey] = value.toString();
      }
    });
    return sanitized;
  }

  String _sanitizeName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'event';
    }
    final sanitized = trimmed
        .replaceAll(RegExp('[^a-zA-Z0-9_]+'), '_')
        .replaceAll(RegExp('_+'), '_')
        .toLowerCase();
    final safe = sanitized.isEmpty ? 'event' : sanitized;
    final maxLength = safe.length > 40 ? 40 : safe.length;
    return safe.substring(0, maxLength);
  }

  String? _sanitizeKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final clean = trimmed
        .replaceAll(RegExp('[^a-zA-Z0-9_]+'), '_')
        .toLowerCase();
    if (clean.isEmpty) {
      return null;
    }
    final maxLength = clean.length > 40 ? 40 : clean.length;
    return clean.substring(0, maxLength);
  }
}

class _TelemetryEvent {
  _TelemetryEvent(String name, Map<String, Object> parameters)
    : name = name,
      parameters = Map<String, Object>.unmodifiable(parameters);

  final String name;
  final Map<String, Object> parameters;
}

/// Local stub used when Firebase Analytics is unavailable.
class FirebaseAnalytics {
  FirebaseAnalytics._();

  static final FirebaseAnalytics instance = FirebaseAnalytics._();

  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    // No-op when Firebase Analytics is unavailable.
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    // No-op when Firebase Analytics is unavailable.
  }
}
