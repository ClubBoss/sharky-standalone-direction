import 'dart:convert';
import 'dart:io';

const String _servicePath = 'lib/services/ai_personalization_service.dart';
const String _profilePath = 'lib/ui_v3/theme/personalization_profile.dart';
const String _lessonScreenPath = 'lib/ui_v3/lesson_screen.dart';
const String _progressScreenPath = 'lib/ui_v3/progress_hub_screen.dart';

const String _reportsDir = 'release/_reports';
const String _summaryPath =
    'release/_reports/ai_palette_integration_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

const List<String> _paletteFields = <String>[
  'backgroundGradient',
  'cardGradient',
  'accent',
  'badgeBackground',
  'badgeForeground',
];

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final serviceMoods = _extractServiceMoods();
  final paletteMappings = _extractPaletteMappings();
  final fallbackMapping = paletteMappings['default'];

  final moodReports = <_MoodReport>[];
  for (final mood in serviceMoods) {
    final mapping = paletteMappings[mood] ?? fallbackMapping;
    final status = paletteMappings.containsKey(mood)
        ? _MoodStatus.direct
        : (mapping != null ? _MoodStatus.fallback : _MoodStatus.missing);
    moodReports.add(_MoodReport(mood: mood, mapping: mapping, status: status));
  }

  final paletteBindings = <String, Set<String>>{
    _lessonScreenPath: _extractScreenBindings(_lessonScreenPath),
    _progressScreenPath: _extractScreenBindings(_progressScreenPath),
  };

  final bindingCount = paletteBindings.values
      .map((set) => set.length)
      .fold<int>(0, (sum, value) => sum + value);

  await _withReportsWritable(() async {
    await _writeSummary(
      moodReports: moodReports,
      paletteMappings: paletteMappings,
      paletteBindings: paletteBindings,
    );
    await _appendTelemetry(
      moods: serviceMoods.length,
      bindings: bindingCount,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'ai_palette_integrator: ${serviceMoods.length} moods, '
    '$bindingCount palette bindings.',
  );
}

Set<String> _extractServiceMoods() {
  final file = File(_servicePath);
  if (!file.existsSync()) {
    stderr.writeln('ai_palette_integrator: missing $_servicePath');
    return <String>{};
  }
  final content = file.readAsStringSync();
  final match = RegExp(
    r'Map<String, dynamic>\s+adjustVisualProfile\(\)\s*{([\s\S]*?)\n\s*}',
  ).firstMatch(content);
  if (match == null) {
    return <String>{};
  }
  final body = match.group(1) ?? '';
  final assignment = RegExp(r'final\s+mood\s*=([\s\S]*?);').firstMatch(body);
  if (assignment == null) {
    return <String>{};
  }
  final moodExpression = assignment.group(1) ?? '';
  final moods = RegExp(r"'([A-Za-z0-9_\-]+)'")
      .allMatches(moodExpression)
      .map((m) => m.group(1))
      .whereType<String>()
      .toSet();
  return moods;
}

Map<String, _PaletteMapping> _extractPaletteMappings() {
  final file = File(_profilePath);
  if (!file.existsSync()) {
    stderr.writeln('ai_palette_integrator: missing $_profilePath');
    return <String, _PaletteMapping>{};
  }
  final content = file.readAsStringSync();
  final result = <String, _PaletteMapping>{};
  final blockRegex = RegExp(
    r"(case '([^']+)':|default:)\s*return\s+PersonalizationPalette\(([^;]+?)\);",
    multiLine: true,
  );
  for (final match in blockRegex.allMatches(content)) {
    final mood = match.group(2) ?? 'default';
    final body = match.group(3) ?? '';
    final expressions = <String, String>{};
    for (final field in _paletteFields) {
      final expression = _extractFieldExpression(body, field);
      if (expression != null && expression.isNotEmpty) {
        expressions[field] = expression;
      }
    }
    result[mood] = _PaletteMapping(mood: mood, expressions: expressions);
  }
  return result;
}

String? _extractFieldExpression(String body, String field) {
  final marker = '$field:';
  final start = body.indexOf(marker);
  if (start == -1) return null;
  int index = start + marker.length;
  while (index < body.length && _isWhitespace(body.codeUnitAt(index))) {
    index++;
  }
  final buffer = StringBuffer();
  int depth = 0;
  for (; index < body.length; index++) {
    final char = body[index];
    if (char == '(' || char == '[' || char == '{') {
      depth++;
    } else if (char == ')' || char == ']' || char == '}') {
      if (depth > 0) depth--;
    } else if (char == ',' && depth == 0) {
      break;
    }
    buffer.write(char);
  }
  return buffer.toString().trim();
}

bool _isWhitespace(int codeUnit) {
  return codeUnit == 0x20 ||
      codeUnit == 0x09 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D;
}

Set<String> _extractScreenBindings(String path) {
  final file = File(path);
  if (!file.existsSync()) return <String>{};
  final content = file.readAsStringSync();
  final matches = RegExp(
    r'palette\.(\w+)',
  ).allMatches(content).map((m) => m.group(1)).whereType<String>().toSet();
  return matches;
}

Future<void> _writeSummary({
  required List<_MoodReport> moodReports,
  required Map<String, _PaletteMapping> paletteMappings,
  required Map<String, Set<String>> paletteBindings,
}) async {
  final buffer = StringBuffer()
    ..writeln('AI PALETTE INTEGRATION SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln();

  buffer
    ..writeln('Mood coverage (source: $_servicePath):')
    ..writeln('----------------------------------------');
  for (final report in moodReports) {
    final mapping = report.mapping;
    final label = _statusLabel(report.status, mapping?.mood);
    buffer.writeln('- ${report.mood}: $label');
    if (mapping != null) {
      for (final field in _paletteFields) {
        final expression = mapping.expressions[field];
        if (expression == null) continue;
        final tokens = mapping.tokens[field]?.toList() ?? const <String>[];
        final tokenLabel = tokens.isEmpty
            ? 'tokens: n/a'
            : 'tokens: ${tokens.map((t) => 'VisualThemeV3.$t').join(', ')}';
        buffer.writeln('  • $field => ${expression.trim()} ($tokenLabel)');
      }
    }
  }

  final extras =
      paletteMappings.keys
          .where(
            (key) => key != 'default' && !moodReports.any((r) => r.mood == key),
          )
          .toList()
        ..sort();
  if (extras.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln(
        'Additional palette cases defined but not issued by the service:',
      )
      ..writeln(extras.map((e) => '- $e').join('\n'));
  }

  buffer
    ..writeln()
    ..writeln('Screen bindings:')
    ..writeln('----------------');
  paletteBindings.forEach((path, bindings) {
    final bindingList = bindings.toList()..sort();
    final status = bindingList.isEmpty
        ? 'no palette bindings detected'
        : bindingList.join(', ');
    buffer.writeln('- $path: $status');
  });

  await File(_summaryPath).writeAsString(buffer.toString());
}

String _statusLabel(_MoodStatus status, String? mappingKey) {
  switch (status) {
    case _MoodStatus.direct:
      return 'mapped via PersonalizationPalette.$mappingKey';
    case _MoodStatus.fallback:
      return 'covered by default palette';
    case _MoodStatus.missing:
      return 'no palette mapping available';
  }
}

Future<void> _appendTelemetry({
  required int moods,
  required int bindings,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'ai_palette_integrated',
    'timestamp': DateTime.now().toIso8601String(),
    'moods': moods,
    'bindings': bindings,
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
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'ai_palette_integrator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _PaletteMapping {
  _PaletteMapping({required this.mood, required this.expressions})
    : tokens = expressions.map(
        (key, value) => MapEntry(key, _extractThemeTokens(value)),
      );

  final String mood;
  final Map<String, String> expressions;
  final Map<String, Set<String>> tokens;
}

Set<String> _extractThemeTokens(String expression) {
  return RegExp(
    r'VisualThemeV3\.(\w+)',
  ).allMatches(expression).map((m) => m.group(1)).whereType<String>().toSet();
}

class _MoodReport {
  const _MoodReport({
    required this.mood,
    required this.mapping,
    required this.status,
  });

  final String mood;
  final _PaletteMapping? mapping;
  final _MoodStatus status;
}

enum _MoodStatus { direct, fallback, missing }
