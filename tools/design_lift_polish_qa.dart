import 'dart:convert';
import 'dart:io';

const String _uiDirPath = 'lib/ui_v3';
const String _outputPath = 'release/_reports/design_lift_polish_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final directory = Directory(_uiDirPath);
  if (!directory.existsSync()) {
    stderr.writeln('design_lift_polish_qa: $_uiDirPath not found');
    return;
  }

  final files = await _collectDartFiles(directory);
  final motionConstants = <String>{
    'VisualThemeV3.motionFast',
    'VisualThemeV3.motionMedium',
    'VisualThemeV3.motionSlow',
  };

  final fileIssues = <_FileReport>[];
  var totalInlineColors = 0;
  var totalInlineText = 0;
  var totalInlineSpacing = 0;
  var totalMotionViolations = 0;
  var totalDeprecatedAssets = 0;
  var totalMissingImports = 0;

  for (final file in files) {
    final content = await file.readAsString();
    final inlineColors = _countInlineColors(content);
    final inlineText = _countInlineText(content);
    final inlineSpacing = _countInlineSpacing(content);
    final motionViolations = _countMotionViolations(content, motionConstants);
    final deprecatedAssets = _countDeprecatedAssets(content);
    final missingAdaptiveImport =
        _requiresAdaptiveImport(content) && !_hasAdaptiveImport(content);

    totalInlineColors += inlineColors;
    totalInlineText += inlineText;
    totalInlineSpacing += inlineSpacing;
    totalMotionViolations += motionViolations;
    totalDeprecatedAssets += deprecatedAssets;
    if (missingAdaptiveImport) {
      totalMissingImports += 1;
    }

    final hasIssue =
        inlineColors > 0 ||
        inlineText > 0 ||
        inlineSpacing > 0 ||
        motionViolations > 0 ||
        deprecatedAssets > 0 ||
        missingAdaptiveImport;

    fileIssues.add(
      _FileReport(
        path: file.path,
        inlineColors: inlineColors,
        inlineText: inlineText,
        inlineSpacing: inlineSpacing,
        motionViolations: motionViolations,
        deprecatedAssets: deprecatedAssets,
        missingAdaptiveImport: missingAdaptiveImport,
        status: hasIssue ? 'FAIL' : 'PASS',
      ),
    );
  }

  final finalIndex = _computeIndex(fileIssues);
  final verdict = _verdict(finalIndex);

  await _withReportsWritable(() async {
    await _writeSummary(
      filesScanned: files.length,
      issues: fileIssues,
      totals: _Totals(
        inlineColors: totalInlineColors,
        inlineText: totalInlineText,
        inlineSpacing: totalInlineSpacing,
        motionViolations: totalMotionViolations,
        deprecatedAssets: totalDeprecatedAssets,
        missingAdaptiveImports: totalMissingImports,
      ),
      finalIndex: finalIndex,
      verdict: verdict,
    );
    await _appendTelemetry(
      finalIndex: finalIndex,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'design_lift_polish_qa: scanned=${files.length} '
    'finalIndex=${(finalIndex * 100).toStringAsFixed(1)}% verdict=$verdict',
  );
}

Future<List<File>> _collectDartFiles(Directory dir) async {
  final files = <File>[];
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  return files;
}

int _countInlineColors(String content) {
  final regex = RegExp(r'Color\s*\(');
  return regex.allMatches(content).length;
}

int _countInlineText(String content) {
  final regex = RegExp(r'TextStyle\s*\(');
  return regex.allMatches(content).length;
}

int _countInlineSpacing(String content) {
  final regex = RegExp(r'EdgeInsets[^\(]*\(');
  final allowed = <String>{
    'VisualThemeV3.spacing',
    'VisualTheme.spacing',
    'AppSpacing',
  };
  var count = 0;
  for (final match in regex.allMatches(content)) {
    final start = match.start;
    final end = (start + 120).clamp(0, content.length);
    final snippet = content.substring(start, end);
    final hasToken = allowed.any(snippet.contains);
    if (!hasToken) count++;
  }
  return count;
}

int _countMotionViolations(String content, Set<String> allowedConstants) {
  final regex = RegExp(r'Duration\s*\(\s*milliseconds\s*:\s*(\d+)\s*\)');
  final count = regex.allMatches(content).length;
  final allowedUsage = allowedConstants.where(content.contains).length;
  return count > allowedUsage ? count - allowedUsage : 0;
}

int _countDeprecatedAssets(String content) {
  final regex = RegExp(r'''assets/(legacy|deprecated)/[^'"\\s]+''');
  return regex.allMatches(content).length;
}

bool _requiresAdaptiveImport(String content) {
  return RegExp(r'TextStyle\s*\(').hasMatch(content) ||
      RegExp(r'Color\s*\(').hasMatch(content) ||
      RegExp(r'EdgeInsets[^\(]*\(').hasMatch(content);
}

bool _hasAdaptiveImport(String content) {
  return content.contains('VisualThemeV3') ||
      content.contains('AppTextStyles') ||
      content.contains('AppColors');
}

double _computeIndex(List<_FileReport> reports) {
  if (reports.isEmpty) return 1.0;
  final passes = reports.where((r) => r.status == 'PASS').length;
  return passes / reports.length;
}

String _verdict(double index) {
  if (index >= 0.9) return 'PASS';
  if (index >= 0.75) return 'WARN';
  return 'FAIL';
}

Future<void> _writeSummary({
  required int filesScanned,
  required List<_FileReport> issues,
  required _Totals totals,
  required double finalIndex,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('DESIGN-LIFT POLISH SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Files scanned: $filesScanned')
    ..writeln(
      'Totals → inline colors: ${totals.inlineColors}, '
      'inline text: ${totals.inlineText}, '
      'inline spacing: ${totals.inlineSpacing}, '
      'motion violations: ${totals.motionViolations}, '
      'deprecated assets: ${totals.deprecatedAssets}, '
      'missing adaptive imports: ${totals.missingAdaptiveImports}',
    )
    ..writeln(
      'Design-Lift Polish Index: ${(finalIndex * 100).toStringAsFixed(1)}% '
      '($verdict)',
    )
    ..writeln();

  for (final issue in issues) {
    buffer.writeln(issue.describe());
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double finalIndex,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'design_lift_polish_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'final_index': double.parse(finalIndex.toStringAsFixed(3)),
    'verdict': verdict,
    'duration_ms': durationMs,
  };

  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'design_lift_polish_qa: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}

class _FileReport {
  const _FileReport({
    required this.path,
    required this.inlineColors,
    required this.inlineText,
    required this.inlineSpacing,
    required this.motionViolations,
    required this.deprecatedAssets,
    required this.missingAdaptiveImport,
    required this.status,
  });

  final String path;
  final int inlineColors;
  final int inlineText;
  final int inlineSpacing;
  final int motionViolations;
  final int deprecatedAssets;
  final bool missingAdaptiveImport;
  final String status;

  String describe() {
    final details = <String>[];
    if (inlineColors > 0) {
      details.add('$inlineColors inline colors');
    }
    if (inlineText > 0) {
      details.add('$inlineText inline text styles');
    }
    if (inlineSpacing > 0) {
      details.add('$inlineSpacing inline spacing values');
    }
    if (motionViolations > 0) {
      details.add('$motionViolations motion violations');
    }
    if (deprecatedAssets > 0) {
      details.add('$deprecatedAssets deprecated assets');
    }
    if (missingAdaptiveImport) {
      details.add('missing adaptive import');
    }
    final detailStr = details.isEmpty ? 'OK' : details.join(', ');
    return 'File $path → $status ($detailStr)';
  }
}

class _Totals {
  const _Totals({
    required this.inlineColors,
    required this.inlineText,
    required this.inlineSpacing,
    required this.motionViolations,
    required this.deprecatedAssets,
    required this.missingAdaptiveImports,
  });

  final int inlineColors;
  final int inlineText;
  final int inlineSpacing;
  final int motionViolations;
  final int deprecatedAssets;
  final int missingAdaptiveImports;
}
