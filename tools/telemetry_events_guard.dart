import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final runner = _TelemetryEventsGuard();
  final report = await runner.run();
  report.printTable();
  if (!report.isPass) {
    exit(1);
  }
}

class _TelemetryEventsGuard {
  Future<_GuardReport> run() async {
    final doc = File('TELEMETRY_EVENTS.md');
    if (!doc.existsSync()) {
      return _GuardReport(
        missingDoc: true,
        missingInDoc: const [],
        missingInCode: const [],
      );
    }
    final mdEvents = _extractFromMarkdown(await doc.readAsLines());
    final codeEvents = Set<String>.from(TelemetryEvents.all);
    final missingInDoc = codeEvents.difference(mdEvents).toList()..sort();
    final missingInCode = mdEvents.difference(codeEvents).toList()..sort();
    return _GuardReport(
      missingDoc: false,
      missingInDoc: missingInDoc,
      missingInCode: missingInCode,
    );
  }

  Set<String> _extractFromMarkdown(List<String> lines) {
    final events = <String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ')) {
        events.add(trimmed.substring(2).trim());
      }
    }
    return events;
  }
}

class _GuardReport {
  _GuardReport({
    required this.missingDoc,
    required this.missingInDoc,
    required this.missingInCode,
  });

  final bool missingDoc;
  final List<String> missingInDoc;
  final List<String> missingInCode;

  bool get isPass =>
      !missingDoc && missingInDoc.isEmpty && missingInCode.isEmpty;

  void printTable() {
    final rows = <List<String>>[
      ['Status', isPass ? 'PASS' : 'FAIL'],
      ['Doc present', missingDoc ? 'NO' : 'YES'],
      ['Missing in doc', missingInDoc.isEmpty ? 'OK' : missingInDoc.join(', ')],
      [
        'Missing in code',
        missingInCode.isEmpty ? 'OK' : missingInCode.join(', '),
      ],
    ];
    _asciiTable(rows);
  }

  void _asciiTable(List<List<String>> rows) {
    final widths = List<int>.filled(2, 0);
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }
    final border = '+-${'-' * widths[0]}-+-${'-' * widths[1]}-+';
    stdout.writeln(border);
    for (final row in rows) {
      stdout.writeln(
        '| ${row[0].padRight(widths[0])} | ${row[1].padRight(widths[1])} |',
      );
    }
    stdout.writeln(border);
  }
}
