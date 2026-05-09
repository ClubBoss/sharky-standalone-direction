import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final runner = _TelemetryDriftCleanup();
  final result = await runner.run();
  result.printTable();
  await result.writeReport();
  await result.emitTelemetry(stopwatch.elapsed);
  if (result.hasUndeclared) {
    exit(1);
  }
}

class _TelemetryDriftCleanup {
  static const String _constantsPath = 'lib/constants/telemetry_events.dart';
  static const String _docPath = 'TELEMETRY_EVENTS.md';
  static const String _reportPath =
      'release/_reports/telemetry_drift_report.txt';
  static final RegExp _constPattern = RegExp(
    r"static const String\s+([a-zA-Z0-9_]+)\s*=\s*'([^']+)'",
  );
  static final RegExp _usagePattern = RegExp(
    r'TelemetryEvents\.([a-zA-Z0-9_]+)',
  );
  static const Set<String> _ignoredUsageProps = {'_', 'all'};

  Future<_DriftResult> run() async {
    final errors = <String>[];
    final declarations = <String, String>{};
    final docEvents = <String>{};

    try {
      declarations.addAll(await _loadDeclarations());
    } catch (e) {
      errors.add('Failed to parse $_constantsPath: $e');
    }

    try {
      docEvents.addAll(await _loadDocEvents());
    } catch (e) {
      errors.add('Failed to parse $_docPath: $e');
    }

    final usage = await _scanUsage();

    final declaredProps = declarations.keys.toSet();
    final declaredEvents = declarations.values.toSet();
    final undeclared = <String, List<String>>{};
    final unused = <String>[];

    usage.forEach((prop, files) {
      if (!declaredProps.contains(prop)) {
        undeclared[prop] = files;
      }
    });

    for (final prop in declaredProps) {
      if (!usage.containsKey(prop)) {
        unused.add(prop);
      }
    }

    final undocumented = declaredEvents.difference(docEvents).toList()..sort();
    final docOnly = docEvents.difference(declaredEvents).toList()..sort();

    return _DriftResult(
      undeclaredUsage: undeclared,
      unusedProps: unused..sort(),
      undocumentedEvents: undocumented,
      docOnlyEvents: docOnly,
      errors: errors,
    );
  }

  Future<Map<String, String>> _loadDeclarations() async {
    final file = File(_constantsPath);
    if (!file.existsSync()) {
      throw 'File not found';
    }
    final content = await file.readAsString();
    final matches = _constPattern.allMatches(content);
    return {for (final match in matches) match.group(1)!: match.group(2)!};
  }

  Future<Set<String>> _loadDocEvents() async {
    final file = File(_docPath);
    if (!file.existsSync()) {
      throw 'File not found';
    }
    final lines = await file.readAsLines();
    final events = <String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ')) {
        events.add(trimmed.substring(2).trim());
      }
    }
    return events;
  }

  Future<Map<String, List<String>>> _scanUsage() async {
    final Map<String, List<String>> usage = {};
    final roots = <String>['lib', 'tools'];
    for (final root in roots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;
      final stream = dir.list(recursive: true, followLinks: false);
      await for (final entity in stream) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('.dart')) continue;
        final content = await entity.readAsString();
        for (final match in _usagePattern.allMatches(content)) {
          final prop = match.group(1)!;
          if (_ignoredUsageProps.contains(prop)) continue;
          final relative = p.relative(
            entity.path,
            from: Directory.current.path,
          );
          usage.putIfAbsent(prop, () => <String>[]).add(relative);
        }
      }
    }
    return usage;
  }
}

class _DriftResult {
  _DriftResult({
    required Map<String, List<String>> undeclaredUsage,
    required List<String> unusedProps,
    required List<String> undocumentedEvents,
    required List<String> docOnlyEvents,
    required List<String> errors,
  }) : undeclaredUsage = _dedupFiles(undeclaredUsage),
       unusedProps = unusedProps,
       undocumentedEvents = undocumentedEvents,
       docOnlyEvents = docOnlyEvents,
       errors = errors;

  final Map<String, List<String>> undeclaredUsage;
  final List<String> unusedProps;
  final List<String> undocumentedEvents;
  final List<String> docOnlyEvents;
  final List<String> errors;

  bool get hasUndeclared => undeclaredUsage.isNotEmpty;

  static Map<String, List<String>> _dedupFiles(
    Map<String, List<String>> source,
  ) {
    final result = <String, List<String>>{};
    source.forEach((key, files) {
      final sorted = files.toSet().toList()..sort();
      result[key] = sorted;
    });
    return result;
  }

  void printTable() {
    final rows = <List<String>>[];
    void addRows(String category, Iterable<String> events, [String? detail]) {
      for (final event in events) {
        rows.add([category, event, detail ?? '']);
      }
    }

    undeclaredUsage.forEach((prop, files) {
      final sample = files.take(3).join(', ');
      addRows('undeclared', [prop], sample);
    });
    addRows('unused', unusedProps, 'declared but not referenced');
    addRows('undocumented', undocumentedEvents, 'missing in TELEMETRY_EVENTS');
    addRows('doc_only', docOnlyEvents, 'documented but not declared');

    if (rows.isEmpty) {
      stdout.writeln('+---------+-------+--------+');
      stdout.writeln('| Status  | Event | Notes  |');
      stdout.writeln('+---------+-------+--------+');
      stdout.writeln('| clean   |   -   |   -    |');
      stdout.writeln('+---------+-------+--------+');
      return;
    }

    final headers = ['Category', 'Event', 'Details'];
    final widths = List<int>.filled(headers.length, 0);
    void _updateWidths(List<String> row) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }

    _updateWidths(headers);
    for (final row in rows) {
      _updateWidths(row);
    }

    String border() => '+${widths.map((w) => '-' * (w + 2)).join('+')}+';

    String formatRow(List<String> row) =>
        '|${[for (var i = 0; i < row.length; i++) ' ${row[i].padRight(widths[i])} '].join('|')}|';

    stdout.writeln(border());
    stdout.writeln(formatRow(headers));
    stdout.writeln(border());
    for (final row in rows) {
      stdout.writeln(formatRow(row));
    }
    stdout.writeln(border());
    if (errors.isNotEmpty) {
      stdout.writeln('Errors:');
      for (final error in errors) {
        stdout.writeln(' - $error');
      }
    }
  }

  Future<void> writeReport() async {
    final file = File(_TelemetryDriftCleanup._reportPath);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Telemetry Drift Report')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('');

    if (undeclaredUsage.isEmpty &&
        unusedProps.isEmpty &&
        undocumentedEvents.isEmpty &&
        docOnlyEvents.isEmpty) {
      buffer.writeln('No drift detected.');
    } else {
      void writeSection(String title, Iterable<String> items) {
        if (items.isEmpty) return;
        buffer.writeln('$title:');
        for (final item in items) {
          buffer.writeln(' - $item');
        }
        buffer.writeln('');
      }

      if (undeclaredUsage.isNotEmpty) {
        buffer.writeln('Undeclared usages:');
        undeclaredUsage.forEach((prop, files) {
          buffer.writeln(' - $prop');
          for (final file in files) {
            buffer.writeln('    > $file');
          }
        });
        buffer.writeln('');
      }

      writeSection('Unused declarations', unusedProps);
      writeSection('Undocumented events', undocumentedEvents);
      writeSection('Doc-only events', docOnlyEvents);
    }

    if (errors.isNotEmpty) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln(' - $error');
      }
    }

    await file.writeAsString(buffer.toString());
  }

  Future<void> emitTelemetry(Duration duration) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.telemetryDriftCleanupCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'counts': {
        'undeclared': undeclaredUsage.length,
        'unused': unusedProps.length,
        'undocumented': undocumentedEvents.length,
        'doc_only': docOnlyEvents.length,
        'errors': errors.length,
      },
    };
    stdout.writeln(jsonEncode(payload));
  }
}
