import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _phiSummaryPath = '$_reportsDir/phi_v2_final_summary.json';
const String _regressionSummaryPath =
    '$_reportsDir/continuous_regression_assurance_summary.json';
const String _automationSummaryPath =
    '$_reportsDir/automation_maintenance_consolidator_summary.json';
const String _monetizationSummaryPath =
    '$_reportsDir/global_monetization_summary.json';
const String _summaryTextPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/stability_qa_consolidator_v2_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _threshold = 0.90;

Future<void> main(List<String> args) async {
  final consolidator = StabilityQaConsolidatorV2();
  final ok = await consolidator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class StabilityQaConsolidatorV2 {
  Future<bool> run() async {
    final phi = await _readJson(_phiSummaryPath);
    final regression = await _readJson(_regressionSummaryPath);
    final automation = await _readJson(_automationSummaryPath);
    final monetization = await _readJson(_monetizationSummaryPath);

    if (phi == null ||
        regression == null ||
        automation == null ||
        monetization == null) {
      stderr.writeln(
        'Missing required summaries (Φ-v2 / regression assurance / automation / monetization).',
      );
      return false;
    }

    final phiIndex =
        (phi['phi_v2_final_design_index'] as num?)?.toDouble() ?? 0;
    final regressionScore =
        (regression['regression_assurance_score'] as num?)?.toDouble() ?? 0;
    final automationScore =
        (automation['automation_integrity_index'] as num?)?.toDouble() ?? 0;
    final monetizationScore =
        (monetization['global_monetization_index'] as num?)?.toDouble() ?? 0;

    final stabilityIntegrity =
        ((phiIndex * 0.35) +
                (regressionScore * 0.25) +
                (automationScore * 0.25) +
                (monetizationScore * 0.15))
            .clamp(0, 1)
            .toDouble();
    final pass = stabilityIntegrity >= _threshold;

    final summaryText = _buildTextSummary(
      phiIndex,
      regressionScore,
      automationScore,
      monetizationScore,
      stabilityIntegrity,
      pass,
    );
    final summaryJson = _buildJsonSummary(
      phiIndex,
      regressionScore,
      automationScore,
      monetizationScore,
      stabilityIntegrity,
      pass,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        phiIndex,
        regressionScore,
        automationScore,
        monetizationScore,
        stabilityIntegrity,
        pass,
      );
    });

    if (!pass) {
      stderr.writeln(
        'Stability Integrity Score ${stabilityIntegrity.toStringAsFixed(3)} below 0.90.',
      );
    }

    return pass;
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
    double phiIndex,
    double regression,
    double automation,
    double monetization,
    double stability,
    bool pass,
  ) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('STABILITY QA CONSOLIDATOR V2 SUMMARY')
      ..writeln('====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Φ-v2 Final Design Index: ${pct(phiIndex)}')
      ..writeln('Regression Assurance Score: ${pct(regression)}')
      ..writeln('Automation Integrity Index: ${pct(automation)}')
      ..writeln('Global Monetization Index: ${pct(monetization)}')
      ..writeln('Stability Integrity Score: ${pct(stability)}')
      ..writeln('Threshold: ${(_threshold * 100).toStringAsFixed(2)}%')
      ..writeln('Verdict: ${pass ? 'PASS' : 'FAIL'}');
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double phiIndex,
    double regression,
    double automation,
    double monetization,
    double stability,
    bool pass,
  ) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'phi_v2_final_design_index': phiIndex,
      'regression_assurance_score': regression,
      'automation_integrity_index': automation,
      'global_monetization_index': monetization,
      'stability_integrity_score': stability,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
  }

  Future<void> _appendTelemetry(
    double phiIndex,
    double regression,
    double automation,
    double monetization,
    double stability,
    bool pass,
  ) async {
    final payload = <String, Object?>{
      'event': 'stability_qa_consolidator_v2_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'phi_v2_final_design_index': phiIndex,
      'regression_assurance_score': regression,
      'automation_integrity_index': automation,
      'global_monetization_index': monetization,
      'stability_integrity_score': stability,
      'threshold': _threshold,
      'verdict': pass ? 'PASS' : 'FAIL',
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
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
