import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final sweep = _RegressionConsistencySweep();
  try {
    final result = await sweep.run();
    await sweep.writeSummary(result);
    await sweep.emitTelemetry(result);
  } finally {
    await sweep.restorePermissions();
  }
}

class _RegressionConsistencySweep {
  bool _madeWritable = false;

  Future<_SweepResult> run() async {
    final flutter = await _parseFlutterReport(
      'release/_reports/flutter_test_stability_summary.txt',
    );
    final readiness = await _parseReadinessReport(
      'release/_reports/readiness_verification_v2_summary.txt',
    );
    final postRelease = await _parsePostReleaseReport(
      'release/_reports/post_release_validation_summary.txt',
    );

    final reports = <_ReportData>[flutter, readiness, postRelease];
    final statusSet = reports.map((r) => r.status).toSet();
    final mismatches = statusSet.length > 1;

    final driftIssues = _computeDurationDrift(reports);

    return _SweepResult(
      timestamp: DateTime.now().toUtc(),
      reports: reports,
      statusMismatch: mismatches,
      durationDrifts: driftIssues,
    );
  }

  Future<void> writeSummary(_SweepResult result) async {
    final buffer = StringBuffer()
      ..writeln('Regression Consistency Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Report | Status | Duration (s) | Notes |')
      ..writeln('|--------|--------|--------------|-------|');
    for (final report in result.reports) {
      buffer.writeln(
        '| ${report.name} | ${report.status} | '
        '${report.durationSeconds?.toStringAsFixed(2) ?? 'n/a'} | '
        '${report.note} |',
      );
    }

    if (!result.statusMismatch && result.durationDrifts.isEmpty) {
      buffer
        ..writeln()
        ..writeln(
          'All regression checkpoints aligned (no mismatches detected).',
        );
    } else {
      buffer
        ..writeln()
        ..writeln('Findings:');
      if (result.statusMismatch) {
        buffer.writeln('- PASS/FAIL status mismatch detected between reports.');
      }
      for (final drift in result.durationDrifts) {
        buffer.writeln(
          '- Duration drift between ${drift.a} and ${drift.b}: '
          '${(drift.deltaPercent * 100).toStringAsFixed(1)}%',
        );
      }
    }

    await _safeWrite(
      File('release/_reports/regression_consistency_summary.txt'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_SweepResult result) async {
    final statusMap = <String, String>{
      for (final report in result.reports) report.name: report.status,
    };
    final durations = <String, double>{
      for (final report in result.reports)
        if (report.durationSeconds != null)
          report.name: report.durationSeconds!,
    };

    final payload = <String, Object>{
      'event': TelemetryEvents.regressionConsistencyCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'statusMismatch': result.statusMismatch,
      'durationDrifts': result.durationDrifts.length,
      'statuses': statusMap,
      'durations': durations,
    };
    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  Future<_ReportData> _parseFlutterReport(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Missing $path');
    }
    final lines = await file.readAsLines();
    final entries = <_FlutterEntry>[];
    _FlutterEntry? current;
    for (final line in lines) {
      if (line.startsWith('Flutter Test Stability Audit')) {
        if (current != null) {
          entries.add(current);
        }
        current = _FlutterEntry();
      } else if (line.startsWith('Duration:')) {
        final match = RegExp(r'Duration:\s+(\d+)\s*s').firstMatch(line);
        if (match != null && current != null) {
          current.durationSeconds = double.parse(match.group(1)!);
        }
      } else if (line.trim().startsWith('- Failed:')) {
        final match = RegExp(r'- Failed:\s+(\d+)').firstMatch(line);
        if (match != null && current != null) {
          current.failed = int.parse(match.group(1)!);
        }
      }
    }
    if (current != null) {
      entries.add(current);
    }
    if (entries.isEmpty) {
      throw StateError('No audit entries in $path');
    }
    final latest = entries.last;
    final status = (latest.failed ?? 0) == 0 ? 'PASS' : 'FAIL';
    return _ReportData(
      name: 'flutter_test_stability',
      status: status,
      durationSeconds: latest.durationSeconds,
      note: 'Failed=${latest.failed ?? 0}',
    );
  }

  Future<_ReportData> _parseReadinessReport(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Missing $path');
    }
    final lines = await file.readAsLines();
    final rowPattern = RegExp(r'^\|\s*(.+?)\s*\|\s*(\w+)\s*\|\s*(\d+)\s*\|');
    var allPass = true;
    double totalDuration = 0;
    for (final line in lines) {
      final match = rowPattern.firstMatch(line);
      if (match == null) {
        continue;
      }
      final status = match.group(2)!.trim().toUpperCase();
      final duration = double.tryParse(match.group(3)!.trim()) ?? 0;
      if (status != 'PASS') {
        allPass = false;
      }
      totalDuration += duration;
    }
    return _ReportData(
      name: 'readiness_verification_v2',
      status: allPass ? 'PASS' : 'FAIL',
      durationSeconds: totalDuration == 0 ? null : totalDuration,
      note: 'Sum of gate durations',
    );
  }

  Future<_ReportData> _parsePostReleaseReport(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Missing $path');
    }
    final lines = await file.readAsLines();
    final statusLine = lines.firstWhere(
      (line) => line.startsWith('Status:'),
      orElse: () => 'Status: UNKNOWN',
    );
    final status = statusLine.split(':').last.trim().toUpperCase();
    return _ReportData(
      name: 'post_release_validation',
      status: status,
      durationSeconds: null,
      note: 'Archive diff count: ${_extractDiffCount(lines)}',
    );
  }

  String _extractDiffCount(List<String> lines) {
    final line = lines.firstWhere(
      (l) => l.startsWith('Diff Count:'),
      orElse: () => 'Diff Count: n/a',
    );
    return line.split(':').last.trim();
  }

  List<_DriftIssue> _computeDurationDrift(List<_ReportData> reports) {
    final drifts = <_DriftIssue>[];
    for (var i = 0; i < reports.length; i += 1) {
      final a = reports[i];
      if (a.durationSeconds == null) continue;
      for (var j = i + 1; j < reports.length; j += 1) {
        final b = reports[j];
        if (b.durationSeconds == null) continue;
        final avg = (a.durationSeconds! + b.durationSeconds!) / 2;
        if (avg == 0) continue;
        final deltaPercent =
            (a.durationSeconds! - b.durationSeconds!).abs() / avg;
        if (deltaPercent > 0.10) {
          drifts.add(
            _DriftIssue(a: a.name, b: b.name, deltaPercent: deltaPercent),
          );
        }
      }
    }
    return drifts;
  }

  Future<void> _safeWrite(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _safeAppend(File file, String contents) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents, mode: FileMode.append);
    } on FileSystemException {
      await _makeWritable();
      await file.writeAsString(contents, mode: FileMode.append);
    }
  }

  Future<void> _makeWritable() async {
    if (_madeWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }

  Future<void> restorePermissions() async {
    if (!_madeWritable) return;
    await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
    _madeWritable = false;
  }
}

class _FlutterEntry {
  double? durationSeconds;
  int? failed;
}

class _ReportData {
  _ReportData({
    required this.name,
    required this.status,
    required this.durationSeconds,
    required this.note,
  });

  final String name;
  final String status;
  final double? durationSeconds;
  final String note;
}

class _DriftIssue {
  _DriftIssue({required this.a, required this.b, required this.deltaPercent});

  final String a;
  final String b;
  final double deltaPercent;
}

class _SweepResult {
  _SweepResult({
    required this.timestamp,
    required this.reports,
    required this.statusMismatch,
    required this.durationDrifts,
  });

  final DateTime timestamp;
  final List<_ReportData> reports;
  final bool statusMismatch;
  final List<_DriftIssue> durationDrifts;
}
