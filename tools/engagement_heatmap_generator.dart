import 'dart:convert';
import 'dart:io';

const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _funnelSummaryPath =
    'release/_reports/retention_funnel_summary.txt';
const String _outputPath = 'release/_reports/engagement_heatmap_summary.txt';
const String _telemetryOutput = 'release/_reports/telemetry.jsonl';

const Map<String, List<String>> _stageKeywords = {
  'Home': ['home', 'dashboard', 'first_launch'],
  'Lessons': ['lesson', 'learning_map', 'tutorial'],
  'Drills': ['drill', 'practice'],
  'Quizzes': ['quiz', 'assessment'],
  'Recaps': ['recap'],
};

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final events = await _loadTelemetry();
  final funnelLines = await _loadFunnelSummary();

  final heatmap = _computeHeatmap(events);
  final ascii = _renderHeatmap(heatmap);

  await _withReportsWritable(() async {
    await _writeSummary(ascii, funnelLines, stopwatch.elapsedMilliseconds);
    await _emitTelemetry(heatmap, stopwatch.elapsedMilliseconds);
  });

  stdout.writeln('engagement_heatmap_generator: heatmap generated.');
}

Future<List<_TelemetryEvent>> _loadTelemetry() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) {
    throw StateError('Telemetry file missing at $_telemetryPath');
  }

  final events = <_TelemetryEvent>[];
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is! Map<String, dynamic>) continue;
    final eventName = payload['event']?.toString() ?? '';
    final screen = payload['screen']?.toString() ?? '';
    events.add(_TelemetryEvent(eventName, screen));
  }
  if (events.isEmpty) {
    throw StateError('Telemetry file contains no usable events.');
  }
  return events;
}

Future<List<String>> _loadFunnelSummary() async {
  final file = File(_funnelSummaryPath);
  if (!await file.exists()) return const [];
  return file.readAsLines();
}

Map<String, double> _computeHeatmap(List<_TelemetryEvent> events) {
  final counts = <String, int>{};
  for (final stage in _stageKeywords.keys) {
    counts[stage] = 0;
  }

  for (final event in events) {
    for (final entry in _stageKeywords.entries) {
      if (_matches(event, entry.value)) {
        counts[entry.key] = (counts[entry.key] ?? 0) + 1;
      }
    }
  }

  final maxCount = counts.values.fold<int>(
    0,
    (prev, count) => count > prev ? count : prev,
  );
  if (maxCount == 0) {
    return counts.map((key, value) => MapEntry(key, 0.0));
  }

  return counts.map((key, value) => MapEntry(key, (value / maxCount) * 100));
}

bool _matches(_TelemetryEvent event, List<String> keywords) {
  final eventLower = event.name.toLowerCase();
  final screenLower = event.screen.toLowerCase();
  for (final keyword in keywords) {
    final lower = keyword.toLowerCase();
    if (eventLower.contains(lower) || screenLower.contains(lower)) {
      return true;
    }
  }
  return false;
}

List<String> _renderHeatmap(Map<String, double> heatmap) {
  const blocks = ['░░░░░', '░░░▒▒', '░▒▒▒▒', '▒▒▒▓▓', '▒▓▓▓▓', '▓▓▓▓▓'];

  String cell(double percentage) {
    final index = (percentage / 20).clamp(0, blocks.length - 1).floor();
    return '${blocks[index]} ${percentage.toStringAsFixed(1)}%';
  }

  final lines = <String>[
    'ENGAGEMENT HEATMAP (ASCII)',
    '=========================',
    '',
  ];

  for (final entry in heatmap.entries) {
    lines
      ..add('${entry.key.padRight(8)} | ${cell(entry.value)}')
      ..add('');
  }
  return lines;
}

Future<void> _writeSummary(
  List<String> ascii,
  List<String> funnelLines,
  int durationMs,
) async {
  final buffer = StringBuffer()
    ..writeln('ENGAGEMENT HEATMAP SUMMARY')
    ..writeln('=========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln()
    ..writeln('Heatmap:')
    ..writeln();

  for (final line in ascii) {
    buffer.writeln(line);
  }

  if (funnelLines.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Retention Funnel Snapshot:')
      ..writeln();
    for (final line in funnelLines) {
      buffer.writeln(line);
    }
  }

  await File(_outputPath).writeAsString('${buffer.toString()}\n');
}

Future<void> _emitTelemetry(Map<String, double> heatmap, int durationMs) async {
  final payload = <String, Object?>{
    'event': 'engagement_heatmap_generated',
    'timestamp': DateTime.now().toIso8601String(),
    'heatmap': heatmap.map(
      (key, value) => MapEntry(key, double.parse(value.toStringAsFixed(1))),
    ),
    'duration_ms': durationMs,
  };

  await File(_telemetryOutput).writeAsString(
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
  final result = await Process.run('chmod', ['-R', mode, 'release/_reports']);
  if (result.exitCode != 0) {
    stderr.writeln(
      'engagement_heatmap_generator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _TelemetryEvent {
  const _TelemetryEvent(this.name, this.screen);

  final String name;
  final String screen;
}
