import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final kickoff = _MaintenanceKickoff();
  try {
    final plan = await kickoff.buildPlan();
    await kickoff.writePlan(plan);
    await kickoff.emitTelemetry(plan);
  } finally {
    await kickoff.restorePermissions();
  }
}

class _MaintenanceKickoff {
  bool _reportsWritable = false;

  Future<_MaintenancePlan> buildPlan() async {
    final watch = Stopwatch()..start();
    final auditStats = await _parseSystemAudit();
    final telemetryStats = await _parseTelemetry();
    final stabilityStats = await _parseStability();
    watch.stop();

    final riskScore = _calculateRisk(
      auditStats.failCount,
      auditStats.warnCount,
      telemetryStats.deprecated,
      stabilityStats.stabilityScore,
    );
    final nextAuditDays = _nextAuditDays(riskScore);

    return _MaintenancePlan(
      timestamp: DateTime.now().toUtc(),
      auditStats: auditStats,
      telemetryStats: telemetryStats,
      stabilityStats: stabilityStats,
      riskScore: riskScore,
      nextAuditDays: nextAuditDays,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_AuditStats> _parseSystemAudit() async {
    final file = File('release/_reports/final_system_audit_summary.txt');
    if (!file.existsSync()) {
      throw StateError('final_system_audit_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    int? passCount;
    int? warnCount;
    int? failCount;
    for (final line in lines) {
      if (line.startsWith('PASS:')) {
        final parts = line.split(RegExp(r'[: ]+'));
        passCount = int.tryParse(parts[1]);
        warnCount = int.tryParse(parts[3]);
        failCount = int.tryParse(parts[5]);
        break;
      }
    }
    return _AuditStats(
      passCount: passCount ?? 0,
      warnCount: warnCount ?? 0,
      failCount: failCount ?? 0,
    );
  }

  Future<_TelemetryStats> _parseTelemetry() async {
    final file = File(
      'release/_reports/system_telemetry_harmonization_summary.txt',
    );
    if (!file.existsSync()) {
      throw StateError('system_telemetry_harmonization_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    int declared = 0;
    int logged = 0;
    int deprecated = 0;
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 4 || parts[1] == 'Metric') continue;
      final metric = parts[1];
      final count = int.tryParse(parts[2]) ?? 0;
      if (metric == 'Declared') {
        declared = count;
      } else if (metric == 'Logged') {
        logged = count;
      } else if (metric == 'Deprecated') {
        deprecated = count;
      }
    }
    return _TelemetryStats(
      declared: declared,
      logged: logged,
      deprecated: deprecated,
    );
  }

  Future<_StabilityStats> _parseStability() async {
    final file = File('release/_reports/stability_scaling_audit.txt');
    if (!file.existsSync()) {
      throw StateError('stability_scaling_audit.txt not found.');
    }
    final lines = await file.readAsLines();
    double stabilityScore = 1.0;
    for (final line in lines) {
      if (line.startsWith('stability_score=')) {
        stabilityScore = double.tryParse(line.split('=').last.trim()) ?? 1.0;
      }
    }
    return _StabilityStats(stabilityScore: stabilityScore);
  }

  double _calculateRisk(
    int failCount,
    int warnCount,
    int deprecatedEvents,
    double stabilityScore,
  ) {
    var risk = 0.0;
    risk += failCount * 4;
    risk += warnCount * 2;
    risk += deprecatedEvents * 0.5;
    risk += (1 - stabilityScore) * 10;
    return risk.clamp(0, 100);
  }

  int _nextAuditDays(double riskScore) {
    if (riskScore > 20) return 14;
    if (riskScore > 10) return 30;
    return 45;
  }

  Future<void> writePlan(_MaintenancePlan plan) async {
    final buffer = StringBuffer()
      ..writeln('Maintenance Kickoff Plan')
      ..writeln('Timestamp: ${plan.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Area | Metric | Value |')
      ..writeln('|------|--------|-------|')
      ..writeln(
        '| System Audit | PASS/WARN/FAIL | '
        '${plan.auditStats.passCount}/${plan.auditStats.warnCount}/${plan.auditStats.failCount} |',
      )
      ..writeln(
        '| Telemetry | Declared vs Logged | '
        '${plan.telemetryStats.declared}/${plan.telemetryStats.logged} |',
      )
      ..writeln(
        '| Telemetry | Deprecated events | ${plan.telemetryStats.deprecated} |',
      )
      ..writeln(
        '| Stability | Score | ${plan.stabilityStats.stabilityScore.toStringAsFixed(3)} |',
      )
      ..writeln()
      ..writeln('Risk Score: ${plan.riskScore.toStringAsFixed(1)}')
      ..writeln('Next audit in: ${plan.nextAuditDays} days');

    await _writeReportsFile(
      'release/_reports/maintenance_kickoff_plan.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_MaintenancePlan plan) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.maintenanceKickoffCompleted,
      'timestamp': plan.timestamp.toIso8601String(),
      'risk_score': plan.riskScore,
      'next_audit_days': plan.nextAuditDays,
      'duration_ms': plan.durationMs,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    try {
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _AuditStats {
  _AuditStats({
    required this.passCount,
    required this.warnCount,
    required this.failCount,
  });

  final int passCount;
  final int warnCount;
  final int failCount;
}

class _TelemetryStats {
  _TelemetryStats({
    required this.declared,
    required this.logged,
    required this.deprecated,
  });

  final int declared;
  final int logged;
  final int deprecated;
}

class _StabilityStats {
  _StabilityStats({required this.stabilityScore});

  final double stabilityScore;
}

class _MaintenancePlan {
  _MaintenancePlan({
    required this.timestamp,
    required this.auditStats,
    required this.telemetryStats,
    required this.stabilityStats,
    required this.riskScore,
    required this.nextAuditDays,
    required this.durationMs,
  });

  final DateTime timestamp;
  final _AuditStats auditStats;
  final _TelemetryStats telemetryStats;
  final _StabilityStats stabilityStats;
  final double riskScore;
  final int nextAuditDays;
  final int durationMs;
}
