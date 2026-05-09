// Visual Retrospective Audit (Stage Φ-L)
// Pure Dart CLI: scans lib/ui_v3 for visual theme usage vs tokens.
// Outputs ranked issues + recommendations.
// Telemetry event: visual_retrospective_completed
// ASCII-only logs.

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  final sw = Stopwatch()..start();
  final themePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
  final rootDir = Directory('lib/ui_v3');
  if (!rootDir.existsSync()) {
    stderr.writeln('ERROR: lib/ui_v3 not found');
    exit(2);
  }

  final themeSource = await _readFile(themePath);
  final tokens = _extractTokens(themeSource);
  final files = _dartFiles(rootDir);

  final issues = <_Issue>[];
  for (final f in files) {
    final content = await _readFile(f.path);
    issues.addAll(_analyzeFile(f.path, content, tokens));
  }

  // Rank issues: severity (HIGH > MEDIUM > LOW), then frequency desc
  issues.sort((a, b) {
    final sev = _severityRank(b.severity).compareTo(_severityRank(a.severity));
    if (sev != 0) return sev;
    return b.count.compareTo(a.count);
  });

  final recommendations = _deriveRecommendations(issues);

  final reportSb = StringBuffer()
    ..writeln('# Visual Retrospective Summary')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('\n## Token Inventory')
    ..writeln('- Colors: ${tokens.colors.length}')
    ..writeln('- Spacing: ${tokens.spacing.length}')
    ..writeln('- Durations: ${tokens.durations.length}')
    ..writeln('\n## Ranked Issues')
    ..writeln('| Severity | Count | Pattern | Example File | Suggested Fix |')
    ..writeln('| -------- | ----- | ------- | ------------ | ------------- |');

  for (final issue in issues.take(60)) {
    reportSb..writeln(
      '| ${issue.severity} | ${issue.count} | `${issue.pattern}` | `${issue.file}` | ${issue.fix} |',
    );
  }

  reportSb
    ..writeln('\n## Recommendations')
    ..writeln('| Priority | Recommendation | Rationale |')
    ..writeln('| -------- | -------------- | --------- |');
  for (final r in recommendations) {
    reportSb.writeln('| ${r.priority} | ${r.text} | ${r.reason} |');
  }

  reportSb
    ..writeln('\n## Summary Metrics')
    ..writeln('- Total files scanned: ${files.length}')
    ..writeln('- Issues found: ${issues.length}')
    ..writeln(
      '- Unique patterns: ${issues.map((e) => e.pattern).toSet().length}',
    )
    ..writeln('- Recommendations: ${recommendations.length}')
    ..writeln('\n*End of report*');

  var outPath = 'release/_reports/visual_retrospective_summary.md';
  try {
    await File(outPath).writeAsString(reportSb.toString());
  } catch (_) {
    outPath = 'release/_exports/visual_retrospective_summary.md';
    await File(outPath).writeAsString(reportSb.toString());
  }

  final telemetry = {
    'event': 'visual_retrospective_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'issues_found': issues.length,
    'recommendations': recommendations.length,
    'duration_ms': sw.elapsedMilliseconds,
  };
  final telemetryPath = 'release/_exports/visual_retrospective_telemetry.jsonl';
  await File(
    telemetryPath,
  ).writeAsString(jsonEncode(telemetry) + '\n', mode: FileMode.append);

  print('Visual retrospective audit complete');
  print('Report: ' + outPath);
  print('Issues: ${issues.length}');
  print('Recommendations: ${recommendations.length}');
  print('Duration ms: ${sw.elapsedMilliseconds}');
}

Future<String> _readFile(String path) async {
  try {
    return await File(path).readAsString();
  } catch (_) {
    return '';
  }
}

Iterable<File> _dartFiles(Directory d) sync* {
  for (final entity in d.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      if (entity.path.contains('/theme/')) continue; // skip theme file itself
      yield entity;
    }
  }
}

class _Tokens {
  _Tokens({
    required this.colors,
    required this.spacing,
    required this.durations,
  });
  final Set<String> colors;
  final Set<String> spacing;
  final Set<String> durations;
}

_Tokens _extractTokens(String source) {
  final colorRegex = RegExp(r'static const Color (\w+)');
  final spacingRegex = RegExp(r'static const double (spacing\w+)');
  final durationRegex = RegExp(r'static const Duration (\w+)');
  final colors = <String>{};
  final spacing = <String>{};
  final durations = <String>{};
  for (final m in colorRegex.allMatches(source)) {
    colors.add(m.group(1)!);
  }
  for (final m in spacingRegex.allMatches(source)) {
    spacing.add(m.group(1)!);
  }
  for (final m in durationRegex.allMatches(source)) {
    durations.add(m.group(1)!);
  }
  return _Tokens(colors: colors, spacing: spacing, durations: durations);
}

class _Issue {
  _Issue({
    required this.file,
    required this.pattern,
    required this.count,
    required this.severity,
    required this.fix,
  });
  final String file;
  final String pattern;
  final int count;
  final String severity; // HIGH / MEDIUM / LOW
  final String fix;
}

List<_Issue> _analyzeFile(String path, String content, _Tokens tokens) {
  final issues = <_Issue>[];
  final lines = content.split('\n');
  final rawHex = RegExp(r'0xFF[0-9A-Fa-f]{6}');
  final hardSpacing = RegExp(
    r'EdgeInsets(\.all|\.symmetric|\.only)?\([^)]*([1-9][0-9]?\.?0?)',
  );
  final hardDuration = RegExp(
    r'Duration\(milliseconds: (?!1[58]0|200|250|260|420)[0-9]{2,4}\)',
  );

  int hexCount = 0;
  int spacingCount = 0;
  int durationCount = 0;

  for (final line in lines) {
    if (rawHex.hasMatch(line) && !tokens.colors.any(line.contains)) {
      hexCount++;
    }
    if (hardSpacing.hasMatch(line) && !tokens.spacing.any(line.contains)) {
      spacingCount++;
    }
    if (hardDuration.hasMatch(line) && !tokens.durations.any(line.contains)) {
      durationCount++;
    }
  }

  if (hexCount > 0) {
    issues.add(
      _Issue(
        file: path,
        pattern: 'inline_hex_colors',
        count: hexCount,
        severity: hexCount > 3 ? 'HIGH' : 'MEDIUM',
        fix: 'Replace with VisualThemeV3.<colorToken>',
      ),
    );
  }
  if (spacingCount > 0) {
    issues.add(
      _Issue(
        file: path,
        pattern: 'hard_coded_spacing',
        count: spacingCount,
        severity: spacingCount > 4 ? 'HIGH' : 'MEDIUM',
        fix: 'Use VisualThemeV3.spacing* tokens',
      ),
    );
  }
  if (durationCount > 0) {
    issues.add(
      _Issue(
        file: path,
        pattern: 'non_token_duration',
        count: durationCount,
        severity: 'LOW',
        fix: 'Use VisualThemeV3.motion* or speed* tokens',
      ),
    );
  }

  return issues;
}

int _severityRank(String s) {
  switch (s) {
    case 'HIGH':
      return 3;
    case 'MEDIUM':
      return 2;
    case 'LOW':
      return 1;
    default:
      return 0;
  }
}

class _Recommendation {
  _Recommendation({
    required this.priority,
    required this.text,
    required this.reason,
  });
  final String priority; // P1/P2/P3
  final String text;
  final String reason;
}

List<_Recommendation> _deriveRecommendations(List<_Issue> issues) {
  final recs = <_Recommendation>[];
  final byPattern = <String, List<_Issue>>{};
  for (final i in issues) {
    byPattern.putIfAbsent(i.pattern, () => []).add(i);
  }

  if (byPattern.containsKey('inline_hex_colors')) {
    final total = byPattern['inline_hex_colors']!.fold<int>(
      0,
      (a, b) => a + b.count,
    );
    recs.add(
      _Recommendation(
        priority: total > 12 ? 'P1' : 'P2',
        text: 'Refactor inline hex colors to central tokens',
        reason:
            '$total inline hex occurrences reduce consistency and risk theme divergence',
      ),
    );
  }
  if (byPattern.containsKey('hard_coded_spacing')) {
    final total = byPattern['hard_coded_spacing']!.fold<int>(
      0,
      (a, b) => a + b.count,
    );
    recs.add(
      _Recommendation(
        priority: total > 15 ? 'P1' : 'P2',
        text: 'Normalize spacing to VisualThemeV3.spacing tokens',
        reason: '$total spacing literals impact layout rhythm',
      ),
    );
  }
  if (byPattern.containsKey('non_token_duration')) {
    final total = byPattern['non_token_duration']!.fold<int>(
      0,
      (a, b) => a + b.count,
    );
    recs.add(
      _Recommendation(
        priority: 'P3',
        text: 'Unify motion durations with motion/speed tokens',
        reason: '$total custom durations fragment motion language',
      ),
    );
  }

  // Sort recommendations by priority
  recs.sort((a, b) => a.priority.compareTo(b.priority));
  return recs;
}
