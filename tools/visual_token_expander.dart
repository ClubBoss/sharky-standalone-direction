import 'dart:convert';
import 'dart:io';

const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _textStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';
const String _designSummaryPath = 'release/_reports/design_ai_sync_summary.txt';
const String _alignmentSummaryPath =
    'release/_reports/ai_visual_alignment_summary.txt';
const String _outputPath =
    'release/_reports/visual_token_expansion_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final definedSpacing = await _extractSpacingTokens();
  final definedTypography = await _extractTypographyTokens();
  final referencedSpacing = await _collectReferencedTokens([
    'Spacing:',
    'Spacing tokens:',
  ]);
  final referencedTypography = await _collectReferencedTokens([
    'Typography:',
    'Typography tokens:',
  ]);

  final missingSpacing = referencedSpacing.difference(definedSpacing);
  final missingTypography = referencedTypography.difference(definedTypography);

  final spacingPlaceholders = _buildSpacingPlaceholders(missingSpacing);
  final typographyPlaceholders = _buildTypographyPlaceholders(
    missingTypography,
  );

  await _withReportsWritable(() async {
    await _writeSummary(
      definedSpacing: definedSpacing,
      definedTypography: definedTypography,
      referencedSpacing: referencedSpacing,
      referencedTypography: referencedTypography,
      spacingPlaceholders: spacingPlaceholders,
      typographyPlaceholders: typographyPlaceholders,
    );
    await _appendTelemetry(
      addedSpacing: missingSpacing.length,
      addedTypography: missingTypography.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'visual_token_expander: spacing+${missingSpacing.length} '
    'typography+${missingTypography.length}',
  );
}

Future<Set<String>> _extractSpacingTokens() async {
  final file = File(_visualThemePath);
  if (!await file.exists()) return const {};
  final content = await file.readAsString();
  final pattern = RegExp(r'static\s+const\s+double\s+(spacing\w+)\s*=');
  return {for (final match in pattern.allMatches(content)) match.group(1)!};
}

Future<Set<String>> _extractTypographyTokens() async {
  final file = File(_textStylesPath);
  if (!await file.exists()) return const {};
  final content = await file.readAsString();
  final pattern = RegExp(r'static\s+TextStyle\s+(\w+)\(');
  return {for (final match in pattern.allMatches(content)) match.group(1)!};
}

Future<Set<String>> _collectReferencedTokens(List<String> prefixes) async {
  final sources = <String>[];
  for (final path in [_designSummaryPath, _alignmentSummaryPath]) {
    final file = File(path);
    if (await file.exists()) {
      sources.add(await file.readAsString());
    }
  }
  final references = <String>{};
  for (final source in sources) {
    final lines = source.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (prefixes.any(trimmed.startsWith)) {
        final parts = trimmed.split(':');
        if (parts.length < 2) continue;
        final tokens = parts.sublist(1).join(':').trim();
        if (tokens == '—' || tokens.isEmpty) continue;
        references.addAll(
          tokens
              .split(',')
              .map((token) => token.trim())
              .where((token) => token.isNotEmpty),
        );
      }
    }
  }
  return references;
}

List<String> _buildSpacingPlaceholders(Set<String> tokens) {
  if (tokens.isEmpty) return const [];
  final template =
      'static const double {token} = spacingM; // placeholder TODO';
  return tokens
      .map((token) => template.replaceFirst('{token}', token))
      .toList();
}

List<String> _buildTypographyPlaceholders(Set<String> tokens) {
  if (tokens.isEmpty) return const [];
  final template = '''
static TextStyle {token}(BuildContext context) {
  final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}''';
  return tokens.map((token) => template.replaceAll('{token}', token)).toList();
}

Future<void> _writeSummary({
  required Set<String> definedSpacing,
  required Set<String> definedTypography,
  required Set<String> referencedSpacing,
  required Set<String> referencedTypography,
  required List<String> spacingPlaceholders,
  required List<String> typographyPlaceholders,
}) async {
  final buffer = StringBuffer()
    ..writeln('VISUAL TOKEN EXPANSION SUMMARY')
    ..writeln('===============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Spacing tokens: defined=${definedSpacing.length} '
      'referenced=${referencedSpacing.length} '
      'missing=${spacingPlaceholders.length}',
    )
    ..writeln(
      'Typography tokens: defined=${definedTypography.length} '
      'referenced=${referencedTypography.length} '
      'missing=${typographyPlaceholders.length}',
    )
    ..writeln();

  if (spacingPlaceholders.isEmpty && typographyPlaceholders.isEmpty) {
    buffer.writeln(
      'All referenced tokens exist in VisualThemeV3/AppTextStyles.',
    );
  } else {
    if (spacingPlaceholders.isNotEmpty) {
      buffer
        ..writeln('Placeholder spacing tokens:')
        ..writeln(spacingPlaceholders.map((line) => '  $line').join('\n'))
        ..writeln();
    }
    if (typographyPlaceholders.isNotEmpty) {
      buffer
        ..writeln('Placeholder typography tokens:')
        ..writeln(
          typographyPlaceholders
              .map((block) => '  ' + block.replaceAll('\n', '\n  '))
              .join('\n\n'),
        )
        ..writeln();
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int addedSpacing,
  required int addedTypography,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'visual_token_expanded',
    'timestamp': DateTime.now().toIso8601String(),
    'added_spacing': addedSpacing,
    'added_typography': addedTypography,
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
      'visual_token_expander: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
