import 'dart:convert';
import 'dart:io';

const String _aiServicePath = 'lib/services/ai_personalization_service.dart';
const String _palettePath = 'lib/ui_v3/theme/personalization_profile.dart';
const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _textStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';
const String _outputPath = 'release/_reports/design_ai_sync_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _extractMoods();
  final paletteBlocks = await _extractPaletteBlocks();
  final tokens = await _extractVisualTokens();
  final textStyles = await _extractTextStyles();

  final reports = <_MoodReport>[];
  for (final mood in moods) {
    final block = paletteBlocks[mood] ?? paletteBlocks['default'];
    final colorRefs = block == null
        ? const <String>{}
        : _collectRefs(block, tokens.colorTokens);
    final spacingRefs = block == null
        ? const <String>{}
        : _collectRefs(block, tokens.spacingTokens);
    final typographyRefs = block == null
        ? const <String>{}
        : _collectTypographyRefs(block, textStyles);

    final gaps = <String>[];
    if (block == null) {
      gaps.add('palette_missing');
    }
    if (colorRefs.isEmpty) {
      gaps.add('color_token_missing');
    }
    if (spacingRefs.isEmpty) {
      gaps.add('spacing_token_missing');
    }
    if (typographyRefs.isEmpty) {
      gaps.add('typography_token_missing');
    }

    reports.add(
      _MoodReport(
        mood: mood,
        colors: colorRefs.toList()..sort(),
        spacings: spacingRefs.toList()..sort(),
        typography: typographyRefs.toList()..sort(),
        gaps: gaps,
      ),
    );
  }

  final mappedCount = reports.where((r) => r.gaps.isEmpty).length;
  final missingCount = reports.length - mappedCount;

  await _withReportsWritable(() async {
    await _writeSummary(reports, mappedCount, missingCount);
    await _appendTelemetry(
      mappedCount: mappedCount,
      missingCount: missingCount,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'design_ai_sync_engine: moods=${reports.length} '
    'mapped=$mappedCount missing=$missingCount',
  );
}

Future<Set<String>> _extractMoods() async {
  final moods = <String>{};
  Future<void> scanFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return;
    final content = await file.readAsString();
    final literalPattern = RegExp(r"'mood'\s*:\s*'([^']+)'");
    moods.addAll(
      literalPattern
          .allMatches(content)
          .map((match) => match.group(1)!)
          .where((value) => value.isNotEmpty),
    );
    final casePattern = RegExp(r"case\s+'([^']+)':");
    moods.addAll(
      casePattern
          .allMatches(content)
          .map((match) => match.group(1)!)
          .where((value) => value.isNotEmpty),
    );
  }

  await scanFile(_aiServicePath);
  await scanFile(_palettePath);
  if (moods.contains('default')) {
    moods.remove('default');
  }
  if (moods.isEmpty) {
    moods.add('neutral');
  }
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
    final body = match.group(3)?.trim() ?? '';
    map[label] = body;
  }
  return map;
}

Future<_VisualTokens> _extractVisualTokens() async {
  final file = File(_visualThemePath);
  if (!await file.exists()) return const _VisualTokens();
  final content = await file.readAsString();
  final colorPattern = RegExp(
    r'static\s+(?:const\s+)?(?:Color|LinearGradient)\s+(?:get\s+)?(\w+)',
  );
  final spacingPattern = RegExp(r'static\s+const\s+double\s+(spacing\w+)\s*=');

  final colors = {
    for (final match in colorPattern.allMatches(content)) match.group(1)!,
  };
  final spacing = {
    for (final match in spacingPattern.allMatches(content)) match.group(1)!,
  };
  return _VisualTokens(colorTokens: colors, spacingTokens: spacing);
}

Future<Set<String>> _extractTextStyles() async {
  final file = File(_textStylesPath);
  if (!await file.exists()) return const {};
  final content = await file.readAsString();
  final pattern = RegExp(r'static\s+TextStyle\s+(\w+)\(');
  return {for (final match in pattern.allMatches(content)) match.group(1)!};
}

Set<String> _collectRefs(String block, Set<String> allowed) {
  final matches = RegExp(r'VisualThemeV3\.([a-zA-Z0-9_]+)').allMatches(block);
  final result = <String>{};
  for (final match in matches) {
    final token = match.group(1);
    if (token != null && allowed.contains(token)) {
      result.add(token);
    }
  }
  return result;
}

Set<String> _collectTypographyRefs(String block, Set<String> allowed) {
  final matches = RegExp(r'AppTextStyles\.([a-zA-Z0-9_]+)').allMatches(block);
  final result = <String>{};
  for (final match in matches) {
    final token = match.group(1);
    if (token != null && allowed.contains(token)) {
      result.add(token);
    }
  }
  return result;
}

Future<void> _writeSummary(
  List<_MoodReport> reports,
  int mappedCount,
  int missingCount,
) async {
  final buffer = StringBuffer()
    ..writeln('DESIGN–AI SYNC SUMMARY')
    ..writeln('=======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Moods analyzed: ${reports.length}')
    ..writeln('Mapped: $mappedCount  Missing: $missingCount')
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
      ..writeln(
        '  Gaps: ${report.gaps.isEmpty ? 'none' : report.gaps.join(', ')}',
      )
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int mappedCount,
  required int missingCount,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'design_ai_sync_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'mapped_count': mappedCount,
    'missing_count': missingCount,
    'duration_ms': durationMs,
  };
  await File(_telemetryPath).writeAsString(
    '${jsonEncode(payload)}\n',
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
      'design_ai_sync_engine: chmod failed '
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
    required this.gaps,
  });

  final String mood;
  final List<String> colors;
  final List<String> spacings;
  final List<String> typography;
  final List<String> gaps;
}

class _VisualTokens {
  const _VisualTokens({
    this.colorTokens = const {},
    this.spacingTokens = const {},
  });

  final Set<String> colorTokens;
  final Set<String> spacingTokens;
}
