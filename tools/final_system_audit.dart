import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final audit = _FinalSystemAudit();
  try {
    final result = await audit.run();
    await audit.writeSummary(result);
    await audit.emitTelemetry(result);
  } finally {
    await audit.restorePermissions();
  }
}

class _FinalSystemAudit {
  bool _reportsWritable = false;

  Future<_AuditResult> run() async {
    final watch = Stopwatch()..start();
    final reportDir = Directory('release/_reports');
    if (!reportDir.existsSync()) {
      throw StateError('release/_reports directory not found.');
    }
    final files = reportDir
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) =>
              file.path.endsWith('_summary.txt') ||
              file.path.endsWith('_audit.txt'),
        )
        .toList();

    final entries = <_FileStatus>[];
    for (final file in files) {
      entries.add(await _analyzeFile(file));
    }
    watch.stop();

    final passCount = entries.where((e) => e.status == _Status.pass).length;
    final failCount = entries.where((e) => e.status == _Status.fail).length;
    final warnCount = entries.where((e) => e.status == _Status.warn).length;
    final coveredCount = entries
        .where((e) => e.status != _Status.unknown)
        .length;
    final coveragePct = files.isEmpty ? 0 : coveredCount / files.length * 100.0;

    return _AuditResult(
      timestamp: DateTime.now().toUtc(),
      files: entries,
      passCount: passCount,
      failCount: failCount,
      warnCount: warnCount,
      coveragePct: coveragePct.toDouble(),
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_FileStatus> _analyzeFile(File file) async {
    final lines = await file.readAsLines();
    final statuses = <_Status>{};
    final statusRegex = RegExp(
      r'Status:\s*(PASS|FAIL|WARN)',
      caseSensitive: false,
    );
    final tableRegex = RegExp(
      r'\|\s*[^\|]+\|\s*(PASS|FAIL|WARN)\s*\|',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = statusRegex.firstMatch(line);
      if (match != null) {
        statuses.add(_parseStatus(match.group(1)!));
      }
      final tableMatch = tableRegex.firstMatch(line);
      if (tableMatch != null) {
        statuses.add(_parseStatus(tableMatch.group(1)!));
      }
    }

    _Status status;
    if (statuses.contains(_Status.fail)) {
      status = _Status.fail;
    } else if (statuses.contains(_Status.warn)) {
      status = _Status.warn;
    } else if (statuses.contains(_Status.pass)) {
      status = _Status.pass;
    } else {
      status = _Status.unknown;
    }

    return _FileStatus(path: file.path, status: status);
  }

  _Status _parseStatus(String value) {
    switch (value.toUpperCase()) {
      case 'PASS':
        return _Status.pass;
      case 'FAIL':
        return _Status.fail;
      case 'WARN':
        return _Status.warn;
      default:
        return _Status.unknown;
    }
  }

  Future<void> writeSummary(_AuditResult result) async {
    final buffer = StringBuffer()
      ..writeln('Final System Audit Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln('Files audited: ${result.files.length}')
      ..writeln('Coverage: ${result.coveragePct.toStringAsFixed(2)}%')
      ..writeln(
        'PASS: ${result.passCount} '
        'WARN: ${result.warnCount} FAIL: ${result.failCount}',
      )
      ..writeln()
      ..writeln('| File | Status |')
      ..writeln('|------|--------|');
    for (final entry in result.files) {
      buffer.writeln('| ${entry.path} | ${entry.status.label} |');
    }

    await _writeReportsFile(
      'release/_reports/final_system_audit_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_AuditResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.finalSystemAuditCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'pass_count': result.passCount,
      'fail_count': result.failCount,
      'warn_count': result.warnCount,
      'coverage_pct': result.coveragePct,
      'duration_ms': result.durationMs,
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

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

enum _Status { pass, warn, fail, unknown }

extension on _Status {
  String get label {
    switch (this) {
      case _Status.pass:
        return 'PASS';
      case _Status.warn:
        return 'WARN';
      case _Status.fail:
        return 'FAIL';
      case _Status.unknown:
        return 'UNKNOWN';
    }
  }
}

class _FileStatus {
  _FileStatus({required this.path, required this.status});

  final String path;
  final _Status status;
}

class _AuditResult {
  _AuditResult({
    required this.timestamp,
    required this.files,
    required this.passCount,
    required this.failCount,
    required this.warnCount,
    required this.coveragePct,
    required this.durationMs,
  });

  final DateTime timestamp;
  final List<_FileStatus> files;
  final int passCount;
  final int failCount;
  final int warnCount;
  final double coveragePct;
  final int durationMs;
}
