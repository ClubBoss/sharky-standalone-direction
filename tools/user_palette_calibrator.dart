import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _moodSummaryPath = 'release/_reports/ai_mood_training_summary.txt';
const String _designSummaryPath = 'release/_reports/design_ai_sync_summary.txt';
const String _outputPath =
    'release/_reports/user_palette_calibration_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moodScores = await _parseMoodScores();
  final designMappings = await _parseDesignMappings();

  final calibrations = <_PaletteCalibration>[];
  for (final entry in designMappings.entries) {
    final mood = entry.key;
    final tokens = entry.value;
    final score = moodScores[mood];
    calibrations.add(_calculateCalibration(mood, tokens, score));
  }

  final avgDelta = calibrations.isEmpty
      ? 0.0
      : calibrations.map((c) => c.averageDelta).reduce((a, b) => a + b) /
            calibrations.length;

  await _withReportsWritable(() async {
    await _writeSummary(calibrations, avgDelta);
    await _appendTelemetry(
      moods: calibrations.length,
      avgDelta: avgDelta,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'user_palette_calibrator: moods=${calibrations.length} '
    'avgDelta=${avgDelta.toStringAsFixed(2)}',
  );
}

Future<Map<String, double>> _parseMoodScores() async {
  final file = File(_moodSummaryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, double>{};
  String? currentMood;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      currentMood = line.substring(5).trim();
    } else if (currentMood != null && line.startsWith('Composite score:')) {
      final value = double.tryParse(line.split(':').last.trim()) ?? 0;
      map[currentMood] = value;
    }
  }
  return map;
}

Future<Map<String, List<String>>> _parseDesignMappings() async {
  final file = File(_designSummaryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, List<String>>{};
  String? currentMood;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      currentMood = line.substring(5).trim();
    } else if (currentMood != null && line.startsWith('Colors:')) {
      final value = line.split(':').sublist(1).join(':').trim();
      if (value != '—' && value.isNotEmpty) {
        map[currentMood] = value.split(',').map((t) => t.trim()).toList();
      } else {
        map[currentMood] = const [];
      }
    }
  }
  return map;
}

_PaletteCalibration _calculateCalibration(
  String mood,
  List<String> tokens,
  double? score,
) {
  final adjustments = <_TokenAdjustment>[];
  for (final token in tokens) {
    final baseHue = _hashValue(token) % 360;
    final baseSat = 0.5 + (_hashValue(token + 'sat') % 50) / 100;
    final bias = (score ?? 0) - 0.5;
    final hueDelta = (bias * 10).clamp(-5.0, 5.0);
    final satDelta = (bias * 0.2).clamp(-0.05, 0.05);
    final adjustedHue = (baseHue + hueDelta + 360) % 360;
    final adjustedSat = (baseSat + satDelta).clamp(0.0, 1.0);
    adjustments.add(
      _TokenAdjustment(
        token: token,
        baseHue: baseHue.toDouble(),
        baseSaturation: baseSat,
        hueDelta: hueDelta,
        saturationDelta: satDelta,
        adjustedHue: adjustedHue,
        adjustedSaturation: adjustedSat,
      ),
    );
  }
  final avgDelta = adjustments.isEmpty
      ? 0.0
      : adjustments.map((adj) => adj.deltaMagnitude).reduce((a, b) => a + b) /
            adjustments.length;
  return _PaletteCalibration(
    mood: mood,
    adjustments: adjustments,
    averageDelta: avgDelta,
  );
}

int _hashValue(String input) {
  var hash = 0;
  for (final codeUnit in input.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return hash;
}

Future<void> _writeSummary(
  List<_PaletteCalibration> calibrations,
  double avgDelta,
) async {
  final buffer = StringBuffer()
    ..writeln('USER PALETTE CALIBRATION SUMMARY')
    ..writeln('================================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Calibrated moods: ${calibrations.length}   '
      'Average delta: ${avgDelta.toStringAsFixed(2)}',
    )
    ..writeln();

  if (calibrations.isEmpty) {
    buffer.writeln('No moods to calibrate.');
  } else {
    for (final calibration in calibrations) {
      buffer
        ..writeln('Mood: ${calibration.mood}')
        ..writeln(
          '  Avg delta: ${calibration.averageDelta.toStringAsFixed(2)}',
        );
      for (final adj in calibration.adjustments) {
        buffer..writeln(
          '    ${adj.token}: hue ${adj.baseHue.toStringAsFixed(1)}'
          '${_formatDelta(adj.hueDelta)} '
          '→ ${adj.adjustedHue.toStringAsFixed(1)}, '
          'sat ${adj.baseSaturation.toStringAsFixed(2)}'
          '${_formatDelta(adj.saturationDelta)} '
          '→ ${adj.adjustedSaturation.toStringAsFixed(2)}',
        );
      }
      buffer.writeln();
    }
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

String _formatDelta(double value) {
  if (value == 0) return ' (no change)';
  final sign = value > 0 ? '+' : '';
  return ' ($sign${value.toStringAsFixed(2)})';
}

Future<void> _appendTelemetry({
  required int moods,
  required double avgDelta,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'user_palette_calibrated',
    'timestamp': DateTime.now().toIso8601String(),
    'moods': moods,
    'avg_delta': double.parse(avgDelta.toStringAsFixed(2)),
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
      'user_palette_calibrator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _PaletteCalibration {
  const _PaletteCalibration({
    required this.mood,
    required this.adjustments,
    required this.averageDelta,
  });

  final String mood;
  final List<_TokenAdjustment> adjustments;
  final double averageDelta;
}

class _TokenAdjustment {
  const _TokenAdjustment({
    required this.token,
    required this.baseHue,
    required this.baseSaturation,
    required this.hueDelta,
    required this.saturationDelta,
    required this.adjustedHue,
    required this.adjustedSaturation,
  });

  final String token;
  final double baseHue;
  final double baseSaturation;
  final double hueDelta;
  final double saturationDelta;
  final double adjustedHue;
  final double adjustedSaturation;

  double get deltaMagnitude =>
      sqrt(hueDelta * hueDelta + saturationDelta * saturationDelta);
}
