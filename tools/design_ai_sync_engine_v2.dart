import 'dart:convert';
import 'dart:io';

const String _aiServicePath = 'lib/services/ai_personalization_service.dart';
const String _palettePath = 'lib/ui_v3/theme/personalization_profile.dart';
const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _textStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';
const String _outputPath = 'release/_reports/design_ai_sync_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _extractMoods();
  final paletteBlocks = await _extractPaletteBlocks();
  final visualTokens = await _extractVisualTokens();
  final textTokens = await _extractTextStyles();

  final reports = <_MoodReport>[];
  int mappedCategories = 0;
  int missingCategories = 0;

  for (final mood in moods) {
    final block = paletteBlocks[mood] ?? '';
    final colors = _collectRefs(block, visualTokens.colorTokens);
    final spacings = _collectRefs(block, visualTokens.spacingTokens);
    final typography = _collectRefs(block, textTokens);

    final colorMissing = colors.isEmpty;
    final spacingMissing = spacings.isEmpty;
    final typographyMissing = typography.isEmpty;

    mappedCategories +=
        (colorMissing ? 0 : 1) +
        (spacingMissing ? 0 : 1) +
        (typographyMissing ? 0 : 1);
    missingCategories +=
        (colorMissing ? 1 : 0) +
        (spacingMissing ? 1 : 0) +
        (typographyMissing ? 1 : 0);

    reports.add(
      _MoodReport(
        mood: mood,
        colors: colors,
        spacings: spacings,
        typography: typography,
      ),
    );
  }

  final totalCategories = moods.length * 3;
  final coverage = totalCategories == 0
      ? 0.0
      : (mappedCategories / totalCategories) * 100;

  await _withReportsWritable(() async {
    await _writeSummary(
      reports: reports,
      mapped: mappedCategories,
      missing: missingCategories,
      coverage: coverage,
    );
    await _appendTelemetry(
      mapped: mappedCategories,
      missing: missingCategories,
      coverage: coverage,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'design_ai_sync_engine_v2: moods=${moods.length} '
    'coverage=${coverage.toStringAsFixed(1)}%',
  );
}

Future<Set<String>> _extractMoods() async {
  final file = File(_aiServicePath);
  if (!await file.exists()) return const {};
  final content = await file.readAsString();
  final moods = <String>{};
  moods.addAll(
    RegExp(
      r"'mood'\s*:\s*'([^']+)'",
    ).allMatches(content).map((m) => m.group(1) ?? ''),
  );
  moods.addAll(
    RegExp(r"'([a-zA-Z_]+)'")
        .allMatches(content)
        .map((m) => m.group(1) ?? '')
        .where((value) => value == 'confident' || value == 'frustrated'),
  );
  if (moods.isEmpty) moods.add('neutral');
  return moods;
}

Future<Map<String, String>> _extractPaletteBlocks() async {
  final file = File(_palettePath);
  if (!await file.exists()) return const {};
  final content = await file.readAsString();
  final pattern = RegExp(
    r"(case\s+'([^']+)':|default:)([\s\S]*?)(?=case\s+'|default:|$)",
  );
  final map = <String, String>{};
  for (final match in pattern.allMatches(content)) {
    final label = match.group(2) ?? 'default';
    map[label] = match.group(3)?.trim() ?? '';
  }
  return map;
}

Future<_VisualTokens> _extractVisualTokens() async {
  final file = File(_visualThemePath);
  if (!await file.exists()) return const _VisualTokens();
  final content = await file.readAsString();
  final colorPattern = RegExp(r'VisualThemeV3\.(\w+)');
  final spacingPattern = RegExp(r'spacing\w+');
  return _VisualTokens(
    colorTokens: {
      for (final match in colorPattern.allMatches(content)) match.group(1)!,
    },
    spacingTokens: {
      for (final match in spacingPattern.allMatches(content)) match.group(0)!,
    },
  );
}

Future<Set<String>> _extractTextStyles() async {
  final file = File(_textStylesPath);
  if (!await file.exists()) return const {};
  final content = await file.readAsString();
  return {
    for (final match in RegExp(r'AppTextStyles\.(\w+)').allMatches(content))
      match.group(1)!,
  };
}

Set<String> _collectRefs(String block, Set<String> tokens) {
  if (block.isEmpty) return const {};
  final matches = RegExp(
    r'(VisualThemeV3|AppTextStyles)\.(\w+)',
  ).allMatches(block);
  final refs = <String>{};
  for (final match in matches) {
    final token = match.group(2);
    if (token != null && tokens.contains(token)) refs.add(token);
  }
  return refs;
}

Future<void> _writeSummary({
  required List<_MoodReport> reports,
  required int mapped,
  required int missing,
  required double coverage,
}) async {
  final buffer = StringBuffer()
    ..writeln('DESIGN–AI SYNC V2 SUMMARY')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Mapped categories: $mapped   Missing categories: $missing   '
      'Coverage: ${coverage.toStringAsFixed(1)}%',
    )
    ..writeln();

  for (final report in reports) {
    buffer
      ..writeln('Mood: ${report.mood}')
      ..writeln(
        '  Colors: ${report.colors.isEmpty ? '—' : report.colors.join(', ')}',
      )
      ..writeln(
        '  Spacing: ${report.spacings.isEmpty ? '—' : report.spacings.join(', ')}',
      )
      ..writeln(
        '  Typography: '
        '${report.typography.isEmpty ? '—' : report.typography.join(', ')}',
      )
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int mapped,
  required int missing,
  required double coverage,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'design_ai_sync_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'mapped_count': mapped,
    'missing_count': missing,
    'coverage': double.parse(coverage.toStringAsFixed(1)),
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
      'design_ai_sync_engine_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _MoodReport {
  const _MoodReport({
    required this.mood,
    required this.colors,
    required this.spacings,
    required this.typography,
  });

  final String mood;
  final Set<String> colors;
  final Set<String> spacings;
  final Set<String> typography;
}

class _VisualTokens {
  const _VisualTokens({
    this.colorTokens = const {},
    this.spacingTokens = const {},
  });

  final Set<String> colorTokens;
  final Set<String> spacingTokens;
}
