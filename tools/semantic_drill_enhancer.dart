import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _semanticSummaryPath =
    '$_reportsDir/semantic_expansion_summary.txt';
const String _adaptiveSummaryPath =
    '$_reportsDir/adaptive_content_evolution_summary.txt';
const String _aiSummaryPath = '$_reportsDir/ai_personalization_summary.txt';
const String _traitsProfilePath = '$_reportsDir/player_traits_profile.json';
const String _summaryPath = '$_reportsDir/semantic_drill_enhancer_summary.txt';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const double _evTarget = 0.09; // 9%

Future<void> main(List<String> args) async {
  final enhancer = SemanticDrillEnhancer();
  final ok = await enhancer.run();
  if (!ok) {
    exitCode = 2;
  }
}

class SemanticDrillEnhancer {
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
    final semanticTemplates = await _parseSemanticSummary();
    final traitCount = await _loadTraitCount();

    final weightValues = aiSummary.weights.values.toList();
    final weightMax = weightValues.isEmpty ? 0.0 : weightValues.reduce(max);
    final weightMin = weightValues.isEmpty ? 0.0 : weightValues.reduce(min);
    final weightRange = (weightMax - weightMin).abs();

    final enhancements = <_DrillEnhancement>[];
    final topicUpliftSum = <String, double>{};
    final topicUpliftCount = <String, int>{};

    for (final template in semanticTemplates) {
      final adaptive = adaptiveTopics[template.topic];
      if (adaptive == null) {
        stderr.writeln('Missing adaptive data for topic ${template.topic}.');
        return false;
      }
      final weight = aiSummary.weights[adaptive.stat];
      if (weight == null) {
        stderr.writeln(
          'Missing AI weight for stat ${adaptive.stat} (topic ${template.topic}).',
        );
        return false;
      }
      final baselineAccuracy = adaptive.accuracy;
      if (!baselineAccuracy.isFinite) {
        stderr.writeln('Missing baseline accuracy for ${template.topic}.');
        return false;
      }
      final targetAccuracy = template.targetAccuracy;

      final accuracyGap = targetAccuracy - baselineAccuracy;
      final clusterConfidence = weightRange == 0
          ? 0.5
          : ((weight - weightMin) / weightRange).clamp(0, 1);
      final recFactor = (adaptive.recommendationScore / 100).clamp(0, 1);
      final positiveGap = max(0, accuracyGap);
      final traitMultiplier = 1 + (0.05 * traitCount);
      final reinforcementFactor =
          positiveGap * clusterConfidence * traitMultiplier;
      final difficultyRelief = (1 - baselineAccuracy).clamp(0, 1) * 0.25;
      final baseWeight =
          (weight * 0.5) +
          (recFactor * 0.3) +
          difficultyRelief +
          (adaptive.reinforcement ? 0.15 : 0.0);
      final rawUplift = reinforcementFactor * max(baseWeight, 0);
      final bool needsNerf =
          baselineAccuracy > targetAccuracy + 0.05 || baselineAccuracy > 0.85;
      final double uplift = needsNerf ? 0.0 : rawUplift.clamp(0, 0.3);
      final bool clampedMax = !needsNerf && rawUplift > 0.3;
      final bool clampedMin = uplift <= 0.000001;
      final double tunedDifficulty = needsNerf
          ? (template.difficulty -
                    min(
                      0.05,
                      ((baselineAccuracy - targetAccuracy).abs().clamp(0, 1) *
                              0.25) +
                          max(0, baselineAccuracy - 0.85) * 0.1,
                    ))
                .clamp(0.05, 1.0)
          : (template.difficulty + uplift).clamp(0.05, 1.0);
      final hintDensity = _hintDensity(
        aiWeight: weight,
        baselineAccuracy: baselineAccuracy,
        targetAccuracy: targetAccuracy,
      );

      topicUpliftSum[template.topic] =
          (topicUpliftSum[template.topic] ?? 0) + uplift;
      topicUpliftCount[template.topic] =
          (topicUpliftCount[template.topic] ?? 0) + 1;

      enhancements.add(
        _DrillEnhancement(
          topic: template.topic,
          kind: template.kind,
          originalDifficulty: template.difficulty,
          tunedDifficulty: tunedDifficulty,
          hintDensity: hintDensity,
          strategy: template.strategy,
          stat: adaptive.stat,
          aiWeight: weight,
          accuracyTarget: targetAccuracy,
          baselineAccuracy: baselineAccuracy,
          uplift: uplift,
          clampedMax: clampedMax,
          clampedMin: clampedMin,
          nerfed: needsNerf,
        ),
      );
    }

    if (enhancements.isEmpty) {
      stderr.writeln('No semantic templates available to enhance.');
      return false;
    }

    final topicAverages = <double>[];
    topicUpliftSum.forEach((topic, value) {
      final num clampedCount = (topicUpliftCount[topic] ?? 1).clamp(1, 1 << 20);
      topicAverages.add(value / clampedCount.toDouble());
    });
    final double avgEv = topicAverages.isEmpty
        ? 0.0
        : topicAverages.reduce((a, b) => a + b) / topicAverages.length;
    final meetsEv = avgEv >= _evTarget;

    final summary = _buildSummary(
      enhancements: enhancements,
      avgEv: avgEv,
      durationMs: stopwatch.elapsedMilliseconds,
    );

    await _withReportsWritable(() async {
      await File(_summaryPath).writeAsString(summary);
      await _appendTelemetry(
        avgEv: avgEv,
        enhancements: enhancements,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    });

    if (!meetsEv) {
      stderr.writeln(
        'EV uplift ${(avgEv * 100).toStringAsFixed(2)}% below target ${(_evTarget * 100).toStringAsFixed(1)}%.',
      );
    }
    return meetsEv;
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
    double recommendationScore = 0;
    bool reinforcement = false;

    void commit() {
      final topicName = currentTopic;
      if (topicName == null) return;
      topics[topicName] = _AdaptiveTopic(
        topic: topicName,
        stat: mappedStat,
        accuracy: progress,
        recommendationScore: recommendationScore,
        reinforcement: reinforcement,
      );
    }

    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Topic:')) {
        commit();
        currentTopic = trimmed.substring('- Topic:'.length).trim();
        mappedStat = 'discipline';
        progress = 0.5;
        recommendationScore = 0;
        reinforcement = false;
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
        }
      } else if (trimmed.startsWith('Recommendation score:')) {
        recommendationScore =
            double.tryParse(trimmed.split(':').last.trim()) ?? 0;
      } else if (trimmed.contains('⚠')) {
        reinforcement = true;
      }
    }
    commit();
    return topics;
  }

  Future<List<_SemanticTemplate>> _parseSemanticSummary() async {
    final file = File(_semanticSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_semanticSummaryPath');
    }
    final templates = <_SemanticTemplate>[];
    String? currentTopic;
    _TemplateCursor? cursor;

    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- Topic:')) {
        currentTopic = trimmed
            .substring('- Topic:'.length)
            .split('(')
            .first
            .trim();
      } else if (trimmed.startsWith('•')) {
        final match = RegExp(r'•\s*([A-Z]+):\s*(.+)').firstMatch(trimmed);
        if (match != null) {
          cursor = _TemplateCursor(
            topic: currentTopic ?? 'unknown_topic',
            kind: match.group(1)!,
            title: match.group(2)!,
          );
        }
      } else if (trimmed.startsWith('desc=')) {
        cursor?.description = trimmed.substring(5);
      } else if (trimmed.startsWith('difficulty=') && cursor != null) {
        final match = RegExp(
          r'difficulty=([0-9.]+)\s+targetAcc=([0-9.]+)\s+strategy=([\w_]+)',
        ).firstMatch(trimmed);
        if (match != null) {
          templates.add(
            cursor.toTemplate(
              difficulty: double.tryParse(match.group(1)!) ?? 0.5,
              targetAccuracy: double.tryParse(match.group(2)!) ?? 0.8,
              strategy: match.group(3)!,
            ),
          );
          cursor = null;
        }
      }
    }
    return templates;
  }

  double _hintDensity({
    required double aiWeight,
    required double baselineAccuracy,
    required double targetAccuracy,
  }) {
    var density = 0.35 + aiWeight * 0.25;
    if (baselineAccuracy < 0.7) {
      final severity = (0.7 - baselineAccuracy).clamp(0, 0.7);
      final weightBoost = aiWeight > 0.5 ? 1.2 : 1.0;
      density *= (1 + 1.2 * severity * weightBoost);
    }
    if (baselineAccuracy > targetAccuracy + 0.05) {
      density *= 0.9;
    }
    if (baselineAccuracy > 0.85) {
      final over = (baselineAccuracy - 0.85).clamp(0, 0.3);
      density *= (1 - 0.5 * over);
    }
    return density.clamp(0.2, 0.95);
  }

  String _buildSummary({
    required List<_DrillEnhancement> enhancements,
    required double avgEv,
    required int durationMs,
  }) {
    final buffer = StringBuffer()
      ..writeln('SEMANTIC DRILL ENHANCER SUMMARY')
      ..writeln('================================')
      ..writeln('Generated: ${DateTime.now().toIso8601String()}')
      ..writeln('Duration: ${durationMs}ms')
      ..writeln('Enhancements: ${enhancements.length}')
      ..writeln(
        'Average EV uplift: ${(avgEv * 100).toStringAsFixed(2)}% (target ${(_evTarget * 100).toStringAsFixed(1)}%)',
      )
      ..writeln();

    for (final enhancement in enhancements.take(50)) {
      buffer
        ..writeln(
          '- ${enhancement.topic} [${enhancement.stat}] ${enhancement.kind}',
        )
        ..writeln(
          '  difficulty: ${enhancement.originalDifficulty.toStringAsFixed(2)} → ${enhancement.tunedDifficulty.toStringAsFixed(2)}',
        )
        ..writeln(
          '  hint density: ${enhancement.hintDensity.toStringAsFixed(2)} (weight=${enhancement.aiWeight.toStringAsFixed(2)} accuracy=${enhancement.baselineAccuracy.toStringAsFixed(2)})',
        )
        ..writeln(
          '  strategy=${enhancement.strategy} uplift=${(enhancement.uplift * 100).toStringAsFixed(1)}%',
        );
      if (enhancement.clampedMax) {
        buffer.writeln('  clamp: reached +30% limit');
      }
      if (enhancement.clampedMin) {
        buffer.writeln('  clamp: floor 0% (nerf/balance)');
      }
      if (enhancement.nerfed) {
        buffer.writeln('  note: slight nerf applied for overperformance');
      }
      buffer.writeln();
    }
    if (enhancements.length > 50) {
      buffer.writeln(
        '... ${enhancements.length - 50} additional drills omitted',
      );
    }
    return buffer.toString();
  }

  Future<void> _appendTelemetry({
    required double avgEv,
    required List<_DrillEnhancement> enhancements,
    required int durationMs,
  }) async {
    final payload = {
      'event': 'semantic_drill_enhancer_completed',
      'timestamp': DateTime.now().toIso8601String(),
      'avg_ev_uplift': avgEv,
      'drills_adjusted': enhancements.length,
      'topics': enhancements
          .take(20)
          .map(
            (enhancement) => {
              'topic': enhancement.topic,
              'kind': enhancement.kind,
              'uplift': enhancement.uplift,
              'tuned_difficulty': enhancement.tunedDifficulty,
              'hint_density': enhancement.hintDensity,
            },
          )
          .toList(),
      'duration_ms': durationMs,
    };
    final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
    sink.writeln(jsonEncode(payload));
    await sink.close();
  }

  Future<int> _loadTraitCount() async {
    final file = File(_traitsProfilePath);
    if (!await file.exists()) return 0;
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final traits = decoded['traits'];
      if (traits is List) {
        return traits.length;
      }
    } catch (_) {}
    return 0;
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
    required this.accuracy,
    required this.recommendationScore,
    required this.reinforcement,
  });

  final String topic;
  final String stat;
  final double accuracy;
  final double recommendationScore;
  final bool reinforcement;
}

class _SemanticTemplate {
  _SemanticTemplate({
    required this.topic,
    required this.kind,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.targetAccuracy,
    required this.strategy,
  });

  final String topic;
  final String kind;
  final String title;
  final String description;
  final double difficulty;
  final double targetAccuracy;
  final String strategy;
}

class _TemplateCursor {
  _TemplateCursor({
    required this.topic,
    required this.kind,
    required this.title,
  });

  final String topic;
  final String kind;
  final String title;
  String? description;

  _SemanticTemplate toTemplate({
    required double difficulty,
    required double targetAccuracy,
    required String strategy,
  }) {
    return _SemanticTemplate(
      topic: topic,
      kind: kind,
      title: title,
      description: description ?? title,
      difficulty: difficulty,
      targetAccuracy: targetAccuracy,
      strategy: strategy,
    );
  }
}

class _DrillEnhancement {
  _DrillEnhancement({
    required this.topic,
    required this.kind,
    required this.originalDifficulty,
    required this.tunedDifficulty,
    required this.hintDensity,
    required this.strategy,
    required this.stat,
    required this.aiWeight,
    required this.accuracyTarget,
    required this.baselineAccuracy,
    required this.uplift,
    required this.clampedMax,
    required this.clampedMin,
    required this.nerfed,
  });

  final String topic;
  final String kind;
  final double originalDifficulty;
  final double tunedDifficulty;
  final double hintDensity;
  final String strategy;
  final String stat;
  final double aiWeight;
  final double accuracyTarget;
  final double baselineAccuracy;
  final double uplift;
  final bool clampedMax;
  final bool clampedMin;
  final bool nerfed;
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
