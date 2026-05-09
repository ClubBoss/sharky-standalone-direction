import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final sw = Stopwatch()..start();
  final runner = _DedupPass1Cli();
  final result = await runner.run();
  result.printSummary();
  await result.writeLists();
  await result.emitTelemetry(sw.elapsed);
  if (result.hasErrors) {
    exit(1);
  }
}

class _DedupPass1Cli {
  static const List<String> _prefixes = <String>['booster_', 'smart_'];
  static const String _sourceCsv = 'release/_reports/duplication_matrix.csv';
  static const String _targetRoot = 'release/_reports/dedup';

  Future<_DedupResult> run() async {
    final file = File(_sourceCsv);
    if (!file.existsSync()) {
      return _DedupResult.errors(<String>[
        'Missing duplication matrix: $_sourceCsv',
      ]);
    }

    final lines = await file.readAsLines();
    if (lines.length <= 1) {
      return _DedupResult.errors(<String>['Empty duplication matrix']);
    }

    final groups = <String, _DedupGroup>{};
    for (final prefix in _prefixes) {
      groups[prefix] = _DedupGroup(prefix: prefix);
    }

    for (var i = 1; i < lines.length; i++) {
      final row = _parseCsvLine(lines[i]);
      if (row.length < 3) continue;
      final prefix = row[0].trim().toLowerCase();
      if (!_prefixes.contains(prefix)) continue;
      final paths = row[2]
          .split(';')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      final sorted = List<String>.from(paths)..sort();
      final keep = <String>[];
      final merge = <String>[];
      if (sorted.isNotEmpty) {
        keep.add(sorted.first);
        if (sorted.length > 1) {
          merge.addAll(sorted.skip(1));
        }
      }
      groups[prefix] = _DedupGroup(prefix: prefix, keep: keep, merge: merge);
    }

    return _DedupResult(groups: groups);
  }

  List<String> _parseCsvLine(String line) {
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
}

class _DedupResult {
  _DedupResult({required this.groups}) : errors = const <String>[];

  _DedupResult.errors(this.errors) : groups = const <String, _DedupGroup>{};

  final Map<String, _DedupGroup> groups;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  void printSummary() {
    final rows = <List<String>>[
      ['Prefix', 'Total', 'Keep', 'Merge'],
    ];
    for (final entry in groups.values) {
      rows.add([
        entry.prefix,
        entry.total.toString(),
        entry.keep.length.toString(),
        entry.merge.length.toString(),
      ]);
    }
    final widths = List<int>.filled(rows.first.length, 0);
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }
    final border = _buildBorder(widths);
    stdout.writeln(border);
    stdout.writeln(_buildRow(rows.first, widths));
    stdout.writeln(border);
    for (var i = 1; i < rows.length; i++) {
      stdout.writeln(_buildRow(rows[i], widths));
    }
    stdout.writeln(border);
    if (errors.isNotEmpty) {
      stdout.writeln('Errors:');
      for (final err in errors) {
        stdout.writeln(' - $err');
      }
    }
  }

  String _buildBorder(List<int> widths) {
    final segments = widths.map((w) => '-${'-' * w}-').join('+');
    return '+$segments+';
  }

  String _buildRow(List<String> row, List<int> widths) {
    final cells = <String>[];
    for (var i = 0; i < row.length; i++) {
      cells.add(' ${row[i].padRight(widths[i])} ');
    }
    return '|${cells.join('|')}|';
  }

  Future<void> writeLists() async {
    if (hasErrors) return;
    for (final group in groups.values) {
      final dir = Directory('${_DedupPass1Cli._targetRoot}/${group.prefix}');
      await dir.create(recursive: true);
      await File('${dir.path}/KEEP.list').writeAsString(group.keep.join('\n'));
      await File(
        '${dir.path}/MERGE.list',
      ).writeAsString(group.merge.join('\n'));
    }
  }

  Future<void> emitTelemetry(Duration duration) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.dedupPass1Completed,
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
      if (errors.isNotEmpty) 'errors': errors,
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
