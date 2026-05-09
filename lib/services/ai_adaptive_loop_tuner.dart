import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _aiSummaryPath = '$_reportsDir/ai_personalization_summary.txt';
const String _adaptiveSummaryPath =
    '$_reportsDir/adaptive_content_evolution_summary.txt';
const String _summaryPath = '$_reportsDir/adaptive_loop_tuner_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _evTarget = 0.10;

Future<void> main(List<String> args) async {
  final tuner = AiAdaptiveLoopTuner();
  final ok = await tuner.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiAdaptiveLoopTuner {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final aiSummary = await _parseAiSummary();
    if (aiSummary.sampleSize < 100) {
      stderr.writeln(
        'Telemetry sample below threshold (${aiSummary.sampleSize}). Need >= 100.',
      );
      return false;
    }
    if (aiSummary.weights.isEmpty) {
      stderr.writeln('AI summary missing cluster weights.');
      return false;
    }
    final adaptiveTopics = await _parseAdaptiveSummary();
    if (adaptiveTopics.isEmpty) {
      stderr.writeln('Adaptive content evolution summary missing topics.');
      return false;
    }

    final weightAvg =
        aiSummary.weights.values.reduce((a, b) => a + b) /
        aiSummary.weights.length;
    final results = <_LoopAdjustment>[];
    double evUplift = 0;
    for (final topic in adaptiveTopics.values) {
      final aiWeight = aiSummary.weights[topic.mappedStat] ?? weightAvg;
      final progressGap = (1 - topic.progress).clamp(0, 1);
      final recommendationFactor = (topic.recommendationScore / 100).clamp(
        0,
        1,
      );
      final reinforcementBoost = topic.needsReinforcement ? 0.15 : 0;
      final tunedWeight =
          aiWeight +
          (progressGap * 0.4) +
          (recommendationFactor * 0.2) +
          reinforcementBoost +
          0.05;
      final normalized = tunedWeight.clamp(0.05, 1.0);
      final delta = normalized - topic.aiWeight;
      evUplift += delta;
      results.add(
        _LoopAdjustment(
          topic: topic.name,
          stat: topic.mappedStat,
          baseWeight: aiWeight,
          adaptiveWeight: topic.aiWeight,
          tunedWeight: normalized,
          progress: topic.progress,
          recommendationScore: topic.recommendationScore,
          reinforcement: topic.needsReinforcement,
          difficultyDelta: topic.difficultyDelta,
        ),
      );
    }

    final avgEv = evUplift / results.length;
    final passEv = avgEv >= _evTarget;

    final summary = _buildSummary(
      adjustments: results,
      sampleSize: aiSummary.sampleSize,
      avgEv: avgEv,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryPath).writeAsString(summary);
      await _appendTelemetry(
        adjustments: results,
        avgEv: avgEv,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    if (!passEv) {
      stderr.writeln(
        'EV uplift ${(avgEv * 100).toStringAsFixed(2)}% below target ${_evTarget * 100}%.',
      );
    }
    return passEv;
  }

  Future<_AiSummary> _parseAiSummary() async {
    final file = File(_aiSummaryPath);
    if (!await file.exists()) {
      throw StateError('AI summary missing at $_aiSummaryPath');
    }
    final weights = <String, double>{};
    var sampleSize = 0;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Sample size:')) {
        sampleSize =
            int.tryParse(trimmed.split(':').last.trim().split(' ').first) ?? 0;
      } else if (trimmed.startsWith('•')) {
        final match = RegExp(r'•\s*(.+?)\s*→\s*([0-9.]+)%').firstMatch(trimmed);
        if (match != null) {
          final stat = match
              .group(1)!
              .trim()
              .toLowerCase()
              .replaceAll(' ', '_');
          final value = double.tryParse(match.group(2)!) ?? 0;
          weights[stat] = value / 100;
        }
      }
    }
    return _AiSummary(sampleSize: sampleSize, weights: weights);
  }

  Future<Map<String, _AdaptiveTopic>> _parseAdaptiveSummary() async {
    final file = File(_adaptiveSummaryPath);
    if (!await file.exists()) {
      throw StateError(
        'Adaptive content evolution summary missing at $_adaptiveSummaryPath',
      );
    }
    final topics = <String, _AdaptiveTopic>{};
    String? currentTopic;
    String mappedStat = 'discipline';
    double progress = 0.5;
    double aiWeight = 0.25;
    double recommendationScore = 0;
    bool reinforcement = false;
    double difficultyDelta = 0;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Topic:')) {
        if (currentTopic != null) {
          topics[currentTopic] = _AdaptiveTopic(
            name: currentTopic,
            mappedStat: mappedStat,
            progress: progress,
            aiWeight: aiWeight,
            recommendationScore: recommendationScore,
            needsReinforcement: reinforcement,
            difficultyDelta: difficultyDelta,
          );
        }
        currentTopic = trimmed.substring('- Topic:'.length).trim();
        mappedStat = 'discipline';
        progress = 0.5;
        aiWeight = 0.25;
        recommendationScore = 0;
        reinforcement = false;
        difficultyDelta = 0;
      } else if (trimmed.startsWith('Mapped stat:')) {
        final statMatch = RegExp(
          r'Mapped stat:\s*([^(]+)\(progress=([0-9.]+)\s*\)\s*weight=([0-9.]+)',
        ).firstMatch(trimmed);
        if (statMatch != null) {
          mappedStat = statMatch
              .group(1)!
              .trim()
              .toLowerCase()
              .replaceAll(' ', '_');
          progress = double.tryParse(statMatch.group(2)!) ?? 0.5;
          aiWeight = double.tryParse(statMatch.group(3)!) ?? 0.25;
        }
      } else if (trimmed.startsWith('Recommendation score:')) {
        recommendationScore =
            double.tryParse(trimmed.split(':').last.trim()) ?? 0;
      } else if (trimmed.contains('⚠')) {
        reinforcement = true;
      } else if (trimmed.startsWith('Difficulty:')) {
        final diffMatch = RegExp(
          r'Difficulty:\s*([0-9.]+)\s*→\s*([0-9.]+)',
        ).firstMatch(trimmed);
        if (diffMatch != null) {
          final before = double.tryParse(diffMatch.group(1)!) ?? 0;
          final after = double.tryParse(diffMatch.group(2)!) ?? before;
          difficultyDelta = after - before;
        }
      }
    }
    if (currentTopic != null) {
      topics[currentTopic] = _AdaptiveTopic(
        name: currentTopic,
        mappedStat: mappedStat,
        progress: progress,
        aiWeight: aiWeight,
        recommendationScore: recommendationScore,
        needsReinforcement: reinforcement,
        difficultyDelta: difficultyDelta,
      );
    }
    return topics;
  }

  String _buildSummary({
    required List<_LoopAdjustment> adjustments,
    required int sampleSize,
    required double avgEv,
    required int durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('AI ADAPTIVE LOOP TUNER SUMMARY')
      ..writeln('==============================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Sample size: $sampleSize users')
      ..writeln(
        'Average EV uplift: ${(avgEv * 100).toStringAsFixed(2)}% (target ${(_evTarget * 100).toStringAsFixed(0)}%)',
      )
      ..writeln('Topics tuned: ${adjustments.length}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln();
    adjustments.sort((a, b) => b.delta.compareTo(a.delta));
    for (final adj in adjustments.take(50)) {
      buffer
        ..writeln('- ${adj.topic} [${adj.stat}]')
        ..writeln(
          '  weights: ai=${adj.baseWeight.toStringAsFixed(2)} '
          'adaptive=${adj.adaptiveWeight.toStringAsFixed(2)} '
          'tuned=${adj.tunedWeight.toStringAsFixed(2)} '
          '(Δ ${(adj.delta * 100).toStringAsFixed(1)}%)',
        )
        ..writeln(
          '  progress=${adj.progress.toStringAsFixed(2)} '
          'recScore=${adj.recommendationScore.toStringAsFixed(1)} '
          'difficultyΔ=${adj.difficultyDelta.toStringAsFixed(2)} '
          '${adj.reinforcement ? '⚠ reinforcement' : 'stable'}',
        )
        ..writeln();
    }
    if (adjustments.length > 50) {
      buffer.writeln(
        '... ${adjustments.length - 50} additional topics omitted',
      );
    }
    return buffer.toString();
  }

  Future<void> _appendTelemetry({
    required List<_LoopAdjustment> adjustments,
    required double avgEv,
    required int durationMs,
  }) async {
    final payload = {
      'event': 'adaptive_loop_tuner_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'avg_ev_uplift': avgEv,
      'topics': adjustments
          .map(
            (adj) => {
              'topic': adj.topic,
              'stat': adj.stat,
              'delta': adj.delta,
              'tuned_weight': adj.tunedWeight,
            },
          )
          .toList(),
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }
}

class _AiSummary {
  _AiSummary({required this.sampleSize, required this.weights});

  final int sampleSize;
  final Map<String, double> weights;
}

class _AdaptiveTopic {
  _AdaptiveTopic({
    required this.name,
    required this.mappedStat,
    required this.progress,
    required this.aiWeight,
    required this.recommendationScore,
    required this.needsReinforcement,
    required this.difficultyDelta,
  });

  final String name;
  final String mappedStat;
  final double progress;
  final double aiWeight;
  final double recommendationScore;
  final bool needsReinforcement;
  final double difficultyDelta;
}

class _LoopAdjustment {
  _LoopAdjustment({
    required this.topic,
    required this.stat,
    required this.baseWeight,
    required this.adaptiveWeight,
    required this.tunedWeight,
    required this.progress,
    required this.recommendationScore,
    required this.reinforcement,
    required this.difficultyDelta,
  });

  final String topic;
  final String stat;
  final double baseWeight;
  final double adaptiveWeight;
  final double tunedWeight;
  final double progress;
  final double recommendationScore;
  final bool reinforcement;
  final double difficultyDelta;

  double get delta => tunedWeight - adaptiveWeight;
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
