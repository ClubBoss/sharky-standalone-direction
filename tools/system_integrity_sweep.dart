import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/constants/telemetry_schema.dart';

Future<void> main(List<String> args) async {
  final sweep = _SystemIntegritySweep();
  try {
    final result = await sweep.run();
    await sweep.writeSummary(result);
    await sweep.emitTelemetry(result);
  } finally {
    await sweep.restorePermissions();
  }
}

class _SystemIntegritySweep {
  bool _madeWritable = false;
  final Map<String, RegExp> _regexCache = <String, RegExp>{};

  Future<_SweepResult> run() async {
    final telemetry = await _loadTelemetryEvents();
    final reportChecks = await _scanReports(telemetry.eventsInLog);
    final orphanEvents =
        telemetry.eventsInLog
            .where((event) => TelemetrySchema.byId[event] == null)
            .toList()
          ..sort();

    final totalReferences = reportChecks.fold<int>(
      0,
      (sum, report) => sum + report.references.length,
    );
    final missingReferences = reportChecks.fold<int>(
      0,
      (sum, report) => sum + report.missing.length,
    );
    final reportsWithMissing = reportChecks
        .where((report) => report.missing.isNotEmpty)
        .length;
    final timestamp = DateTime.now().toUtc();

    return _SweepResult(
      timestamp: timestamp,
      reportChecks: reportChecks,
      orphanEvents: orphanEvents,
      telemetryEntryCount: telemetry.entryCount,
      totalReferences: totalReferences,
      missingReferences: missingReferences,
      passCount: reportChecks.length - reportsWithMissing,
      warnCount: reportsWithMissing,
      failCount: orphanEvents.length,
    );
  }

  Future<void> writeSummary(_SweepResult result) async {
    final buffer = StringBuffer()
      ..writeln('System Integrity Sweep Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('+-----------------------------+--------+')
      ..writeln('| Metric                      | Value  |')
      ..writeln('+-----------------------------+--------+')
      ..writeln(
        '| Reports scanned             | ${result.reportChecks.length.toString().padLeft(6)} |',
      )
      ..writeln(
        '| Telemetry entries           | ${result.telemetryEntryCount.toString().padLeft(6)} |',
      )
      ..writeln(
        '| Referenced events           | ${result.totalReferences.toString().padLeft(6)} |',
      )
      ..writeln(
        '| Missing references          | ${result.missingReferences.toString().padLeft(6)} |',
      )
      ..writeln(
        '| Orphan telemetry events     | ${result.orphanEvents.length.toString().padLeft(6)} |',
      )
      ..writeln('+-----------------------------+--------+');

    final mismatches = result.reportChecks.where(
      (report) => report.missing.isNotEmpty,
    );
    if (mismatches.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Report Reference Integrity')
        ..writeln(
          '+----------------------------------------------------------+---------+-------------------------+',
        )
        ..writeln(
          '| Report                                                   | Refs    | Missing Events          |',
        )
        ..writeln(
          '+----------------------------------------------------------+---------+-------------------------+',
        );
      for (final report in mismatches) {
        buffer.writeln(
          '| ${report.path.padRight(58)}'
          '| ${report.references.length.toString().padLeft(7)} '
          '| ${report.missing.join(', ')} |',
        );
      }
      buffer.writeln(
        '+----------------------------------------------------------+---------+-------------------------+',
      );
    } else {
      buffer
        ..writeln()
        ..writeln('No missing telemetry references detected in summaries.');
    }

    if (result.orphanEvents.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Orphan telemetry events (missing from schema):')
        ..writeln(result.orphanEvents.map((event) => '- $event').join('\n'));
    } else {
      buffer
        ..writeln()
        ..writeln('No orphan telemetry events detected.');
    }

    await _safeWrite(
      File('release/_reports/system_integrity_summary.txt'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_SweepResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.systemIntegritySweepCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'reports': result.reportChecks.length,
      'references': result.totalReferences,
      'missing': result.missingReferences,
      'orphans': result.orphanEvents.length,
      'pass_count': result.passCount,
      'warn_count': result.warnCount,
      'fail_count': result.failCount,
    };
    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  Future<_TelemetryData> _loadTelemetryEvents() async {
    final logFile = File('release/_reports/telemetry.jsonl');
    if (!await logFile.exists()) {
      throw StateError('telemetry.jsonl not found under release/_reports.');
    }

    final events = <String>{};
    var entryCount = 0;
    final lines = await logFile.readAsLines();
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      entryCount += 1;
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final dynamic eventValue = decoded['event'];
          if (eventValue is String) {
            events.add(eventValue);
          }
        }
      } on FormatException {
        // Skip malformed line but keep counting for visibility.
      }
    }

    return _TelemetryData(entryCount: entryCount, eventsInLog: events);
  }

  Future<List<_ReportCheck>> _scanReports(Set<String> telemetryEvents) async {
    final dir = Directory('release/_reports');
    if (!await dir.exists()) {
      throw StateError('release/_reports directory not found.');
    }

    final files =
        dir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (file) =>
                  file.path.endsWith('_summary.txt') ||
                  file.path.endsWith('_audit.txt'),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final checks = <_ReportCheck>[];
    for (final file in files) {
      final contents = await file.readAsString();
      final references = <String>{};
      for (final event in TelemetryEvents.all) {
        final regex = _regexCache[event] ??= RegExp(
          '(^|[^a-z0-9_])${RegExp.escape(event)}([^a-z0-9_]|\$)',
        );
        if (regex.hasMatch(contents)) {
          references.add(event);
        }
      }
      final missing = references
          .where((event) => !telemetryEvents.contains(event))
          .toSet();
      checks.add(
        _ReportCheck(path: file.path, references: references, missing: missing),
      );
    }
    return checks;
  }

  Future<void> restorePermissions() async {
    if (_madeWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _madeWritable = false;
    }
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
    if (_madeWritable) {
      return;
    }
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _madeWritable = true;
  }
}

class _TelemetryData {
  const _TelemetryData({required this.entryCount, required this.eventsInLog});

  final int entryCount;
  final Set<String> eventsInLog;
}

class _SweepResult {
  _SweepResult({
    required this.timestamp,
    required this.reportChecks,
    required this.orphanEvents,
    required this.telemetryEntryCount,
    required this.totalReferences,
    required this.missingReferences,
    required this.passCount,
    required this.warnCount,
    required this.failCount,
  });

  final DateTime timestamp;
  final List<_ReportCheck> reportChecks;
  final List<String> orphanEvents;
  final int telemetryEntryCount;
  final int totalReferences;
  final int missingReferences;
  final int passCount;
  final int warnCount;
  final int failCount;
}

class _ReportCheck {
  _ReportCheck({
    required this.path,
    required this.references,
    required this.missing,
  });

  final String path;
  final Set<String> references;
  final Set<String> missing;
}
