import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _monetizationPath =
    '$_reportsDir/monetization_synergy_summary.json';
const String _growthPath = '$_reportsDir/user_growth_analytics_summary.json';
const String _retentionPath =
    '$_reportsDir/retention_intelligence_summary.json';
const String _validationPath = '$_reportsDir/final_validation_summary.json';
const String _summaryTextPath = '$_reportsDir/growth_validation_summary.txt';
const String _summaryJsonPath = '$_reportsDir/growth_validation_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final pass = GrowthValidationPass();
  final ok = await pass.run();
  if (!ok) {
    exitCode = 2;
  }
}

class GrowthValidationPass {
  Future<bool> run() async {
    final monetization = await _loadSummary(
      _monetizationPath,
      'monetization_synergy_index',
    );
    final growth = await _loadSummary(_growthPath, 'user_growth_index');
    final retention = await _loadSummary(
      _retentionPath,
      'retention_intelligence_index',
    );
    final validation = await _loadSummary(
      _validationPath,
      'final_integrity_index',
    );

    if (monetization == null ||
        growth == null ||
        retention == null ||
        validation == null) {
      stderr.writeln('Missing growth validation inputs.');
      return false;
    }

    if (!monetization.pass ||
        !growth.pass ||
        !retention.pass ||
        !validation.pass) {
      stderr.writeln('One or more inputs failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (monetization.timestamp != null) monetization.timestamp!,
      if (growth.timestamp != null) growth.timestamp!,
      if (retention.timestamp != null) retention.timestamp!,
      if (validation.timestamp != null) validation.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Timestamps span more than ${_timeWindow.inHours}h.');
      return false;
    }

    final scores = [
      _normalize(monetization.score),
      _normalize(growth.score),
      _normalize(retention.score),
      _normalize(validation.score),
    ];

    if (scores.any((score) => score == null)) {
      stderr.writeln('Unable to parse numeric scores.');
      return false;
    }

    final monetizationScore = scores[0]!;
    final growthScore = scores[1]!;
    final retentionScore = scores[2]!;
    final validationScore = scores[3]!;

    final index =
        ((monetizationScore * 0.35) +
                (growthScore * 0.30) +
                (retentionScore * 0.20) +
                (validationScore * 0.15))
            .clamp(0.0, 1.0);
    final passScore = index >= _threshold;

    final text = _buildText(
      monetizationScore,
      growthScore,
      retentionScore,
      validationScore,
      index,
      passScore,
    );
    final json = _buildJson(
      monetizationScore,
      growthScore,
      retentionScore,
      validationScore,
      index,
      passScore,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(text);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
      await _appendTelemetry(
        monetizationScore,
        growthScore,
        retentionScore,
        validationScore,
        index,
        passScore,
      );
    });

    if (!passScore) {
      stderr.writeln(
        'Growth Validation Index ${(index * 100).toStringAsFixed(2)}% below threshold.',
      );
    }

    return passScore;
  }

  Future<_Summary?> _loadSummary(String path, String key) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, Object?>) return null;
      final verdict = ((decoded['verdict'] as String?) ?? '').toUpperCase();
      final generated =
          decoded['generated_at'] as String? ??
          decoded['generated'] as String? ??
          decoded['timestamp'] as String?;
      final parsed = generated != null ? DateTime.tryParse(generated) : null;
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
    double monetization,
    double growth,
    double retention,
    double validation,
    double index,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('GROWTH VALIDATION SUMMARY')
      ..writeln('=========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Monetization synergy: ${pct(monetization)}')
      ..writeln('User Growth Index: ${pct(growth)}')
      ..writeln('Retention intelligence: ${pct(retention)}')
      ..writeln('Final validation: ${pct(validation)}')
      ..writeln('Growth Validation Index: ${pct(index)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double monetization,
    double growth,
    double retention,
    double validation,
    double index,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'monetization_synergy_index': monetization,
    'user_growth_index': growth,
    'retention_intelligence_index': retention,
    'final_validation_index': validation,
    'growth_validation_index': index,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double monetization,
    double growth,
    double retention,
    double validation,
    double index,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'growth_validation_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'monetization_synergy_index': monetization,
      'user_growth_index': growth,
      'retention_intelligence_index': retention,
      'final_validation_index': validation,
      'growth_validation_index': index,
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
