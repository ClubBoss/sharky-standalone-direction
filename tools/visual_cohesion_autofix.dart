import 'dart:convert';
import 'dart:io';

const String _qaSummaryPath = 'release/_reports/visual_cohesion_qa_summary.txt';
const String _fallbackSummaryPath =
    'release/_reports/visual_cohesion_v2_summary.txt';
const String _reportsDir = 'release/_reports';
const String _outputPath =
    'release/_reports/visual_cohesion_autofix_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  var summaryFile = File(_qaSummaryPath);
  if (!await summaryFile.exists()) {
    summaryFile = File(_fallbackSummaryPath);
  }
  if (!await summaryFile.exists()) {
    stderr.writeln('visual_cohesion_autofix: no summary file found.');
    return;
  }

  final paths = _extractPaths(await summaryFile.readAsLines());
  final results = <_AutofixResult>[];
  for (final path in paths) {
    final file = File(path);
    if (!await file.exists()) continue;
    final content = await file.readAsString();
    final updated = _autofixContent(content);
    if (updated.content != content) {
      await file.writeAsString(updated.content);
    }
    results.add(
      _AutofixResult(
        path: path,
        fixes: updated.fixes,
        modified: updated.content != content,
      ),
    );
  }

  final totalFixes = results.fold<int>(0, (sum, r) => sum + r.fixes);
  final filesPatched = results.where((r) => r.modified).length;

  await _withReportsWritable(() async {
    await _writeReport(results, filesPatched, totalFixes);
    await _appendTelemetry(
      filesPatched: filesPatched,
      issuesFixed: totalFixes,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'visual_cohesion_autofix: files=$filesPatched fixes=$totalFixes',
  );
}

Set<String> _extractPaths(List<String> lines) {
  final paths = <String>{};
  final pathRegex = RegExp(r'(lib/[\w\-/]+\.dart)');
  for (final line in lines) {
    final match = pathRegex.firstMatch(line);
    if (match != null) {
      paths.add(match.group(1)!);
    }
  }
  return paths;
}

class _AutofixResult {
  const _AutofixResult({
    required this.path,
    required this.fixes,
    required this.modified,
  });

  final String path;
  final int fixes;
  final bool modified;
}

class _AutofixOutput {
  const _AutofixOutput({required this.content, required this.fixes});

  final String content;
  final int fixes;
}

_AutofixOutput _autofixContent(String content) {
  var updated = content;
  var fixes = 0;

  updated = _ensureImport(
    updated,
    "import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';",
    'VisualThemeV3.',
    () => fixes++,
  );
  updated = _ensureImport(
    updated,
    "import 'package:poker_analyzer/ui_v3/theme/app_text_styles.dart';",
    'AppTextStyles.',
    () => fixes++,
  );
  updated = _ensureImport(
    updated,
    "import 'package:poker_analyzer/ui_v3/theme/personalization_profile.dart';",
    'PersonalizationPalette',
    () => fixes++,
  );

  updated = _replaceRegex(
    updated,
    RegExp(r'Color\(0xFF[0-9A-Fa-f]{6}\)'),
    'VisualThemeV3.primary',
    () => fixes++,
  );
  updated = _replaceRegex(
    updated,
    RegExp(r'Colors\.[A-Za-z_]+'),
    'VisualThemeV3.primary',
    () => fixes++,
  );
  updated = _replaceRegex(
    updated,
    RegExp(r'SizedBox\(width:\s*\d+'),
    'SizedBox(width: VisualThemeV3.spacingXL',
    () => fixes++,
  );
  updated = _replaceRegex(
    updated,
    RegExp(r'SizedBox\(height:\s*\d+'),
    'SizedBox(height: VisualThemeV3.spacingXL',
    () => fixes++,
  );

  return _AutofixOutput(content: updated, fixes: fixes);
}

String _replaceRegex(
  String content,
  RegExp pattern,
  String replacement,
  void Function() onFix,
) {
  final matches = pattern.allMatches(content).length;
  if (matches == 0) return content;
  var updated = content;
  for (var i = 0; i < matches; i++) {
    updated = updated.replaceFirst(pattern, replacement);
    onFix();
  }
  return updated;
}

String _ensureImport(
  String content,
  String importLine,
  String token,
  void Function() onFix,
) {
  if (!content.contains(token) || content.contains(importLine)) {
    return content;
  }
  final insertIndex = content.indexOf("import 'package");
  if (insertIndex == -1) {
    return content;
  }
  final updated = content.replaceRange(
    insertIndex,
    insertIndex,
    '$importLine\n',
  );
  onFix();
  return updated;
}

Future<void> _writeReport(
  List<_AutofixResult> results,
  int filesPatched,
  int issuesFixed,
) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION AUTOFIX SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Files patched: $filesPatched')
    ..writeln('Issues fixed: $issuesFixed')
    ..writeln()
    ..writeln('| File | Fixes | Modified |')
    ..writeln('|------|-------|----------|');
  for (final result in results) {
    buffer.writeln(
      '| ${result.path} | ${result.fixes} | ${result.modified ? 'YES' : 'NO'} |',
    );
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int filesPatched,
  required int issuesFixed,
  required int durationMs,
}) async {
  final payload = <String, Object>{
    'event': 'visual_cohesion_autofix_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'files_patched': filesPatched,
    'issues_fixed': issuesFixed,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    jsonEncode(payload) + '\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(false);
  }
}

Future<void> _setReportsPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'visual_cohesion_autofix: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
