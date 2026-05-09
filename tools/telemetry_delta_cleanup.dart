import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/constants/telemetry_schema.dart';

Future<void> main(List<String> args) async {
  final cleanup = _TelemetryDeltaCleanup();
  try {
    final result = await cleanup.run();
    await cleanup.writeSummary(result);
    await cleanup.emitTelemetry(result);
  } finally {
    await cleanup.restorePermissions();
  }
}

class _TelemetryDeltaCleanup {
  bool _madeWritable = false;

  Future<_DeltaResult> run() async {
    final logEvents = await _readLogEvents();
    final docEvents = await _readDocEvents();
    final schemaEvents = _readSchemaEvents();
    final codeEvents = Set<String>.from(TelemetryEvents.all);

    return _DeltaResult(
      timestamp: DateTime.now().toUtc(),
      logUnknown: logEvents.difference(codeEvents),
      docMissing: codeEvents.difference(docEvents),
      docExtras: docEvents.difference(codeEvents),
      schemaMissing: codeEvents.difference(schemaEvents),
      schemaExtras: schemaEvents.difference(codeEvents),
      totalLogEvents: logEvents.length,
    );
  }

  Future<Set<String>> _readLogEvents() async {
    final file = File('release/_reports/telemetry.jsonl');
    if (!file.existsSync()) {
      throw StateError('telemetry.jsonl not found under release/_reports.');
    }
    final lines = await file.readAsLines();
    final events = <String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final dynamic eventField = decoded['event'];
          if (eventField is String) {
            events.add(eventField);
          }
        }
      } on FormatException {
        // Skip malformed lines.
      }
    }
    return events;
  }

  Future<Set<String>> _readDocEvents() async {
    final file = File('TELEMETRY_EVENTS.md');
    if (!file.existsSync()) {
      throw StateError('TELEMETRY_EVENTS.md not found.');
    }
    final lines = await file.readAsLines();
    final events = <String>{};
    final bullet = RegExp(r'^-\s+([a-z0-9_]+)$');
    for (final line in lines) {
      final match = bullet.firstMatch(line.trim());
      if (match != null) {
        events.add(match.group(1)!);
      }
    }
    return events;
  }

  Set<String> _readSchemaEvents() {
    return TelemetrySchema.events.map((e) => e.id).toSet();
  }

  Future<void> writeSummary(_DeltaResult result) async {
    final buffer = StringBuffer()
      ..writeln('Telemetry Delta Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln(
        'Total events seen in telemetry.jsonl: ${result.totalLogEvents}',
      )
      ..writeln()
      ..writeln('## Missing / Extra Checks')
      ..writeln(
        '+----------------+-------+-------------------------------------------+',
      )
      ..writeln(
        '| Category       | Count | Sample                                    |',
      )
      ..writeln(
        '+----------------+-------+-------------------------------------------+',
      )
      ..writeln(_row('Log unknown', result.logUnknown))
      ..writeln(_row('Doc missing', result.docMissing))
      ..writeln(_row('Doc extras', result.docExtras))
      ..writeln(_row('Schema missing', result.schemaMissing))
      ..writeln(_row('Schema extras', result.schemaExtras))
      ..writeln(
        '+----------------+-------+-------------------------------------------+',
      );

    await _safeWrite(
      File('release/_reports/telemetry_delta_summary.txt'),
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_DeltaResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.telemetryDeltaCleanupCompleted,
      'timestamp': result.timestamp.toIso8601String(),
      'log_unknown': result.logUnknown.length,
      'doc_missing': result.docMissing.length,
      'doc_extras': result.docExtras.length,
      'schema_missing': result.schemaMissing.length,
      'schema_extras': result.schemaExtras.length,
    };

    await _safeAppend(
      File('release/_reports/telemetry.jsonl'),
      '${jsonEncode(payload)}\n',
    );
  }

  String _row(String label, Set<String> values) {
    final sample = values.isEmpty ? '-' : values.take(3).join(', ');
    return '| ${label.padRight(14)} | '
        '${values.length.toString().padLeft(5)} | '
        '${sample.padRight(41)} |';
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

class _DeltaResult {
  _DeltaResult({
    required this.timestamp,
    required this.logUnknown,
    required this.docMissing,
    required this.docExtras,
    required this.schemaMissing,
    required this.schemaExtras,
    required this.totalLogEvents,
  });

  final DateTime timestamp;
  final Set<String> logUnknown;
  final Set<String> docMissing;
  final Set<String> docExtras;
  final Set<String> schemaMissing;
  final Set<String> schemaExtras;
  final int totalLogEvents;
}
