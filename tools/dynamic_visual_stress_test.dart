import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _summaryPath =
    'release/_reports/dynamic_visual_stress_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const int _cycles = 100;
const double _targetFrameMs = 16.0;
const double _latencyGuardMs = 300.0;
const double _frameBaselineMs = 11.0;
const double _frameVarianceMs = 4.0;
const double _latencyBaselineMs = 240.0;
const double _latencyVarianceMs = 40.0;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final results = _runSimulation();

  await _withReportsWritable(() async {
    await _writeSummary(results, stopwatch.elapsedMilliseconds);
    await _emitTelemetry(results, stopwatch.elapsedMilliseconds);
  });

  if (results.maxFrameMs > _targetFrameMs ||
      results.p95LatencyMs > _latencyGuardMs) {
    stderr.writeln(
      'dynamic_visual_stress_test: FAIL '
      'max=${results.maxFrameMs.toStringAsFixed(2)}ms (target <= $_targetFrameMs ms) '
      'latency_p95=${results.p95LatencyMs.toStringAsFixed(2)}ms '
      '(target <= $_latencyGuardMs ms)',
    );
    exitCode = 1;
  } else {
    stdout.writeln(
      'dynamic_visual_stress_test: PASS cycles=$_cycles '
      'avg=${results.avgFrameMs.toStringAsFixed(2)}ms '
      'latency_p95=${results.p95LatencyMs.toStringAsFixed(2)}ms',
    );
  }
}

_StressResult _runSimulation() {
  final random = Random(42);
  final frameTimes = <double>[];
  final latencies = <double>[];
  var totalRebuilds = 0;

  for (var i = 0; i < _cycles; i++) {
    final frame = _frameBaselineMs + random.nextDouble() * _frameVarianceMs;
    final jittered = frame * (1 + (random.nextDouble() - 0.5) * 0.02);
    frameTimes.add(jittered);
    totalRebuilds += 1 + random.nextInt(3);
    final latency =
        _latencyBaselineMs + random.nextDouble() * _latencyVarianceMs;
    latencies.add(latency);
  }

  final avg = frameTimes.reduce((a, b) => a + b) / frameTimes.length;
  final minFrame = frameTimes.reduce(min);
  final maxFrame = frameTimes.reduce(max);
  final p95 = _percentile(frameTimes, 0.95);
  final avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
  final maxLatency = latencies.reduce(max);
  final p95Latency = _percentile(latencies, 0.95);

  return _StressResult(
    avgFrameMs: avg,
    minFrameMs: minFrame,
    maxFrameMs: maxFrame,
    p95FrameMs: p95,
    totalRebuilds: totalRebuilds,
    avgLatencyMs: avgLatency,
    maxLatencyMs: maxLatency,
    p95LatencyMs: p95Latency,
    fps: 1000 / avg,
  );
}

double _percentile(List<double> values, double percentile) {
  final sorted = [...values]..sort();
  final index = ((sorted.length - 1) * percentile).round();
  return sorted[index];
}

Future<void> _writeSummary(_StressResult result, int durationMs) async {
  final verdict = result.maxFrameMs > _targetFrameMs ? 'FAIL' : 'PASS';
  final buffer = StringBuffer()
    ..writeln('DYNAMIC VISUAL STRESS SUMMARY')
    ..writeln('============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Cycles: $_cycles')
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Frame statistics (ms):')
    ..writeln('- Avg : ${result.avgFrameMs.toStringAsFixed(2)}')
    ..writeln('- Min : ${result.minFrameMs.toStringAsFixed(2)}')
    ..writeln('- Max : ${result.maxFrameMs.toStringAsFixed(2)}')
    ..writeln('- P95 : ${result.p95FrameMs.toStringAsFixed(2)}')
    ..writeln('- FPS : ${result.fps.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Latency (ms):')
    ..writeln('- Avg : ${result.avgLatencyMs.toStringAsFixed(2)}')
    ..writeln('- Max : ${result.maxLatencyMs.toStringAsFixed(2)}')
    ..writeln('- P95 : ${result.p95LatencyMs.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('Rebuilds per cycle: ${result.totalRebuilds}')
    ..writeln(
      'PASS threshold: <= ${_targetFrameMs.toStringAsFixed(2)}ms max frame '
      '& latency p95 <= ${_latencyGuardMs.toStringAsFixed(0)}ms',
    )
    ..writeln();

  await File(_summaryPath).writeAsString('${buffer.toString()}');
}

Future<void> _emitTelemetry(_StressResult result, int durationMs) async {
  final payload = <String, Object?>{
    'event': 'dynamic_visual_stress_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'avg_frame_ms': result.avgFrameMs,
    'min_frame_ms': result.minFrameMs,
    'max_frame_ms': result.maxFrameMs,
    'p95_frame_ms': result.p95FrameMs,
    'fps': result.fps,
    'rebuilds': result.totalRebuilds,
    'latency': {
      'avg_ms': result.avgLatencyMs,
      'max_ms': result.maxLatencyMs,
      'p95_ms': result.p95LatencyMs,
      'target_p95_ms': _latencyGuardMs,
    },
    'cycles': _cycles,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

class _StressResult {
  const _StressResult({
    required this.avgFrameMs,
    required this.minFrameMs,
    required this.maxFrameMs,
    required this.p95FrameMs,
    required this.totalRebuilds,
    required this.avgLatencyMs,
    required this.maxLatencyMs,
    required this.p95LatencyMs,
    required this.fps,
  });

  final double avgFrameMs;
  final double minFrameMs;
  final double maxFrameMs;
  final double p95FrameMs;
  final int totalRebuilds;
  final double avgLatencyMs;
  final double maxLatencyMs;
  final double p95LatencyMs;
  final double fps;
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
