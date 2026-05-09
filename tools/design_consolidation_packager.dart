import 'dart:convert';
import 'dart:io';

const String _visualThemePath = 'lib/ui_v3/theme/visual_theme_v3.dart';
const String _textStylesPath = 'lib/ui_v3/theme/app_text_styles.dart';
const String _personalizationPath =
    'lib/ui_v3/theme/personalization_profile.dart';
const String _brandingPath = 'lib/ui_v3/branding/branding_assets.dart';

const String _manifestPath =
    'release/_reports/design_consolidation_manifest.md';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

final RegExp _colorPattern = RegExp(
  r'static const Color (\w+) = Color\(([^)]+)\);',
);
final RegExp _spacingPattern = RegExp(
  r'static const double (spacing\w+) = ([0-9.]+);',
);
final RegExp _textStylePattern = RegExp(r'static TextStyle (\w+)\(');
final RegExp _moodCasePattern = RegExp(r"case '([^']+)':");
final RegExp _assetPattern = RegExp(r"(\w+)Path:\s*'([^']+)'", multiLine: true);

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final colors = await _extract(_visualThemePath, _colorPattern, (m) {
    final name = m.group(1)!;
    final value = m.group(2)!.trim();
    return '$name = Color($value)';
  });
  final spacings = await _extract(_visualThemePath, _spacingPattern, (m) {
    final name = m.group(1)!;
    final value = m.group(2)!;
    return '$name = $value';
  });
  final textStyles = await _extract(
    _textStylesPath,
    _textStylePattern,
    (m) => m.group(1)!,
  );
  final moods = await _extractMoods();
  final assets = await _extractAssets();

  final buffer = StringBuffer()
    ..writeln('# Design Consolidation Manifest')
    ..writeln()
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('## VisualThemeV3 Colors')
    ..writeln(_asList(colors))
    ..writeln('## VisualThemeV3 Spacing Tokens')
    ..writeln(_asList(spacings))
    ..writeln('## AppTextStyles')
    ..writeln(_asList(textStyles))
    ..writeln('## Personalization Moods')
    ..writeln(_asList(moods))
    ..writeln('## Brand Assets')
    ..writeln(_asList(assets));

  await _withReportsWritable(() async {
    await File(_manifestPath).writeAsString(buffer.toString());
    await _appendTelemetry(
      tokens:
          colors.length + spacings.length + textStyles.length + moods.length,
      assets: assets.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'design_consolidation_packager: '
    'tokens=${colors.length + spacings.length + textStyles.length + moods.length}, '
    'assets=${assets.length}',
  );
}

Future<List<String>> _extract(
  String path,
  RegExp pattern,
  String Function(RegExpMatch) formatter,
) async {
  final file = File(path);
  if (!await file.exists()) return const [];
  final content = await file.readAsString();
  return [for (final match in pattern.allMatches(content)) formatter(match)];
}

Future<List<String>> _extractMoods() async {
  final file = File(_personalizationPath);
  if (!await file.exists()) return const [];
  final content = await file.readAsString();
  final matches = _moodCasePattern.allMatches(content);
  final moods = <String>{for (final m in matches) m.group(1)!, 'default'};
  return moods.toList()..sort();
}

Future<List<String>> _extractAssets() async {
  final file = File(_brandingPath);
  if (!await file.exists()) return const [];
  final content = await file.readAsString();
  final matches = _assetPattern.allMatches(content);
  final entries = <String>[];
  for (final match in matches) {
    final key = match.group(1)!;
    final value = match.group(2)!;
    entries.add('$key: $value');
  }
  return entries;
}

String _asList(List<String> items) {
  if (items.isEmpty) return '- _None_';
  return items.map((e) => '- $e').join('\n');
}

Future<void> _appendTelemetry({
  required int tokens,
  required int assets,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = {
    'event': 'design_consolidation_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'tokens': tokens,
    'assets': assets,
    'duration_ms': durationMs,
  };
  await telemetryFile.writeAsString(
    jsonEncode(event) + '\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(addWrite: true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(addWrite: false);
  }
}

Future<void> _setReportsPermissions({required bool addWrite}) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'design_consolidation_packager: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}
