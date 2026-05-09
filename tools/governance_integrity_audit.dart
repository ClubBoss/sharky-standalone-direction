import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final audit = _GovernanceIntegrityAudit();
  final result = await audit.run();
  result.printSummary();
  await result.writeReport('release/_reports/governance_integrity_summary.txt');
  result.emitTelemetry(stopwatch.elapsed);
  if (!result.passed) {
    exit(1);
  }
}

class _GovernanceIntegrityAudit {
  Future<_AuditResult> run() async {
    final logFile = File('release/_reports/governance_log.txt');
    final log = await _GovernanceLog.load(logFile);
    final files = <File>[
      ..._collectFiles('release/_reports'),
      ..._collectFiles('release/_archives'),
    ];

    final missingEntries = <String>[];
    final mismatches = <String>[];

    for (final file in files) {
      final name = file.path.split('/').last;
      final checksum = await _sha256(file);
      final logged = log.lookup(name);
      if (logged == null) {
        missingEntries.add(name);
        continue;
      }
      if (!_equalsIgnoreCase(checksum, logged)) {
        mismatches.add(name);
      }
    }

    final logMissing = !logFile.existsSync();
    return _AuditResult(
      totalFiles: files.length,
      missingEntries: missingEntries,
      mismatches: mismatches,
      missingLog: logMissing,
    );
  }

  Iterable<File> _collectFiles(String path) sync* {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      return;
    }
    for (final entity in dir.listSync(recursive: false)) {
      if (entity is File && !entity.path.endsWith('governance_log.txt')) {
        yield entity;
      }
    }
  }
}

class _AuditResult {
  _AuditResult({
    required this.totalFiles,
    required this.missingEntries,
    required this.mismatches,
    required this.missingLog,
  });

  final int totalFiles;
  final List<String> missingEntries;
  final List<String> mismatches;
  final bool missingLog;

  bool get passed => !missingLog;
  int get warningCount => missingEntries.length + mismatches.length;

  void printSummary() {
    final color = passed ? _Ansi.green : _Ansi.red;
    stdout.writeln(
      '${color}Governance Integrity: ${passed ? 'PASS' : 'FAIL'}${_Ansi.reset}',
    );
    stdout.writeln(
      '  files_checked=$totalFiles missing_log=${missingLog ? 1 : 0} '
      'missing_entries=${missingEntries.length} mismatches=${mismatches.length}',
    );
    if (missingEntries.isNotEmpty) {
      stdout.writeln('Missing entries: ${missingEntries.join(', ')}');
    }
    if (mismatches.isNotEmpty) {
      stdout.writeln('Checksum mismatches: ${mismatches.join(', ')}');
    }
  }

  Future<void> writeReport(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Governance Integrity Summary')
      ..writeln('files_checked=$totalFiles')
      ..writeln('missing_log=${missingLog ? 1 : 0}')
      ..writeln('missing_entries=${missingEntries.length}')
      ..writeln('mismatches=${mismatches.length}')
      ..writeln('status=${passed ? 'PASS' : 'FAIL'}')
      ..writeln('warnings=$warningCount');
    if (missingEntries.isNotEmpty) {
      buffer.writeln('Missing: ${missingEntries.join(', ')}');
    }
    if (mismatches.isNotEmpty) {
      buffer.writeln('Mismatched: ${mismatches.join(', ')}');
    }
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry(Duration duration) {
    final payload = <String, Object>{
      'event': 'governance_integrity_audit_completed',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'files': totalFiles,
      'missing_entries': missingEntries.length,
      'mismatches': mismatches.length,
      'missing_log': missingLog ? 1 : 0,
      'warnings': warningCount,
      'status': passed ? 'pass' : 'fail',
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _GovernanceLog {
  _GovernanceLog(this._entries);

  final Map<String, String> _entries;

  String? lookup(String name) => _entries[name];

  static Future<_GovernanceLog> load(File file) async {
    if (!file.existsSync()) {
      return _GovernanceLog(<String, String>{});
    }
    final content = await file.readAsString();
    final map = <String, String>{};
    final regex = RegExp(r'-\s+([^:]+):\s+([0-9a-fA-F]{64})');
    for (final match in regex.allMatches(content)) {
      final name = match.group(1)!.trim();
      final checksum = match.group(2)!.toLowerCase();
      map[name] = checksum;
    }
    return _GovernanceLog(map);
  }
}

Future<String> _sha256(File file) async {
  final bytes = await file.readAsBytes();
  final digest = sha256.convert(bytes);
  final buffer = StringBuffer();
  for (final byte in digest.bytes) {
    buffer.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}

bool _equalsIgnoreCase(String a, String b) =>
    a.toLowerCase() == b.toLowerCase();

class _Ansi {
  static const String green = '\x1B[32m';
  static const String red = '\x1B[31m';
  static const String reset = '\x1B[0m';
}
