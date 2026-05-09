import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/services/user_action_logger.dart';

/// Collects lightweight UI timing metrics and logs periodic summaries.
///
/// Notes:
/// - Uses SchedulerBinding.addTimingsCallback to receive frame timings.
/// - Aggregates average frame time and FPS over a moving window.
/// - Emits events via UserActionLogger under event 'ui_metrics'.
/// - Additionally appends raw samples to a local file (best-effort) to support
///   CI export scripts when running on desktop.
class UiTelemetryService {
  UiTelemetryService._();
  static final UiTelemetryService instance = UiTelemetryService._();

  final List<int> _frameMs = <int>[]; // recent frame durations in ms
  static const int _maxSamples = 240; // ~4 seconds at 60 FPS
  Timer? _flushTimer;
  bool _tracking = false;
  final List<int> _animMs = <int>[]; // transition durations in ms
  final List<_NavSample> _nav = <_NavSample>[]; // navigation durations

  void startFrameTracking(BuildContext context) {
    if (_tracking) return;
    _tracking = true;

    // Capture frame timings into a ring buffer
    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final total = t.totalSpan.inMilliseconds;
        _frameMs.add(total);
        if (_frameMs.length > _maxSamples) {
          _frameMs.removeAt(0);
        }
        // Opportunistically persist raw sample for offline processing
        _appendRawSample(total);
      }
    });

    // Periodically compute and log avg metrics
    _flushTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_frameMs.isEmpty) return;
      final avgMs = _frameMs.reduce((a, b) => a + b) / _frameMs.length;
      final avgFps = avgMs <= 0 ? 0.0 : (1000.0 / avgMs);
      final routeName = _routeName(context);
      await UserActionLogger.instance.logEvent({
        'event': 'ui_metrics',
        'screen': routeName,
        'avgFps': double.parse(avgFps.toStringAsFixed(1)),
        'avgFrameMs': double.parse(avgMs.toStringAsFixed(2)),
        'samples': _frameMs.length,
      });

      // Emit aggregate animation telemetry if available
      if (_animMs.isNotEmpty) {
        final sum = _animMs.fold<int>(0, (a, b) => a + b);
        final avg = sum / _animMs.length;
        try {
          final f = File('ui_metrics_events.jsonl');
          final record = jsonEncode({
            'event': 'ui_anim',
            'avgTransitionMs': double.parse(avg.toStringAsFixed(1)),
            'count': _animMs.length,
          });
          f.writeAsStringSync('$record\n', mode: FileMode.append, flush: false);
        } catch (_) {}
      }

      if (_nav.isNotEmpty) {
        final map = <String, _Agg>{};
        for (final s in _nav) {
          (map[s.route] ??= _Agg()).addMs(s.ms.toDouble(), 1);
        }
        final f = File('ui_metrics_events.jsonl');
        for (final e in map.entries) {
          final rec = jsonEncode({
            'event': 'ui_nav',
            'route': e.key,
            'avgDurationMs': e.value.avgMs,
            'count': e.value.samples,
          });
          try {
            f.writeAsStringSync('$rec\n', mode: FileMode.append, flush: false);
          } catch (_) {}
        }
      }
    });
  }

  void stop() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _tracking = false;
  }

  String _routeName(BuildContext context) {
    final r = ModalRoute.of(context);
    final name = r?.settings.name;
    if (name != null && name.isNotEmpty) return name;
    final w = context.widget;
    return w.runtimeType.toString();
  }

  void _appendRawSample(int ms) {
    try {
      final f = File('ui_metrics_events.jsonl');
      final record = jsonEncode({
        't': DateTime.now().toIso8601String(),
        'ms': ms,
      });
      f.writeAsStringSync('$record\n', mode: FileMode.append, flush: false);
    } catch (_) {
      // Ignore file write errors (mobile sandboxes / permissions)
    }
  }

  /// Record a UI transition duration (in milliseconds) for animation telemetry.
  void recordTransition(int ms) {
    _animMs.add(ms);
    if (_animMs.length > 1000) {
      _animMs.removeRange(0, _animMs.length - 1000);
    }
    try {
      final f = File('ui_metrics_events.jsonl');
      final record = jsonEncode({'event': 'ui_anim', 'ms': ms});
      f.writeAsStringSync('$record\n', mode: FileMode.append, flush: false);
    } catch (_) {}
  }

  /// Record a navigation transition duration with route name.
  void recordNavigation(String route, int durationMs) {
    _nav.add(_NavSample(route, durationMs));
    if (_nav.length > 2000) {
      _nav.removeRange(0, _nav.length - 2000);
    }
    try {
      final f = File('ui_metrics_events.jsonl');
      final record = jsonEncode({
        'event': 'ui_nav',
        'route': route,
        'ms': durationMs,
      });
      f.writeAsStringSync('$record\n', mode: FileMode.append, flush: false);
    } catch (_) {}
  }
}

class _NavSample {
  final String route;
  final int ms;
  _NavSample(this.route, this.ms);
}

class _Agg {
  double _sumMs = 0;
  int _w = 0;
  void addMs(double ms, int weight) {
    final ww = weight > 0 ? weight : 1;
    _sumMs += ms * ww;
    _w += ww;
  }

  double get avgMs =>
      _w == 0 ? 0.0 : double.parse((_sumMs / _w).toStringAsFixed(1));
  int get samples => _w;
}
