import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _reliabilityPath =
    '$_reportsDir/long_term_reliability_summary.json';
const String _stabilityPath = '$_reportsDir/stability_regression_summary.json';
const String _systemPath = '$_reportsDir/system_snapshot_v3_summary.json';
const String _textPath = '$_reportsDir/forecast_resilience_summary.txt';
const String _jsonPath = '$_reportsDir/forecast_resilience_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(days: 7);

Future<void> main(List<String> args) async {
  final analyzer = ForecastResilienceAnalyzer();
  final ok = await analyzer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ForecastResilienceAnalyzer {
  Future<bool> run() async {
    final reliability = await _readSummary(_reliabilityPath);
    final stability = await _readSummary(_stabilityPath);
    final system = await _readSummary(_systemPath);

    if (reliability == null || stability == null || system == null) {
      stderr.writeln('Missing forecast resilience inputs.');
      return false;
    }

    if (!reliability.pass || !stability.pass || !system.pass) {
      stderr.writeln('One or more inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (reliability.timestamp != null) reliability.timestamp!,
      if (stability.timestamp != null) stability.timestamp!,
      if (system.timestamp != null) system.timestamp!,
    ];
    if (!_withinWindow(timestamps)) {
      stderr.writeln('Input timestamps span more than ${_timeWindow.inDays}d.');
      return false;
    }

    final reliabilityScore = _normalize(reliability.score);
    final stabilityScore = _normalize(stability.score);
    final systemScore = _normalize(system.score);
    if (reliabilityScore == null ||
        stabilityScore == null ||
        systemScore == null) {
      stderr.writeln('Unable to extract scores.');
      return false;
    }

    final forecastScore =
        ((reliabilityScore * 0.4) +
                (stabilityScore * 0.35) +
                (systemScore * 0.25))
            .clamp(0.0, 1.0);

    final previous = await _averageHistoricalScore(
      'long_term_reliability_completed',
    );
    final trendDelta = previous == null ? 0.0 : forecastScore - previous;
    final pass = forecastScore >= _threshold;

    final text = _buildText(
      reliabilityScore,
      stabilityScore,
      systemScore,
      forecastScore,
      trendDelta,
      pass,
    );
    final json = _buildJson(
      reliabilityScore,
      stabilityScore,
      systemScore,
      forecastScore,
      trendDelta,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_textPath).writeAsString(text);
      await File(
        _jsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        reliabilityScore,
        stabilityScore,
        systemScore,
        forecastScore,
        trendDelta,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Forecast Resilience Index ${(forecastScore * 100).toStringAsFixed(2)}% below threshold.',
      );
    }
    return pass;
  }

  Future<_Summary?> _readSummary(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final timestamp =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = timestamp != null ? DateTime.tryParse(timestamp) : null;
      final score = _extractScore(decoded);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  bool _withinWindow(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _extractScore(Map<String, Object?> data) {
    const keys = <String>[
      'reliability_trend_score',
      'stability_regression_score',
      'system_snapshot_v3_score',
    ];
    for (final key in keys) {
      if (!data.containsKey(key)) continue;
      final value = _toDouble(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  Future<double?> _averageHistoricalScore(String eventName) async {
    final file = File(_telemetryPath);
    if (!await file.exists()) return null;
    final now = DateTime.now();
    final scores = <double>[];
    await for (final line
        in file
            .openRead()
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
      if (line.trim().isEmpty) continue;
      try {
        final decoded = json.decode(line) as Map<String, Object?>;
        if (decoded['event'] != eventName) continue;
        final timestamp = decoded['timestamp'] as String?;
        if (timestamp == null) continue;
        final parsed = DateTime.tryParse(timestamp);
        if (parsed == null) continue;
        if (now.difference(parsed) > _timeWindow) continue;
        final score = _normalize(_toDouble(decoded['reliability_trend_score']));
        if (score != null) scores.add(score);
      } catch (_) {
        continue;
      }
    }
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String _buildText(
    double reliability,
    double stability,
    double system,
    double index,
    double delta,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('FORECAST RESILIENCE SUMMARY')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Recovery reliability: ${pct(reliability)}')
      ..writeln('Stability regression: ${pct(stability)}')
      ..writeln('System snapshot score: ${pct(system)}')
      ..writeln('Resilience Forecast Index: ${pct(index)}')
      ..writeln('Trend delta (vs 7d avg): ${pct(delta)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double reliability,
    double stability,
    double system,
    double index,
    double delta,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'reliability_trend_score': reliability,
    'stability_regression_score': stability,
    'system_snapshot_score': system,
    'resilience_forecast_index': index,
    'trend_delta': delta,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double reliability,
    double stability,
    double system,
    double index,
    double delta,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'forecast_resilience_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'reliability_trend_score': reliability,
      'stability_regression_score': stability,
      'system_snapshot_score': system,
      'resilience_forecast_index': index,
      'trend_delta': delta,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  const _Summary({
    required this.pass,
    required this.timestamp,
    required this.score,
  });

  final bool pass;
  final DateTime? timestamp;
  final double? score;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
