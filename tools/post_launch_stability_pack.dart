import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _integrationPath = '$_reportsDir/final_validation_summary.json';
const String _telemetrySummaryPath =
    '$_reportsDir/post_release_telemetry_summary.json';
const String _reliabilityPath =
    '$_reportsDir/long_term_reliability_summary.json';
const String _summaryTextPath =
    '$_reportsDir/post_launch_stability_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/post_launch_stability_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _window = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final pack = PostLaunchStabilityPack();
  final ok = await pack.run();
  if (!ok) {
    exitCode = 2;
  }
}

class PostLaunchStabilityPack {
  Future<bool> run() async {
    final integration = await _readReport(
      _integrationPath,
      'final_integrity_index',
    );
    final telemetrySummary = await _readReport(
      _telemetrySummaryPath,
      'coverage_percent',
      defaultScoreKey: 'coverage_percent',
    );
    final reliability = await _readReport(
      _reliabilityPath,
      'reliability_trend_score',
    );

    if (integration == null ||
        telemetrySummary == null ||
        reliability == null) {
      stderr.writeln('Missing post-launch stability inputs.');
      return false;
    }

    if (!integration.pass || !telemetrySummary.pass || !reliability.pass) {
      stderr.writeln('One or more summaries did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (integration.timestamp != null) integration.timestamp!,
      if (telemetrySummary.timestamp != null) telemetrySummary.timestamp!,
      if (reliability.timestamp != null) reliability.timestamp!,
    ];

    if (!_withinWindow(timestamps)) {
      stderr.writeln('Input timestamps span more than ${_window.inHours}h.');
      return false;
    }

    final integrityScore = _normalize(integration.score);
    final telemetryScore = _normalize(telemetrySummary.score);
    final reliabilityScore = _normalize(reliability.score);

    if (integrityScore == null ||
        telemetryScore == null ||
        reliabilityScore == null) {
      stderr.writeln('Failed to extract scores.');
      return false;
    }

    final stabilityIndex =
        ((integrityScore * 0.4) +
                (telemetryScore * 0.35) +
                (reliabilityScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = stabilityIndex >= _threshold;

    final text = _buildText(
      integrityScore,
      telemetryScore,
      reliabilityScore,
      stabilityIndex,
      pass,
    );
    final json = _buildJson(
      integrityScore,
      telemetryScore,
      reliabilityScore,
      stabilityIndex,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        integrityScore,
        telemetryScore,
        reliabilityScore,
        stabilityIndex,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Post-launch stability index ${(stabilityIndex * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Report?> _readReport(
    String path,
    String scoreKey, {
    String? defaultScoreKey,
  }) async {
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
      final score =
          _toDouble(decoded[scoreKey]) ?? _toDouble(decoded[defaultScoreKey]);
      return _Report(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
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

  String _buildText(
    double integrity,
    double telemetry,
    double reliability,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('POST-LAUNCH STABILITY SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Final integrity index: ${pct(integrity)}')
      ..writeln('Telemetry coverage: ${pct(telemetry)}')
      ..writeln('Reliability trend: ${pct(reliability)}')
      ..writeln('Post-launch stability: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double integrity,
    double telemetry,
    double reliability,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'final_integrity_index': integrity,
    'telemetry_coverage': telemetry,
    'reliability_trend_score': reliability,
    'post_launch_stability_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double integrity,
    double telemetry,
    double reliability,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'post_launch_stability_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'final_integrity_index': integrity,
      'telemetry_coverage': telemetry,
      'reliability_trend_score': reliability,
      'post_launch_stability_index': index,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Report {
  _Report({required this.pass, required this.timestamp, required this.score});

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
