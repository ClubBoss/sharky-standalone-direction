import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _designPath =
    '$_reportsDir/design_audit_consolidator_summary.json';
const String _validationPath = '$_reportsDir/final_validation_summary.json';
const String _systemPath = '$_reportsDir/system_snapshot_v3_summary.json';
const String _certificationPath =
    '$_reportsDir/final_release_certification_summary.json';
const String _summaryTextPath =
    '$_reportsDir/final_integrity_consolidator_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/final_integrity_consolidator_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.9;
const Duration _timeWindow = Duration(hours: 24);

Future<void> main(List<String> args) async {
  final consolidator = FinalIntegrityConsolidator();
  final ok = await consolidator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class FinalIntegrityConsolidator {
  Future<bool> run() async {
    final design = await _loadSummary(_designPath, 'design_audit_score');
    final validation = await _loadSummary(
      _validationPath,
      'final_integrity_index',
    );
    final system = await _loadSummary(_systemPath, 'system_snapshot_v3_score');
    final certification = await _loadSummary(
      _certificationPath,
      'certification_score',
    );

    if (design == null ||
        validation == null ||
        system == null ||
        certification == null) {
      stderr.writeln('Missing final integrity inputs.');
      return false;
    }

    if (!design.pass ||
        !validation.pass ||
        !system.pass ||
        !certification.pass) {
      stderr.writeln('One or more summaries failed.');
      return false;
    }

    final timestamps = <DateTime>[
      if (design.timestamp != null) design.timestamp!,
      if (validation.timestamp != null) validation.timestamp!,
      if (system.timestamp != null) system.timestamp!,
      if (certification.timestamp != null) certification.timestamp!,
    ];
    if (!_aligned(timestamps)) {
      stderr.writeln('Input timestamps span more than $_timeWindow.');
      return false;
    }

    final designScore = _normalize(design.score);
    final validationScore = _normalize(validation.score);
    final systemScore = _normalize(system.score);
    final certificationScore = _normalize(certification.score);

    if (designScore == null ||
        validationScore == null ||
        systemScore == null ||
        certificationScore == null) {
      stderr.writeln('Unable to parse numeric scores.');
      return false;
    }

    final integrity =
        ((designScore * 0.35) +
                (validationScore * 0.3) +
                (systemScore * 0.2) +
                (certificationScore * 0.15))
            .clamp(0.0, 1.0);

    final pass = integrity >= _threshold;

    final text = _buildText(
      designScore,
      validationScore,
      systemScore,
      certificationScore,
      integrity,
      pass,
    );
    final json = _buildJson(
      designScore,
      validationScore,
      systemScore,
      certificationScore,
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
        validationScore,
        systemScore,
        certificationScore,
        integrity,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Final Integrity Index ${(integrity * 100).toStringAsFixed(2)}% below threshold.',
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
    double validation,
    double system,
    double certification,
    double integrity,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('FINAL INTEGRITY CONSOLIDATOR')
      ..writeln('============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Design audit score: ${pct(design)}')
      ..writeln('Final validation: ${pct(validation)}')
      ..writeln('System snapshot: ${pct(system)}')
      ..writeln('Certification: ${pct(certification)}')
      ..writeln('Final Integrity Index: ${pct(integrity)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJson(
    double design,
    double validation,
    double system,
    double certification,
    double integrity,
    bool pass,
  ) => {
    'generated_at': DateTime.now().toIso8601String(),
    'design_audit_score': design,
    'final_validation_score': validation,
    'system_snapshot_score': system,
    'certification_score': certification,
    'final_integrity_index': integrity,
    'threshold': _threshold,
    'verdict': pass ? 'PASS' : 'FAIL',
  };

  Future<void> _appendTelemetry(
    double design,
    double validation,
    double system,
    double certification,
    double integrity,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'final_integrity_consolidator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'design_audit_score': design,
      'final_validation_score': validation,
      'system_snapshot_score': system,
      'certification_score': certification,
      'final_integrity_index': integrity,
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
