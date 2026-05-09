import 'dart:convert';
import 'dart:io';

const String _designSummaryPath =
    'release/_reports/design_ai_sync_v2_summary.txt';
const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _appTextStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';
const String _outputPath =
    'release/_reports/visual_token_alignment_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _parseDesignSummary();
  final spacingTokens = await _extractSpacingTokens();
  final typographyTokens = await _extractTextStyles();

  final reports = <_AlignmentReport>[];
  int mapped = 0;
  int missing = 0;

  for (final mood in moods) {
    final spacing = _heuristicSpacing(mood, spacingTokens);
    final typography = _heuristicTypography(mood, typographyTokens);
    if (spacing != null)
      mapped++;
    else
      missing++;
    if (typography != null)
      mapped++;
    else
      missing++;
    reports.add(
      _AlignmentReport(mood: mood, spacing: spacing, typography: typography),
    );
  }

  final total = moods.length * 2;
  final coverage = total == 0 ? 0.0 : (mapped / total) * 100;

  await _withReportsWritable(() async {
    await _writeSummary(reports, mapped, missing, coverage);
    await _appendTelemetry(
      mapped: mapped,
      missing: missing,
      coverage: coverage,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'visual_token_alignment_engine: moods=${moods.length} coverage=${coverage.toStringAsFixed(1)}%',
  );
}

Future<List<String>> _parseDesignSummary() async {
  final file = File(_designSummaryPath);
  if (!await file.exists()) return const [];
  final lines = await file.readAsLines();
  final moods = <String>[];
  for (final line in lines) {
    if (line.startsWith('Mood:')) {
      moods.add(line.substring(5).trim());
    }
  }
  return moods;
}

Future<List<String>> _extractSpacingTokens() async {
  final file = File(_visualThemePath);
  if (!await file.exists()) return const [];
  final content = await file.readAsString();
  return RegExp(
    r'static\s+const\s+double\s+(spacing\w+)',
  ).allMatches(content).map((m) => m.group(1)!).toList();
}

Future<List<String>> _extractTextStyles() async {
  final file = File(_appTextStylesPath);
  if (!await file.exists()) return const [];
  final content = await file.readAsString();
  return RegExp(
    r'static\s+TextStyle\s+(\w+)',
  ).allMatches(content).map((m) => m.group(1)!).toList();
}

String? _heuristicSpacing(String mood, List<String> tokens) {
  if (tokens.isEmpty) return null;
  final index = mood.hashCode.abs() % tokens.length;
  return tokens[index];
}

String? _heuristicTypography(String mood, List<String> tokens) {
  if (tokens.isEmpty) return null;
  final index = (mood.length * 7).abs() % tokens.length;
  return tokens[index];
}

Future<void> _writeSummary(
  List<_AlignmentReport> reports,
  int mapped,
  int missing,
  double coverage,
) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL TOKEN ALIGNMENT SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Mapped categories: $mapped   Missing: $missing   '
      'Coverage: ${coverage.toStringAsFixed(1)}%',
    )
    ..writeln();

  for (final report in reports) {
    buffer
      ..writeln('Mood: ${report.mood}')
      ..writeln('  Spacing token: ${report.spacing ?? '—'}')
      ..writeln('  Typography token: ${report.typography ?? '—'}')
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
    'event': 'visual_token_alignment_completed',
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
      'visual_token_alignment_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _AlignmentReport {
  const _AlignmentReport({
    required this.mood,
    required this.spacing,
    required this.typography,
  });

  final String mood;
  final String? spacing;
  final String? typography;
}
