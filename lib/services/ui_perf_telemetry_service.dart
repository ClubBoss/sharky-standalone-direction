import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Captures Flutter frame timings and exposes rolling UI performance metrics.
class UiPerfTelemetryService {
  UiPerfTelemetryService._();
  static final UiPerfTelemetryService instance = UiPerfTelemetryService._();

  final ValueNotifier<UiPerfSnapshot> metrics = ValueNotifier<UiPerfSnapshot>(
    UiPerfSnapshot.initial(),
  );

  final List<_FrameSample> _samples = <_FrameSample>[];
  bool _started = false;
  DateTime _lastWrite = DateTime.fromMillisecondsSinceEpoch(0);

  /// Start listening for frame timing callbacks. Safe to call multiple times.
  void start() {
    if (_started) return;
    final binding = WidgetsBinding.instance;
    _started = true;
    binding.addTimingsCallback(_handleTimings);
  }

  void _handleTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    final now = DateTime.now();
    for (final timing in timings) {
      _samples.add(
        _FrameSample(
          timestamp: now,
          frameMs: timing.totalSpan.inMicroseconds / 1000.0,
        ),
      );
    }
    _prune(now);
    _recompute(now);
  }

  void _prune(DateTime now) {
    while (_samples.isNotEmpty &&
        now.difference(_samples.first.timestamp).inSeconds > 60) {
      _samples.removeAt(0);
    }
  }

  void _recompute(DateTime now) {
    if (_samples.isEmpty) return;
    final windowMs = now
        .difference(_samples.first.timestamp)
        .inMilliseconds
        .clamp(1000, 60000);
    final frames = _samples.length;
    final fps = frames * 1000 / windowMs;
    final misses =
        _samples.where((s) => s.frameMs > 16.7).length * 60000 / windowMs;
    final snapshot = UiPerfSnapshot(
      fpsAvg: fps,
      missesPerMinute: misses,
      samples: frames,
      recordedAt: now,
    );
    metrics.value = snapshot;
    if (now.difference(_lastWrite).inSeconds >= 1) {
      _lastWrite = now;
      final payload = jsonEncode({
        'fps_avg': double.parse(snapshot.fpsAvg.toStringAsFixed(1)),
        'frame_misses': double.parse(
          snapshot.missesPerMinute.toStringAsFixed(2),
        ),
        'samples': snapshot.samples,
        'timestamp': snapshot.recordedAt.toIso8601String(),
      });
      unawaited(File('ui_perf_metrics.json').writeAsString(payload));
    }
  }
}

/// Immutable snapshot of recent UI performance metrics.
class UiPerfSnapshot {
  final double fpsAvg;
  final double missesPerMinute;
  final int samples;
  final DateTime recordedAt;

  const UiPerfSnapshot({
    required this.fpsAvg,
    required this.missesPerMinute,
    required this.samples,
    required this.recordedAt,
  });

  factory UiPerfSnapshot.initial() => UiPerfSnapshot(
    fpsAvg: 0,
    missesPerMinute: 0,
    samples: 0,
    recordedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class _FrameSample {
  final DateTime timestamp;
  final double frameMs;

  const _FrameSample({required this.timestamp, required this.frameMs});
}
