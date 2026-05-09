import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _aiSummaryPath = '$_reportsDir/ai_personalization_summary.txt';
const String _adaptiveSummaryPath =
    '$_reportsDir/adaptive_content_evolution_summary.txt';
const String _tunerSummaryPath = '$_reportsDir/adaptive_loop_tuner_summary.txt';
const String _summaryTextPath = '$_reportsDir/ai_feedback_loop_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ai_feedback_loop_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final dashboard = AiFeedbackLoopDashboard();
  final ok = await dashboard.run();
  if (!ok) {
    exitCode = 2;
  }
}

class AiFeedbackLoopDashboard {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final aiSummary = await _parseAiSummary();
    if (aiSummary.sampleSize < 100) {
      stderr.writeln(
        'AI personalization sample below threshold (${aiSummary.sampleSize}).',
      );
      return false;
    }
    if (aiSummary.weights.isEmpty) {
      stderr.writeln('AI personalization weights missing.');
      return false;
    }
    final adaptiveTopics = await _parseAdaptiveSummary();
    final tunerData = await _parseTunerSummary();
    if (tunerData.avgEvUplift < 0) {
      stderr.writeln(
        'Average EV uplift ${tunerData.avgEvUplift * 100}% below 0%.',
      );
      return false;
    }

    final clusterStats = _aggregateClusters(
      aiSummary: aiSummary,
      tunerTopics: tunerData.topics,
    );
    final moduleInsights = _buildModuleInsights(
      adaptiveTopics: adaptiveTopics,
      tunerTopics: tunerData.topics,
    );
    final uxCorrelations = _computeUxCorrelations(
      adaptiveTopics,
      tunerData.topics,
    );

    final minClusterUplift = clusterStats
        .map((stat) => stat.uplift)
        .fold<double>(double.infinity, min);
    if (minClusterUplift < 0) {
      stderr.writeln(
        'Cluster uplift below zero (${(minClusterUplift * 100).toStringAsFixed(2)}%).',
      );
      return false;
    }

    final summaryText = _buildTextSummary(
      aiSummary: aiSummary,
      tunerData: tunerData,
      clusters: clusterStats,
      modules: moduleInsights,
      correlations: uxCorrelations,
      durationMs: stopwatch.elapsedMilliseconds,
    );
    final summaryJson = _buildJsonSummary(
      aiSummary: aiSummary,
      tunerData: tunerData,
      clusters: clusterStats,
      modules: moduleInsights,
      correlations: uxCorrelations,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(
        clusters: clusterStats,
        modules: moduleInsights,
        avgEv: tunerData.avgEvUplift,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    return true;
  }

  Future<_AiSummary> _parseAiSummary() async {
    final file = File(_aiSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_aiSummaryPath');
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
      throw StateError('Missing $_adaptiveSummaryPath');
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
            topic: currentTopic,
            stat: mappedStat,
            progress: progress,
            aiWeight: aiWeight,
            recommendationScore: recommendationScore,
            reinforcement: reinforcement,
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
        final match = RegExp(
          r'Mapped stat:\s*([^(]+)\(progress=([0-9.]+)\s*\)\s*weight=([0-9.]+)',
        ).firstMatch(trimmed);
        if (match != null) {
          mappedStat = match
              .group(1)!
              .trim()
              .toLowerCase()
              .replaceAll(' ', '_');
          progress = double.tryParse(match.group(2)!) ?? 0.5;
          aiWeight = double.tryParse(match.group(3)!) ?? 0.25;
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
        topic: currentTopic,
        stat: mappedStat,
        progress: progress,
        aiWeight: aiWeight,
        recommendationScore: recommendationScore,
        reinforcement: reinforcement,
        difficultyDelta: difficultyDelta,
      );
    }
    return topics;
  }

  Future<_TunerData> _parseTunerSummary() async {
    final file = File(_tunerSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_tunerSummaryPath');
    }
    final topics = <String, _TunedTopic>{};
    double avgEv = 0;
    String? currentTopic;
    String currentStat = 'discipline';
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Average EV uplift:')) {
        final match = RegExp(
          r'Average EV uplift:\s*([0-9.]+)%',
        ).firstMatch(trimmed);
        if (match != null) {
          avgEv = (double.tryParse(match.group(1)!) ?? 0) / 100;
        }
      } else if (trimmed.startsWith('- ')) {
        final match = RegExp(r'-\s*(.+)\s+\[(.+)\]').firstMatch(trimmed);
        if (match != null) {
          currentTopic = match.group(1)!.trim();
          currentStat = match.group(2)!.trim().toLowerCase();
        }
      } else if (trimmed.startsWith('weights:') && currentTopic != null) {
        final match = RegExp(
          r'weights:\s*ai=([0-9.]+)\s+adaptive=([0-9.]+)\s+tuned=([0-9.]+)',
        ).firstMatch(trimmed);
        if (match != null) {
          final ai = double.tryParse(match.group(1)!) ?? 0;
          final adaptive = double.tryParse(match.group(2)!) ?? ai;
          final tuned = double.tryParse(match.group(3)!) ?? adaptive;
          topics[currentTopic] = _TunedTopic(
            topic: currentTopic,
            stat: currentStat,
            baseWeight: ai,
            adaptiveWeight: adaptive,
            tunedWeight: tuned,
          );
        }
      }
    }
    return _TunerData(avgEvUplift: avgEv, topics: topics);
  }

  List<_ClusterStat> _aggregateClusters({
    required _AiSummary aiSummary,
    required Map<String, _TunedTopic> tunerTopics,
  }) {
    final clusterTotals = <String, List<double>>{};
    final clusterBase = <String, List<double>>{};
    tunerTopics.forEach((topic, tuned) {
      clusterTotals.putIfAbsent(tuned.stat, () => []).add(tuned.tunedWeight);
      clusterBase.putIfAbsent(tuned.stat, () => []).add(tuned.baseWeight);
    });
    final stats = <_ClusterStat>[];
    clusterTotals.forEach((stat, tunedValues) {
      final baseVals = clusterBase[stat] ?? const [];
      if (tunedValues.isEmpty || baseVals.isEmpty) return;
      final tunedAvg = tunedValues.reduce((a, b) => a + b) / tunedValues.length;
      final baseAvg = baseVals.reduce((a, b) => a + b) / baseVals.length;
      final aiWeight = aiSummary.weights[stat] ?? baseAvg;
      final uplift = tunedAvg - baseAvg;
      stats.add(
        _ClusterStat(
          stat: stat,
          aiWeight: aiWeight,
          baseWeight: baseAvg,
          tunedWeight: tunedAvg,
          uplift: uplift,
        ),
      );
    });
    stats.sort((a, b) => b.uplift.compareTo(a.uplift));
    return stats;
  }

  List<_ModuleInsight> _buildModuleInsights({
    required Map<String, _AdaptiveTopic> adaptiveTopics,
    required Map<String, _TunedTopic> tunerTopics,
  }) {
    final insights = <_ModuleInsight>[];
    adaptiveTopics.forEach((topic, adaptive) {
      final tuned = tunerTopics[topic];
      if (tuned == null) return;
      final reinforcementScore =
          adaptive.recommendationScore +
          (adaptive.reinforcement ? 15 : 0) +
          (1 - adaptive.progress) * 100;
      insights.add(
        _ModuleInsight(
          topic: topic,
          stat: adaptive.stat,
          reinforcementScore: reinforcementScore,
          tunedWeight: tuned.tunedWeight,
          difficultyDelta: adaptive.difficultyDelta,
        ),
      );
    });
    insights.sort(
      (a, b) => b.reinforcementScore.compareTo(a.reinforcementScore),
    );
    return insights;
  }

  List<_CorrelationInfo> _computeUxCorrelations(
    Map<String, _AdaptiveTopic> adaptiveTopics,
    Map<String, _TunedTopic> tunerTopics,
  ) {
    final perStat = <String, List<_CorrelationPair>>{};
    adaptiveTopics.forEach((topic, adaptive) {
      final tuned = tunerTopics[topic];
      if (tuned == null) return;
      perStat
          .putIfAbsent(adaptive.stat, () => [])
          .add(
            _CorrelationPair(
              x: 1 - adaptive.progress,
              y: tuned.tunedWeight - tuned.adaptiveWeight,
            ),
          );
    });
    final correlations = <_CorrelationInfo>[];
    perStat.forEach((stat, pairs) {
      if (pairs.length < 2) {
        correlations.add(_CorrelationInfo(stat: stat, correlation: 0));
        return;
      }
      final meanX =
          pairs.map((p) => p.x).reduce((a, b) => a + b) / pairs.length;
      final meanY =
          pairs.map((p) => p.y).reduce((a, b) => a + b) / pairs.length;
      var numerator = 0.0;
      var denomX = 0.0;
      var denomY = 0.0;
      for (final pair in pairs) {
        final dx = pair.x - meanX;
        final dy = pair.y - meanY;
        numerator += dx * dy;
        denomX += dx * dx;
        denomY += dy * dy;
      }
      final denominator = sqrt(denomX * denomY);
      final corr = denominator == 0 ? 0 : numerator / denominator;
      correlations.add(
        _CorrelationInfo(stat: stat, correlation: corr.clamp(-1, 1).toDouble()),
      );
    });
    correlations.sort((a, b) => b.correlation.compareTo(a.correlation));
    return correlations;
  }

  String _buildTextSummary({
    required _AiSummary aiSummary,
    required _TunerData tunerData,
    required List<_ClusterStat> clusters,
    required List<_ModuleInsight> modules,
    required List<_CorrelationInfo> correlations,
    required int durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('AI FEEDBACK LOOP DASHBOARD')
      ..writeln('===========================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Sample size: ${aiSummary.sampleSize}')
      ..writeln(
        'Average EV uplift: ${(tunerData.avgEvUplift * 100).toStringAsFixed(2)}%',
      )
      ..writeln();
    buffer
      ..writeln('Clusters:')
      ..writeln('---------');
    for (final cluster in clusters) {
      buffer.writeln(
        '${cluster.stat} → base ${cluster.baseWeight.toStringAsFixed(2)} | tuned ${cluster.tunedWeight.toStringAsFixed(2)} | uplift ${(cluster.uplift * 100).toStringAsFixed(1)}%',
      );
    }
    buffer
      ..writeln()
      ..writeln('Top reinforcement candidates:')
      ..writeln('-----------------------------');
    for (final module in modules.take(10)) {
      buffer.writeln(
        '${module.topic} [${module.stat}] score=${module.reinforcementScore.toStringAsFixed(1)} tuned=${module.tunedWeight.toStringAsFixed(2)} diffΔ=${module.difficultyDelta.toStringAsFixed(2)}',
      );
    }
    buffer
      ..writeln()
      ..writeln('UX response correlations:')
      ..writeln('-------------------------');
    for (final corr in correlations) {
      buffer.writeln(
        '${corr.stat}: ${(corr.correlation * 100).toStringAsFixed(1)}%',
      );
    }
    return buffer.toString();
  }

  Map<String, Object?> _buildJsonSummary({
    required _AiSummary aiSummary,
    required _TunerData tunerData,
    required List<_ClusterStat> clusters,
    required List<_ModuleInsight> modules,
    required List<_CorrelationInfo> correlations,
    required int durationMs,
  }) {
    return {
      'generated': DateTime.now().toIso8601String(),
      'duration_ms': durationMs,
      'sample_size': aiSummary.sampleSize,
      'avg_ev_uplift': tunerData.avgEvUplift,
      'clusters': clusters
          .map(
            (cluster) => {
              'stat': cluster.stat,
              'base_weight': cluster.baseWeight,
              'tuned_weight': cluster.tunedWeight,
              'uplift': cluster.uplift,
            },
          )
          .toList(),
      'modules': modules
          .map(
            (module) => {
              'topic': module.topic,
              'stat': module.stat,
              'reinforcement_score': module.reinforcementScore,
              'tuned_weight': module.tunedWeight,
              'difficulty_delta': module.difficultyDelta,
            },
          )
          .toList(),
      'ux_correlations': correlations
          .map((corr) => {'stat': corr.stat, 'correlation': corr.correlation})
          .toList(),
    };
  }

  Future<void> _appendTelemetry({
    required List<_ClusterStat> clusters,
    required List<_ModuleInsight> modules,
    required double avgEv,
    required int durationMs,
  }) async {
    final payload = {
      'event': 'ai_feedback_loop_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'avg_ev_uplift': avgEv,
      'clusters': clusters
          .map((cluster) => {'stat': cluster.stat, 'uplift': cluster.uplift})
          .toList(),
      'top_modules': modules.take(10).map((module) => module.topic).toList(),
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
    required this.topic,
    required this.stat,
    required this.progress,
    required this.aiWeight,
    required this.recommendationScore,
    required this.reinforcement,
    required this.difficultyDelta,
  });

  final String topic;
  final String stat;
  final double progress;
  final double aiWeight;
  final double recommendationScore;
  final bool reinforcement;
  final double difficultyDelta;
}

class _TunedTopic {
  _TunedTopic({
    required this.topic,
    required this.stat,
    required this.baseWeight,
    required this.adaptiveWeight,
    required this.tunedWeight,
  });

  final String topic;
  final String stat;
  final double baseWeight;
  final double adaptiveWeight;
  final double tunedWeight;
}

class _TunerData {
  _TunerData({required this.avgEvUplift, required this.topics});

  final double avgEvUplift;
  final Map<String, _TunedTopic> topics;
}

class _ClusterStat {
  _ClusterStat({
    required this.stat,
    required this.aiWeight,
    required this.baseWeight,
    required this.tunedWeight,
    required this.uplift,
  });

  final String stat;
  final double aiWeight;
  final double baseWeight;
  final double tunedWeight;
  final double uplift;
}

class _ModuleInsight {
  _ModuleInsight({
    required this.topic,
    required this.stat,
    required this.reinforcementScore,
    required this.tunedWeight,
    required this.difficultyDelta,
  });

  final String topic;
  final String stat;
  final double reinforcementScore;
  final double tunedWeight;
  final double difficultyDelta;
}

class _CorrelationPair {
  _CorrelationPair({required this.x, required this.y});

  final double x;
  final double y;
}

class _CorrelationInfo {
  _CorrelationInfo({required this.stat, required this.correlation});

  final String stat;
  final double correlation;
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
