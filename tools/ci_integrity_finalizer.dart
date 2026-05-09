import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _automationPath =
    '$_reportsDir/automation_maintenance_consolidator_summary.json';
const String _regressionPath =
    '$_reportsDir/continuous_regression_assurance_summary.json';
const String _telemetryPath =
    '$_reportsDir/telemetry_health_sweep_summary.json';
const String _docsPath = '$_reportsDir/docs_audit_summary.json';
const String _summaryTextPath =
    '$_reportsDir/ci_integrity_finalizer_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/ci_integrity_finalizer_summary.json';
const String _telemetryOut = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final finalizer = CiIntegrityFinalizer();
  final ok = await finalizer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class CiIntegrityFinalizer {
  Future<bool> run() async {
    final automation = await _readJson(_automationPath);
    final regression = await _readJson(_regressionPath);
    final telemetry = await _readJson(_telemetryPath);
    final docs = await _readJson(_docsPath);

    if (automation == null ||
        regression == null ||
        telemetry == null ||
        docs == null) {
      stderr.writeln('CI integrity finalizer missing required inputs.');
      return false;
    }

    final regressionScore =
        (regression['regression_assurance_score'] as num?)?.toDouble() ?? 0;
    final automationScore =
        (automation['automation_integrity_index'] as num?)?.toDouble() ?? 0;
    final telemetryScore =
        (telemetry['coverage_ratio'] as num?)?.toDouble() ?? 0;
    final docsScore = (docs['doc_missing_ratio'] is num)
        ? (1 - (docs['doc_missing_ratio'] as num).toDouble())
              .clamp(0, 1)
              .toDouble()
        : 1.0;

    final ciis =
        (regressionScore * 0.4) +
        (automationScore * 0.3) +
        (telemetryScore * 0.2) +
        (docsScore * 0.1);
    final clampedCiis = ciis.clamp(0, 1).toDouble();

    final verdict = clampedCiis >= _passThreshold
        ? 'PASS'
        : clampedCiis >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      regressionScore,
      automationScore,
      telemetryScore,
      docsScore,
      clampedCiis,
      verdict,
    );
    final summaryJson = _buildJsonSummary(
      regressionScore,
      automationScore,
      telemetryScore,
      docsScore,
      clampedCiis,
      verdict,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        regressionScore,
        automationScore,
        telemetryScore,
        docsScore,
        clampedCiis,
        verdict,
      );
    });

    if (clampedCiis < _warnThreshold) {
      stderr.writeln(
        'CI Integrity Score ${clampedCiis.toStringAsFixed(3)} below 0.85.',
      );
    } else if (clampedCiis < _passThreshold) {
      stderr.writeln(
        'CI Integrity Score ${clampedCiis.toStringAsFixed(3)} warning range.',
      );
    }

    return clampedCiis >= _passThreshold;
  }

  Future<Map<String, dynamic>?> _readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  String _buildTextSummary(
    double regression,
    double automation,
    double telemetry,
    double docs,
    double ciis,
    String verdict,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('CI INTEGRITY FINALIZER SUMMARY')
      ..writeln('=============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Regression Assurance: ${pct(regression)}')
      ..writeln('Automation Integrity: ${pct(automation)}')
      ..writeln('Telemetry Coverage: ${pct(telemetry)}')
      ..writeln('Docs Audit Confidence: ${pct(docs)}')
      ..writeln('CI Integrity Score: ${pct(ciis)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double regression,
    double automation,
    double telemetry,
    double docs,
    double ciis,
    String verdict,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'regression_assurance_score': regression,
      'automation_integrity_index': automation,
      'telemetry_coverage': telemetry,
      'docs_confidence': docs,
      'ci_integrity_score': ciis,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double regression,
    double automation,
    double telemetry,
    double docs,
    double ciis,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'ci_integrity_finalizer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'regression_assurance_score': regression,
      'automation_integrity_index': automation,
      'telemetry_coverage': telemetry,
      'docs_confidence': docs,
      'ci_integrity_score': ciis,
      'verdict': verdict,
    };
    final sink = File(_telemetryOut).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
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
