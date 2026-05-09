import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _resiliencePath = '$_reportsDir/forecast_resilience_summary.json';
const String _reliabilityPath =
    '$_reportsDir/long_term_reliability_summary.json';
const String _ciIntegrityPath =
    '$_reportsDir/ci_integrity_finalizer_summary.json';
const String _textSummaryPath =
    '$_reportsDir/system_sustainability_summary.txt';
const String _jsonSummaryPath =
    '$_reportsDir/system_sustainability_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _window = Duration(days: 7);

Future<void> main(List<String> args) async {
  final evaluator = SystemSustainabilityEvaluator();
  final ok = await evaluator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SystemSustainabilityEvaluator {
  Future<bool> run() async {
    final resilience = await _readReport(_resiliencePath, [
      'resilience_forecast_index',
    ]);
    final reliability = await _readReport(_reliabilityPath, [
      'reliability_trend_score',
    ]);
    final ci = await _readReport(_ciIntegrityPath, ['ci_integrity_score']);

    if (resilience == null || reliability == null || ci == null) {
      stderr.writeln('Missing sustainability inputs.');
      return false;
    }

    if (!resilience.pass || !reliability.pass || !ci.pass) {
      stderr.writeln('Some inputs did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (resilience.timestamp != null) resilience.timestamp!,
      if (reliability.timestamp != null) reliability.timestamp!,
      if (ci.timestamp != null) ci.timestamp!,
    ];

    if (!_withinWindow(timestamps)) {
      stderr.writeln('Input timestamps span more than ${_window.inDays} days.');
      return false;
    }

    final resilienceScore = _normalize(resilience.score);
    final reliabilityScore = _normalize(reliability.score);
    final ciScore = _normalize(ci.score);

    if (resilienceScore == null ||
        reliabilityScore == null ||
        ciScore == null) {
      stderr.writeln('Unable to extract numeric scores.');
      return false;
    }

    final sustainabilityIndex =
        ((resilienceScore * 0.4) + (reliabilityScore * 0.35) + (ciScore * 0.25))
            .clamp(0.0, 1.0);

    final previous = await _historicalAverage(
      'system_sustainability_completed',
    );
    final trendDelta = previous == null ? 0.0 : sustainabilityIndex - previous;
    final pass = sustainabilityIndex >= _threshold;

    final text = _buildText(
      resilienceScore,
      reliabilityScore,
      ciScore,
      sustainabilityIndex,
      trendDelta,
      pass,
    );
    final json = _buildJson(
      resilienceScore,
      reliabilityScore,
      ciScore,
      sustainabilityIndex,
      trendDelta,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_textSummaryPath).writeAsString(text);
      await File(
        _jsonSummaryPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        resilienceScore,
        reliabilityScore,
        ciScore,
        sustainabilityIndex,
        trendDelta,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Sustainability Score ${(sustainabilityIndex * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Report?> _readReport(String path, List<String> scoreKeys) async {
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
      final score = _extractScore(decoded, scoreKeys);
      return _Report(
        pass: verdict == 'PASS',
        verdict: verdict,
        timestamp: parsed,
        score: score,
      );
    } catch (_) {
      return null;
    }
  }

  double? _extractScore(Map<String, Object?> data, List<String> keys) {
    for (final key in keys) {
      if (!data.containsKey(key)) continue;
      final value = _toDouble(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  bool _withinWindow(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _window;
  }

  double? _normalize(double? value) {
    if (value == null) return null;
    final normalized = value > 1 ? value / 100 : value;
    return normalized.clamp(0.0, 1.0);
  }

  double? _toDouble(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }

  Future<double?> _historicalAverage(String eventName) async {
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
        if (now.difference(parsed) > _window) continue;
        final score = _normalize(_toDouble(decoded['sustainability_score']));
        if (score != null) scores.add(score);
      } catch (_) {
        continue;
      }
    }
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  String _buildText(
    double resilience,
    double reliability,
    double ci,
    double index,
    double trend,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('SYSTEM SUSTAINABILITY SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Resilience index: ${pct(resilience)}')
      ..writeln('Reliability index: ${pct(reliability)}')
      ..writeln('CI integrity: ${pct(ci)}')
      ..writeln('Sustainability score: ${pct(index)}')
      ..writeln('Trend delta: ${pct(trend)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double resilience,
    double reliability,
    double ci,
    double index,
    double trend,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'resilience_index': resilience,
    'reliability_index': reliability,
    'ci_integrity_score': ci,
    'sustainability_score': index,
    'trend_delta': trend,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double resilience,
    double reliability,
    double ci,
    double index,
    double trend,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'system_sustainability_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'resilience_index': resilience,
      'reliability_index': reliability,
      'ci_integrity_score': ci,
      'sustainability_score': index,
      'trend_delta': trend,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Report {
  _Report({
    required this.pass,
    required this.verdict,
    required this.timestamp,
    required this.score,
  });

  final bool pass;
  final String verdict;
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
