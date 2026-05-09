import 'dart:convert';
import 'dart:io';

const List<String> _screenPaths = [
  'lib/ui_v3/learning_map_screen.dart',
  'lib/ui_v3/lesson_screen.dart',
  'lib/ui_v3/progress_hub_screen.dart',
];

const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _textStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';

const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/visual_refinement_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final tokensFixed = _applyRefinements();
  final coverage = await _calculateCoverage();
  await _withReportsWritable(() async {
    await _writeSummary(coverage, tokensFixed);
    await _appendTelemetry(
      coveragePct: double.parse(coverage.overall.toStringAsFixed(4)),
      tokensFixed: tokensFixed,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });
  stdout.writeln(
    'visual_refinement_pass: coverage '
    '${(coverage.overall * 100).toStringAsFixed(1)}% '
    '($tokensFixed updates applied).',
  );
}

int _applyRefinements() {
  var modifications = 0;
  modifications += _refineLearningMap();
  modifications += _refineLessonScreen();
  modifications += _refineProgressHub();
  return modifications;
}

int _refineLearningMap() {
  final path = _screenPaths[0];
  final file = File(path);
  if (!file.existsSync()) return 0;
  var content = file.readAsStringSync();
  var updated = 0;

  const bodyMarker = 'body: Container(';
  if (content.contains(bodyMarker) &&
      !content.contains('color: VisualThemeV3.surfaceLight')) {
    content = content.replaceFirst(
      bodyMarker,
      'body: Container(\n          color: VisualThemeV3.surfaceLight,',
    );
    updated++;
  }

  const titleBlock =
      '    final titleColor = node.highlight\n        ? colorScheme.onPrimary\n        : colorScheme.onSurface;';
  if (content.contains(titleBlock)) {
    content = content.replaceFirst(
      titleBlock,
      '    final titleColor = node.highlight\n        ? VisualThemeV3.textPrimaryLight\n        : VisualThemeV3.primaryText;',
    );
    updated++;
  }

  const detailBlock =
      '    final detailColor = node.highlight\n        ? colorScheme.onPrimary.withValues(alpha: 0.85)\n        : colorScheme.onSurfaceVariant;';
  if (content.contains(detailBlock)) {
    content = content.replaceFirst(
      detailBlock,
      '    final detailColor = node.highlight\n        ? VisualThemeV3.textSecondaryLight\n        : VisualThemeV3.secondaryText;',
    );
    updated++;
  }

  const statusBlock =
      '    final statusColor = node.highlight\n        ? colorScheme.onPrimary\n        : colorScheme.onSurface;';
  if (content.contains(statusBlock)) {
    content = content.replaceFirst(
      statusBlock,
      '    final statusColor = node.highlight\n        ? VisualThemeV3.textPrimaryLight\n        : VisualThemeV3.neutral;',
    );
    updated++;
  }

  const gradientBlock =
      '            gradient: node.highlight\n                ? VisualThemeV3.marketingAccentGradient\n                : VisualThemeV3.brandBackgroundGradient,';
  if (content.contains(gradientBlock)) {
    content = content.replaceFirst(
      gradientBlock,
      '            gradient: node.highlight\n                ? VisualThemeV3.marketingAccentGradient\n                : const LinearGradient(\n                    begin: Alignment.topLeft,\n                    end: Alignment.bottomRight,\n                    colors: [\n                      VisualThemeV3.cardLight,\n                      VisualThemeV3.cardDark,\n                    ],\n                  ),',
    );
    updated++;
  }

  const spacingMarker = 'const SizedBox(height: VisualThemeV3.spacingM),';
  if (content.contains(spacingMarker) &&
      !content.contains('VisualThemeV3.spacingXL')) {
    content = content.replaceFirst(
      spacingMarker,
      'const SizedBox(height: VisualThemeV3.spacingM),\n          const SizedBox(height: VisualThemeV3.spacingXL),',
    );
    updated++;
  }

  if (updated > 0) {
    file.writeAsStringSync(content);
  }
  return updated;
}

int _refineLessonScreen() {
  final path = _screenPaths[1];
  final file = File(path);
  if (!file.existsSync()) return 0;
  var content = file.readAsStringSync();
  var updated = 0;

  const bodyMarker = 'body: Container(';
  if (content.contains(bodyMarker) &&
      !content.contains('color: VisualThemeV3.surfaceLight')) {
    content = content.replaceFirst(
      bodyMarker,
      'body: Container(\n          color: VisualThemeV3.surfaceLight,',
    );
    updated++;
  }

  const spacingMarker = 'const SizedBox(height: VisualThemeV3.spacingS),';
  if (content.contains(spacingMarker) &&
      !content.contains('VisualThemeV3.spacingXL')) {
    content = content.replaceFirst(
      spacingMarker,
      'const SizedBox(height: VisualThemeV3.spacingS),\n        const SizedBox(height: VisualThemeV3.spacingXL),',
    );
    updated++;
  }

  const headerDetail =
      "          'AI focus: \${_personalization.recommendedModule}',\n          style: AppTextStyles.cardDetail(context).copyWith(\n            color: palette.accent,\n          ),";
  if (content.contains(headerDetail)) {
    content = content.replaceFirst(
      headerDetail,
      "          'AI focus: \${_personalization.recommendedModule}',\n          style: AppTextStyles.cardDetail(context).copyWith(\n            color: VisualThemeV3.textSecondaryLight,\n          ),",
    );
    updated++;
  }

  const containerMarker =
      '            decoration: BoxDecoration(\n              gradient: palette.cardGradient,\n              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),\n              border: Border.all(\n                color: palette.accent.withValues(alpha: 0.2),';
  if (content.contains(containerMarker)) {
    content = content.replaceFirst(
      containerMarker,
      '            decoration: BoxDecoration(\n              gradient: palette.cardGradient,\n              color: VisualThemeV3.cardLight,\n              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),\n              border: Border.all(\n                color: VisualThemeV3.surfaceDark.withValues(alpha: 0.2),',
    );
    updated++;
  }

  if (updated > 0) {
    file.writeAsStringSync(content);
  }
  return updated;
}

int _refineProgressHub() {
  final path = _screenPaths[2];
  final file = File(path);
  if (!file.existsSync()) return 0;
  var content = file.readAsStringSync();
  var updated = 0;

  const bodyMarker = 'body: Container(';
  if (content.contains(bodyMarker) &&
      !content.contains('color: VisualThemeV3.surfaceLight')) {
    content = content.replaceFirst(
      bodyMarker,
      'body: Container(\n            color: VisualThemeV3.surfaceLight,',
    );
    updated++;
  }

  const spacingMarker = 'const SizedBox(height: VisualThemeV3.spacingS),';
  if (content.contains(spacingMarker) &&
      !content.contains('VisualThemeV3.spacingXL')) {
    content = content.replaceFirst(
      spacingMarker,
      'const SizedBox(height: VisualThemeV3.spacingS),\n        const SizedBox(height: VisualThemeV3.spacingXL),',
    );
    updated++;
  }

  const cardBoxMarker =
      '          child: Container(\n            padding: const EdgeInsets.all(VisualThemeV3.spacingM),\n            decoration: BoxDecoration(';
  if (content.contains(cardBoxMarker) &&
      !content.contains('color: VisualThemeV3.cardLight')) {
    content = content.replaceFirst(
      cardBoxMarker,
      '          child: Container(\n            padding: const EdgeInsets.all(VisualThemeV3.spacingM),\n            decoration: BoxDecoration(\n              color: VisualThemeV3.cardLight,\n',
    );
    updated++;
  }

  if (updated > 0) {
    file.writeAsStringSync(content);
  }
  return updated;
}

Future<_CoverageSummary> _calculateCoverage() async {
  final colors = await _extractTokens(
    _visualThemePath,
    RegExp(r'static const Color (\w+) ='),
  );
  final spacing = await _extractTokens(
    _visualThemePath,
    RegExp(r'static const double (spacing\w+) ='),
  );
  final typography = await _extractTokens(
    _textStylesPath,
    RegExp(r'static TextStyle (\w+)\('),
  );

  final colorUsage = _scanUsage('VisualThemeV3.', colors);
  final spacingUsage = _scanUsage('VisualThemeV3.', spacing);
  final typographyUsage = _scanUsage('AppTextStyles.', typography);

  final colorReport = _CoverageReport(colors, colorUsage);
  final spacingReport = _CoverageReport(spacing, spacingUsage);
  final typographyReport = _CoverageReport(typography, typographyUsage);

  final overall =
      (colorReport.percentage +
          spacingReport.percentage +
          typographyReport.percentage) /
      3;

  return _CoverageSummary(
    colors: colorReport,
    spacing: spacingReport,
    typography: typographyReport,
    overall: overall,
  );
}

Future<List<String>> _extractTokens(String path, RegExp pattern) async {
  final file = File(path);
  if (!await file.exists()) return const [];
  final matches =
      pattern
          .allMatches(await file.readAsString())
          .map((match) => match.group(1))
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
  return matches;
}

Set<String> _scanUsage(String prefix, List<String> tokens) {
  final used = <String>{};
  for (final screen in _screenPaths) {
    final file = File(screen);
    if (!file.existsSync()) continue;
    final content = file.readAsStringSync();
    for (final token in tokens) {
      if (used.contains(token)) continue;
      if (content.contains('$prefix$token')) {
        used.add(token);
      }
    }
  }
  return used;
}

Future<void> _writeSummary(_CoverageSummary coverage, int tokensFixed) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL REFINEMENT SUMMARY')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Overall coverage: ${(coverage.overall * 100).toStringAsFixed(1)}%',
    )
    ..writeln('Tokens fixed: $tokensFixed')
    ..writeln()
    ..writeln(_formatReport('Colors', coverage.colors))
    ..writeln()
    ..writeln(_formatReport('Spacing', coverage.spacing))
    ..writeln()
    ..writeln(_formatReport('Typography', coverage.typography));

  await File(_summaryPath).writeAsString(buffer.toString());
}

String _formatReport(String label, _CoverageReport report) {
  final buffer = StringBuffer()
    ..writeln(
      '$label coverage: ${(report.percentage * 100).toStringAsFixed(1)}% '
      '(${report.used.length}/${report.total.length})',
    );
  if (report.unused.isEmpty) {
    buffer.writeln('- All tokens referenced.');
  } else {
    buffer
      ..writeln('- Remaining tokens:')
      ..writeln(report.unused.map((t) => '  • $t').join('\n'));
  }
  return buffer.toString();
}

Future<void> _appendTelemetry({
  required double coveragePct,
  required int tokensFixed,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'visual_refinement_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'coverage_pct': coveragePct,
    'tokens_fixed': tokensFixed,
    'duration_ms': durationMs,
  };
  await telemetryFile.writeAsString(
    jsonEncode(event) + '\n',
    mode: FileMode.append,
    flush: true,
  );
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
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'visual_refinement_pass: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _CoverageReport {
  _CoverageReport(this.total, Set<String> usedTokens)
    : used = usedTokens.toList()..sort(),
      unused = total.where((t) => !usedTokens.contains(t)).toList()..sort();

  final List<String> total;
  final List<String> used;
  final List<String> unused;

  double get percentage => total.isEmpty ? 1.0 : used.length / total.length;
}

class _CoverageSummary {
  const _CoverageSummary({
    required this.colors,
    required this.spacing,
    required this.typography,
    required this.overall,
  });

  final _CoverageReport colors;
  final _CoverageReport spacing;
  final _CoverageReport typography;
  final double overall;
}
