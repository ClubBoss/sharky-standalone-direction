import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _maintenancePath =
    '$_reportsDir/automation_maintenance_loop_v2_summary.json';
const String _telemetryPath =
    '$_reportsDir/telemetry_health_sweep_summary.json';
const String _stabilityPath = '$_reportsDir/stability_dashboard_summary.json';
const String _monetizationPath =
    '$_reportsDir/global_monetization_summary.json';
const String _visualPath = '$_reportsDir/visual_cohesion_final_summary.txt';
const String _summaryTextPath =
    '$_reportsDir/automation_maintenance_consolidator_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/automation_maintenance_consolidator_summary.json';
const String _telemetryOut = '$_reportsDir/telemetry.jsonl';

const double _warnThreshold = 0.85;
const double _passThreshold = 0.95;

Future<void> main(List<String> args) async {
  final consolidator = AutomationMaintenanceConsolidator();
  final ok = await consolidator.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AutomationMaintenanceConsolidator {
  Future<bool> run() async {
    final maintenance = await _readJson(_maintenancePath);
    final telemetry = await _readJson(_telemetryPath);
    final stability = await _readJson(_stabilityPath);
    final monetization = await _readJson(_monetizationPath);
    if (maintenance == null ||
        telemetry == null ||
        stability == null ||
        monetization == null) {
      stderr.writeln('Required consolidator inputs missing or malformed.');
      return false;
    }

    final maintenanceScore =
        (maintenance['integrity_score'] as num?)?.toDouble() ?? 0;
    final telemetryScore =
        (telemetry['coverage_ratio'] as num?)?.toDouble() ?? 0;
    final stabilityScore = (stability['health_score'] as num?)?.toDouble() ?? 0;
    final monetizationScore =
        (monetization['global_monetization_index'] as num?)?.toDouble() ?? 0;

    double aii =
        (maintenanceScore * 0.35) +
        (telemetryScore * 0.25) +
        (stabilityScore * 0.25) +
        (monetizationScore * 0.15);

    final visualBonus = await _readVisualBonus();
    if (visualBonus != null) {
      aii = (aii * visualBonus).clamp(0, 1);
    }

    final verdict = aii >= _passThreshold
        ? 'PASS'
        : aii >= _warnThreshold
        ? 'WARN'
        : 'FAIL';

    final summaryText = _buildTextSummary(
      maintenanceScore,
      telemetryScore,
      stabilityScore,
      monetizationScore,
      aii,
      verdict,
      visualApplied: visualBonus != null,
    );
    final summaryJson = _buildJsonSummary(
      maintenanceScore,
      telemetryScore,
      stabilityScore,
      monetizationScore,
      aii,
      verdict,
      visualApplied: visualBonus != null,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        maintenanceScore,
        telemetryScore,
        stabilityScore,
        monetizationScore,
        aii,
        verdict,
      );
    });

    if (aii < _warnThreshold) {
      stderr.writeln(
        'Automation Integrity Index ${aii.toStringAsFixed(3)} below 0.85.',
      );
    } else if (aii < _passThreshold) {
      stderr.writeln(
        'Automation Integrity Index ${aii.toStringAsFixed(3)} warning range.',
      );
    }

    return aii >= _passThreshold;
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

  Future<double?> _readVisualBonus() async {
    final file = File(_visualPath);
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      final match = RegExp(
        r'Final Visual Health:\s*([0-9.]+)%',
      ).firstMatch(contents);
      if (match == null) return null;
      final value = double.tryParse(match.group(1) ?? '');
      if (value == null) return null;
      return value >= 95 ? 1.03 : null;
    } catch (_) {
      return null;
    }
  }

  String _buildTextSummary(
    double maintenance,
    double telemetry,
    double stability,
    double monetization,
    double aii,
    String verdict, {
    required bool visualApplied,
  }) {
    String pct(double value) => '${(value * 100).toStringAsFixed(2)}%';
    final buffer = StringBuffer()
      ..writeln('AUTOMATION & MAINTENANCE CONSOLIDATOR')
      ..writeln('=====================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Maintenance Integrity: ${pct(maintenance)}')
      ..writeln('Telemetry Coverage: ${pct(telemetry)}')
      ..writeln('Stability Health: ${pct(stability)}')
      ..writeln('Monetization Index: ${pct(monetization)}')
      ..writeln('Automation Integrity Index: ${pct(aii)}')
      ..writeln(
        'Thresholds: PASS ≥ ${(_passThreshold * 100).toStringAsFixed(0)}%, '
        'WARN ≥ ${(_warnThreshold * 100).toStringAsFixed(0)}%',
      )
      ..writeln('Verdict: $verdict')
      ..writeln(
        'Visual cohesion bonus: ${visualApplied ? 'applied (×1.03 cap)' : 'not applied'}',
      );
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary(
    double maintenance,
    double telemetry,
    double stability,
    double monetization,
    double aii,
    String verdict, {
    required bool visualApplied,
  }) {
    return {
      'generated_at': DateTime.now().toIso8601String(),
      'maintenance_integrity': maintenance,
      'telemetry_coverage': telemetry,
      'stability_health': stability,
      'monetization_index': monetization,
      'automation_integrity_index': aii,
      'thresholds': {'warn': _warnThreshold, 'pass': _passThreshold},
      'visual_bonus_applied': visualApplied,
      'verdict': verdict,
    };
  }

  Future<void> _appendTelemetry(
    double maintenance,
    double telemetry,
    double stability,
    double monetization,
    double aii,
    String verdict,
  ) async {
    final payload = <String, Object?>{
      'event': 'automation_maintenance_consolidator_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'maintenance_integrity': maintenance,
      'telemetry_coverage': telemetry,
      'stability_health': stability,
      'monetization_index': monetization,
      'automation_integrity_index': aii,
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
