import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _aiSummaryPath = '$_reportsDir/ai_personalization_summary.txt';
const String _statsProfilePath = '$_reportsDir/player_stats_profile.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _summaryPath =
    '$_reportsDir/adaptive_content_evolution_summary.txt';

const double _minProgressForStrength = 0.6;
const double _minAvgDifficulty = 0.4;
const double _weightFloor = 0.05;

Future<void> main(List<String> args) async {
  final tool = AdaptiveContentEvolutionPass();
  final ok = await tool.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AdaptiveContentEvolutionPass {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final aiSummary = await _loadAiSummary();
    if (aiSummary.sampleSize < 100) {
      stderr.writeln(
        'AI personalization sample below threshold (${aiSummary.sampleSize}). Need >= 100.',
      );
      return false;
    }
    if (!aiSummary.weights.values.every((w) => w >= _weightFloor)) {
      stderr.writeln('AI weights contain invalid values (too low).');
      return false;
    }

    final statsProfile = await _loadStatsProfile();
    final contentTopics = await _scanContentTopics();
    if (contentTopics.isEmpty) {
      stderr.writeln('No content topics detected under content/**/v1/.');
      return false;
    }

    final adjustments = <_TopicAdjustment>[];
    for (final topic in contentTopics) {
      final statKey = _mapTopicToStat(topic.name);
      final weight =
          aiSummary.weights[statKey] ?? (1 / aiSummary.weights.length);
      final progress = statsProfile[statKey]?.progress ?? 0.5;
      final difficultyMultiplier = 0.85 + weight;
      final newDifficulty = _clamp(
        topic.avgDifficulty * difficultyMultiplier,
        0.1,
        1.0,
      );
      final recommendationScore =
          (((weight * 0.7) + ((1 - progress) * 0.3)).clamp(0, 1) * 100)
              .toDouble();
      final needsReinforcement =
          progress < _minProgressForStrength ||
          (topic.avgDifficulty < _minAvgDifficulty && weight > 0.2);
      adjustments.add(
        _TopicAdjustment(
          name: topic.name,
          path: topic.path,
          baseDifficulty: topic.avgDifficulty,
          adjustedDifficulty: newDifficulty,
          recommendationScore: recommendationScore,
          weight: weight,
          mappedStat: statKey,
          needsReinforcement: needsReinforcement,
          drillCount: topic.drillCount,
        ),
      );
    }

    final summary = _buildSummary(
      adjustments: adjustments,
      statsProfile: statsProfile,
      aiSummary: aiSummary,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryPath).writeAsString(summary);
      await _appendTelemetry(
        adjustments: adjustments,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    return true;
  }

  Future<_AiSummary> _loadAiSummary() async {
    final file = File(_aiSummaryPath);
    if (!await file.exists()) {
      throw StateError('AI personalization summary missing at $_aiSummaryPath');
    }
    final lines = await file.readAsLines();
    final weights = <String, double>{};
    var sampleSize = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Sample size:')) {
        sampleSize =
            int.tryParse(trimmed.split(':').last.trim().split(' ').first) ?? 0;
      } else if (trimmed.startsWith('•')) {
        final parts = trimmed
            .replaceAll('•', '')
            .split('→')
            .map((part) => part.trim())
            .toList();
        if (parts.length == 2) {
          final stat = _statAliases[parts[0]] ?? parts[0];
          final value = double.tryParse(parts[1].replaceAll('%', '')) ?? 0;
          weights[stat] = value / 100;
        }
      }
    }
    if (weights.isEmpty) {
      throw StateError('Unable to parse AI cluster weights from summary.');
    }
    return _AiSummary(sampleSize: sampleSize, weights: weights);
  }

  Future<Map<String, _StatProfile>> _loadStatsProfile() async {
    final file = File(_statsProfilePath);
    if (!await file.exists()) return {};
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final result = <String, _StatProfile>{};
      decoded.forEach((key, value) {
        final map = value is Map ? value.cast<String, Object?>() : {};
        result[key] = _StatProfile(
          id: key,
          progress: (map['progress_0_1'] as num?)?.toDouble() ?? 0.5,
          rank: map['rank']?.toString() ?? 'Novice',
        );
      });
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<List<_ContentTopic>> _scanContentTopics() async {
    final contentDir = Directory('content');
    if (!await contentDir.exists()) return const [];
    final topics = <_ContentTopic>[];
    await for (final entity in contentDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! Directory) continue;
      final segments = entity.path.split(Platform.pathSeparator);
      if (segments.isEmpty || segments.last != 'v1') continue;
      final drillsFile = File('${entity.path}/drills.jsonl');
      final summary = await _summarizeDrills(drillsFile);
      topics.add(
        _ContentTopic(
          name: segments[segments.length - 2],
          path: entity.path,
          drillCount: summary.count,
          avgDifficulty: summary.avgDifficulty,
        ),
      );
    }
    return topics;
  }

  Future<_DrillSummary> _summarizeDrills(File file) async {
    if (!await file.exists()) {
      return const _DrillSummary(count: 0, avgDifficulty: 0.5);
    }
    try {
      final lines = await file.readAsLines();
      var total = 0.0;
      var count = 0;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        try {
          final decoded = json.decode(trimmed);
          if (decoded is Map<String, Object?>) {
            final difficulty =
                (decoded['difficulty'] as num?)?.toDouble() ?? double.nan;
            if (difficulty.isFinite) {
              total += difficulty;
              count++;
            }
          }
        } catch (_) {
          // ignore malformed blocks
        }
      }
      if (count == 0) {
        return const _DrillSummary(count: 0, avgDifficulty: 0.5);
      }
      return _DrillSummary(count: count, avgDifficulty: total / count);
    } catch (_) {
      return const _DrillSummary(count: 0, avgDifficulty: 0.5);
    }
  }

  String _buildSummary({
    required List<_TopicAdjustment> adjustments,
    required Map<String, _StatProfile> statsProfile,
    required _AiSummary aiSummary,
    required int durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('ADAPTIVE CONTENT EVOLUTION SUMMARY')
      ..writeln('==================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('AI sample size: ${aiSummary.sampleSize}')
      ..writeln('Topics analyzed: ${adjustments.length}')
      ..writeln();
    for (final adjustment in adjustments) {
      buffer
        ..writeln('- Topic: ${adjustment.name}')
        ..writeln('  Path: ${adjustment.path}')
        ..writeln(
          '  Mapped stat: ${adjustment.mappedStat} '
          '(progress=${(statsProfile[adjustment.mappedStat]?.progress ?? 0.5).toStringAsFixed(2)}) '
          'weight=${adjustment.weight.toStringAsFixed(2)}',
        )
        ..writeln(
          '  Difficulty: ${adjustment.baseDifficulty.toStringAsFixed(2)} → '
          '${adjustment.adjustedDifficulty.toStringAsFixed(2)}',
        )
        ..writeln(
          '  Recommendation score: ${adjustment.recommendationScore.toStringAsFixed(1)}',
        )
        ..writeln(
          '  Drills analyzed: ${adjustment.drillCount} '
          '${adjustment.needsReinforcement ? '⚠ Reinforcement required' : '✓ Stable'}',
        )
        ..writeln();
    }
    return buffer.toString();
  }

  Future<void> _appendTelemetry({
    required List<_TopicAdjustment> adjustments,
    required int durationMs,
  }) async {
    final payload = {
      'event': 'adaptive_content_evolution_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'topics': adjustments
          .map(
            (adj) => {
              'name': adj.name,
              'stat': adj.mappedStat,
              'weight': adj.weight,
              'adjusted_difficulty': adj.adjustedDifficulty,
              'recommendation_score': adj.recommendationScore,
              'reinforcement': adj.needsReinforcement,
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

class _ContentTopic {
  _ContentTopic({
    required this.name,
    required this.path,
    required this.drillCount,
    required this.avgDifficulty,
  });

  final String name;
  final String path;
  final int drillCount;
  final double avgDifficulty;
}

class _DrillSummary {
  const _DrillSummary({required this.count, required this.avgDifficulty});

  final int count;
  final double avgDifficulty;
}

class _TopicAdjustment {
  _TopicAdjustment({
    required this.name,
    required this.path,
    required this.baseDifficulty,
    required this.adjustedDifficulty,
    required this.recommendationScore,
    required this.weight,
    required this.mappedStat,
    required this.needsReinforcement,
    required this.drillCount,
  });

  final String name;
  final String path;
  final double baseDifficulty;
  final double adjustedDifficulty;
  final double recommendationScore;
  final double weight;
  final String mappedStat;
  final bool needsReinforcement;
  final int drillCount;
}

class _StatProfile {
  const _StatProfile({
    required this.id,
    required this.progress,
    required this.rank,
  });

  final String id;
  final double progress;
  final String rank;
}

String _mapTopicToStat(String topic) {
  final lower = topic.toLowerCase();
  for (final entry in _topicKeywords.entries) {
    if (entry.value.any(lower.contains)) {
      return entry.key;
    }
  }
  return 'discipline';
}

double _clamp(double value, double min, double max) {
  return value < min
      ? min
      : value > max
      ? max
      : value;
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

const Map<String, List<String>> _topicKeywords = {
  'preflop_mastery': ['preflop', 'opening', 'blind_vs_blind', 'open', 'range'],
  'three_bet_mastery': ['3bet', 'threebet', 'fourbet', '4bet', 'squeeze'],
  'bluff_control': ['bluff', 'cbet', 'barrel', 'bet_sizing', 'probe'],
  'discipline': [
    'mental',
    'study',
    'bankroll',
    'review',
    'final_table',
    'live_speech',
    'workflow',
  ],
};

const Map<String, String> _statAliases = {
  'preflop mastery': 'preflop_mastery',
  'three bet mastery': 'three_bet_mastery',
  '3bet mastery': 'three_bet_mastery',
  'discipline': 'discipline',
  'bluff control': 'bluff_control',
};
