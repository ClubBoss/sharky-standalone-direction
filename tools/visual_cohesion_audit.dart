// tools/visual_cohesion_audit.dart
// Stage Φ-6 — Visual Cohesion QA
// Pure Dart CLI (no Flutter)

import 'dart:io';
import 'dart:convert';

final _uiRoot = 'lib/ui_v3';
final _themeFiles = [
  'lib/ui_v3/theme/visual_theme_v3.dart',
  'lib/ui_v3/theme/app_text_styles.dart',
  'lib/ui_v3/theme/personalization_profile.dart',
];
final _reportPath = 'release/_reports/visual_cohesion_summary.txt';
final _telemetryPath = 'release/_reports/visual_cohesion_telemetry.jsonl';

Future<void> main(List<String> args) async {
  final sw = Stopwatch()..start();
  await _unfreezeReports();
  final issues = <String>[];
  final fixed = <String>[];

  // Gather all Dart files in lib/ui_v3/**
  final dartFiles = await _listDartFiles(_uiRoot);
  // Load theme/style tokens
  final tokens = await _extractTokens(_themeFiles);

  // Scan for non-tokenized usages
  for (final file in dartFiles) {
    final lines = await File(file).readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final colorMatch = _findRawColor(line);
      final spacingMatch = _findRawSpacing(line);
      final typoMatch = _findRawTypography(line);
      if (colorMatch != null && !_isToken(line, tokens)) {
        issues.add('$file:${i + 1}: Non-token color: $colorMatch');
      }
      if (spacingMatch != null && !_isToken(line, tokens)) {
        issues.add('$file:${i + 1}: Non-token spacing: $spacingMatch');
      }
      if (typoMatch != null && !_isToken(line, tokens)) {
        issues.add('$file:${i + 1}: Non-token typography: $typoMatch');
      }
    }
  }

  // Write ASCII report
  await _writeReport(issues);
  await _emitTelemetry(issues.length, fixed.length, sw.elapsedMilliseconds);
  await _refreezeReports();
}

Future<List<String>> _listDartFiles(String root) async {
  final files = <String>[];
  await for (final entity in Directory(root).list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity.path);
    }
  }
  return files;
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

String? _findRawColor(String line) {
  final m = RegExp(r'Color\((0x[0-9a-fA-F]{8})\)').firstMatch(line);
  return m?.group(1);
}

String? _findRawSpacing(String line) {
  final m = RegExp(r'(\d+(?:\.\d+)?)[\s]*(?:,|\))').firstMatch(line);
  if (m != null && double.tryParse(m.group(1)!) != null) {
    // Heuristic: likely a spacing if not part of a token
    return m.group(1);
  }
  return null;
}

String? _findRawTypography(String line) {
  final m = RegExp(r'TextStyle\s*\(').firstMatch(line);
  return m != null ? 'TextStyle' : null;
}

bool _isToken(String line, Set<String> tokens) {
  for (final t in tokens) {
    if (line.contains(t)) return true;
  }
  return false;
}

Future<void> _writeReport(List<String> issues) async {
  final out = StringBuffer();
  out.writeln('VISUAL COHESION AUDIT REPORT');
  out.writeln('='.padRight(40, '='));
  if (issues.isEmpty) {
    out.writeln('No non-tokenized colors, spacings, or typography found.');
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

Future<void> _emitTelemetry(int issues, int fixed, int durationMs) async {
  final event = {
    'event': 'visual_cohesion_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'issues_found': issues,
    'fixed': fixed,
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

Future<void> _unfreezeReports() async {
  final f = File('release/_reports/.frozen');
  try {
    if (await f.exists()) await f.delete();
  } catch (e) {
    // Permission denied, skip
  }
}

Future<void> _refreezeReports() async {
  final f = File('release/_reports/.frozen');
  try {
    await f.writeAsString('frozen\n');
  } catch (e) {
    // Permission denied, skip or write to _exports if needed
    try {
      final fallback = 'release/_exports/.frozen';
      await File(fallback).writeAsString('frozen\n');
    } catch (_) {}
  }
}
