import 'package:poker_analyzer/personalization/progression_quality_gate_v1.dart';
import 'package:poker_analyzer/personalization/recent_activity_personalization_v1.dart';
import 'package:poker_analyzer/personalization/weakness_confidence_layer_v1.dart';
import 'package:poker_analyzer/personalization/world_mastery_v1.dart';

enum RecoveryReadinessStateV1 { rebuild, steady, readyToStep }

class RecoveryReadinessContractV1 {
  const RecoveryReadinessContractV1({
    required this.state,
    required this.fitLine,
    required this.deltaSignal,
  });

  final RecoveryReadinessStateV1 state;
  final String fitLine;
  final String deltaSignal;
}

class RecoveryReadinessContractFactoryV1 {
  RecoveryReadinessContractFactoryV1._();

  static RecoveryReadinessContractV1? derive({
    required LatestSessionOutcomeSnapshotV1? latestSession,
    required PersonalizedRecommendationV1? recommendation,
    required WeaknessConfidenceAssessmentV1? weaknessAssessment,
    required WorldMasteryLevelV1? worldMasteryLevel,
  }) {
    final snapshot = latestSession;
    final nextStep = recommendation;
    final masteryLevel = worldMasteryLevel;
    if (snapshot == null || nextStep == null || masteryLevel == null) {
      return null;
    }
    final state = _resolveState(
      latestSession: snapshot,
      weaknessAssessment: weaknessAssessment,
      worldMasteryLevel: masteryLevel,
    );
    return RecoveryReadinessContractV1(
      state: state,
      fitLine: _buildFitLine(
        state: state,
        weaknessAssessment: weaknessAssessment,
        latestSession: snapshot,
      ),
      deltaSignal: _buildDeltaSignal(
        state: state,
        weaknessAssessment: weaknessAssessment,
        worldMasteryLevel: masteryLevel,
      ),
    );
  }

  static RecoveryReadinessStateV1 _resolveState({
    required LatestSessionOutcomeSnapshotV1 latestSession,
    required WeaknessConfidenceAssessmentV1? weaknessAssessment,
    required WorldMasteryLevelV1 worldMasteryLevel,
  }) {
    final weaknessState = weaknessAssessment?.state;
    if (weaknessState == WeaknessConfidenceStateV1.active) {
      return RecoveryReadinessStateV1.rebuild;
    }
    if (weaknessState == WeaknessConfidenceStateV1.stabilizing) {
      return RecoveryReadinessStateV1.steady;
    }
    if (!latestSession.hadMistake &&
        latestSession.accuracy >= 0.85 &&
        (worldMasteryLevel == WorldMasteryLevelV1.silver ||
            worldMasteryLevel == WorldMasteryLevelV1.gold)) {
      return RecoveryReadinessStateV1.readyToStep;
    }
    if (latestSession.hadMistake &&
        worldMasteryLevel == WorldMasteryLevelV1.bronze) {
      return RecoveryReadinessStateV1.rebuild;
    }
    return RecoveryReadinessStateV1.steady;
  }

  static String _buildFitLine({
    required RecoveryReadinessStateV1 state,
    required WeaknessConfidenceAssessmentV1? weaknessAssessment,
    required LatestSessionOutcomeSnapshotV1 latestSession,
  }) {
    switch (state) {
      case RecoveryReadinessStateV1.rebuild:
        if (weaknessAssessment?.state == WeaknessConfidenceStateV1.active) {
          return 'Readiness: Rebuild first. This weakness is still showing up across recent sessions.';
        }
        return 'Readiness: Rebuild the core pattern before you add more pressure.';
      case RecoveryReadinessStateV1.steady:
        if (weaknessAssessment?.state ==
            WeaknessConfidenceStateV1.stabilizing) {
          return 'Readiness: Stay steady. Recent corrective work is starting to hold.';
        }
        if (latestSession.hadMistake) {
          return 'Readiness: Stay steady and confirm the pattern before you stretch further.';
        }
        return 'Readiness: Stay steady here and keep confirming the pattern under similar pressure.';
      case RecoveryReadinessStateV1.readyToStep:
        return 'Readiness: You look ready to step up because this pattern held cleanly at your current level.';
    }
  }

  static String _buildDeltaSignal({
    required RecoveryReadinessStateV1 state,
    required WeaknessConfidenceAssessmentV1? weaknessAssessment,
    required WorldMasteryLevelV1 worldMasteryLevel,
  }) {
    final masteryLabel = _masteryLabel(worldMasteryLevel);
    switch (state) {
      case RecoveryReadinessStateV1.rebuild:
        return 'Recovery state: Rebuild · $masteryLabel mastery still needs another clean rep';
      case RecoveryReadinessStateV1.steady:
        if (weaknessAssessment?.state ==
            WeaknessConfidenceStateV1.stabilizing) {
          return 'Recovery state: Steady · $masteryLabel mastery is stabilizing after recent review';
        }
        return 'Recovery state: Steady · $masteryLabel mastery is holding at this level';
      case RecoveryReadinessStateV1.readyToStep:
        return 'Recovery state: Ready to step · $masteryLabel mastery looks ready for added pressure';
    }
  }

  static String _masteryLabel(WorldMasteryLevelV1 level) {
    final raw = level.name;
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}
