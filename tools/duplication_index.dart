import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final runner = _DuplicationIndex();
  final report = await runner.run();
  report.printTable();
  await report.writeCsv();
  report.emitTelemetry(stopwatch.elapsed);
  if (report.hasErrors) {
    exit(1);
  }
}

class _DuplicationIndex {
  static const List<String> _prefixes = <String>[
    'booster_',
    'theory_',
    'smart_',
    'adaptive_',
    'goal_',
  ];

  Future<_DupReport> run() async {
    final libDir = Directory('lib');
    if (!libDir.existsSync()) {
      return _DupReport.empty('Missing lib/ directory');
    }
    final matches = <String, List<String>>{
      for (final prefix in _prefixes) prefix: <String>[],
    };
    final errors = <String>[];

    try {
      final stream = libDir.list(recursive: true, followLinks: false);
      await for (final entity in stream) {
        if (entity is! File) continue;
        final relative = p.relative(entity.path, from: Directory.current.path);
        final name = p.basename(relative).toLowerCase();
        for (final prefix in _prefixes) {
          if (name.startsWith(prefix)) {
            matches[prefix]!.add(relative);
            break;
          }
        }
      }
    } catch (e) {
      errors.add('Scan error: $e');
    }

    return _DupReport(matches: matches, errors: errors);
  }
}

class _DupReport {
  _DupReport({required this.matches, required this.errors});

  _DupReport.empty(String error)
    : matches = const <String, List<String>>{},
      errors = <String>[error];

  final Map<String, List<String>> matches;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  void printTable() {
    final rows = <List<String>>[];
    final sorted = matches.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    for (final entry in sorted) {
      rows.add([entry.key, entry.value.length.toString()]);
    }
    final widths = [0, 0];
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }
    final border = '+-${'-' * widths[0]}-+-${'-' * widths[1]}-+';
    stdout.writeln(border);
    stdout.writeln(
      '| ${'Prefix'.padRight(widths[0])} | ${'Count'.padRight(widths[1])} |',
    );
    stdout.writeln(border);
    for (final row in rows) {
      stdout.writeln(
        '| ${row[0].padRight(widths[0])} | ${row[1].padRight(widths[1])} |',
      );
    }
    stdout.writeln(border);
    if (errors.isNotEmpty) {
      stdout.writeln('Errors:');
      for (final err in errors) {
        stdout.writeln(' - $err');
      }
    }
  }

  Future<void> writeCsv() async {
    final file = File('release/_reports/duplication_matrix.csv');
    await file.parent.create(recursive: true);
    final sink = file.openWrite();
    sink.writeln('prefix,count,paths');
    final sorted = matches.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    for (final entry in sorted) {
      final escapedPaths = entry.value
          .map((path) => path.replaceAll('"', '""'))
          .join(';');
      sink.writeln('${entry.key},${entry.value.length},"$escapedPaths"');
    }
    await sink.close();
  }

  void emitTelemetry(Duration duration) {
    final prefixCounts = <String, int>{
      for (final entry in matches.entries) entry.key: entry.value.length,
    };
    final payload = <String, Object>{
      'event': TelemetryEvents.duplicationIndexCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'prefixCounts': prefixCounts,
      'errors': errors.length,
    };
    stdout.writeln(jsonEncode(payload));
  }
}
