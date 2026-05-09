import 'dart:convert';
import 'dart:io';

const String _integrationSummaryPath =
    'release/_reports/ai_mood_integration_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _outputPath = 'release/_reports/adaptive_ux_tuning_summary.txt';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _parseIntegrationSummary();
  final telemetryWeights = await _parseTelemetryWeights();

  final reports = <_UxReport>[];
  double totalScore = 0;

  for (final mood in moods.entries) {
    final engagement = mood.value.engagementScore;
    final telemetryWeight = telemetryWeights[mood.key] ?? 1.0;

    final animationSpeed = (0.8 + (1 - engagement) * 0.4) * telemetryWeight;
    final buttonScale = (1.0 + (engagement - 0.5) * 0.3).clamp(0.8, 1.3);
    final spacingMultiplier = (1.0 + (engagement - 0.5) * 0.4).clamp(0.7, 1.4);

    final score = (animationSpeed + buttonScale + spacingMultiplier) / 3;
    totalScore += score;

    reports.add(
      _UxReport(
        mood: mood.key,
        animationSpeed: animationSpeed,
        buttonScale: buttonScale,
        spacingMultiplier: spacingMultiplier,
        tuningScore: score,
      ),
    );
  }

  final avgWeight = moods.isEmpty ? 0.0 : totalScore / moods.length;

  await _withReportsWritable(() async {
    await _writeSummary(reports, avgWeight);
    await _appendTelemetry(
      moods: moods.length,
      avgWeight: avgWeight,
      tuningScore: avgWeight,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'adaptive_ux_tuner: moods=${moods.length} avgWeight=${avgWeight.toStringAsFixed(2)}',
  );
}

Future<Map<String, _MoodIntegration>> _parseIntegrationSummary() async {
  final file = File(_integrationSummaryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, _MoodIntegration>{};
  String? currentMood;
  double engagement = 0;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      currentMood = line.substring(5).trim();
    } else if (currentMood != null && line.startsWith('Engagement score:')) {
      engagement = double.tryParse(line.split(':').last.trim()) ?? 0;
      map[currentMood] = _MoodIntegration(engagementScore: engagement);
    }
  }
  return map;
}

Future<Map<String, double>> _parseTelemetryWeights() async {
  final file = File(_telemetryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, double>{};
  for (final line in lines.reversed) {
    if (line.trim().isEmpty) continue;
    dynamic payload;
    try {
      payload = json.decode(line);
    } catch (_) {
      continue;
    }
    if (payload is Map && payload['event'] == 'ai_mood_integrated') {
      final moods = payload['moods'];
      final score = payload['integration_score'];
      if (moods is int && moods > 0 && score is num) {
        map['default'] = score.toDouble();
      }
    }
  }
  return map;
}

Future<void> _writeSummary(List<_UxReport> reports, double avgWeight) async {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE UX TUNING SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Moods tuned: ${reports.length}   Avg weight: '
      '${avgWeight.toStringAsFixed(2)}',
    )
    ..writeln();

  for (final report in reports) {
    buffer
      ..writeln('Mood: ${report.mood}')
      ..writeln(
        '  Animation speed: ${report.animationSpeed.toStringAsFixed(2)}',
      )
      ..writeln('  Button scale: ${report.buttonScale.toStringAsFixed(2)}')
      ..writeln(
        '  Spacing multiplier: '
        '${report.spacingMultiplier.toStringAsFixed(2)}',
      )
      ..writeln('  Tuning score: ${report.tuningScore.toStringAsFixed(2)}')
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int moods,
  required double avgWeight,
  required double tuningScore,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'adaptive_ux_tuned',
    'timestamp': DateTime.now().toIso8601String(),
    'moods': moods,
    'avg_weight': double.parse(avgWeight.toStringAsFixed(2)),
    'tuning_score': double.parse(tuningScore.toStringAsFixed(2)),
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
      'adaptive_ux_tuner: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _MoodIntegration {
  const _MoodIntegration({required this.engagementScore});

  final double engagementScore;
}

class _UxReport {
  const _UxReport({
    required this.mood,
    required this.animationSpeed,
    required this.buttonScale,
    required this.spacingMultiplier,
    required this.tuningScore,
  });

  final String mood;
  final double animationSpeed;
  final double buttonScale;
  final double spacingMultiplier;
  final double tuningScore;
}
