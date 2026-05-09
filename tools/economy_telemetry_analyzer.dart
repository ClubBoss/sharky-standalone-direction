import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _maxEntries = 50;

Future<void> main(List<String> args) async {
  final summary = await _analyzeEconomy();

  final fps = summary.fpsAverage;
  final xpStart = summary.xpStart;
  final xpEnd = summary.xpEnd;
  final driftPct = summary.drift * 100;
  final sign = driftPct >= 0 ? '+' : '';
  final status = summary.pass ? 'PASS' : 'FAIL';

  stdout.writeln(
    'Economy Analyzer: $status '
    '(avg fps ${fps.toStringAsFixed(1)} '
    'xp ${xpStart.toStringAsFixed(2)} → ${xpEnd.toStringAsFixed(2)} '
    'drift $sign${driftPct.toStringAsFixed(1)}%)',
  );

  stdout.writeln(
    jsonEncode({
      'fps_avg': double.parse(summary.fpsAverage.toStringAsFixed(2)),
      'xp_avg': double.parse(summary.xpAverage.toStringAsFixed(3)),
      'refill_avg': double.parse(summary.refillAverage.toStringAsFixed(2)),
      'drift': double.parse(summary.drift.toStringAsFixed(4)),
      'risk': double.parse(summary.risk.toStringAsFixed(4)),
      'pass': summary.pass,
      'trend': summary.trend,
    }),
  );

  await File('economy_telemetry_analyzer.json').writeAsString(
    jsonEncode({
      'fps_avg': summary.fpsAverage,
      'xp_avg': summary.xpAverage,
      'refill_avg': summary.refillAverage,
      'drift': summary.drift,
      'risk': summary.risk,
      'pass': summary.pass,
      'trend': summary.trend,
      'timestamp': DateTime.now().toIso8601String(),
    }),
  );
}

Future<_EconomySummary> _analyzeEconomy() async {
  final tuning = await _readEconomyTuning();
  final dynamicMetrics = await _readDynamicMetrics();
  final events = await _readTelemetryEvents();

  final samples = <_Sample>[];
  samples.add(
    _Sample(
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      xpFactor: tuning.xpFactor,
      refillMinutes: tuning.refillMinutes.toDouble(),
      fps: 0,
    ),
  );
  if (dynamicMetrics != null) samples.add(dynamicMetrics);
  samples.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final xpAvg =
      samples.map((s) => s.xpFactor).reduce((a, b) => a + b) / samples.length;
  final refillAvg =
      samples.map((s) => s.refillMinutes).reduce((a, b) => a + b) /
      samples.length;
  final fpsSamples = samples.where((s) => s.fps > 0).toList();
  final fpsAvg = fpsSamples.isEmpty
      ? 0.0
      : fpsSamples.map((s) => s.fps).reduce((a, b) => a + b) /
            fpsSamples.length;

  final xpStart = samples.first.xpFactor;
  final xpEnd = samples.last.xpFactor;
  final refillStart = samples.first.refillMinutes;
  final refillEnd = samples.last.refillMinutes;

  final xpDelta = xpStart == 0 ? 0 : (xpEnd - xpStart) / xpStart;
  final refillDelta = refillStart == 0
      ? 0
      : (refillEnd - refillStart) / refillStart;
  final eventDelta = events.avgDrift;

  final drift = (xpDelta + refillDelta + eventDelta) / 3;
  final risk = _sigmoid(drift.abs() * 10);
  final pass = risk < 0.6;

  final trend = drift.abs() < 0.01
      ? 'stable'
      : drift > 0
      ? 'accelerating'
      : 'decelerating';

  return _EconomySummary(
    fpsAverage: fpsAvg,
    xpAverage: xpAvg,
    refillAverage: refillAvg,
    xpStart: xpStart,
    xpEnd: xpEnd,
    drift: drift,
    risk: risk,
    pass: pass,
    trend: trend,
  );
}

double _sigmoid(double x) => 1 / (1 + exp(-x));

class _EconomySummary {
  final double fpsAverage;
  final double xpAverage;
  final double refillAverage;
  final double xpStart;
  final double xpEnd;
  final double drift;
  final double risk;
  final bool pass;
  final String trend;

  const _EconomySummary({
    required this.fpsAverage,
    required this.xpAverage,
    required this.refillAverage,
    required this.xpStart,
    required this.xpEnd,
    required this.drift,
    required this.risk,
    required this.pass,
    required this.trend,
  });
}

class _Sample {
  final DateTime timestamp;
  final double xpFactor;
  final double refillMinutes;
  final double fps;

  const _Sample({
    required this.timestamp,
    required this.xpFactor,
    required this.refillMinutes,
    required this.fps,
  });
}

class _TelemetryStats {
  final double avgDrift;

  _TelemetryStats({required this.avgDrift});
}

class _TuningConfig {
  final double xpFactor;
  final int refillMinutes;

  _TuningConfig({required this.xpFactor, required this.refillMinutes});
}

Future<_TuningConfig> _readEconomyTuning() async {
  final file = File('economy_tuning.json');
  if (!await file.exists()) {
    return _TuningConfig(xpFactor: 1.0, refillMinutes: 30);
  }
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      final xp = (data['xpFactor'] ?? data['xp_factor']) as num?;
      final refill = (data['refillMinutes'] ?? data['refill']) as num?;
      return _TuningConfig(
        xpFactor: (xp?.toDouble() ?? 1.0).clamp(0.2, 3.0),
        refillMinutes: (refill?.toInt() ?? 30).clamp(10, 120),
      );
    }
  } catch (_) {}
  return _TuningConfig(xpFactor: 1.0, refillMinutes: 30);
}

Future<_Sample?> _readDynamicMetrics() async {
  final file = File('economy_dynamic_metrics.json');
  if (!await file.exists()) return null;
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      final xp = (data['xpFactor'] as num?)?.toDouble();
      final interval = (data['energyInterval'] as num?)?.toDouble();
      final fps = (data['fpsAvg'] as num?)?.toDouble();
      final tsRaw = data['timestamp'] as String?;
      final timestamp = tsRaw != null
          ? DateTime.tryParse(tsRaw) ?? DateTime.now()
          : DateTime.now();
      if (xp != null && interval != null) {
        return _Sample(
          timestamp: timestamp,
          xpFactor: xp,
          refillMinutes: interval,
          fps: fps ?? 0,
        );
      }
    }
  } catch (_) {}
  return null;
}

Future<_TelemetryStats> _readTelemetryEvents() async {
  final file = File('telemetry_events.jsonl');
  if (!await file.exists()) return _TelemetryStats(avgDrift: 0);
  try {
    final lines = await file.readAsLines();
    final tail = lines.reversed
        .where((line) => line.trim().isNotEmpty)
        .take(_maxEntries)
        .map((line) {
          try {
            return jsonDecode(line);
          } catch (_) {
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .where((event) {
          final name = event['event'];
          return name == 'economy_tuning_drift';
        })
        .toList();
    if (tail.isEmpty) return _TelemetryStats(avgDrift: 0);
    final avg =
        tail
            .map((e) => (e['drift_percent'] as num?)?.toDouble() ?? 0.0)
            .fold<double>(0, (a, b) => a + b) /
        tail.length /
        100.0;
    return _TelemetryStats(avgDrift: avg);
  } catch (_) {
    return _TelemetryStats(avgDrift: 0);
  }
}
