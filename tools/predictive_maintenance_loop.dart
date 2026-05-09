import 'dart:convert';
import 'dart:io';

const String _stressSummaryPath =
    'release/_reports/auto_recovery_stress_summary.txt';
const String _reportsDir = 'release/_reports';
const String _outputPath =
    'release/_reports/predictive_maintenance_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final snapshot = await _readStressSummary();
  final meanLatency = snapshot.results.isEmpty
      ? 0.0
      : snapshot.results.map((r) => r.latencyMs).reduce((a, b) => a + b) /
            snapshot.results.length;
  final riskThreshold = 2500.0;

  final daysSince = snapshot.generated == null
      ? 1
      : DateTime.now().difference(snapshot.generated!).inDays.clamp(1, 365);
  final slope = meanLatency / daysSince;
  final predictedDays = slope <= 0
      ? null
      : ((riskThreshold - meanLatency) / slope).ceil();

  final categories = snapshot.results.map((result) {
    final risk = result.status == 'FAIL'
        ? 'HIGH'
        : result.status == 'WARN'
        ? 'MED'
        : 'LOW';
    final projected = (result.latencyMs >= riskThreshold)
        ? 'due now'
        : (predictedDays == null || predictedDays < 0)
        ? 'n/a'
        : '${predictedDays}d';
    return _CategoryMatrix(
      name: result.name,
      latencyMs: result.latencyMs,
      status: result.status,
      risk: risk,
      projected: projected,
    );
  }).toList();

  await _withReportsWritable(() async {
    await _writeSummary(
      snapshot.generated,
      categories,
      meanLatency,
      predictedDays,
    );
    await _appendTelemetry(
      meanLatency: meanLatency,
      predictedDays: predictedDays,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'predictive_maintenance_loop: meanLatency=${meanLatency.toStringAsFixed(0)}ms '
    'predictedDays=${predictedDays ?? -1}',
  );
}

class _StressResult {
  const _StressResult({
    required this.name,
    required this.latencyMs,
    required this.status,
  });

  final String name;
  final int latencyMs;
  final String status;
}

class _StressSnapshot {
  const _StressSnapshot({required this.generated, required this.results});

  final DateTime? generated;
  final List<_StressResult> results;
}

class _CategoryMatrix {
  const _CategoryMatrix({
    required this.name,
    required this.latencyMs,
    required this.status,
    required this.risk,
    required this.projected,
  });

  final String name;
  final int latencyMs;
  final String status;
  final String risk;
  final String projected;
}

Future<_StressSnapshot> _readStressSummary() async {
  final file = File(_stressSummaryPath);
  if (!await file.exists()) {
    return const _StressSnapshot(generated: null, results: []);
  }
  DateTime? generated;
  final results = <_StressResult>[];
  final rowPattern = RegExp(
    r'^\|\s*(.+?)\s*\|\s*(\d+)\s*\|\s*(PASS|WARN|FAIL)\s*\|',
  );
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('Generated:')) {
      generated = DateTime.tryParse(trimmed.split(':').last.trim());
      continue;
    }
    final match = rowPattern.firstMatch(trimmed);
    if (match != null) {
      results.add(
        _StressResult(
          name: match.group(1)!,
          latencyMs: int.parse(match.group(2)!),
          status: match.group(3)!,
        ),
      );
    }
  }
  return _StressSnapshot(generated: generated, results: results);
}

Future<void> _writeSummary(
  DateTime? generated,
  List<_CategoryMatrix> categories,
  double meanLatency,
  int? predictedDays,
) async {
  final buffer = StringBuffer()
    ..writeln('PREDICTIVE MAINTENANCE SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Last stress run: ${generated?.toIso8601String() ?? 'unknown'}')
    ..writeln('Mean stress latency: ${meanLatency.toStringAsFixed(0)} ms')
    ..writeln('Projected days to risk: ${predictedDays ?? -1}')
    ..writeln()
    ..writeln('| Scenario | Latency (ms) | Status | Risk | Next Maintenance |')
    ..writeln('|----------|--------------|--------|------|------------------|');
  for (final category in categories) {
    buffer.writeln(
      '| ${category.name} | ${category.latencyMs} | ${category.status} | '
      '${category.risk} | ${category.projected} |',
    );
  }
  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double meanLatency,
  required int? predictedDays,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'predictive_maintenance_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'mean_latency_ms': meanLatency,
    'predicted_days_to_risk': predictedDays,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'predictive_maintenance_loop: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
