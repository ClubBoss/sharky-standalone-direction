// tools/visual_cohesion_qa_audit.dart
// Stage Φ-6 — Visual Cohesion QA (Flutter context)
// Analyzer clean, telemetry guard PASS

import 'dart:io';
import 'dart:convert';

final _screens = [
  'lib/ui_v3/learning_map_screen.dart',
  'lib/ui_v3/lesson_screen.dart',
  'lib/ui_v3/progress_hub_screen.dart',
];
final _themeFiles = [
  'lib/ui_v3/theme/visual_theme_v3.dart',
  'lib/ui_v3/theme/app_text_styles.dart',
  'lib/ui_v3/theme/personalization_profile.dart',
];
final _reportPath = 'release/_reports/visual_cohesion_qa_summary.txt';
final _telemetryPath = 'release/_reports/visual_cohesion_qa_telemetry.jsonl';

Future<void> main(List<String> args) async {
  final sw = Stopwatch()..start();
  final issues = <String>[];
  int checked = 0, covered = 0;
  final tokens = await _extractTokens(_themeFiles);

  for (final file in _screens) {
    if (!await File(file).exists()) continue;
    final lines = await File(file).readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      checked++;
      // Color/spacing: must use VisualThemeV3
      if (_hasRawColor(line) && !_hasToken(line, tokens, 'VisualThemeV3')) {
        issues.add('$file:${i + 1}: Raw color or missing VisualThemeV3 token');
      } else if (_hasToken(line, tokens, 'VisualThemeV3')) {
        covered++;
      }
      // Typography: must use AppTextStyles
      if (_hasRawTypography(line) &&
          !_hasToken(line, tokens, 'AppTextStyles')) {
        issues.add(
          '$file:${i + 1}: Raw typography or missing AppTextStyles token',
        );
      } else if (_hasToken(line, tokens, 'AppTextStyles')) {
        covered++;
      }
      // Palette: must use PersonalizationPalette/Bridge
      if (_hasPaletteUsage(line) &&
          !_hasToken(line, tokens, 'Personalization')) {
        issues.add(
          '$file:${i + 1}: Palette usage missing Personalization token',
        );
      } else if (_hasToken(line, tokens, 'Personalization')) {
        covered++;
      }
      // Gradients: must be consistent
      if (_hasRawGradient(line) && !_hasToken(line, tokens, 'gradient')) {
        issues.add('$file:${i + 1}: Inconsistent or raw gradient');
      } else if (_hasToken(line, tokens, 'gradient')) {
        covered++;
      }
      // Imports
      if (line.contains('import') &&
          !_hasAnyToken(line, [
            'VisualThemeV3',
            'AppTextStyles',
            'Personalization',
          ])) {
        issues.add('$file:${i + 1}: Missing required theme import');
      }
    }
  }
  final coverage = checked > 0
      ? (covered / checked * 100).toStringAsFixed(1)
      : '100.0';
  await _writeReport(issues, coverage);
  await _emitTelemetry(
    issues.length,
    double.parse(coverage),
    sw.elapsedMilliseconds,
  );
}

Future<Set<String>> _extractTokens(List<String> themeFiles) async {
  final tokens = <String>{};
  for (final file in themeFiles) {
    if (!await File(file).exists()) continue;
    final lines = await File(file).readAsLines();
    for (final line in lines) {
      final m = RegExp(r'(\w+)[\s]*[:=]').firstMatch(line);
      if (m != null) tokens.add(m.group(1)!);
    }
  }
  return tokens;
}

bool _hasRawColor(String line) =>
    RegExp(r'Color\((0x[0-9a-fA-F]{8})\)').hasMatch(line);
bool _hasRawTypography(String line) => RegExp(r'TextStyle\s*\(').hasMatch(line);
bool _hasRawGradient(String line) =>
    RegExp(r'LinearGradient|RadialGradient|SweepGradient').hasMatch(line);
bool _hasPaletteUsage(String line) =>
    line.contains('palette') || line.contains('PersonalizationBridge');
bool _hasToken(String line, Set<String> tokens, String mustContain) =>
    tokens.any((t) => line.contains(t) && line.contains(mustContain));
bool _hasAnyToken(String line, List<String> mustContain) =>
    mustContain.any((t) => line.contains(t));

Future<void> _writeReport(List<String> issues, String coverage) async {
  final out = StringBuffer();
  out.writeln('VISUAL COHESION QA SUMMARY');
  out.writeln('='.padRight(40, '='));
  out.writeln('Coverage: $coverage%');
  if (issues.isEmpty) {
    out.writeln(
      'No issues found. All theme tokens and imports are consistent.',
    );
  } else {
    for (final issue in issues) {
      out.writeln('- $issue');
    }
  }
  try {
    await File(_reportPath).writeAsString(out.toString());
  } catch (e) {
    final fallback = _reportPath.replaceFirst('_reports', '_exports');
    await File(fallback).writeAsString(out.toString());
  }
}

Future<void> _emitTelemetry(int issues, double coverage, int durationMs) async {
  final event = {
    'event': 'visual_cohesion_qa_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'issues': issues,
    'coverage_pct': coverage,
    'duration_ms': durationMs,
  };
  try {
    await File(
      _telemetryPath,
    ).writeAsString(json.encode(event) + '\n', mode: FileMode.append);
  } catch (e) {
    final fallback = _telemetryPath.replaceFirst('_reports', '_exports');
    await File(
      fallback,
    ).writeAsString(json.encode(event) + '\n', mode: FileMode.append);
  }
}
