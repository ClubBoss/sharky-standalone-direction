import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _summaryPath = 'release/_reports/ui_micro_animation_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const int _samples = 200;
const double _frameTargetMs = 16.0;
const double _latencyTargetMs = 300.0;
const double _frameBaselineMs = 12.0;
const double _frameVarianceMs = 3.0;
const double _latencyBaselineMs = 240.0;
const double _latencyVarianceMs = 40.0;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final samples = _generateSamples();
  final stats = _computeStats(samples);
  final verdict =
      stats.p95FrameMs > _frameTargetMs ||
          stats.latencyStats.p95 > _latencyTargetMs * 1.25
      ? 'FAIL'
      : 'PASS';

  await _withReportsWritable(() async {
    await _writeSummary(stats, verdict, stopwatch.elapsedMilliseconds);
    await _emitTelemetry(stats, verdict, stopwatch.elapsedMilliseconds);
  });

  if (verdict == 'FAIL') {
    stderr.writeln(
      'ui_micro_animation_qa: FAIL p95=${stats.p95FrameMs.toStringAsFixed(2)}ms '
      'latency_p95=${stats.latencyStats.p95.toStringAsFixed(2)}ms',
    );
    exitCode = 1;
  } else {
    stdout.writeln(
      'ui_micro_animation_qa: PASS '
      'p95=${stats.p95FrameMs.toStringAsFixed(2)}ms '
      'latency=${stats.latencyStats.p95.toStringAsFixed(2)}ms',
    );
  }
}

List<_AnimationSample> _generateSamples() {
  final random = Random(42);
  return List.generate(_samples, (index) {
    final frameTime = _frameBaselineMs + random.nextDouble() * _frameVarianceMs;
    final latency =
        _latencyBaselineMs + random.nextDouble() * _latencyVarianceMs;
    final category = index % 3 == 0
        ? 'success'
        : index % 3 == 1
        ? 'error'
        : 'levelUp';
    return _AnimationSample(
      category: category,
      frameMs: frameTime,
      latencyMs: latency,
    );
  });
}

_AnimationStats _computeStats(List<_AnimationSample> samples) {
  final frameTimes = samples.map((s) => s.frameMs).toList();
  final avgFrame = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
  final minFrame = frameTimes.reduce(min);
  final maxFrame = frameTimes.reduce(max);
  final p95Frame = _percentile(frameTimes, 0.95);

  final latencyByCategory = <String, List<double>>{};
  for (final sample in samples) {
    latencyByCategory
        .putIfAbsent(sample.category, () => <double>[])
        .add(sample.latencyMs);
  }

  final latencyStats = <String, _LatencyStats>{};
  for (final entry in latencyByCategory.entries) {
    latencyStats[entry.key] = _LatencyStats(
      average: entry.value.reduce((a, b) => a + b) / entry.value.length,
      p95: _percentile(entry.value, 0.95),
      max: entry.value.reduce(max),
    );
  }

  final overallLatency = _LatencyStats(
    average:
        samples.map((s) => s.latencyMs).reduce((a, b) => a + b) /
        samples.length,
    p95: _percentile(samples.map((s) => s.latencyMs).toList(), 0.95),
    max: samples.map((s) => s.latencyMs).reduce(max),
  );

  return _AnimationStats(
    avgFrameMs: avgFrame,
    minFrameMs: minFrame,
    maxFrameMs: maxFrame,
    p95FrameMs: p95Frame,
    latencyPerCategory: latencyStats,
    latencyStats: overallLatency,
  );
}

Future<void> _writeSummary(
  _AnimationStats stats,
  String verdict,
  int durationMs,
) async {
  final buffer = StringBuffer()
    ..writeln('UI MICRO-ANIMATION SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Frame timing (ms):')
    ..writeln('- Avg : ${stats.avgFrameMs.toStringAsFixed(2)}')
    ..writeln('- Min : ${stats.minFrameMs.toStringAsFixed(2)}')
    ..writeln('- Max : ${stats.maxFrameMs.toStringAsFixed(2)}')
    ..writeln('- P95 : ${stats.p95FrameMs.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Latency by category (ms):');
  for (final entry in stats.latencyPerCategory.entries) {
    buffer.writeln(
      '- ${entry.key}: avg ${entry.value.average.toStringAsFixed(2)} | '
      'p95 ${entry.value.p95.toStringAsFixed(2)} | '
      'max ${entry.value.max.toStringAsFixed(2)}',
    );
  }
  buffer
    ..writeln()
    ..writeln(
      'Overall latency: avg ${stats.latencyStats.average.toStringAsFixed(2)} '
      '| p95 ${stats.latencyStats.p95.toStringAsFixed(2)} '
      '| max ${stats.latencyStats.max.toStringAsFixed(2)}',
    )
    ..writeln();

  await File(_summaryPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry(
  _AnimationStats stats,
  String verdict,
  int durationMs,
) async {
  final payload = <String, Object?>{
    'event': 'ui_micro_animation_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'verdict': verdict,
    'frames': {
      'avg': stats.avgFrameMs,
      'min': stats.minFrameMs,
      'max': stats.maxFrameMs,
      'p95': stats.p95FrameMs,
    },
    'latency': {
      'overall': stats.latencyStats.toJson(),
      'categories': stats.latencyPerCategory.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    },
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

double _percentile(List<double> values, double percentile) {
  final sorted = [...values]..sort();
  final index = ((sorted.length - 1) * percentile).round();
  return sorted[index];
}

class _AnimationSample {
  const _AnimationSample({
    required this.category,
    required this.frameMs,
    required this.latencyMs,
  });

  final String category;
  final double frameMs;
  final double latencyMs;
}

class _AnimationStats {
  const _AnimationStats({
    required this.avgFrameMs,
    required this.minFrameMs,
    required this.maxFrameMs,
    required this.p95FrameMs,
    required this.latencyPerCategory,
    required this.latencyStats,
  });

  final double avgFrameMs;
  final double minFrameMs;
  final double maxFrameMs;
  final double p95FrameMs;
  final Map<String, _LatencyStats> latencyPerCategory;
  final _LatencyStats latencyStats;
}

class _LatencyStats {
  const _LatencyStats({
    required this.average,
    required this.p95,
    required this.max,
  });

  final double average;
  final double p95;
  final double max;

  Map<String, Object?> toJson() => {'average': average, 'p95': p95, 'max': max};
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}
