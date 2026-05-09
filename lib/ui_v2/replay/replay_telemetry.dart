import 'dart:convert';
import 'dart:io';

/// Telemetry tracker for replay/review mode metrics.
///
/// Logs replay_duration_ms, user_scrub_actions, review_focus_ratio
/// to tools/_reports/replay_metrics.json.
class ReplayTelemetry {
  ReplayTelemetry() : _startTime = DateTime.now();

  final DateTime _startTime;
  int _scrubActions = 0;
  int _totalFocusMs = 0;
  DateTime? _lastFocusTime;
  bool _isFocused = false;

  /// Record a user scrub action (timeline interaction).
  void recordScrubAction() {
    _scrubActions++;
  }

  /// Mark replay view as focused (user actively watching).
  void setFocused(bool focused) {
    if (_isFocused == focused) return;

    if (focused) {
      _lastFocusTime = DateTime.now();
    } else if (_lastFocusTime != null) {
      final focusDuration = DateTime.now()
          .difference(_lastFocusTime!)
          .inMilliseconds;
      _totalFocusMs += focusDuration;
      _lastFocusTime = null;
    }

    _isFocused = focused;
  }

  /// Calculate review focus ratio (time focused / total time).
  double get reviewFocusRatio {
    final totalMs = DateTime.now().difference(_startTime).inMilliseconds;
    if (totalMs == 0) return 0.0;

    var focusMs = _totalFocusMs;
    // Add current focus session if still focused
    if (_isFocused && _lastFocusTime != null) {
      focusMs += DateTime.now().difference(_lastFocusTime!).inMilliseconds;
    }

    return (focusMs / totalMs).clamp(0.0, 1.0);
  }

  /// Get total replay duration in milliseconds.
  int get replayDurationMs =>
      DateTime.now().difference(_startTime).inMilliseconds;

  /// Get total user scrub actions.
  int get userScrubActions => _scrubActions;

  /// Write replay metrics to JSON file.
  Future<void> writeMetricsReport({
    int? totalSnapshots,
    int? snapshotsViewed,
    double? playbackSpeed,
  }) async {
    final reportsDir = Directory('tools/_reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File('tools/_reports/replay_metrics.json');

    // Calculate final focus ratio before writing
    if (_isFocused && _lastFocusTime != null) {
      final focusDuration = DateTime.now()
          .difference(_lastFocusTime!)
          .inMilliseconds;
      _totalFocusMs += focusDuration;
    }

    final json = {
      'replay_duration_ms': replayDurationMs,
      'user_scrub_actions': userScrubActions,
      'review_focus_ratio': reviewFocusRatio,
      'timestamp': DateTime.now().toIso8601String(),
      if (totalSnapshots != null) 'total_snapshots': totalSnapshots,
      if (snapshotsViewed != null) 'snapshots_viewed': snapshotsViewed,
      if (playbackSpeed != null) 'final_playback_speed': playbackSpeed,
    };

    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      // ASCII-only log
      stdout.writeln('[ReplayTelemetry] Wrote metrics to ${file.path}');
      stdout.writeln('  Duration: ${replayDurationMs}ms');
      stdout.writeln('  Scrub actions: $userScrubActions');
      stdout.writeln(
        '  Focus ratio: ${(reviewFocusRatio * 100).toStringAsFixed(1)}%',
      );
      if (totalSnapshots != null) {
        stdout.writeln('  Total snapshots: $totalSnapshots');
      }
      if (snapshotsViewed != null) {
        stdout.writeln('  Snapshots viewed: $snapshotsViewed');
      }
    } catch (e) {
      stderr.writeln('[ReplayTelemetry] Failed to write metrics: $e');
    }
  }

  /// Read existing replay metrics from file.
  static Future<Map<String, dynamic>?> readMetricsReport() async {
    final file = File('tools/_reports/replay_metrics.json');
    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      stderr.writeln('[ReplayTelemetry] Failed to read metrics: $e');
      return null;
    }
  }
}
