import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _integrityPath =
    '$_reportsDir/global_release_integrity_summary.json';
const String _telemetryPath =
    '$_reportsDir/post_release_telemetry_summary.json';
const String _reliabilityPath =
    '$_reportsDir/long_term_reliability_summary.json';
const String _summaryTextPath = '$_reportsDir/omega_health_summary.txt';
const String _summaryJsonPath = '$_reportsDir/omega_health_summary.json';
const String _telemetryLogPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final summarizer = OmegaHealthSummarizer();
  final ok = await summarizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class OmegaHealthSummarizer {
  Future<bool> run() async {
    final integrity = await _loadSummary(
      _integrityPath,
      'global_release_integrity_index',
    );
    final telemetry = await _loadSummary(_telemetryPath, 'coverage_percent');
    final reliability = await _loadSummary(
      _reliabilityPath,
      'reliability_trend_score',
    );

    if (integrity == null || telemetry == null || reliability == null) {
      stderr.writeln('Missing Ω health inputs.');
      return false;
    }

    if (!integrity.pass || !telemetry.pass || !reliability.pass) {
      stderr.writeln('One or more summaries did not pass.');
      return false;
    }

    final timestamps = <DateTime>[
      if (integrity.timestamp != null) integrity.timestamp!,
      if (telemetry.timestamp != null) telemetry.timestamp!,
      if (reliability.timestamp != null) reliability.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final integrityScore = _normalize(integrity.score);
    final telemetryScore = _normalize(telemetry.score);
    final reliabilityScore = _normalize(reliability.score);

    if (integrityScore == null ||
        telemetryScore == null ||
        reliabilityScore == null) {
      stderr.writeln('Unable to parse scores.');
      return false;
    }

    final omegaScore =
        ((integrityScore * 0.4) +
                (telemetryScore * 0.35) +
                (reliabilityScore * 0.25))
            .clamp(0.0, 1.0);
    final pass = omegaScore >= _threshold;

    final text = _buildText(
      integrityScore,
      telemetryScore,
      reliabilityScore,
      omegaScore,
      pass,
    );
    final json = _buildJson(
      integrityScore,
      telemetryScore,
      reliabilityScore,
      omegaScore,
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
        omegaScore,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Ω Health Score ${(omegaScore * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return pass;
  }

  Future<_Summary?> _loadSummary(String path, String key) async {
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
      final score = _toDouble(decoded[key]) ?? _fallbackScore(decoded);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
  }

  double? _fallbackScore(Map<String, Object?> data) {
    const keys = <String>[
      'system_snapshot_v3_score',
      'final_integrity_index',
      'coverage_percent',
      'reliability_trend_score',
    ];
    for (final key in keys) {
      final value = _toDouble(data[key]);
      if (value != null) return value;
    }
    return null;
  }

  bool _aligned(List<DateTime> timestamps) {
    if (timestamps.length < 2) return true;
    timestamps.sort();
    return timestamps.last.difference(timestamps.first) <= _timeWindow;
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
    double score,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('Ω HEALTH SUMMARY')
      ..writeln('================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Global integrity: ${pct(integrity)}')
      ..writeln('Telemetry coverage: ${pct(telemetry)}')
      ..writeln('Reliability trend: ${pct(reliability)}')
      ..writeln('Ω Health Score: ${pct(score)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double integrity,
    double telemetry,
    double reliability,
    double score,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'global_integrity_index': integrity,
    'telemetry_coverage': telemetry,
    'reliability_trend_score': reliability,
    'omega_health_score': score,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double integrity,
    double telemetry,
    double reliability,
    double score,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'omega_health_summarizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'global_integrity_index': integrity,
      'telemetry_coverage': telemetry,
      'reliability_trend_score': reliability,
      'omega_health_score': score,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _Summary {
  _Summary({required this.pass, required this.timestamp, required this.score});

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
