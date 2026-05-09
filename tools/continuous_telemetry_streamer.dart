import 'dart:convert';
import 'dart:io';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _adaptiveSummaryPath =
    'release/_reports/adaptive_feedback_summary.txt';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/continuous_stream_summary.txt';
const int _windowSize = 20;
const double _defaultRiskThreshold = 0.5;
const double _defaultVarianceThreshold = 0.5;
const int _defaultLatencyThresholdMs = 300;
const double _defaultSuccessRateThreshold = 0.8;

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final thresholds = await _readAdaptiveThresholds();
  final stream = await _readTelemetryWindow();
  final evaluated = _evaluateStream(stream, thresholds);
  final stats = _aggregateStats(evaluated);
  final verdict = _verdictForPassRate(stats.passRate);

  await _withReportsWritable(() async {
    await _writeSummary(evaluated, stats, thresholds, verdict);
    await _appendTelemetry(
      eventsSimulated: evaluated.length,
      passRate: stats.passRate,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'continuous_telemetry_streamer: events=${evaluated.length} passRate=${stats.passRate.toStringAsFixed(2)}',
  );

  if (verdict == 'FAIL') {
    exitCode = 2;
  } else if (verdict == 'WARN') {
    exitCode = 1;
  }
}

Future<_Thresholds> _readAdaptiveThresholds() async {
  final file = File(_adaptiveSummaryPath);
  if (!await file.exists()) return const _Thresholds();
  final lines = await file.readAsLines();
  double _valueFor(String label) {
    final row = lines.firstWhere(
      (line) => line.contains(label),
      orElse: () => '',
    );
    if (row.isEmpty) return 0;
    final match = RegExp(r'(-?\d+\.?\d*)').firstMatch(row);
    if (match == null) return 0;
    return double.tryParse(match.group(1)!) ?? 0;
  }

  final latencyRow = lines.firstWhere(
    (line) => line.contains('Latency threshold'),
    orElse: () => '',
  );
  final latencyMatch = RegExp(
    r'\|\s+Latency threshold.*\|\s+(\d+)\s+\|',
  ).firstMatch(latencyRow);
  final latency = latencyMatch == null
      ? 0
      : int.tryParse(latencyMatch.group(1)!) ?? 0;

  return _Thresholds(
    risk: _valueFor('Risk threshold'),
    variance: _valueFor('Variance threshold'),
    latencyMs: latency,
    successRate: _valueFor('Success rate threshold'),
  );
}

Future<List<_TelemetryEvent>> _readTelemetryWindow() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const [];
  final events = <_TelemetryEvent>[];
  for (final raw in await file.readAsLines()) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) continue;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) continue;
      final name = decoded['event']?.toString() ?? 'unknown';
      final timestamp = DateTime.tryParse(
        decoded['timestamp']?.toString() ?? '',
      );
      if (timestamp == null) continue;
      final risk = (decoded['risk_score'] as num?)?.toDouble();
      final variance = (decoded['variance_avg'] as num?)?.toDouble();
      final latency = (decoded['duration_ms'] as num?)?.toDouble();
      final successRate = (decoded['risk_reduction'] as num?)?.toDouble();
      events.add(
        _TelemetryEvent(
          name: name,
          timestamp: timestamp,
          risk: risk,
          variance: variance,
          latencyMs: latency,
          successRate: successRate,
        ),
      );
    } catch (_) {
      continue;
    }
  }

  events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  if (events.length <= _windowSize) return events;
  return events.sublist(events.length - _windowSize);
}

List<_EvaluatedEvent> _evaluateStream(
  List<_TelemetryEvent> events,
  _Thresholds thresholds,
) {
  final evaluated = <_EvaluatedEvent>[];
  for (final event in events) {
    final status = _classify(event, thresholds);
    evaluated.add(_EvaluatedEvent(event: event, status: status));
  }
  return evaluated;
}

String _classify(_TelemetryEvent event, _Thresholds thresholds) {
  var level = _Status.pass;

  void evaluate(double? value, double threshold, double fallback) {
    if (value == null) return;
    final base = threshold <= 0 ? fallback : threshold;
    if (value > base * 1.5) {
      level = _Status.fail;
    } else if (value > base && level != _Status.fail) {
      level = _Status.warn;
    }
  }

  evaluate(event.risk, thresholds.risk, _defaultRiskThreshold);
  evaluate(event.variance, thresholds.variance, _defaultVarianceThreshold);
  evaluate(
    event.latencyMs,
    thresholds.latencyMs.toDouble(),
    _defaultLatencyThresholdMs.toDouble(),
  );
  if (event.successRate != null) {
    final targetSuccess = thresholds.successRate <= 0
        ? _defaultSuccessRateThreshold
        : thresholds.successRate;
    final successDiff = targetSuccess - event.successRate!;
    if (successDiff > 0.2) {
      level = _Status.fail;
    } else if (successDiff > 0 && level != _Status.fail) {
      level = _Status.warn;
    }
  }

  return level.name.toUpperCase();
}

_StreamStats _aggregateStats(List<_EvaluatedEvent> events) {
  if (events.isEmpty) return const _StreamStats();
  final counts = <String, int>{'PASS': 0, 'WARN': 0, 'FAIL': 0};
  for (final event in events) {
    counts[event.status] = (counts[event.status] ?? 0) + 1;
  }
  final passRate = counts['PASS']! / events.length;
  return _StreamStats(
    pass: counts['PASS']!,
    warn: counts['WARN']!,
    fail: counts['FAIL']!,
    passRate: passRate,
  );
}

Future<void> _writeSummary(
  List<_EvaluatedEvent> events,
  _StreamStats stats,
  _Thresholds thresholds,
  String verdict,
) async {
  final buffer = StringBuffer()
    ..writeln('CONTINUOUS TELEMETRY STREAM SUMMARY')
    ..writeln('==================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Events simulated: ${events.length}')
    ..writeln(
      'PASS/WARN/FAIL: ${stats.pass}/${stats.warn}/${stats.fail} '
      '(pass rate ${stats.passRate.toStringAsFixed(2)})',
    )
    ..writeln('Verdict: $verdict')
    ..writeln()
    ..writeln('Thresholds (learned)')
    ..writeln('- Risk: ${thresholds.risk.toStringAsFixed(2)}')
    ..writeln('- Variance: ${thresholds.variance.toStringAsFixed(2)}')
    ..writeln('- Latency: ${thresholds.latencyMs} ms')
    ..writeln('- Success rate: ${thresholds.successRate.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('| Timestamp | Event | Risk | Variance | Latency | Status |')
    ..writeln('|-----------|-------|------|----------|---------|--------|');

  for (final e in events) {
    buffer.writeln(
      '| ${e.event.timestamp.toIso8601String()} | ${e.event.name} | '
      '${(e.event.risk ?? 0).toStringAsFixed(2)} | '
      '${(e.event.variance ?? 0).toStringAsFixed(2)} | '
      '${(e.event.latencyMs ?? 0).toStringAsFixed(0)} | ${e.status} |',
    );
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int eventsSimulated,
  required double passRate,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'continuous_telemetry_stream_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'events_simulated': eventsSimulated,
    'pass_rate': double.parse(passRate.toStringAsFixed(2)),
    'verdict': verdict,
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
      'continuous_telemetry_streamer: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _Thresholds {
  const _Thresholds({
    this.risk = _defaultRiskThreshold,
    this.variance = _defaultVarianceThreshold,
    this.latencyMs = _defaultLatencyThresholdMs,
    this.successRate = _defaultSuccessRateThreshold,
  });

  final double risk;
  final double variance;
  final int latencyMs;
  final double successRate;
}

class _TelemetryEvent {
  const _TelemetryEvent({
    required this.name,
    required this.timestamp,
    this.risk,
    this.variance,
    this.latencyMs,
    this.successRate,
  });

  final String name;
  final DateTime timestamp;
  final double? risk;
  final double? variance;
  final double? latencyMs;
  final double? successRate;
}

class _EvaluatedEvent {
  const _EvaluatedEvent({required this.event, required this.status});

  final _TelemetryEvent event;
  final String status;
}

class _StreamStats {
  const _StreamStats({
    this.pass = 0,
    this.warn = 0,
    this.fail = 0,
    this.passRate = 0,
  });

  final int pass;
  final int warn;
  final int fail;
  final double passRate;
}

enum _Status { pass, warn, fail }

String _verdictForPassRate(double passRate) {
  if (passRate >= 0.9) return 'PASS';
  if (passRate >= 0.75) return 'WARN';
  return 'FAIL';
}
