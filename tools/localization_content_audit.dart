import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localization_core.dart';

Future<void> main(List<String> args) async {
  final localization = LocalizationCore.instance;
  final auditor = _LocalizationContentAuditor(localization);
  final report = await auditor.run();
  report.printTable();
  await localization.reportMissingKeys(report.missingKeys);
  await report.writeReport('release/_reports/localization_content_audit.json');
  report.emitTelemetry();
  if (!report.isClean) {
    exit(1);
  }
}

class _LocalizationContentAuditor {
  _LocalizationContentAuditor(this.localization);

  final LocalizationCore localization;

  Future<_AuditReport> run() async {
    final asciiIssues = <String>[];
    final jsonIssues = <String>[];
    final missingKeyIssues = <String>[];
    final missingKeys = <String>{};

    final packs = await _discoverPacks();
    for (final dir in packs) {
      final theory = File('${dir.path}/theory.md');
      final drills = File('${dir.path}/drills.jsonl');
      final demos = File('${dir.path}/demos.jsonl');

      if (!await theory.exists()) {
        asciiIssues.add('${dir.path}/theory.md missing file');
      } else {
        final content = await theory.readAsString();
        if (!localization.validateString(content)) {
          asciiIssues.add('${theory.path} contains non-ASCII text');
        }
      }

      if (!await drills.exists()) {
        asciiIssues.add('${dir.path}/drills.jsonl missing file');
      } else {
        await _scanJsonl(
          drills,
          asciiIssues: asciiIssues,
          jsonIssues: jsonIssues,
          missingKeyIssues: missingKeyIssues,
          missingKeys: missingKeys,
        );
      }

      if (!await demos.exists()) {
        asciiIssues.add('${dir.path}/demos.jsonl missing file');
      } else {
        await _scanJsonl(
          demos,
          asciiIssues: asciiIssues,
          jsonIssues: jsonIssues,
          missingKeyIssues: missingKeyIssues,
          missingKeys: missingKeys,
        );
      }
    }

    return _AuditReport(
      asciiIssues: asciiIssues,
      jsonIssues: jsonIssues,
      missingKeyIssues: missingKeyIssues,
      missingKeys: missingKeys,
    );
  }

  Future<List<Directory>> _discoverPacks() async {
    final root = Directory('content');
    if (!await root.exists()) {
      return <Directory>[];
    }
    final packs = <Directory>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is Directory && entity.path.endsWith('/v1')) {
        packs.add(entity);
      }
    }
    packs.sort((a, b) => a.path.compareTo(b.path));
    return packs;
  }

  Future<void> _scanJsonl(
    File file, {
    required List<String> asciiIssues,
    required List<String> jsonIssues,
    required List<String> missingKeyIssues,
    required Set<String> missingKeys,
  }) async {
    final lines = await file.readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final lineNo = i + 1;
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      if (!localization.validateString(trimmed)) {
        asciiIssues.add('${file.path}:$lineNo non-ASCII content');
      }
      try {
        final decoded = jsonDecode(trimmed);
        _visitStrings(decoded, (value, field) {
          if (!localization.validateString(value)) {
            asciiIssues.add('${file.path}:$lineNo non-ASCII value "$value"');
          }
          if (field != null &&
              _isUiField(field) &&
              _looksLikeUiString(value) &&
              !localization.hasKey(value)) {
            missingKeys.add(value);
            missingKeyIssues.add('${file.path}:$lineNo missing key "$value"');
          }
        });
      } catch (error) {
        jsonIssues.add(
          '${file.path}:$lineNo invalid JSON (${error.runtimeType})',
        );
      }
    }
  }

  void _visitStrings(
    Object? node,
    void Function(String value, String? field) onString, [
    String? currentField,
  ]) {
    if (node is Map) {
      node.forEach((key, value) {
        final field = key?.toString();
        if (value is String) {
          onString(value, field);
        } else {
          _visitStrings(value, onString, field);
        }
      });
    } else if (node is Iterable) {
      for (final value in node) {
        if (value is String) {
          onString(value, currentField);
        } else {
          _visitStrings(value, onString, currentField);
        }
      }
    } else if (node is String) {
      onString(node, currentField);
    }
  }

  bool _isUiField(String field) {
    final lower = field.toLowerCase();
    return lower.contains('label') ||
        lower.contains('title') ||
        lower.contains('button') ||
        lower.contains('description') ||
        lower.contains('message') ||
        lower.contains('text') ||
        lower.contains('prompt') ||
        lower.endsWith('_key');
  }

  bool _looksLikeUiString(String value) {
    return RegExp(r'[A-Za-z]').hasMatch(value) && value.length <= 120;
  }
}

class _AuditReport {
  _AuditReport({
    required this.asciiIssues,
    required this.jsonIssues,
    required this.missingKeyIssues,
    required this.missingKeys,
  });

  final List<String> asciiIssues;
  final List<String> jsonIssues;
  final List<String> missingKeyIssues;
  final Set<String> missingKeys;

  bool get isClean =>
      asciiIssues.isEmpty && jsonIssues.isEmpty && missingKeyIssues.isEmpty;

  void printTable() {
    final data = <String, List<String>>{
      'ASCII': asciiIssues,
      'JSONL': jsonIssues,
      'i18n': missingKeyIssues,
    };
    final summary =
        'ascii=${asciiIssues.length} | invalid_jsonl=${jsonIssues.length} | missing_keys=${missingKeyIssues.length}';
    _asciiTable(data, summary);
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': 'localization_content_audit_completed',
      'asciiViolations': asciiIssues.length,
      'invalidJsonl': jsonIssues.length,
      'missingKeys': missingKeyIssues.length,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    stdout.writeln(jsonEncode(payload));
  }

  void _asciiTable(Map<String, List<String>> data, String summaryLine) {
    final rows = <List<String>>[];
    data.forEach((category, issues) {
      if (issues.isEmpty) {
        rows.add([category, 'OK']);
      } else {
        for (var i = 0; i < issues.length; i++) {
          rows.add([i == 0 ? category : '', issues[i]]);
        }
      }
    });
    rows.add(['Summary', summaryLine]);
    final colWidths = <int>[0, 0];
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].length > colWidths[i]) {
          colWidths[i] = row[i].length;
        }
      }
    }
    final border = '+-${'-' * colWidths[0]}-+-${'-' * colWidths[1]}-+';
    stdout.writeln(border);
    stdout.writeln(
      '| ${'Category'.padRight(colWidths[0])} | '
      '${'Details'.padRight(colWidths[1])} |',
    );
    stdout.writeln(border);
    for (final row in rows) {
      stdout.writeln(
        '| ${row[0].padRight(colWidths[0])} | '
        '${row[1].padRight(colWidths[1])} |',
      );
    }
    stdout.writeln(border);
  }

  Future<void> writeReport(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final payload = <String, Object>{
      'ascii_issues': asciiIssues,
      'json_issues': jsonIssues,
      'missing_keys': missingKeyIssues,
      'status': isClean ? 'PASS' : 'FAIL',
    };
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(payload));
  }
}
