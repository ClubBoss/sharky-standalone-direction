import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _colorsPath = 'lib/theme/app_colors.dart';
const String _spacingPath = 'lib/theme/app_spacing.dart';
const String _spacingFallbackPath = 'lib/theme/theme_v2.dart';
const String _typographyPath = 'lib/theme/app_text_styles.dart';
const String _typographyFallbackPath = 'lib/theme/app_typography.dart';
const String _outputPath = 'release/_reports/adaptive_theme_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final colorResult = await _parseColorTokens();
  final spacingResult = await _parseSpacingTokens();
  final typeResult = await _parseTypographyTokens();

  final colorGroups = _groupColors(colorResult.tokens);
  final spacingGroups = _groupSpacing(spacingResult.tokens);
  final typeGroups = _groupTypography(typeResult.tokens);

  final colorIndex = _cohesionIndex(colorResult.tokens.length, colorGroups);
  final spacingIndex = _cohesionIndex(
    spacingResult.tokens.length,
    spacingGroups,
  );
  final typeIndex = _cohesionIndex(typeResult.tokens.length, typeGroups);

  final finalIndex = _average([colorIndex, spacingIndex, typeIndex]);
  final verdict = _verdict(finalIndex);

  await _withReportsWritable(() async {
    await _writeSummary(
      colorResult: colorResult,
      spacingResult: spacingResult,
      typeResult: typeResult,
      colorGroups: colorGroups,
      spacingGroups: spacingGroups,
      typeGroups: typeGroups,
      colorIndex: colorIndex,
      spacingIndex: spacingIndex,
      typeIndex: typeIndex,
      finalIndex: finalIndex,
      verdict: verdict,
    );
    await _appendTelemetry(
      finalIndex: finalIndex,
      verdict: verdict,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_theme_pass: tokens(colors=${colorResult.tokens.length}, '
    'spacing=${spacingResult.tokens.length}, type=${typeResult.tokens.length}) '
    'finalIndex=${(finalIndex * 100).toStringAsFixed(1)}% verdict=$verdict',
  );
}

Future<_ColorParseResult> _parseColorTokens() async {
  final tokens = <_ColorToken>[];
  final missingSources = <String>[];

  Future<void> parseFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      missingSources.add(path);
      return;
    }
    final content = await file.readAsString();
    final regex = RegExp(
      r'static\s+(?:const|final)\s+(?:(?:Color|MaterialColor)\s+)?(\w+)\s*=\s*(.+?);',
      dotAll: true,
    );
    for (final match in regex.allMatches(content)) {
      final name = match.group(1)!;
      final value = match.group(2)!.trim();
      final hexMatch = RegExp(
        r'Color\s*\(\s*(0x[0-9a-fA-F]{8})\s*\)',
      ).firstMatch(value);
      final hex = hexMatch != null ? int.parse(hexMatch.group(1)!) : null;
      tokens.add(_ColorToken(name: name, rawValue: value, argb: hex));
    }
  }

  await parseFile(_colorsPath);

  return _ColorParseResult(tokens: tokens, missingSources: missingSources);
}

Future<_SpacingParseResult> _parseSpacingTokens() async {
  final tokens = <_SpacingToken>[];
  final missingSources = <String>[];

  Future<void> parseFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      missingSources.add(path);
      return;
    }
    final content = await file.readAsString();
    final regex = RegExp(r'static\s+const\s+double\s+(\w+)\s*=\s*([\d.]+)');
    for (final match in regex.allMatches(content)) {
      tokens.add(
        _SpacingToken(
          name: match.group(1)!,
          value: double.tryParse(match.group(2) ?? ''),
        ),
      );
    }
  }

  await parseFile(_spacingPath);
  if (tokens.isEmpty) {
    final fallbackFile = File(_spacingFallbackPath);
    if (await fallbackFile.exists()) {
      final content = await fallbackFile.readAsString();
      final regex = RegExp(r'this\.(spacing\w+)\s*=\s*([\d.]+)');
      for (final match in regex.allMatches(content)) {
        tokens.add(
          _SpacingToken(
            name: match.group(1)!,
            value: double.tryParse(match.group(2) ?? ''),
          ),
        );
      }
    } else {
      missingSources.add(_spacingFallbackPath);
    }
  }

  return _SpacingParseResult(tokens: tokens, missingSources: missingSources);
}

Future<_TypographyParseResult> _parseTypographyTokens() async {
  final tokens = <_TypographyToken>[];
  final missingSources = <String>[];

  Future<void> parseFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      missingSources.add(path);
      return;
    }
    final content = await file.readAsString();
    final regex = RegExp(
      r'static\s+const\s+TextStyle\s+(\w+)\s*=\s*TextStyle\((.+?)\);',
      dotAll: true,
    );
    for (final match in regex.allMatches(content)) {
      final name = match.group(1)!;
      final body = match.group(2)!;
      final sizeMatch = RegExp(r'fontSize\s*:\s*([\d.]+)').firstMatch(body);
      final weightMatch = RegExp(
        r'fontWeight\s*:\s*FontWeight\.w(\d+)',
      ).firstMatch(body);
      tokens.add(
        _TypographyToken(
          name: name,
          fontSize: double.tryParse(sizeMatch?.group(1) ?? ''),
          fontWeight: weightMatch != null
              ? int.parse(weightMatch.group(1)!)
              : 400,
        ),
      );
    }
  }

  await parseFile(_typographyPath);
  if (tokens.isEmpty) {
    await parseFile(_typographyFallbackPath);
  }

  return _TypographyParseResult(tokens: tokens, missingSources: missingSources);
}

List<_ColorGroup> _groupColors(List<_ColorToken> tokens) {
  final groups = <_ColorGroup>[];
  final visited = <int>{};
  for (var i = 0; i < tokens.length; i++) {
    if (visited.contains(i)) continue;
    final current = <_ColorToken>[tokens[i]];
    visited.add(i);
    for (var j = i + 1; j < tokens.length; j++) {
      if (visited.contains(j)) continue;
      if (_isColorDuplicate(tokens[i], tokens[j])) {
        current.add(tokens[j]);
        visited.add(j);
      }
    }
    groups.add(_ColorGroup(tokens: current));
  }
  return groups;
}

bool _isColorDuplicate(_ColorToken a, _ColorToken b) {
  if (a.argb != null && b.argb != null) {
    final delta = _colorDelta(a.argb!, b.argb!);
    return delta <= 0.03;
  }
  return a.rawValue == b.rawValue;
}

double _colorDelta(int a, int b) {
  int channel(int value, int shift) => (value >> shift) & 0xFF;
  final ar = channel(a, 16);
  final ag = channel(a, 8);
  final ab = channel(a, 0);
  final br = channel(b, 16);
  final bg = channel(b, 8);
  final bb = channel(b, 0);
  final diff = sqrt(pow(ar - br, 2) + pow(ag - bg, 2) + pow(ab - bb, 2));
  return diff / (sqrt(3) * 255);
}

List<_SpacingGroup> _groupSpacing(List<_SpacingToken> tokens) {
  final groups = <_SpacingGroup>[];
  final visited = <int>{};
  for (var i = 0; i < tokens.length; i++) {
    if (visited.contains(i)) continue;
    final current = <_SpacingToken>[tokens[i]];
    visited.add(i);
    for (var j = i + 1; j < tokens.length; j++) {
      if (visited.contains(j)) continue;
      if (_isSpacingDuplicate(tokens[i], tokens[j])) {
        current.add(tokens[j]);
        visited.add(j);
      }
    }
    groups.add(_SpacingGroup(tokens: current));
  }
  return groups;
}

bool _isSpacingDuplicate(_SpacingToken a, _SpacingToken b) {
  if (a.value == null || b.value == null) return false;
  return (a.value! - b.value!).abs() <= 2.0;
}

List<_TypographyGroup> _groupTypography(List<_TypographyToken> tokens) {
  final groups = <_TypographyGroup>[];
  final visited = <int>{};
  for (var i = 0; i < tokens.length; i++) {
    if (visited.contains(i)) continue;
    final current = <_TypographyToken>[tokens[i]];
    visited.add(i);
    for (var j = i + 1; j < tokens.length; j++) {
      if (visited.contains(j)) continue;
      if (_isTypographyDuplicate(tokens[i], tokens[j])) {
        current.add(tokens[j]);
        visited.add(j);
      }
    }
    groups.add(_TypographyGroup(tokens: current));
  }
  return groups;
}

bool _isTypographyDuplicate(_TypographyToken a, _TypographyToken b) {
  if (a.fontSize == null || b.fontSize == null) return false;
  if (a.fontWeight != b.fontWeight) return false;
  return (a.fontSize! - b.fontSize!).abs() <= 0.01;
}

double _cohesionIndex(int totalTokens, List<dynamic> groups) {
  if (totalTokens == 0) return 1.0;
  final unique = groups.length;
  return unique / totalTokens;
}

double _average(List<double> values) {
  if (values.isEmpty) return 1.0;
  return values.reduce((a, b) => a + b) / values.length;
}

String _verdict(double index) {
  if (index >= 0.85) return 'PASS';
  if (index >= 0.7) return 'WARN';
  return 'FAIL';
}

Future<void> _writeSummary({
  required _ColorParseResult colorResult,
  required _SpacingParseResult spacingResult,
  required _TypographyParseResult typeResult,
  required List<_ColorGroup> colorGroups,
  required List<_SpacingGroup> spacingGroups,
  required List<_TypographyGroup> typeGroups,
  required double colorIndex,
  required double spacingIndex,
  required double typeIndex,
  required double finalIndex,
  required String verdict,
}) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE THEME SUMMARY')
    ..writeln('======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Color tokens: ${colorResult.tokens.length}   '
      'Spacing tokens: ${spacingResult.tokens.length}   '
      'Typography tokens: ${typeResult.tokens.length}',
    )
    ..writeln(
      'Consistency index → colors: ${(colorIndex * 100).toStringAsFixed(1)}%   '
      'spacing: ${(spacingIndex * 100).toStringAsFixed(1)}%   '
      'type: ${(typeIndex * 100).toStringAsFixed(1)}%',
    )
    ..writeln(
      'Final cohesion index: ${(finalIndex * 100).toStringAsFixed(1)}% '
      '($verdict)',
    )
    ..writeln();

  if (colorResult.missingSources.isNotEmpty ||
      spacingResult.missingSources.isNotEmpty ||
      typeResult.missingSources.isNotEmpty) {
    buffer.writeln('Missing sources');
    buffer.writeln('---------------');
    for (final path in [
      ...colorResult.missingSources,
      ...spacingResult.missingSources,
      ...typeResult.missingSources,
    ]) {
      buffer.writeln('- $path');
    }
    buffer.writeln();
  }

  void writeGroups<T>(
    String title,
    List<T> groups,
    String Function(T) formatter,
  ) {
    buffer
      ..writeln(title)
      ..writeln('-' * title.length);
    if (groups.isEmpty) {
      buffer.writeln('No tokens found');
    } else {
      for (final group in groups) {
        buffer.writeln(formatter(group));
      }
    }
    buffer.writeln();
  }

  writeGroups<_ColorGroup>(
    'AdaptiveColors',
    colorGroups,
    (group) => group.describe(),
  );
  writeGroups<_SpacingGroup>(
    'AdaptiveSpacing',
    spacingGroups,
    (group) => group.describe(),
  );
  writeGroups<_TypographyGroup>(
    'AdaptiveTypography',
    typeGroups,
    (group) => group.describe(),
  );

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double finalIndex,
  required String verdict,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_theme_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'final_index': double.parse(finalIndex.toStringAsFixed(3)),
    'verdict': verdict,
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
      'adaptive_theme_pass: chmod failed (${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ColorToken {
  const _ColorToken({
    required this.name,
    required this.rawValue,
    required this.argb,
  });

  final String name;
  final String rawValue;
  final int? argb;
}

class _SpacingToken {
  const _SpacingToken({required this.name, required this.value});

  final String name;
  final double? value;
}

class _TypographyToken {
  const _TypographyToken({
    required this.name,
    required this.fontSize,
    required this.fontWeight,
  });

  final String name;
  final double? fontSize;
  final int fontWeight;
}

class _ColorGroup {
  _ColorGroup({required this.tokens});

  final List<_ColorToken> tokens;

  String describe() {
    final canonical = tokens.first;
    final merged = tokens.skip(1).map((t) => t.name).toList();
    final descriptor = canonical.argb != null
        ? '#${canonical.argb!.toRadixString(16).padLeft(8, '0').toUpperCase()}'
        : canonical.rawValue;
    if (merged.isEmpty) {
      return '${canonical.name} → $descriptor';
    }
    return '${canonical.name} ← ${merged.join(', ')} ($descriptor)';
  }
}

class _SpacingGroup {
  _SpacingGroup({required this.tokens});

  final List<_SpacingToken> tokens;

  String describe() {
    final canonical = tokens.first;
    final merged = tokens.skip(1).map((t) => t.name).toList();
    final value = canonical.value != null
        ? '${canonical.value!.toStringAsFixed(1)} px'
        : 'n/a';
    if (merged.isEmpty) {
      return '${canonical.name} → $value';
    }
    return '${canonical.name} ← ${merged.join(', ')} ($value)';
  }
}

class _TypographyGroup {
  _TypographyGroup({required this.tokens});

  final List<_TypographyToken> tokens;

  String describe() {
    final canonical = tokens.first;
    final merged = tokens.skip(1).map((t) => t.name).toList();
    final value =
        '${canonical.fontSize?.toStringAsFixed(1) ?? 'n/a'} pt / w${canonical.fontWeight}';
    if (merged.isEmpty) {
      return '${canonical.name} → $value';
    }
    return '${canonical.name} ← ${merged.join(', ')} ($value)';
  }
}

class _ColorParseResult {
  const _ColorParseResult({required this.tokens, required this.missingSources});

  final List<_ColorToken> tokens;
  final List<String> missingSources;
}

class _SpacingParseResult {
  const _SpacingParseResult({
    required this.tokens,
    required this.missingSources,
  });

  final List<_SpacingToken> tokens;
  final List<String> missingSources;
}

class _TypographyParseResult {
  const _TypographyParseResult({
    required this.tokens,
    required this.missingSources,
  });

  final List<_TypographyToken> tokens;
  final List<String> missingSources;
}
