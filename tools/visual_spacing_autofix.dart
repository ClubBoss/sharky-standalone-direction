import 'dart:convert';
import 'dart:io';

const String _summaryInput = 'release/_exports/visual_cohesion_summary.txt';
const String _summaryOutput =
    'release/_reports/visual_spacing_autofix_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _visualThemeImport =
    "import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';";

final RegExp _issuePattern = RegExp(
  r'-\s+(?<path>[^:]+):(?<line>\d+):\s+Non-token spacing:\s+(?<value>[0-9.]+)',
);
final RegExp _numberPattern = RegExp(
  r'(?<![A-Za-z0-9_])(\d+(\.\d+)?)(?![A-Za-z0-9_])',
);
final Set<String> _skipFiles = {'lib/ui_v3/theme/visual_theme_v3.dart'};

const List<_SpacingToken> _spacingTokens = [
  _SpacingToken('spacingXS', 4.0),
  _SpacingToken('spacingS', 8.0),
  _SpacingToken('spacingSM', 12.0),
  _SpacingToken('spacingM', 16.0),
  _SpacingToken('spacingL', 24.0),
  _SpacingToken('spacingXL', 32.0),
];

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final issues = await _parseIssues();
  if (issues.isEmpty) {
    stdout.writeln('visual_spacing_autofix: no issues found.');
    return;
  }

  final outcome = await _applyFixes(issues);
  await _withReportsWritable(() async {
    await _writeSummary(outcome, issues.length);
    await _appendTelemetry(
      outcome.totalReplacements,
      stopwatch.elapsedMilliseconds,
    );
  });

  stdout
    ..writeln(
      'visual_spacing_autofix: ${outcome.totalReplacements} replacements across '
      '${outcome.fileResults.length} files.',
    )
    ..writeln('Summary written to $_summaryOutput');
}

Future<List<_SpacingIssue>> _parseIssues() async {
  final file = File(_summaryInput);
  if (!await file.exists()) {
    stdout.writeln('visual_spacing_autofix: $_summaryInput not found.');
    return const [];
  }
  final lines = await file.readAsLines();
  final issues = <_SpacingIssue>[];
  for (final line in lines) {
    final match = _issuePattern.firstMatch(line);
    if (match == null) continue;
    final path = match.namedGroup('path')!;
    final lineNumber = int.tryParse(match.namedGroup('line') ?? '');
    final rawValue = match.namedGroup('value')!;
    final value = double.tryParse(rawValue);
    if (lineNumber == null || value == null) continue;
    issues.add(
      _SpacingIssue(
        path: path.trim(),
        line: lineNumber,
        value: value,
        rawValue: rawValue,
      ),
    );
  }
  return issues;
}

Future<_AutofixOutcome> _applyFixes(List<_SpacingIssue> issues) async {
  final issuesByFile = <String, List<_SpacingIssue>>{};
  for (final issue in issues) {
    issuesByFile.putIfAbsent(issue.path, () => []).add(issue);
  }
  final results = <_FileFixResult>[];
  final skipped = <_SkippedIssue>[];
  var totalReplacements = 0;

  for (final entry in issuesByFile.entries) {
    final path = entry.key;
    if (_skipFiles.contains(path)) {
      skipped.addAll(
        entry.value.map((issue) => _SkippedIssue(issue, 'file_excluded')),
      );
      continue;
    }
    final file = File(path);
    if (!file.existsSync()) {
      skipped.addAll(
        entry.value.map((issue) => _SkippedIssue(issue, 'file_missing')),
      );
      continue;
    }
    final fileResult = _processFile(file, entry.value);
    totalReplacements += fileResult.replacements;
    skipped.addAll(fileResult.skipped);
    if (fileResult.replacements > 0) {
      results.add(fileResult);
    }
  }

  return _AutofixOutcome(
    fileResults: results,
    skipped: skipped,
    totalReplacements: totalReplacements,
  );
}

_FileFixResult _processFile(File file, List<_SpacingIssue> issues) {
  final sortedIssues = issues..sort((a, b) => a.line.compareTo(b.line));
  final lines = file.readAsLinesSync();
  var replacements = 0;
  final changes = <String>[];
  final skipped = <_SkippedIssue>[];

  for (final issue in sortedIssues) {
    final index = issue.line - 1;
    if (index < 0 || index >= lines.length) {
      skipped.add(_SkippedIssue(issue, 'line_out_of_range'));
      continue;
    }
    final line = lines[index];
    if (!_looksLikeSpacingContext(line)) {
      skipped.add(_SkippedIssue(issue, 'context_not_detected'));
      continue;
    }
    final token = _nearestSpacingToken(issue.value);
    final replacementLiteral = 'VisualThemeV3.${token.name}';
    final result = _replaceNumberInLine(line, issue.value, replacementLiteral);
    if (result.replaced) {
      lines[index] = result.line;
      replacements += 1;
      changes.add('line ${issue.line}: ${issue.rawValue} -> ${token.name}');
    } else {
      skipped.add(_SkippedIssue(issue, 'value_not_found'));
    }
  }

  if (replacements > 0) {
    var content = lines.join('\n');
    content = _ensureVisualThemeImport(content, file.path);
    file.writeAsStringSync(content);
  }

  return _FileFixResult(
    path: file.path,
    replacements: replacements,
    details: changes,
    skipped: skipped,
  );
}

bool _looksLikeSpacingContext(String line) {
  const keywords = [
    'height',
    'width',
    'padding',
    'margin',
    'spacing',
    'sizedbox',
    'edgeinsets',
    'gap',
    'sliverpadding',
    'animatedpadding',
    'slivierpadding',
    'listtile.divide',
    'align',
    'fractionallyspaced',
  ];
  final lower = line.toLowerCase();
  return keywords.any(lower.contains);
}

_LineEditResult _replaceNumberInLine(
  String line,
  double targetValue,
  String replacement,
) {
  for (final match in _numberPattern.allMatches(line)) {
    final numericText = match.group(1)!;
    final parsedValue = double.tryParse(numericText);
    if (parsedValue == null) continue;
    if ((parsedValue - targetValue).abs() <= 0.01) {
      final updated = line.replaceRange(match.start, match.end, replacement);
      return _LineEditResult(line: updated, replaced: true);
    }
  }
  return _LineEditResult(line: line, replaced: false);
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(addWrite: true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(addWrite: false);
  }
}

Future<void> _setReportsPermissions({required bool addWrite}) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'visual_spacing_autofix: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}

Future<void> _writeSummary(_AutofixOutcome outcome, int totalIssues) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL SPACING AUTOFIX SUMMARY')
    ..writeln('==============================')
    ..writeln('Timestamp: ${DateTime.now().toIso8601String()}')
    ..writeln('Entries processed: $totalIssues')
    ..writeln('Replacements applied: ${outcome.totalReplacements}')
    ..writeln('Files updated: ${outcome.fileResults.length}')
    ..writeln('Skipped entries: ${outcome.skipped.length}')
    ..writeln();

  if (outcome.fileResults.isNotEmpty) {
    buffer.writeln('Updated files:');
    for (final result in outcome.fileResults) {
      buffer.writeln('- ${result.path}: ${result.replacements} replacements');
      for (final detail in result.details) {
        buffer.writeln('  • $detail');
      }
    }
    buffer.writeln();
  }

  if (outcome.skipped.isNotEmpty) {
    buffer.writeln('Skipped entries:');
    for (final issue in outcome.skipped) {
      buffer.writeln(
        '- ${issue.issue.path}:${issue.issue.line} '
        '(value ${issue.issue.rawValue}) -> ${issue.reason}',
      );
    }
    buffer.writeln();
  }

  await File(_summaryOutput).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry(int count, int durationMs) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'visual_spacing_autofixed',
    'timestamp': DateTime.now().toIso8601String(),
    'count': count,
    'duration_ms': durationMs,
  };
  await telemetryFile.writeAsString(
    jsonEncode(event) + '\n',
    mode: FileMode.append,
    flush: true,
  );
}

String _ensureVisualThemeImport(String content, String path) {
  if (path.contains('visual_theme_v3.dart')) {
    return content;
  }
  if (content.contains('visual_theme_v3.dart')) {
    return content;
  }
  final lines = content.split('\n');
  var insertIndex = 0;
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trimLeft();
    if (trimmed.startsWith('import ')) {
      insertIndex = i + 1;
    } else if (trimmed.isEmpty || trimmed.startsWith('//')) {
      continue;
    } else {
      break;
    }
  }
  lines.insert(insertIndex, _visualThemeImport);
  return lines.join('\n');
}

_SpacingToken _nearestSpacingToken(double value) {
  _SpacingToken closest = _spacingTokens.first;
  var minDelta = (value - closest.value).abs();
  for (final token in _spacingTokens.skip(1)) {
    final delta = (value - token.value).abs();
    if (delta < minDelta) {
      closest = token;
      minDelta = delta;
    }
  }
  return closest;
}

class _SpacingIssue {
  const _SpacingIssue({
    required this.path,
    required this.line,
    required this.value,
    required this.rawValue,
  });

  final String path;
  final int line;
  final double value;
  final String rawValue;
}

class _SpacingToken {
  const _SpacingToken(this.name, this.value);
  final String name;
  final double value;
}

class _LineEditResult {
  const _LineEditResult({required this.line, required this.replaced});
  final String line;
  final bool replaced;
}

class _FileFixResult {
  _FileFixResult({
    required this.path,
    required this.replacements,
    required this.details,
    required this.skipped,
  });

  final String path;
  final int replacements;
  final List<String> details;
  final List<_SkippedIssue> skipped;
}

class _SkippedIssue {
  _SkippedIssue(this.issue, this.reason);
  final _SpacingIssue issue;
  final String reason;
}

class _AutofixOutcome {
  _AutofixOutcome({
    required this.fileResults,
    required this.skipped,
    required this.totalReplacements,
  });

  final List<_FileFixResult> fileResults;
  final List<_SkippedIssue> skipped;
  final int totalReplacements;
}
