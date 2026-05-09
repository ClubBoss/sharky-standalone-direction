import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final harmonizer = _SystemTelemetryHarmonizer();
  try {
    final result = await harmonizer.run();
    await harmonizer.writeSummary(result);
    await harmonizer.emitTelemetry(result);
  } finally {
    await harmonizer.restorePermissions();
  }
}

class _SystemTelemetryHarmonizer {
  bool _reportsWritable = false;

  Future<_HarmonizationResult> run() async {
    final watch = Stopwatch()..start();
    final declared = await _readDeclaredEvents();
    final logged = await _readLoggedEvents();
    watch.stop();

    final missing = declared.difference(logged);
    final deprecated = logged.difference(declared);

    return _HarmonizationResult(
      timestamp: DateTime.now().toUtc(),
      declared: declared,
      logged: logged,
      missing: missing,
      deprecated: deprecated,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<Set<String>> _readDeclaredEvents() async {
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

  Future<Set<String>> _readLoggedEvents() async {
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
          final dynamic event = decoded['event'];
          if (event is String) {
            events.add(event);
          }
        }
      } on FormatException {
        // Skip malformed line.
      }
    }
    return events;
  }

  Future<void> writeSummary(_HarmonizationResult result) async {
    final buffer = StringBuffer()
      ..writeln('System Telemetry Harmonization Summary')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('| Metric | Count | Sample |')
      ..writeln('|--------|-------|--------|')
      ..writeln(
        _row('Declared', result.declared.length, _sample(result.declared)),
      )
      ..writeln(_row('Logged', result.logged.length, _sample(result.logged)))
      ..writeln(_row('Missing', result.missing.length, _sample(result.missing)))
      ..writeln(
        _row(
          'Deprecated',
          result.deprecated.length,
          _sample(result.deprecated),
        ),
      );

    await _writeReportsFile(
      'release/_reports/system_telemetry_harmonization_summary.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_HarmonizationResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.systemTelemetryHarmonized,
      'timestamp': result.timestamp.toIso8601String(),
      'declared': result.declared.length,
      'logged': result.logged.length,
      'deprecated': result.deprecated.length,
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

  String _row(String label, int count, String sample) {
    return '| $label | $count | ${sample.isEmpty ? '-' : sample} |';
  }

  String _sample(Set<String> events) =>
      events.isEmpty ? '' : events.take(3).join(', ');

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

class _HarmonizationResult {
  _HarmonizationResult({
    required this.timestamp,
    required this.declared,
    required this.logged,
    required this.missing,
    required this.deprecated,
    required this.durationMs,
  });

  final DateTime timestamp;
  final Set<String> declared;
  final Set<String> logged;
  final Set<String> missing;
  final Set<String> deprecated;
  final int durationMs;
}
