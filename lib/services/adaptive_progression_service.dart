import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

/// Computes a rolling Performance Index (PI) from recent sessions and suggests
/// difficulty adjustments for the adaptive learning path.
class AdaptiveProgressionService {
  AdaptiveProgressionService._();

  static final AdaptiveProgressionService instance =
      AdaptiveProgressionService._();

  static const int _window = 5;
  final List<_PiEntry> _entries = <_PiEntry>[];
  void Function(String, Map<String, Object?>?)? _telemetryOverride;
  final ValueNotifier<AdaptiveFeedbackSignal?> feedbackNotifier =
      ValueNotifier<AdaptiveFeedbackSignal?>(null);

  /// Processes a telemetry payload that contains session metrics.
  ///
  /// Expected keys:
  /// - `session_accuracy` (0-1 double)
  /// - `ev_delta` (double, positive = winning)
  /// - `time_spent` (seconds, > 0)
  /// - optional `session_id` to deduplicate
  void ingestTelemetry(Map<String, Object?> payload) {
    final accuracy = _asDouble(payload['session_accuracy']);
    final evDelta = _asDouble(payload['ev_delta']);
    final timeSpent = _asDouble(payload['time_spent']);
    final sessionId = payload['session_id']?.toString();
    if (accuracy == null || evDelta == null || timeSpent == null) {
      return;
    }
    recordSession(
      accuracy: accuracy,
      evDelta: evDelta,
      timeSpentSeconds: timeSpent,
      sessionId: sessionId,
    );
  }

  /// Directly record a session result. Returns the computed PI or `null` when
  /// the session is ignored (e.g., duplicate sessionId).
  double? recordSession({
    required double accuracy,
    required double evDelta,
    required double timeSpentSeconds,
    String? sessionId,
  }) {
    final pi = _computeSessionPi(accuracy, evDelta, timeSpentSeconds);
    final appended = _appendPi(pi, sessionId: sessionId);
    if (!appended) {
      return null;
    }
    final recommendation = recommendDifficultyDelta();
    _emitTelemetry(pi, recommendation);
    feedbackNotifier.value = AdaptiveFeedbackSignal(
      delta: recommendation,
      timestamp: DateTime.now(),
    );
    return pi;
  }

  /// Current smoothed PI (average of last [_window] sessions).
  double get rollingPerformanceIndex {
    if (_entries.isEmpty) return 0;
    final total = _entries.fold<double>(0, (sum, entry) => sum + entry.pi);
    return total / _entries.length;
  }

  /// Suggests the next difficulty delta (+1, 0, -1) based on PI thresholds.
  int recommendDifficultyDelta() {
    final pi = rollingPerformanceIndex;
    const double upper = 0.0025; // Performing very well
    const double lower = 0.0010; // Struggling
    if (pi >= upper) return 1;
    if (pi <= lower) return -1;
    return 0;
  }

  List<double> get history =>
      List<double>.unmodifiable(_entries.map((entry) => entry.pi));

  @visibleForTesting
  void clearForTest() {
    _entries.clear();
  }

  @visibleForTesting
  void setTelemetryOverride(
    void Function(String, Map<String, Object?>?)? callback,
  ) {
    _telemetryOverride = callback;
  }

  double _computeSessionPi(
    double accuracy,
    double evDelta,
    double timeSeconds,
  ) {
    if (timeSeconds <= 0) return 0;
    final boundedAccuracy = accuracy.clamp(0.0, 1.0);
    final weighted = boundedAccuracy * evDelta;
    final pi = weighted / timeSeconds;
    if (pi.isNaN || !pi.isFinite) return 0;
    return pi;
  }

  bool _appendPi(double value, {String? sessionId}) {
    if (value.isNaN || !value.isFinite) return false;
    if (sessionId != null &&
        _entries.any((entry) => entry.sessionId == sessionId)) {
      return false;
    }
    _entries.add(_PiEntry(value, sessionId));
    if (_entries.length > _window) {
      _entries.removeAt(0);
    }
    return true;
  }

  void _emitTelemetry(double sessionPi, int recommendation) {
    final payload = <String, Object?>{
      'session_pi': sessionPi,
      'rolling_pi': rollingPerformanceIndex,
      'history_len': _entries.length,
      'recommendation': recommendation,
    };
    final callback = _telemetryOverride;
    if (callback != null) {
      callback(TelemetryEvents.adaptiveDifficultyUpdated, payload);
      return;
    }
    FirebaseLiteTelemetryService.instance.logEvent(
      TelemetryEvents.adaptiveDifficultyUpdated,
      params: payload,
    );
  }

  double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class _PiEntry {
  _PiEntry(this.pi, this.sessionId);

  final double pi;
  final String? sessionId;
}

class AdaptiveFeedbackSignal {
  AdaptiveFeedbackSignal({required this.delta, required this.timestamp});

  final int delta;
  final DateTime timestamp;
}
