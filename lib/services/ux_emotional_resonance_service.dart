import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _personaSummaryPath =
    '$_reportsDir/ai_persona_refinement_summary.json';

class UxEmotionalResonanceService {
  Future<UxEmotionalResonanceResult> calculate() async {
    final telemetry = await _aggregateTelemetry();
    final personaSummary = await _loadPersonaSummary();

    final clusters = personaSummary.personas;
    final clusterScores = <ClusterResonance>[];
    double weightedSum = 0;
    double totalWeight = 0;

    for (final cluster in clusters) {
      final alignment = (cluster.clarity / 100).clamp(0, 1).toDouble();
      final score = _composeScore(
        telemetry.positiveNeutralRatio,
        telemetry.sessionConsistency,
        alignment,
      );
      clusterScores.add(
        ClusterResonance(
          clusterName: cluster.cluster,
          persona: cluster.persona,
          sampleSize: cluster.sampleSize,
          resonanceScore: score,
        ),
      );
      weightedSum += score * cluster.sampleSize;
      totalWeight += cluster.sampleSize.toDouble();
    }

    final globalScore = totalWeight == 0
        ? _composeScore(
            telemetry.positiveNeutralRatio,
            telemetry.sessionConsistency,
            0.9,
          )
        : weightedSum / totalWeight;

    return UxEmotionalResonanceResult(
      globalScore: globalScore,
      clusters: clusterScores,
      telemetry: telemetry,
    );
  }

  Future<_TelemetryEmotionMetrics> _aggregateTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      return const _TelemetryEmotionMetrics.empty();
    }
    int positive = 0;
    int neutral = 0;
    int negative = 0;
    final durations = <double>[];
    try {
      final lines = await file.readAsLines();
      for (final raw in lines) {
        final line = raw.trim();
        if (line.isEmpty) continue;
        Map<String, Object?>? parsed;
        try {
          parsed = json.decode(line) as Map<String, Object?>?;
        } catch (_) {
          continue;
        }
        if (parsed == null) continue;
        final tag = parsed['emotion_tag']?.toString().toLowerCase();
        final reaction = parsed['feedback_reaction']?.toString().toLowerCase();
        void count(String? value) {
          if (value == null) return;
          if (_positiveTags.contains(value)) {
            positive++;
          } else if (_neutralTags.contains(value)) {
            neutral++;
          } else if (_negativeTags.contains(value)) {
            negative++;
          }
        }

        count(tag);
        count(reaction);

        final duration = (parsed['session_duration'] as num?)?.toDouble();
        if (duration != null && duration > 0) {
          durations.add(duration);
        }
      }
    } catch (_) {
      return const _TelemetryEmotionMetrics.empty();
    }

    final total = positive + neutral + negative;
    final ratio = total == 0
        ? 0.75
        : (positive + neutral) / total.clamp(1, double.maxFinite).toDouble();
    final consistency = _sessionConsistency(durations);

    return _TelemetryEmotionMetrics(
      positiveNeutralRatio: ratio,
      sessionConsistency: consistency,
      sampleSize: total,
    );
  }

  static double _sessionConsistency(List<double> durations) {
    if (durations.isEmpty) return 0.7;
    final mean = durations.reduce((a, b) => a + b) / durations.length;
    if (mean == 0) return 0.7;
    final mad =
        durations.map((value) => (value - mean).abs()).reduce((a, b) => a + b) /
        durations.length;
    final normalized = 1 - (mad / (mean + 1));
    return normalized.clamp(0, 1).toDouble();
  }

  double _composeScore(
    double positiveRatio,
    double sessionConsistency,
    double toneAlignment,
  ) {
    final score =
        (positiveRatio * 100 * 0.5) +
        (sessionConsistency * 100 * 0.3) +
        (toneAlignment * 100 * 0.2);
    return score.clamp(0, 100).toDouble();
  }

  Future<_PersonaSummary> _loadPersonaSummary() async {
    final file = File(_personaSummaryPath);
    if (!await file.exists()) {
      return const _PersonaSummary.empty();
    }
    try {
      final Map<String, Object?> decoded =
          json.decode(await file.readAsString()) as Map<String, Object?>;
      final toneConsistency =
          (decoded['tone_consistency'] as num?)?.toDouble() ?? 80.0;
      final personasRaw = decoded['personas'];
      final personas = <_PersonaCluster>[];
      if (personasRaw is List) {
        for (final entry in personasRaw) {
          if (entry is Map<String, Object?>) {
            personas.add(
              _PersonaCluster(
                cluster: entry['cluster']?.toString() ?? 'unknown',
                persona: entry['persona']?.toString() ?? '',
                sampleSize: (entry['sample_size'] as num?)?.toInt() ?? 0,
                clarity: (entry['clarity'] as num?)?.toDouble() ?? 80,
              ),
            );
          }
        }
      }
      return _PersonaSummary(
        toneConsistency: toneConsistency,
        personas: personas,
      );
    } catch (_) {
      return const _PersonaSummary.empty();
    }
  }

  static const Set<String> _positiveTags = {
    'positive',
    'delighted',
    'happy',
    'excited',
  };
  static const Set<String> _neutralTags = {'neutral', 'calm', 'steady'};
  static const Set<String> _negativeTags = {
    'negative',
    'frustrated',
    'angry',
    'sad',
  };
}

class UxEmotionalResonanceResult {
  const UxEmotionalResonanceResult({
    required this.globalScore,
    required this.clusters,
    required this.telemetry,
  });

  final double globalScore;
  final List<ClusterResonance> clusters;
  final _TelemetryEmotionMetrics telemetry;
}

class ClusterResonance {
  const ClusterResonance({
    required this.clusterName,
    required this.persona,
    required this.sampleSize,
    required this.resonanceScore,
  });

  final String clusterName;
  final String persona;
  final int sampleSize;
  final double resonanceScore;
}

class _TelemetryEmotionMetrics {
  const _TelemetryEmotionMetrics({
    required this.positiveNeutralRatio,
    required this.sessionConsistency,
    required this.sampleSize,
  });

  const _TelemetryEmotionMetrics.empty()
    : positiveNeutralRatio = 0.75,
      sessionConsistency = 0.7,
      sampleSize = 0;

  final double positiveNeutralRatio;
  final double sessionConsistency;
  final int sampleSize;
}

class _PersonaSummary {
  const _PersonaSummary({
    required this.toneConsistency,
    required this.personas,
  });

  const _PersonaSummary.empty() : toneConsistency = 80, personas = const [];

  final double toneConsistency;
  final List<_PersonaCluster> personas;
}

class _PersonaCluster {
  const _PersonaCluster({
    required this.cluster,
    required this.persona,
    required this.sampleSize,
    required this.clarity,
  });

  final String cluster;
  final String persona;
  final int sampleSize;
  final double clarity;
}
