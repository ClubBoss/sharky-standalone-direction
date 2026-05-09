import 'dart:convert';
import 'dart:io';

const String _uiDirPath = 'lib/ui';
const String _outputPath = 'release/_reports/visual_cohesion_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final uiDir = Directory(_uiDirPath);
  final files = await _collectDartFiles(uiDir);

  final colorTokens = await _parseColorTokens();
  final textTokens = await _parseTextStyleTokens();
  final spacingTokens = await _parseSpacingTokens();

  final usedColors = <String>{};
  final usedTextStyles = <String>{};
  final usedSpacing = <String>{};

  final issues = <_FileIssue>[];
  final assetMismatches = <String>[];

  for (final file in files) {
    final content = await file.readAsString();
    usedColors.addAll(_extractUsedTokens(content, 'AppColors.', colorTokens));
    usedColors.addAll(
      _extractUsedTokens(content, 'VisualThemeV3.', colorTokens),
    );
    usedTextStyles.addAll(
      _extractUsedTokens(content, 'AppTextStyles.', textTokens),
    );
    usedSpacing.addAll(
      _extractUsedTokens(content, 'VisualThemeV3.', spacingTokens),
    );

    final inlineColors = _countInlineColors(content);
    final inlineTextStyles = _countInlineTextStyles(content);
    final inlineSpacing = _countInlineSpacing(content);
    final missingAssets = _missingAssets(content);
    assetMismatches.addAll(missingAssets.map((path) => '${file.path}: $path'));

    final hasIssue =
        inlineColors > 0 ||
        inlineTextStyles > 0 ||
        inlineSpacing > 0 ||
        missingAssets.isNotEmpty;

    issues.add(
      _FileIssue(
        path: file.path,
        inlineColors: inlineColors,
        inlineTextStyles: inlineTextStyles,
        inlineSpacing: inlineSpacing,
        missingAssets: missingAssets.length,
        status: hasIssue ? 'FAIL' : 'PASS',
      ),
    );
  }

  final unusedColorTokens = colorTokens.difference(usedColors);
  final unusedTextTokens = textTokens.difference(usedTextStyles);
  final unusedSpacingTokens = spacingTokens.difference(usedSpacing);

  await _withReportsWritable(() async {
    await _writeSummary(
      filesScanned: files.length,
      issues: issues,
      unusedColorTokens: unusedColorTokens,
      unusedTextTokens: unusedTextTokens,
      unusedSpacingTokens: unusedSpacingTokens,
      assetMismatches: assetMismatches,
    );
    await _appendTelemetry(
      finalIndex: _finalIndex(issues),
      verdict: _overallVerdict(issues),
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'visual_cohesion_qa: scanned=${files.length} verdict=${_overallVerdict(issues)} '
    'finalIndex=${(_finalIndex(issues) * 100).toStringAsFixed(1)}%',
  );
}

Future<List<File>> _collectDartFiles(Directory dir) async {
  if (!await dir.exists()) return const [];
  return dir
      .list(recursive: true, followLinks: false)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .map((entity) => entity as File)
      .toList();
}

Future<Set<String>> _parseColorTokens() async {
  final tokens = <String>{};
  final file = File('lib/theme/app_colors.dart');
  if (await file.exists()) {
    final lines = await file.readAsLines();
    final regex = RegExp(r'static\s+(?:const\s+)?Color\s+(\w+)');
    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) tokens.add(match.group(1)!);
    }
  }
  final visualTheme = File('lib/ui_v3/theme/visual_theme_v3.dart');
  if (await visualTheme.exists()) {
    final lines = await visualTheme.readAsLines();
    final regex = RegExp(r'static\s+(?:const\s+)?Color\s+(\w+)');
    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) tokens.add(match.group(1)!);
    }
  }
  return tokens;
}

Future<Set<String>> _parseTextStyleTokens() async {
  final tokens = <String>{};
  final file = File('lib/ui_v3/theme/app_text_styles.dart');
  if (!await file.exists()) return tokens;
  final lines = await file.readAsLines();
  final regex = RegExp(
    r'static\s+(?:const\s+)?(?:TextStyle|_DerivedStyle)\s+(\w+)',
  );
  for (final line in lines) {
    final match = regex.firstMatch(line);
    if (match != null) tokens.add(match.group(1)!);
  }
  return tokens;
}

Future<Set<String>> _parseSpacingTokens() async {
  final tokens = <String>{};
  final file = File('lib/ui_v3/theme/visual_theme_v3.dart');
  if (!await file.exists()) return tokens;
  final lines = await file.readAsLines();
  final regex = RegExp(r'static\s+const\s+double\s+(spacing\w+)');
  for (final line in lines) {
    final match = regex.firstMatch(line);
    if (match != null) tokens.add(match.group(1)!);
  }
  return tokens;
}

Set<String> _extractUsedTokens(
  String content,
  String prefix,
  Set<String> tokens,
) {
  final used = <String>{};
  for (final token in tokens) {
    if (content.contains('$prefix$token')) {
      used.add(token);
    }
  }
  return used;
}

int _countInlineColors(String content) {
  final regex = RegExp(r'Color\s*\(');
  return regex.allMatches(content).length;
}

int _countInlineTextStyles(String content) {
  final regex = RegExp(r'TextStyle\s*\(');
  return regex.allMatches(content).length;
}

int _countInlineSpacing(String content) {
  final regex = RegExp(r'EdgeInsets[^\(]*\(');
  final allowed = <String>{
    'AppSpacing',
    'VisualThemeV3.spacing',
    'VisualTheme.spacing',
    'AppSpacingTokens',
  };
  var count = 0;
  for (final match in regex.allMatches(content)) {
    final start = match.start;
    final end = (start + 120) > content.length ? content.length : start + 120;
    final snippet = content.substring(start, end);
    final hasToken = allowed.any(snippet.contains);
    if (!hasToken) count++;
  }
  return count;
}

List<String> _missingAssets(String content) {
  final regex = RegExp("assets/theme/[^'\"\\)]+");
  final matches = regex
      .allMatches(content)
      .map((match) => match.group(0)!)
      .toSet();
  final missing = <String>[];
  for (final asset in matches) {
    final file = File(asset);
    if (!file.existsSync()) missing.add(asset);
  }
  return missing;
}

Future<void> _writeSummary({
  required int filesScanned,
  required List<_FileIssue> issues,
  required Set<String> unusedColorTokens,
  required Set<String> unusedTextTokens,
  required Set<String> unusedSpacingTokens,
  required List<String> assetMismatches,
}) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION SUMMARY')
    ..writeln('=======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Files scanned: $filesScanned')
    ..writeln(
      'Final cohesion index: ${(_finalIndex(issues) * 100).toStringAsFixed(1)}% '
      '(${_overallVerdict(issues)})',
    )
    ..writeln();

  for (final issue in issues) {
    buffer.writeln(_formatIssue(issue));
  }

  buffer
    ..writeln()
    ..writeln('Unused theme tokens')
    ..writeln('-------------------')
    ..writeln(
      'Colors: ${unusedColorTokens.isEmpty ? 'None' : unusedColorTokens.join(', ')}',
    )
    ..writeln(
      'Text styles: ${unusedTextTokens.isEmpty ? 'None' : unusedTextTokens.join(', ')}',
    )
    ..writeln(
      'Spacing: ${unusedSpacingTokens.isEmpty ? 'None' : unusedSpacingTokens.join(', ')}',
    )
    ..writeln()
    ..writeln('Mismatched asset references')
    ..writeln('---------------------------');

  if (assetMismatches.isEmpty) {
    buffer.writeln('None');
  } else {
    for (final mismatch in assetMismatches) {
      buffer.writeln(mismatch);
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

String _formatIssue(_FileIssue issue) {
  final details = <String>[];
  if (issue.inlineColors > 0) {
    details.add('${issue.inlineColors} inline colors');
  }
  if (issue.inlineTextStyles > 0) {
    details.add('${issue.inlineTextStyles} inline text styles');
  }
  if (issue.inlineSpacing > 0) {
    details.add('${issue.inlineSpacing} inline spacing values');
  }
  if (issue.missingAssets > 0) {
    details.add('${issue.missingAssets} missing assets');
  }
  final detailText = details.isEmpty ? 'OK' : details.join(', ');
  return 'File ${issue.path} → ${issue.status} ($detailText)';
}

double _finalIndex(List<_FileIssue> issues) {
  if (issues.isEmpty) return 1.0;
  final passes = issues.where((issue) => issue.status == 'PASS').length;
  return passes / issues.length;
}

String _overallVerdict(List<_FileIssue> issues) {
  final index = _finalIndex(issues);
  if (index >= 0.85) return 'PASS';
  if (index >= 0.6) return 'WARN';
  return 'FAIL';
}

Future<void> _appendTelemetry({
  required double finalIndex,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_completed',
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
      'visual_cohesion_qa: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}

class _FileIssue {
  const _FileIssue({
    required this.path,
    required this.inlineColors,
    required this.inlineTextStyles,
    required this.inlineSpacing,
    required this.missingAssets,
    required this.status,
  });

  final String path;
  final int inlineColors;
  final int inlineTextStyles;
  final int inlineSpacing;
  final int missingAssets;
  final String status;
}
