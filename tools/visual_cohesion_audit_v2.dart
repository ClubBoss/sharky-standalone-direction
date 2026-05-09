import 'dart:convert';
import 'dart:io';

const String _uiRoot = 'lib/ui_v3';
const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _textStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';

const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/visual_cohesion_v2_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final files = await _listDartFiles(_uiRoot);
  final colorTokens = await _extractTokens(
    _visualThemePath,
    RegExp(r'static const (?:Color|LinearGradient) (\w+)'),
  );
  final spacingTokens = await _extractTokens(
    _visualThemePath,
    RegExp(r'static const double (spacing\w+)'),
  );
  final typographyTokens = await _extractTokens(
    _textStylesPath,
    RegExp(r'static TextStyle (\w+)'),
  );

  final stats = <_Category, _CategoryStats>{
    _Category.colors: _CategoryStats(tokens: colorTokens),
    _Category.spacing: _CategoryStats(tokens: spacingTokens),
    _Category.typography: _CategoryStats(tokens: typographyTokens),
  };

  for (final file in files) {
    if (file.startsWith('lib/ui_v3/theme/')) {
      continue; // token definitions are allowed to define raw values
    }
    final lines = await File(file).readAsLines();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      _scanColors(file, i, line, stats[_Category.colors]!);
      _scanSpacing(file, i, line, stats[_Category.spacing]!);
      _scanTypography(file, i, line, stats[_Category.typography]!);
    }
  }

  final coverageValues = [
    stats[_Category.colors]!.coverage,
    stats[_Category.spacing]!.coverage,
    stats[_Category.typography]!.coverage,
  ];
  final overallCoverage = coverageValues.isEmpty
      ? 1.0
      : coverageValues.reduce((a, b) => a + b) / coverageValues.length;
  final issues = stats.values.fold<int>(0, (sum, s) => sum + s.rawUsage);

  await _withReportsWritable(() async {
    await _writeSummary(stats, overallCoverage);
    await _appendTelemetry(
      coveragePct: double.parse(overallCoverage.toStringAsFixed(4)),
      issues: issues,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'visual_cohesion_audit_v2: coverage '
    '${(overallCoverage * 100).toStringAsFixed(1)}% with $issues raw issues.',
  );
}

Future<List<String>> _listDartFiles(String root) async {
  final files = <String>[];
  await for (final entity in Directory(root).list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity.path);
    }
  }
  files.sort();
  return files;
}

Future<Set<String>> _extractTokens(String path, RegExp matcher) async {
  final file = File(path);
  if (!await file.exists()) return <String>{};
  final matches = matcher
      .allMatches(await file.readAsString())
      .map((m) => m.group(1))
      .whereType<String>()
      .toSet();
  return matches;
}

void _scanColors(
  String path,
  int lineIndex,
  String line,
  _CategoryStats stats,
) {
  final tokenMatches = _countTokenUsage(line, 'VisualThemeV3', stats.tokens);
  stats.tokenUsage += tokenMatches;

  final hasToken = tokenMatches > 0;
  for (final match in _colorLiteralRegex.allMatches(line)) {
    if (hasToken) continue;
    stats.rawUsage += 1;
    stats.rawDetails.add('$path:${lineIndex + 1}: raw color ${match.group(0)}');
  }
  if (!hasToken && line.contains('Colors.')) {
    stats.rawUsage += 1;
    stats.rawDetails.add(
      '$path:${lineIndex + 1}: uses Material Colors directly',
    );
  }
}

void _scanSpacing(
  String path,
  int lineIndex,
  String line,
  _CategoryStats stats,
) {
  final tokenMatches = _countTokenUsage(line, 'VisualThemeV3', stats.tokens);
  stats.tokenUsage += tokenMatches;
  if (tokenMatches > 0) return;
  for (final pattern in _spacingPatterns) {
    if (pattern.hasMatch(line)) {
      stats.rawUsage += 1;
      stats.rawDetails.add(
        '$path:${lineIndex + 1}: explicit spacing => $line'.trim(),
      );
      break;
    }
  }
}

void _scanTypography(
  String path,
  int lineIndex,
  String line,
  _CategoryStats stats,
) {
  final tokenMatches = _countTokenUsage(line, 'AppTextStyles', stats.tokens);
  stats.tokenUsage += tokenMatches;
  if (tokenMatches > 0) return;
  if (_textStyleRegex.hasMatch(line)) {
    stats.rawUsage += 1;
    stats.rawDetails.add('$path:${lineIndex + 1}: direct TextStyle usage');
  }
}

int _countTokenUsage(String line, String prefix, Set<String> tokens) {
  int count = 0;
  final pattern = RegExp('$prefix\\.(\\w+)');
  for (final match in pattern.allMatches(line)) {
    final token = match.group(1);
    if (token != null && tokens.contains(token)) {
      count++;
    }
  }
  return count;
}

Future<void> _writeSummary(
  Map<_Category, _CategoryStats> stats,
  double overallCoverage,
) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION AUDIT V2')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Scanned root: $_uiRoot')
    ..writeln(
      'Overall coverage: ${(overallCoverage * 100).toStringAsFixed(1)}%',
    )
    ..writeln();

  for (final entry in stats.entries) {
    final category = entry.key;
    final data = entry.value;
    buffer
      ..writeln(
        '${category.label} coverage: '
        '${(data.coverage * 100).toStringAsFixed(1)}% '
        '(${data.tokenUsage} token vs ${data.rawUsage} raw)',
      )
      ..writeln('Top raw entries:');
    if (data.rawDetails.isEmpty) {
      buffer.writeln('- None 🎉');
    } else {
      final subset = data.rawDetails.take(20);
      for (final item in subset) {
        buffer.writeln('- $item');
      }
      if (data.rawDetails.length > 20) {
        buffer.writeln('- ... (${data.rawDetails.length - 20} more)');
      }
    }
    buffer.writeln();
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double coveragePct,
  required int issues,
  required int durationMs,
}) async {
  final event = <String, Object>{
    'event': 'visual_cohesion_v2_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'coverage_pct': coveragePct,
    'issues': issues,
    'duration_ms': durationMs,
  };
  await File(
    _telemetryPath,
  ).writeAsString(jsonEncode(event) + '\n', mode: FileMode.append, flush: true);
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
      'visual_cohesion_audit_v2: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _CategoryStats {
  _CategoryStats({required this.tokens});

  final Set<String> tokens;
  int tokenUsage = 0;
  int rawUsage = 0;
  final List<String> rawDetails = <String>[];

  double get coverage {
    final total = tokenUsage + rawUsage;
    if (total == 0) return 1.0;
    return tokenUsage / total;
  }
}

enum _Category { colors, spacing, typography }

extension on _Category {
  String get label {
    switch (this) {
      case _Category.colors:
        return 'Colors';
      case _Category.spacing:
        return 'Spacing';
      case _Category.typography:
        return 'Typography';
    }
  }
}

final RegExp _colorLiteralRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]{6,8}');
final RegExp _textStyleRegex = RegExp(r'TextStyle\s*\(');

final List<RegExp> _spacingPatterns = <RegExp>[
  RegExp(r'EdgeInsets\.[^;]*\d'),
  RegExp(r'SizedBox\s*\(\s*(?:height|width)\s*:\s*\d'),
  RegExp(r'padding:\s*const\s*EdgeInsets[^;]*\d'),
  RegExp(r'margin:\s*const\s*EdgeInsets[^;]*\d'),
];
