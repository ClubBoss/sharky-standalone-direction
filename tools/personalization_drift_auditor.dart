import 'dart:convert';
import 'dart:io';

const String _uxTuningPath = 'release/_reports/adaptive_ux_tuning_summary.txt';
const String _feedbackPath =
    'release/_reports/user_adaptation_feedback_summary.txt';
const String _outputPath = 'release/_reports/personalization_drift_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final expected = await _parseUxTuningSummary();
  final actual = await _parseFeedbackSummary();

  final moods = <String>{...expected.keys, ...actual.keys}.toList()..sort();

  final reports = <_DriftReport>[];
  double driftAccumulator = 0;

  for (final mood in moods) {
    final expectedScore = expected[mood]?.tuningScore ?? 0;
    final actualScore = actual[mood]?.feedbackScore ?? 0;

    final double drift = _computeDrift(expectedScore, actualScore);
    driftAccumulator += drift;

    reports.add(
      _DriftReport(
        mood: mood,
        expectedScore: expectedScore,
        actualScore: actualScore,
        driftPercent: drift * 100,
        classification: _classify(drift),
        notes: _buildNotes(
          expected.containsKey(mood),
          actual.containsKey(mood),
        ),
      ),
    );
  }

  final avgDrift = moods.isEmpty ? 0.0 : driftAccumulator / moods.length;
  final stabilityIndex = (1 - avgDrift).clamp(0.0, 1.0);
  final overall = _classify(avgDrift);

  await _withReportsWritable(() async {
    await _writeSummary(
      reports: reports,
      avgDrift: avgDrift,
      stabilityIndex: stabilityIndex,
      overall: overall,
    );
    await _appendTelemetry(
      avgDrift: avgDrift,
      stabilityIndex: stabilityIndex,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'personalization_drift_auditor: moods=${moods.length} '
    'avgDrift=${(avgDrift * 100).toStringAsFixed(1)}% '
    'stability=${stabilityIndex.toStringAsFixed(2)}',
  );
}

Future<Map<String, _Tuning>> _parseUxTuningSummary() async {
  final file = File(_uxTuningPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, _Tuning>{};

  String? mood;
  double tuningScore = 0;

  void commit() {
    final currentMood = mood;
    if (currentMood == null) return;
    map[currentMood] = _Tuning(tuningScore: tuningScore);
  }

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      commit();
      mood = line.substring(5).trim();
      tuningScore = 0;
    } else if (line.startsWith('Tuning score:')) {
      tuningScore = double.tryParse(line.split(':').last.trim()) ?? 0;
    }
  }
  commit();
  return map;
}

Future<Map<String, _Feedback>> _parseFeedbackSummary() async {
  final file = File(_feedbackPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, _Feedback>{};

  String? mood;
  double feedbackScore = 0;

  void commit() {
    final currentMood = mood;
    if (currentMood == null) return;
    map[currentMood] = _Feedback(feedbackScore: feedbackScore);
  }

  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      commit();
      mood = line.substring(5).trim();
      feedbackScore = 0;
    } else if (line.startsWith('Feedback score:')) {
      final value = line.split(':').last.trim().split(' ').first;
      feedbackScore = double.tryParse(value) ?? 0;
    }
  }
  commit();
  return map;
}

double _computeDrift(double expected, double actual) {
  if (expected <= 0 && actual <= 0) return 0;
  if (expected <= 0) return 1;
  final diff = (expected - actual).abs() / expected;
  return diff.clamp(0, 1.0);
}

String _classify(double driftRatio) {
  if (driftRatio <= 0.10) return 'Stable';
  if (driftRatio <= 0.25) return 'Minor';
  return 'Major';
}

String _buildNotes(bool hasExpected, bool hasActual) {
  final notes = <String>[];
  if (!hasExpected) notes.add('No expected tuning data');
  if (!hasActual) notes.add('No feedback data');
  return notes.isEmpty ? 'OK' : notes.join('; ');
}

Future<void> _writeSummary({
  required List<_DriftReport> reports,
  required double avgDrift,
  required double stabilityIndex,
  required String overall,
}) async {
  final buffer = StringBuffer()
    ..writeln('PERSONALIZATION DRIFT SUMMARY')
    ..writeln('=============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Moods analyzed: ${reports.length}   '
      'Average drift: ${(avgDrift * 100).toStringAsFixed(1)}%   '
      'Stability index: ${stabilityIndex.toStringAsFixed(2)} '
      '($overall)',
    )
    ..writeln();

  for (final report in reports) {
    buffer
      ..writeln('Mood: ${report.mood}')
      ..writeln(
        '  Expected tuning score: ${report.expectedScore.toStringAsFixed(2)}',
      )
      ..writeln(
        '  Actual feedback score: ${report.actualScore.toStringAsFixed(2)}',
      )
      ..writeln(
        '  Drift: ${report.driftPercent.toStringAsFixed(1)}% '
        '(${report.classification})',
      )
      ..writeln('  Notes: ${report.notes}')
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required double avgDrift,
  required double stabilityIndex,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'personalization_drift_audited',
    'timestamp': DateTime.now().toIso8601String(),
    'avg_drift': double.parse((avgDrift * 100).toStringAsFixed(1)),
    'stability_index': double.parse(stabilityIndex.toStringAsFixed(2)),
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
      'personalization_drift_auditor: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _Tuning {
  const _Tuning({required this.tuningScore});

  final double tuningScore;
}

class _Feedback {
  const _Feedback({required this.feedbackScore});

  final double feedbackScore;
}

class _DriftReport {
  const _DriftReport({
    required this.mood,
    required this.expectedScore,
    required this.actualScore,
    required this.driftPercent,
    required this.classification,
    required this.notes,
  });

  final String mood;
  final double expectedScore;
  final double actualScore;
  final double driftPercent;
  final String classification;
  final String notes;
}
