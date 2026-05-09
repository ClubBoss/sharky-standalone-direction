import 'dart:convert';
import 'dart:io';

const String _reportsDir = 'release/_reports';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const String _personaSummaryPath =
    '$_reportsDir/ai_persona_refinement_summary.json';

class PersonalizationCalibrationEngine {
  Future<PersonalizationCalibrationResult> calibrate() async {
    final telemetry = await _aggregateTelemetry();
    final persona = await _loadPersonaSummary();

    final adaptationScore = _computeAdaptationScore(
      telemetry,
      persona.toneConsistency,
    );

    final adjustments = _deriveAdjustments(telemetry, persona);

    return PersonalizationCalibrationResult(
      telemetryMetrics: telemetry,
      personaSummary: persona,
      adjustments: adjustments,
      adaptationScore: adaptationScore,
    );
  }

  Future<_TelemetryMetrics> _aggregateTelemetry() async {
    final file = File(_telemetryPath);
    if (!await file.exists()) {
      return const _TelemetryMetrics.empty();
    }
    int sample = 0;
    double engagementTotal = 0;
    double retentionTotal = 0;
    double accuracyTotal = 0;

    try {
      final lines = await file.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        Map<String, Object?>? parsed;
        try {
          parsed = json.decode(line) as Map<String, Object?>?;
        } catch (_) {
          continue;
        }
        if (parsed == null) continue;
        final engagement =
            (parsed['engagement_score'] as num?)?.toDouble() ?? double.nan;
        final retention =
            (parsed['retention_index'] as num?)?.toDouble() ?? double.nan;
        final accuracy = (parsed['accuracy'] as num?)?.toDouble() ?? double.nan;
        if (engagement.isNaN && retention.isNaN && accuracy.isNaN) continue;
        sample++;
        engagementTotal += engagement.isNaN ? 70 : engagement;
        retentionTotal += retention.isNaN ? 70 : retention;
        accuracyTotal += accuracy.isNaN ? 80 : accuracy;
      }
    } catch (_) {
      return const _TelemetryMetrics.empty();
    }

    if (sample == 0) {
      return const _TelemetryMetrics.empty();
    }
    return _TelemetryMetrics(
      engagementAvg: engagementTotal / sample,
      retentionAvg: retentionTotal / sample,
      accuracyAvg: accuracyTotal / sample,
      sampleSize: sample,
    );
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
          (decoded['tone_consistency'] as num?)?.toDouble() ?? 85.0;
      final toneWeights = <String, double>{};
      final rawWeights = decoded['tone_weights'];
      if (rawWeights is Map<String, dynamic>) {
        rawWeights.forEach((key, value) {
          final parsed = (value as num?)?.toDouble();
          if (parsed != null) {
            toneWeights[key] = parsed;
          }
        });
      }
      return _PersonaSummary(
        toneConsistency: toneConsistency,
        toneWeights: toneWeights,
      );
    } catch (_) {
      return const _PersonaSummary.empty();
    }
  }

  double _computeAdaptationScore(
    _TelemetryMetrics telemetry,
    double toneConsistency,
  ) {
    final engagement = telemetry.engagementAvg;
    final retention = telemetry.retentionAvg;
    final accuracy = telemetry.accuracyAvg;
    return (engagement * 0.35) +
        (retention * 0.35) +
        (accuracy * 0.2) +
        (toneConsistency * 0.1);
  }

  CalibrationAdjustments _deriveAdjustments(
    _TelemetryMetrics telemetry,
    _PersonaSummary persona,
  ) {
    final learningRate = (1.0 + (telemetry.engagementAvg - 75) / 400).clamp(
      0.85,
      1.2,
    );
    final hintDensity = (50 - (telemetry.accuracyAvg - 80))
        .clamp(20, 80)
        .toDouble();
    final challengeBalance =
        (telemetry.retentionAvg + persona.toneConsistency) / 2;
    return CalibrationAdjustments(
      learningRate: double.parse(learningRate.toStringAsFixed(3)),
      hintDensity: double.parse(hintDensity.toStringAsFixed(2)),
      challengeBalance: double.parse(challengeBalance.toStringAsFixed(2)),
    );
  }
}

class PersonalizationCalibrationResult {
  const PersonalizationCalibrationResult({
    required this.telemetryMetrics,
    required this.personaSummary,
    required this.adjustments,
    required this.adaptationScore,
  });

  final _TelemetryMetrics telemetryMetrics;
  final _PersonaSummary personaSummary;
  final CalibrationAdjustments adjustments;
  final double adaptationScore;
}

class CalibrationAdjustments {
  const CalibrationAdjustments({
    required this.learningRate,
    required this.hintDensity,
    required this.challengeBalance,
  });

  final double learningRate;
  final double hintDensity;
  final double challengeBalance;
}

class _TelemetryMetrics {
  const _TelemetryMetrics({
    required this.engagementAvg,
    required this.retentionAvg,
    required this.accuracyAvg,
    required this.sampleSize,
  });

  const _TelemetryMetrics.empty()
    : engagementAvg = 0,
      retentionAvg = 0,
      accuracyAvg = 0,
      sampleSize = 0;

  final double engagementAvg;
  final double retentionAvg;
  final double accuracyAvg;
  final int sampleSize;
}

class _PersonaSummary {
  const _PersonaSummary({
    required this.toneConsistency,
    required this.toneWeights,
  });

  const _PersonaSummary.empty() : toneConsistency = 80, toneWeights = const {};

  final double toneConsistency;
  final Map<String, double> toneWeights;
}
