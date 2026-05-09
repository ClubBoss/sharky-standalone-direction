import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final runner = _DedupPass2Cli();
  final result = await runner.run();
  result.printTable();
  await result.writeLists();
  await result.emitTelemetry(stopwatch.elapsed);
  if (result.hasErrors) {
    exit(1);
  }
}

class _DedupPass2Cli {
  static const List<String> _prefixes = <String>['theory_', 'adaptive_'];
  static const String _csvPath = 'release/_reports/duplication_matrix.csv';
  static const String _outputRoot = 'release/_reports/dedup';

  Future<_DedupResult> run() async {
    final errors = <String>[];
    final file = File(_csvPath);
    if (!file.existsSync()) {
      errors.add('Missing duplication matrix at $_csvPath');
      return _DedupResult.empty(errors);
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty || !lines.first.startsWith('prefix,')) {
      errors.add('Malformed duplication matrix header');
      return _DedupResult.empty(errors);
    }

    final groups = <String, _DedupGroup>{
      for (final prefix in _prefixes) prefix: _DedupGroup(prefix: prefix),
    };

    for (var i = 1; i < lines.length; i++) {
      final row = _parseCsvLine(lines[i]);
      if (row.length < 3) continue;
      final prefix = row[0].trim().toLowerCase();
      if (!groups.containsKey(prefix)) continue;
      final rawPaths =
          row[2]
              .split(';')
              .map((segment) => segment.trim())
              .where((segment) => segment.isNotEmpty)
              .toSet()
              .toList()
            ..sort(_pathComparator);
      if (rawPaths.isEmpty) continue;
      final keep = <String>[rawPaths.first];
      final merge = rawPaths.skip(1).toList();
      groups[prefix] = _DedupGroup(prefix: prefix, keep: keep, merge: merge);
    }

    return _DedupResult(groups: groups, errors: errors);
  }

  static List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    values.add(buffer.toString());
    return values;
  }

  static int _pathComparator(String a, String b) {
    final len = a.length.compareTo(b.length);
    if (len != 0) return len;
    return a.compareTo(b);
  }
}

class _DedupResult {
  _DedupResult({required this.groups, required this.errors});

  _DedupResult.empty(List<String> errs)
    : groups = {
        for (final prefix in _DedupPass2Cli._prefixes)
          prefix: _DedupGroup(prefix: prefix),
      },
      errors = errs;

  final Map<String, _DedupGroup> groups;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  void printTable() {
    final headers = ['Prefix', 'Total', 'Keep', 'Merge'];
    final rows = [
      for (final entry in groups.values)
        [
          entry.prefix,
          entry.total.toString(),
          entry.keep.length.toString(),
          entry.merge.length.toString(),
        ],
    ];
    final widths = List<int>.filled(headers.length, 0);
    void updateWidths(List<String> row) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }

    updateWidths(headers);
    for (final row in rows) {
      updateWidths(row);
    }

    String border() => '+${widths.map((w) => '-' * (w + 2)).join('+')}+';
    String format(List<String> row) =>
        '|${[for (var i = 0; i < row.length; i++) ' ${row[i].padRight(widths[i])} '].join('|')}|';

    stdout.writeln(border());
    stdout.writeln(format(headers));
    stdout.writeln(border());
    for (final row in rows) {
      stdout.writeln(format(row));
    }
    stdout.writeln(border());
    if (errors.isNotEmpty) {
      stdout.writeln('Errors:');
      for (final err in errors) {
        stdout.writeln(' - $err');
      }
    }
  }

  Future<void> writeLists() async {
    for (final group in groups.values) {
      final dir = Directory('${_DedupPass2Cli._outputRoot}/${group.prefix}');
      await dir.create(recursive: true);
      await File('${dir.path}/KEEP.list').writeAsString(group.keep.join('\n'));
      await File(
        '${dir.path}/MERGE.list',
      ).writeAsString(group.merge.join('\n'));
    }
  }

  Future<void> emitTelemetry(Duration duration) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.dedupPass2Completed,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': duration.inMilliseconds,
      'groups': {
        for (final entry in groups.entries)
          entry.key: {
            'total': entry.value.total,
            'keep': entry.value.keep.length,
            'merge': entry.value.merge.length,
          },
      },
      'errors': errors.length,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _DedupGroup {
  _DedupGroup({
    required this.prefix,
    this.keep = const <String>[],
    this.merge = const <String>[],
  });

  final String prefix;
  final List<String> keep;
  final List<String> merge;

  int get total => keep.length + merge.length;
}
