import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final forecaster = _PredictiveTrendForecaster();
  try {
    final result = await forecaster.run();
    await forecaster.writeForecast(result);
    await forecaster.emitTelemetry(result);
  } finally {
    await forecaster.restorePermissions();
  }
}

class _PredictiveTrendForecaster {
  bool _reportsWritable = false;

  Future<_ForecastResult> run() async {
    final stopwatch = Stopwatch()..start();
    final summary = await _readAutonomousSummary();
    final ux = await _readUxMetrics();

    final retentionBaseline = summary.retention ?? 0.0;
    final trendBaseline =
        summary.trendIndex ?? _deriveTrendFromMetrics(ux) ?? 0.5;

    final dauSlope = _normalizedSlope(summary.dauCounts.values.toList());
    final warnings = ux.warnings?.toDouble() ?? 0.0;
    final stability = ux.stabilityScore ?? 1.0;
    final uxScore = ux.uxScore ?? stability;
    final avgFps = ux.avgFps ?? 60.0;

    final retentionSlope =
        (dauSlope * 0.05) + ((stability - 0.95) * 0.08) - (warnings * 0.004);
    final trendSlope =
        ((avgFps - 60.0) / 60.0) * 0.04 +
        ((uxScore - 0.9) * 0.12) -
        ((ux.recoveries ?? 0) * 0.003);

    final smoothing = 0.65;
    final retentionForecast = _projectSeries(
      baseline: retentionBaseline,
      slope: retentionSlope,
      smoothing: smoothing,
      days: 7,
    );
    final trendForecast = _projectSeries(
      baseline: trendBaseline,
      slope: trendSlope,
      smoothing: smoothing,
      days: 7,
    );

    stopwatch.stop();
    return _ForecastResult(
      timestamp: DateTime.now().toUtc(),
      summary: summary,
      ux: ux,
      retentionForecast: retentionForecast,
      trendForecast: trendForecast,
      retentionSlope: retentionSlope,
      trendSlope: trendSlope,
      smoothingFactor: smoothing,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  Future<_AutonomousSummary> _readAutonomousSummary() async {
    final searchPaths = [
      'release/_reports/autonomous_telemetry_summary.txt',
      'release/_exports/autonomous_telemetry_summary.txt',
    ];
    File? file;
    for (final path in searchPaths) {
      final candidate = File(path);
      if (candidate.existsSync()) {
        file = candidate;
        break;
      }
    }
    if (file == null) {
      throw StateError('autonomous_telemetry_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    DateTime? generated;
    double? retention;
    double? trendIndex;
    final dauCounts = <String, int>{};
    bool expectTrendValue = false;
    bool inDauSection = false;
    final tablePattern = RegExp(
      r'^\|\s*(\d{4}-\d{2}-\d{2})\s*\|\s*([0-9]+)\s*\|',
    );
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        if (expectTrendValue) continue;
        if (inDauSection && dauCounts.isNotEmpty) {
          inDauSection = false;
        }
        continue;
      }
      if (line.startsWith('Generated:')) {
        generated = _tryParseIso(line.substring('Generated:'.length).trim());
        continue;
      }
      if (line == 'Daily Active Users (DAU)') {
        inDauSection = true;
        continue;
      }
      if (inDauSection && line == '(no data)') {
        inDauSection = false;
        continue;
      }
      if (line.startsWith('Next-day retention:')) {
        retention = double.tryParse(
          line.substring('Next-day retention:'.length).trim(),
        );
        continue;
      }
      if (line.startsWith('UX Trend Index')) {
        expectTrendValue = true;
        continue;
      }
      if (expectTrendValue) {
        trendIndex = double.tryParse(line);
        expectTrendValue = false;
        continue;
      }
      if (inDauSection) {
        final match = tablePattern.firstMatch(rawLine);
        if (match != null) {
          dauCounts[match.group(1)!] = int.parse(match.group(2)!);
        }
      }
    }
    return _AutonomousSummary(
      generated: generated,
      retention: retention,
      trendIndex: trendIndex,
      dauCounts: dauCounts,
    );
  }

  Future<_UxMetrics> _readUxMetrics() async {
    final file = File('release/_exports/ux_metrics.json');
    if (!file.existsSync()) {
      throw StateError('release/_exports/ux_metrics.json is missing.');
    }
    final dynamic decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      throw StateError('ux_metrics.json malformed.');
    }
    double? readDouble(String key) {
      final value = decoded[key];
      if (value is num) return value.toDouble();
      return null;
    }

    return _UxMetrics(
      timestamp: _tryParseIso(decoded['timestamp'] as String?),
      avgFps: readDouble('avg_fps'),
      stabilityScore: readDouble('stability_score'),
      uxScore: readDouble('ux_score'),
      warnings: (decoded['warnings'] as num?)?.toInt(),
      recoveries: (decoded['recoveries'] as num?)?.toInt(),
    );
  }

  double? _deriveTrendFromMetrics(_UxMetrics metrics) {
    final stability = metrics.stabilityScore;
    final uxScore = metrics.uxScore;
    final fps = metrics.avgFps;
    if (stability == null && uxScore == null && fps == null) {
      return null;
    }
    final components = <double>[];
    if (stability != null) components.add(stability.clamp(0.0, 1.0));
    if (uxScore != null) components.add(uxScore.clamp(0.0, 1.0));
    if (fps != null) components.add((fps / 60.0).clamp(0.0, 1.0));
    if (components.isEmpty) return null;
    final total = components.reduce((a, b) => a + b);
    return total / components.length;
  }

  List<double> _projectSeries({
    required double baseline,
    required double slope,
    required double smoothing,
    required int days,
  }) {
    final values = <double>[];
    var last = baseline;
    for (var day = 1; day <= days; day++) {
      final linear = baseline + slope * day;
      last = smoothing * linear + (1 - smoothing) * last;
      values.add(_clamp01(last));
    }
    return values;
  }

  Future<void> writeForecast(_ForecastResult result) async {
    final buffer = StringBuffer()
      ..writeln('Predictive Trend Forecast')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Sources: autonomous_telemetry_summary.txt, ux_metrics.json')
      ..writeln(
        'Model: linear projection + weighted smoothing (factor ${result.smoothingFactor.toStringAsFixed(2)})',
      )
      ..writeln(
        'Retention slope: ${result.retentionSlope.toStringAsFixed(4)}, Trend slope: ${result.trendSlope.toStringAsFixed(4)}',
      )
      ..writeln();

    buffer
      ..writeln('| Day | Retention | UX Trend |')
      ..writeln('|-----|-----------|----------|');
    for (var i = 0; i < result.retentionForecast.length; i++) {
      final day = i + 1;
      buffer.writeln(
        '| Day ${day.toString().padLeft(1)} | '
        '${result.retentionForecast[i].toStringAsFixed(3)} | '
        '${result.trendForecast[i].toStringAsFixed(3)} |',
      );
    }

    buffer
      ..writeln()
      ..writeln('Mini Bar Chart — Retention')
      ..writeln(_barChart(result.retentionForecast))
      ..writeln()
      ..writeln('Mini Bar Chart — UX Trend Index')
      ..writeln(_barChart(result.trendForecast));

    buffer
      ..writeln()
      ..writeln('Baseline snapshot:')
      ..writeln(
        '- Retention (latest): ${(result.summary.retention ?? 0.0).toStringAsFixed(3)}',
      )
      ..writeln(
        '- UX Trend Index (latest): ${(result.summary.trendIndex ?? result.trendForecast.first).toStringAsFixed(3)}',
      )
      ..writeln(
        '- DAU samples: ${result.summary.dauCounts.isEmpty ? 'none' : result.summary.dauCounts.keys.length}',
      )
      ..writeln('Duration (ms): ${result.durationMs}');

    await _writeReportsFile(
      'release/_reports/predictive_trend_forecast.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_ForecastResult result) async {
    final retention = result.retentionForecast.last;
    final trend = result.trendForecast.last;
    final payload = <String, Object>{
      'event': TelemetryEvents.predictiveTrendCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'forecast_retention': _round(retention, 3),
      'forecast_trend_index': _round(trend, 3),
      'duration_ms': result.durationMs,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    try {
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  double _normalizedSlope(List<int> values) {
    if (values.length < 2) return 0.0;
    double sumDelta = 0;
    for (var i = 1; i < values.length; i++) {
      sumDelta += values[i] - values[i - 1];
    }
    final avgDelta = sumDelta / (values.length - 1);
    final maxValue = values.fold<int>(1, (max, v) => v > max ? v : max);
    return avgDelta / maxValue;
  }

  String _barChart(List<double> values) {
    final buffer = StringBuffer();
    for (var i = 0; i < values.length; i++) {
      final value = (values[i].clamp(0.0, 1.0) as num).toDouble();
      final filled = (value * 20).round();
      final bar = '${_repeat('#', filled)}${_repeat('.', 20 - filled)}';
      buffer.writeln('Day ${i + 1}: $bar (${value.toStringAsFixed(3)})');
    }
    return buffer.toString();
  }

  double _round(double value, int precision) {
    final factor = math.pow(10, precision).toDouble();
    return (value * factor).round() / factor;
  }

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _ForecastResult {
  _ForecastResult({
    required this.timestamp,
    required this.summary,
    required this.ux,
    required this.retentionForecast,
    required this.trendForecast,
    required this.retentionSlope,
    required this.trendSlope,
    required this.smoothingFactor,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _AutonomousSummary summary;
  final _UxMetrics ux;
  final List<double> retentionForecast;
  final List<double> trendForecast;
  final double retentionSlope;
  final double trendSlope;
  final double smoothingFactor;
  final int durationMs;
}

class _AutonomousSummary {
  _AutonomousSummary({
    required this.generated,
    required this.retention,
    required this.trendIndex,
    required this.dauCounts,
  });

  final DateTime? generated;
  final double? retention;
  final double? trendIndex;
  final Map<String, int> dauCounts;
}

class _UxMetrics {
  _UxMetrics({
    required this.timestamp,
    required this.avgFps,
    required this.stabilityScore,
    required this.uxScore,
    required this.warnings,
    required this.recoveries,
  });

  final DateTime? timestamp;
  final double? avgFps;
  final double? stabilityScore;
  final double? uxScore;
  final int? warnings;
  final int? recoveries;
}

double _clamp01(double value) => (value.clamp(0.0, 1.0) as num).toDouble();

String _repeat(String char, int count) {
  if (count <= 0) return '';
  final buffer = StringBuffer();
  for (var i = 0; i < count; i++) {
    buffer.write(char);
  }
  return buffer.toString();
}

DateTime? _tryParseIso(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value).toUtc();
  } catch (_) {
    return null;
  }
}
