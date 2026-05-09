import 'dart:convert';
import 'dart:io';

const String _uiRoot = 'lib/ui_v3';
const String _manifestPath =
    'release/_reports/design_consolidation_manifest.md';
const String _reportPath = 'release/_reports/visual_cohesion_v3_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final manifest = await _parseManifest();
  final files = await _collectDartFiles();
  if (files.isEmpty) {
    stdout.writeln('visual_cohesion_audit_v3: no ui_v3 files found.');
    return;
  }

  final audits = <_FileAudit>[];
  for (final file in files) {
    audits.add(await _auditFile(file, manifest));
  }

  final summary = _summarize(audits);
  await _withReportsWritable(() async {
    await _writeSummary(summary, manifest);
    await _appendTelemetry(
      coveragePct: summary.overallCoverage,
      issues: summary.totalIssues,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'visual_cohesion_audit_v3: scanned ${files.length} files, '
    '${summary.totalIssues} issues.',
  );
}

Future<_DesignManifest> _parseManifest() async {
  final file = File(_manifestPath);
  final colorTokens = <String>{};
  final colorHexes = <String>{};
  final spacingTokens = <String>{};
  final spacingValues = <double>{};
  final textStyles = <String>{};
  if (!await file.exists()) {
    return _DesignManifest(
      colorTokens: colorTokens,
      colorHexes: colorHexes,
      spacingTokens: spacingTokens,
      spacingValues: spacingValues,
      textStyles: textStyles,
    );
  }
  final lines = await file.readAsLines();
  String section = '';
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('##')) {
      section = line;
      continue;
    }
    if (!line.startsWith('-')) continue;
    switch (section) {
      case '## VisualThemeV3 Colors':
        final parts = line.substring(1).split('=');
        if (parts.length >= 2) {
          final token = parts[0].trim();
          colorTokens.add(token);
          final hexMatch = RegExp(r'0x[0-9a-fA-F]{8}').firstMatch(parts[1]);
          if (hexMatch != null) {
            colorHexes.add(hexMatch.group(0)!.toUpperCase());
          }
        }
        break;
      case '## VisualThemeV3 Spacing Tokens':
        final parts = line.substring(1).split('=');
        if (parts.length >= 2) {
          final token = parts[0].trim();
          spacingTokens.add(token);
          final value = double.tryParse(parts[1].trim());
          if (value != null) spacingValues.add(value);
        }
        break;
      case '## AppTextStyles':
        textStyles.add(line.substring(1).trim());
        break;
    }
  }
  return _DesignManifest(
    colorTokens: colorTokens,
    colorHexes: colorHexes,
    spacingTokens: spacingTokens,
    spacingValues: spacingValues,
    textStyles: textStyles,
  );
}

Future<List<String>> _collectDartFiles() async {
  final root = Directory(_uiRoot);
  if (!await root.exists()) return const [];
  final files = <String>[];
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.contains('/theme/')) continue;
      files.add(entity.path);
    }
  }
  files.sort();
  return files;
}

Future<_FileAudit> _auditFile(String path, _DesignManifest manifest) async {
  final lines = await File(path).readAsLines();
  var hasVisualImport = false;
  var hasTextStyleImport = false;
  var usesVisualTheme = false;
  var usesTextStyles = false;

  final audit = _FileAudit(path);
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();
    if (trimmed.startsWith('import')) {
      if (trimmed.contains('visual_theme_v3.dart')) {
        hasVisualImport = true;
      }
      if (trimmed.contains('app_text_styles.dart')) {
        hasTextStyleImport = true;
      }
    }
    if (line.contains('VisualThemeV3')) {
      usesVisualTheme = true;
    }
    if (line.contains('AppTextStyles')) {
      usesTextStyles = true;
    }

    _processColor(line, i, audit, manifest);
    _processSpacing(line, i, audit, manifest);
    _processTypography(line, i, audit, manifest);
  }

  if (usesVisualTheme && !hasVisualImport) {
    audit.missingImports.add('VisualThemeV3');
  }
  if (usesTextStyles && !hasTextStyleImport) {
    audit.missingImports.add('AppTextStyles');
  }
  return audit;
}

void _processColor(
  String line,
  int lineIndex,
  _FileAudit audit,
  _DesignManifest manifest,
) {
  final colorTokenUsed = manifest.colorTokens.any(
    (token) => line.contains('VisualThemeV3.$token'),
  );
  if (colorTokenUsed) {
    audit.colorsTotal += 1;
    audit.colorsTokenized += 1;
  }

  final literalMatches = RegExp(
    r'Color\((0x[0-9a-fA-F]{8})\)',
  ).allMatches(line);
  final namedMatches = RegExp(r'Colors\.[a-zA-Z]+').allMatches(line);
  if (literalMatches.isEmpty && namedMatches.isEmpty) return;

  final matches = [
    ...literalMatches.map((m) => m.group(1)!),
    ...namedMatches.map((m) => m.group(0)!),
  ];
  for (final match in matches) {
    audit.colorsTotal += 1;
    final normalized = match.toUpperCase();
    final isManifest = manifest.colorHexes.contains(normalized);
    audit.colorIssues.add(
      '${audit.path}:${lineIndex + 1} -> $match'
      '${isManifest ? ' (manifest color but raw literal)' : ''}',
    );
  }
}

void _processSpacing(
  String line,
  int lineIndex,
  _FileAudit audit,
  _DesignManifest manifest,
) {
  final spacingTokenUsed = manifest.spacingTokens.any(
    (token) => line.contains('VisualThemeV3.$token'),
  );
  if (spacingTokenUsed) {
    audit.spacingTotal += 1;
    audit.spacingTokenized += 1;
  }
  if (!_isSpacingContext(line)) return;

  final numericMatch = RegExp(r'\b\d+(?:\.\d+)?\b').firstMatch(line);
  if (numericMatch == null) return;

  audit.spacingTotal += 1;
  final value = double.tryParse(numericMatch.group(0)!);
  final isManifestValue =
      value != null &&
      manifest.spacingValues.any((tokenVal) => (tokenVal - value).abs() < 0.01);
  audit.spacingIssues.add(
    '${audit.path}:${lineIndex + 1} -> ${numericMatch.group(0)}'
    '${isManifestValue ? ' (matches token value)' : ''}',
  );
}

bool _isSpacingContext(String line) {
  final lowered = line.toLowerCase();
  return lowered.contains('edgeinsets') ||
      lowered.contains('sizedbox') ||
      lowered.contains('padding:') ||
      lowered.contains('margin:') ||
      lowered.contains('spacing:');
}

void _processTypography(
  String line,
  int lineIndex,
  _FileAudit audit,
  _DesignManifest manifest,
) {
  final hasToken = manifest.textStyles.any(
    (style) => line.contains('AppTextStyles.$style'),
  );
  if (hasToken) {
    audit.typographyTotal += 1;
    audit.typographyTokenized += 1;
    return;
  }

  final hasTextStyle =
      line.contains('TextStyle(') || line.contains('TextStyle ');
  if (!hasTextStyle) return;

  audit.typographyTotal += 1;
  audit.typographyIssues.add('${audit.path}:${lineIndex + 1} -> TextStyle');
}

_Summary _summarize(List<_FileAudit> audits) {
  final colorsTotal = audits.fold<int>(0, (sum, a) => sum + a.colorsTotal);
  final colorsTokenized = audits.fold<int>(
    0,
    (sum, a) => sum + a.colorsTokenized,
  );
  final spacingTotal = audits.fold<int>(0, (sum, a) => sum + a.spacingTotal);
  final spacingTokenized = audits.fold<int>(
    0,
    (sum, a) => sum + a.spacingTokenized,
  );
  final typographyTotal = audits.fold<int>(
    0,
    (sum, a) => sum + a.typographyTotal,
  );
  final typographyTokenized = audits.fold<int>(
    0,
    (sum, a) => sum + a.typographyTokenized,
  );

  final totalIssues = audits.fold<int>(
    0,
    (sum, a) =>
        sum +
        a.colorIssues.length +
        a.spacingIssues.length +
        a.typographyIssues.length +
        a.missingImports.length,
  );

  final totalElements = colorsTotal + spacingTotal + typographyTotal;
  final totalTokenized =
      colorsTokenized + spacingTokenized + typographyTokenized;

  double coveragePct = 100.0;
  if (totalElements > 0) {
    coveragePct = (totalTokenized / totalElements) * 100.0;
  }

  return _Summary(
    audits: audits,
    colorsTotal: colorsTotal,
    colorsTokenized: colorsTokenized,
    spacingTotal: spacingTotal,
    spacingTokenized: spacingTokenized,
    typographyTotal: typographyTotal,
    typographyTokenized: typographyTokenized,
    totalIssues: totalIssues,
    overallCoverage: double.parse(coveragePct.toStringAsFixed(2)),
  );
}

Future<void> _writeSummary(_Summary summary, _DesignManifest manifest) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION V3 SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Files scanned: ${summary.audits.length}')
    ..writeln(
      'Overall coverage: ${summary.overallCoverage.toStringAsFixed(2)}%',
    )
    ..writeln(
      'Color coverage: ${_pct(summary.colorsTokenized, summary.colorsTotal)} '
      '(${summary.colorsTokenized}/${summary.colorsTotal})',
    )
    ..writeln(
      'Spacing coverage: ${_pct(summary.spacingTokenized, summary.spacingTotal)} '
      '(${summary.spacingTokenized}/${summary.spacingTotal})',
    )
    ..writeln(
      'Typography coverage: ${_pct(summary.typographyTokenized, summary.typographyTotal)} '
      '(${summary.typographyTokenized}/${summary.typographyTotal})',
    )
    ..writeln();

  final colorIssues = summary.audits.expand((a) => a.colorIssues).toList();
  final spacingIssues = summary.audits.expand((a) => a.spacingIssues).toList();
  final typographyIssues = summary.audits
      .expand((a) => a.typographyIssues)
      .toList();
  final missingImports = summary.audits
      .where((a) => a.missingImports.isNotEmpty)
      .map((a) => '${a.path} -> ${a.missingImports.join(', ')}')
      .toList();

  if (missingImports.isNotEmpty) {
    buffer
      ..writeln('Missing token imports')
      ..writeln('- ' + missingImports.join('\n- '))
      ..writeln();
  }

  if (colorIssues.isNotEmpty) {
    buffer
      ..writeln('Raw color values (${colorIssues.length})')
      ..writeln('- ' + colorIssues.take(20).join('\n- '))
      ..writeln();
    if (colorIssues.length > 20) {
      buffer.writeln('… ${colorIssues.length - 20} more');
      buffer.writeln();
    }
  }

  if (spacingIssues.isNotEmpty) {
    buffer
      ..writeln('Raw spacing values (${spacingIssues.length})')
      ..writeln('- ' + spacingIssues.take(20).join('\n- '))
      ..writeln();
    if (spacingIssues.length > 20) {
      buffer.writeln('… ${spacingIssues.length - 20} more');
      buffer.writeln();
    }
  }

  if (typographyIssues.isNotEmpty) {
    buffer
      ..writeln('Custom TextStyle usages (${typographyIssues.length})')
      ..writeln('- ' + typographyIssues.take(20).join('\n- '))
      ..writeln();
    if (typographyIssues.length > 20) {
      buffer.writeln('… ${typographyIssues.length - 20} more');
      buffer.writeln();
    }
  }

  buffer
    ..writeln('Manifest tokens tracked:')
    ..writeln('- Colors: ${manifest.colorTokens.join(', ')}')
    ..writeln('- Spacing: ${manifest.spacingTokens.join(', ')}')
    ..writeln('- Text styles: ${manifest.textStyles.join(', ')}');

  await File(_reportPath).writeAsString(buffer.toString());
}

String _pct(int tokenized, int total) {
  if (total == 0) return 'n/a';
  final pct = (tokenized / total) * 100.0;
  return '${pct.toStringAsFixed(1)}%';
}

Future<void> _appendTelemetry({
  required double coveragePct,
  required int issues,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_v3_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'coverage_pct': double.parse(coveragePct.toStringAsFixed(2)),
    'issues': issues,
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
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'visual_cohesion_audit_v3: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _DesignManifest {
  const _DesignManifest({
    required this.colorTokens,
    required this.colorHexes,
    required this.spacingTokens,
    required this.spacingValues,
    required this.textStyles,
  });

  final Set<String> colorTokens;
  final Set<String> colorHexes;
  final Set<String> spacingTokens;
  final Set<double> spacingValues;
  final Set<String> textStyles;
}

class _FileAudit {
  _FileAudit(this.path);

  final String path;
  int colorsTotal = 0;
  int colorsTokenized = 0;
  int spacingTotal = 0;
  int spacingTokenized = 0;
  int typographyTotal = 0;
  int typographyTokenized = 0;
  final List<String> colorIssues = [];
  final List<String> spacingIssues = [];
  final List<String> typographyIssues = [];
  final List<String> missingImports = [];
}

class _Summary {
  const _Summary({
    required this.audits,
    required this.colorsTotal,
    required this.colorsTokenized,
    required this.spacingTotal,
    required this.spacingTokenized,
    required this.typographyTotal,
    required this.typographyTokenized,
    required this.totalIssues,
    required this.overallCoverage,
  });

  final List<_FileAudit> audits;
  final int colorsTotal;
  final int colorsTokenized;
  final int spacingTotal;
  final int spacingTokenized;
  final int typographyTotal;
  final int typographyTokenized;
  final int totalIssues;
  final double overallCoverage;
}
