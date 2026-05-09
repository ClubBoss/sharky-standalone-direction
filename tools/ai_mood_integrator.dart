import 'dart:convert';
import 'dart:io';

const String _moodSummaryPath = 'release/_reports/ai_mood_training_summary.txt';
const String _alignmentSummaryPath =
    'release/_reports/visual_token_alignment_summary.txt';
const String _outputPath = 'release/_reports/ai_mood_integration_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';
const String _reportsDir = 'release/_reports';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();

  final moods = await _parseMoodScores();
  final alignment = await _parseAlignmentSummary();

  final integrations = <_IntegrationReport>[];
  int adjustedTokens = 0;

  for (final moodEntry in moods.entries) {
    final mood = moodEntry.key;
    final score = moodEntry.value;
    final tokens =
        alignment[mood] ??
        const _AlignedTokens(spacing: 'spacingM', typography: 'cardDetail');
    final colorHint = score > 0.6
        ? 'success'
        : (score < 0.4 ? 'danger' : 'primary');
    final adjustments = _MoodAdjustments(
      mood: mood,
      engagementScore: score,
      colorToken: colorHint,
      spacingToken: tokens.spacing,
      typographyToken: tokens.typography,
    );
    adjustedTokens += 2; // spacing + typography
    integrations.add(_IntegrationReport(mood: mood, adjustments: adjustments));
  }

  final integrationScore = moods.isEmpty
      ? 0.0
      : moods.values.reduce((a, b) => a + b) / moods.length;

  await _withReportsWritable(() async {
    await _writeSummary(
      integrations: integrations,
      integrationScore: integrationScore,
    );
    await _appendTelemetry(
      moods: moods.length,
      adjustedTokens: adjustedTokens,
      integrationScore: integrationScore,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'ai_mood_integrator: moods=${moods.length} '
    'integrationScore=${integrationScore.toStringAsFixed(2)}',
  );
}

Future<Map<String, double>> _parseMoodScores() async {
  final file = File(_moodSummaryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, double>{};
  String? currentMood;
  for (final line in lines) {
    if (line.startsWith('Mood:')) {
      currentMood = line.substring(5).trim();
    } else if (currentMood != null && line.startsWith('Composite score:')) {
      map[currentMood] = double.tryParse(line.split(':').last.trim()) ?? 0.0;
    }
  }
  return map;
}

Future<Map<String, _AlignedTokens>> _parseAlignmentSummary() async {
  final file = File(_alignmentSummaryPath);
  if (!await file.exists()) return const {};
  final lines = await file.readAsLines();
  final map = <String, _AlignedTokens>{};
  String? currentMood;
  String? spacing;
  String? typography;
  for (final raw in lines) {
    final line = raw.trim();
    if (line.startsWith('Mood:')) {
      if (currentMood != null) {
        map[currentMood] = _AlignedTokens(
          spacing: spacing ?? 'spacingM',
          typography: typography ?? 'cardDetail',
        );
      }
      currentMood = line.substring(5).trim();
      spacing = null;
      typography = null;
    } else if (line.startsWith('Spacing token:')) {
      spacing = line.split(':').last.trim();
    } else if (line.startsWith('Typography token:')) {
      typography = line.split(':').last.trim();
    }
  }
  if (currentMood != null) {
    map[currentMood] = _AlignedTokens(
      spacing: spacing ?? 'spacingM',
      typography: typography ?? 'cardDetail',
    );
  }
  return map;
}

Future<void> _writeSummary({
  required List<_IntegrationReport> integrations,
  required double integrationScore,
}) async {
  final buffer = StringBuffer()
    ..writeln('AI MOOD INTEGRATION SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Integration score: ${integrationScore.toStringAsFixed(2)}')
    ..writeln();

  for (final integration in integrations) {
    final adj = integration.adjustments;
    buffer
      ..writeln('Mood: ${integration.mood}')
      ..writeln('  Engagement score: ${adj.engagementScore.toStringAsFixed(2)}')
      ..writeln('  Color token: ${adj.colorToken}')
      ..writeln('  Spacing token: ${adj.spacingToken}')
      ..writeln('  Typography token: ${adj.typographyToken}')
      ..writeln();
  }

  await File(_outputPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int moods,
  required int adjustedTokens,
  required double integrationScore,
  required int durationMs,
}) async {
  final payload = <String, Object?>{
    'event': 'ai_mood_integrated',
    'timestamp': DateTime.now().toIso8601String(),
    'moods': moods,
    'adjusted_tokens': adjustedTokens,
    'integration_score': double.parse(integrationScore.toStringAsFixed(2)),
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
      'ai_mood_integrator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _IntegrationReport {
  const _IntegrationReport({required this.mood, required this.adjustments});

  final String mood;
  final _MoodAdjustments adjustments;
}

class _MoodAdjustments {
  const _MoodAdjustments({
    required this.mood,
    required this.engagementScore,
    required this.colorToken,
    required this.spacingToken,
    required this.typographyToken,
  });

  final String mood;
  final double engagementScore;
  final String colorToken;
  final String spacingToken;
  final String typographyToken;
}

class _AlignedTokens {
  const _AlignedTokens({required this.spacing, required this.typography});

  final String spacing;
  final String typography;
}
