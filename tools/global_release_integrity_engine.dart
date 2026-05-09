import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _designPath =
    '$_reportsDir/final_integrity_consolidator_summary.json';
const String _resiliencePath = '$_reportsDir/forecast_resilience_summary.json';
const String _reliabilityPath =
    '$_reportsDir/long_term_reliability_summary.json';
const String _validationPath = '$_reportsDir/final_validation_summary.json';
const String _summaryTextPath =
    '$_reportsDir/global_release_integrity_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/global_release_integrity_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final engine = GlobalReleaseIntegrityEngine();
  final ok = await engine.run();
  if (!ok) {
    exitCode = 2;
  }
}

class GlobalReleaseIntegrityEngine {
  Future<bool> run() async {
    final design = await _loadSummary(_designPath, 'final_integrity_index');
    final resilience = await _loadSummary(
      _resiliencePath,
      'resilience_forecast_index',
    );
    final reliability = await _loadSummary(
      _reliabilityPath,
      'reliability_trend_score',
    );
    final validation = await _loadSummary(
      _validationPath,
      'final_integrity_index',
    );

    if (design == null ||
        resilience == null ||
        reliability == null ||
        validation == null) {
      stderr.writeln('Missing global release integrity inputs.');
      return false;
    }

    if (!design.pass ||
        !resilience.pass ||
        !reliability.pass ||
        !validation.pass) {
      stderr.writeln('One or more summaries did not pass.');
      return false;
    }

    final stamps = <DateTime>[
      if (design.timestamp != null) design.timestamp!,
      if (resilience.timestamp != null) resilience.timestamp!,
      if (reliability.timestamp != null) reliability.timestamp!,
      if (validation.timestamp != null) validation.timestamp!,
    ];
    if (!_aligned(stamps)) {
      stderr.writeln('Timestamps exceed ${_timeWindow.inHours}h.');
      return false;
    }

    final designScore = _normalize(design.score);
    final resilienceScore = _normalize(resilience.score);
    final reliabilityScore = _normalize(reliability.score);
    final validationScore = _normalize(validation.score);

    if (designScore == null ||
        resilienceScore == null ||
        reliabilityScore == null ||
        validationScore == null) {
      stderr.writeln('Unable to parse numeric scores.');
      return false;
    }

    final integrity =
        ((designScore * 0.35) +
                (resilienceScore * 0.3) +
                (reliabilityScore * 0.2) +
                (validationScore * 0.15))
            .clamp(0.0, 1.0);
    final pass = integrity >= _threshold;

    final text = _buildText(
      designScore,
      resilienceScore,
      reliabilityScore,
      validationScore,
      integrity,
      pass,
    );
    final json = _buildJson(
      designScore,
      resilienceScore,
      reliabilityScore,
      validationScore,
      integrity,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        designScore,
        resilienceScore,
        reliabilityScore,
        validationScore,
        integrity,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Global Release Integrity Index ${(integrity * 100).toStringAsFixed(2)}% below threshold.',
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
      final score = _toDouble(decoded[key]) ?? _toDouble(decoded['score']);
      return _Summary(pass: verdict == 'PASS', timestamp: parsed, score: score);
    } catch (_) {
      return null;
    }
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
    double design,
    double resilience,
    double reliability,
    double validation,
    double integrity,
    bool pass,
  ) {
    String pct(double v) => '${(v * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('GLOBAL RELEASE INTEGRITY SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Design audit: ${pct(design)}')
      ..writeln('Resilience forecast: ${pct(resilience)}')
      ..writeln('Reliability trend: ${pct(reliability)}')
      ..writeln('Final validation: ${pct(validation)}')
      ..writeln('Integrity index: ${pct(integrity)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double design,
    double resilience,
    double reliability,
    double validation,
    double integrity,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'design_audit_score': design,
    'resilience_forecast_index': resilience,
    'reliability_trend_score': reliability,
    'final_validation_score': validation,
    'global_release_integrity_index': integrity,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double design,
    double resilience,
    double reliability,
    double validation,
    double integrity,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'global_release_integrity_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'design_audit_score': design,
      'resilience_forecast_index': resilience,
      'reliability_trend_score': reliability,
      'final_validation_score': validation,
      'global_release_integrity_index': integrity,
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
