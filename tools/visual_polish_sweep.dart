import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final sweep = _VisualPolishSweep();
  final report = await sweep.run();
  report.printTable();
  report.emitTelemetry();
  if (!report.isClean) {
    exit(1);
  }
}

class _VisualPolishSweep {
  Future<_PolishReport> run() async {
    final files = _collectUiFiles();
    final colorIssues = <String>[];
    final durationIssues = <String>[];
    var normalizedTokens = 0;

    for (final file in files) {
      final relative = _relative(file.path);
      final content = await file.readAsString();
      normalizedTokens += _normalizedMatches(content);
      if (_ignoredFiles.contains(relative)) {
        continue;
      }
      colorIssues.addAll(
        _scan(
          content,
          relative,
          RegExp(r'Colors\.[A-Za-z0-9_]+'),
          'hardcoded color',
        ),
      );
      durationIssues.addAll(
        _scan(
          content,
          relative,
          RegExp(r'Duration\s*\(\s*milliseconds', multiLine: true),
          'raw Duration(milliseconds) detected',
        ),
      );
    }

    return _PolishReport(
      normalizedTokens: normalizedTokens,
      colorIssues: colorIssues,
      durationIssues: durationIssues,
    );
  }

  Iterable<File> _collectUiFiles() sync* {
    final root = Directory('lib/ui_v3');
    if (!root.existsSync()) {
      return;
    }
    for (final entity in root.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        yield entity;
      }
    }
  }

  List<String> _scan(
    String content,
    String path,
    RegExp pattern,
    String label,
  ) {
    final issues = <String>[];
    for (final match in pattern.allMatches(content)) {
      final line = _lineFor(content, match.start);
      final fragment = content
          .substring(match.start, match.end)
          .replaceAll('\n', ' ')
          .trim();
      issues.add('$path:$line $label -> $fragment');
    }
    return issues;
  }

  int _lineFor(String content, int index) {
    var line = 1;
    for (var i = 0; i < index && i < content.length; i++) {
      if (content.codeUnitAt(i) == 0x0A) {
        line++;
      }
    }
    return line;
  }

  int _normalizedMatches(String content) {
    return RegExp(r'VisualThemeV3\.').allMatches(content).length;
  }

  String _relative(String path) {
    final root = Directory.current.path;
    if (path.startsWith(root)) {
      final trimmed = path.substring(root.length);
      if (trimmed.startsWith(Platform.pathSeparator)) {
        return trimmed.substring(1);
      }
      return trimmed;
    }
    return path;
  }
}

class _PolishReport {
  _PolishReport({
    required this.normalizedTokens,
    required this.colorIssues,
    required this.durationIssues,
  });

  final int normalizedTokens;
  final List<String> colorIssues;
  final List<String> durationIssues;

  bool get isClean => colorIssues.isEmpty && durationIssues.isEmpty;

  void printTable() {
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Normalized tokens', normalizedTokens.toString()],
      [
        'Color issues',
        colorIssues.isEmpty ? 'OK' : colorIssues.length.toString(),
      ],
      [
        'Duration issues',
        durationIssues.isEmpty ? 'OK' : durationIssues.length.toString(),
      ],
    ];

    final details = {
      if (colorIssues.isNotEmpty) 'Color details': colorIssues,
      if (durationIssues.isNotEmpty) 'Duration details': durationIssues,
    };

    _printRows(rows);
    for (final entry in details.entries) {
      stdout.writeln('\n${entry.key}:');
      for (final detail in entry.value) {
        stdout.writeln(' - $detail');
      }
    }
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': 'visual_polish_completed',
      'normalized_tokens': normalizedTokens,
      'color_mismatches': colorIssues.length,
      'duration_mismatches': durationIssues.length,
      'mismatched_items': colorIssues.length + durationIssues.length,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
    stdout.writeln(jsonEncode(payload));
  }

  void _printRows(List<List<String>> rows) {
    final widths = List<int>.filled(rows.first.length, 0);
    for (final row in rows) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = row[i].length > widths[i] ? row[i].length : widths[i];
      }
    }
    final border = '+-${'-' * widths[0]}-+-${'-' * widths[1]}-+';
    stdout.writeln(border);
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      stdout.writeln(
        '| ${row[0].padRight(widths[0])} | ${row[1].padRight(widths[1])} |',
      );
      if (i == 0) {
        stdout.writeln(border);
      }
    }
    stdout.writeln(border);
  }
}

const _ignoredFiles = <String>{'lib/ui_v3/theme/visual_theme_v3.dart'};
