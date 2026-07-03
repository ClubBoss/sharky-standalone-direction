import 'act0_fix_proof_projection_v1.dart';
import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_sharky_coach_phrase_contract_v1.dart';

const String act0SharkyImprovementNotEligibleV1 = 'notEligible';
const String act0SharkyImprovementEligibleV1 = 'eligible';

class Act0SharkyImprovementObservationProjectionV1 {
  const Act0SharkyImprovementObservationProjectionV1({
    this.schemaVersion = 1,
    this.observations = const <Act0SharkyImprovementObservationV1>[],
  });

  final int schemaVersion;
  final List<Act0SharkyImprovementObservationV1> observations;

  Act0SharkyImprovementObservationV1? get latestObservation =>
      observations.isEmpty ? null : observations.first;

  static Act0SharkyImprovementObservationProjectionV1 fromFixProof(
    Act0FixProofProjectionV1 source, {
    String completedSessionId = '',
    Act0SharkyCoachTierV1 tier = Act0SharkyCoachTierV1.foundation,
  }) {
    final bySourceRepairId = <String, Act0SharkyImprovementObservationV1>{};
    final safeCompletedSessionId = completedSessionId.trim();
    for (final proof in source.proofs) {
      final observation = _observationFromProof(
        proof,
        tier: tier,
        completedSessionId: safeCompletedSessionId,
      );
      if (observation == null) {
        continue;
      }
      final existing = bySourceRepairId[observation.sourceRepairId];
      if (existing == null || _observationSort(observation, existing) < 0) {
        bySourceRepairId[observation.sourceRepairId] = observation;
      }
    }
    final observations = bySourceRepairId.values.toList(growable: false)
      ..sort(_observationSort);
    return Act0SharkyImprovementObservationProjectionV1(
      observations: List<Act0SharkyImprovementObservationV1>.unmodifiable(
        observations,
      ),
    );
  }
}

class Act0SharkyImprovementObservationV1 {
  const Act0SharkyImprovementObservationV1({
    this.schemaVersion = 1,
    required this.observationId,
    required this.conceptFamilyId,
    required this.sourceRepairId,
    required this.sourceSessionId,
    required this.laterEvidenceId,
    required this.laterSessionId,
    required this.observationState,
    required this.tier,
    required this.phraseContext,
    required this.observedOrder,
    required this.rawSourceReferences,
  });

  final int schemaVersion;
  final String observationId;
  final String conceptFamilyId;
  final String sourceRepairId;
  final String sourceSessionId;
  final String laterEvidenceId;
  final String laterSessionId;
  final String observationState;
  final Act0SharkyCoachTierV1 tier;
  final Act0SharkyCoachPhraseContextV1 phraseContext;
  final int observedOrder;
  final List<String> rawSourceReferences;

  String get line => act0ResolveSharkyCoachPhraseV1(phraseContext).line;

  @override
  bool operator ==(Object other) =>
      other is Act0SharkyImprovementObservationV1 &&
      other.schemaVersion == schemaVersion &&
      other.observationId == observationId &&
      other.conceptFamilyId == conceptFamilyId &&
      other.sourceRepairId == sourceRepairId &&
      other.sourceSessionId == sourceSessionId &&
      other.laterEvidenceId == laterEvidenceId &&
      other.laterSessionId == laterSessionId &&
      other.observationState == observationState &&
      other.tier == tier &&
      _samePhraseContext(other.phraseContext, phraseContext) &&
      other.observedOrder == observedOrder &&
      _sameStrings(other.rawSourceReferences, rawSourceReferences);

  @override
  int get hashCode => Object.hashAll(<Object?>[
    schemaVersion,
    observationId,
    conceptFamilyId,
    sourceRepairId,
    sourceSessionId,
    laterEvidenceId,
    laterSessionId,
    observationState,
    tier,
    phraseContext.surface,
    phraseContext.momentType,
    phraseContext.tier,
    phraseContext.evidenceKind,
    phraseContext.conceptFamilyId,
    phraseContext.transferState,
    observedOrder,
    ...rawSourceReferences,
  ]);
}

Act0SharkyImprovementObservationV1? _observationFromProof(
  Act0FixProofItemV1 proof, {
  required Act0SharkyCoachTierV1 tier,
  required String completedSessionId,
}) {
  final conceptFamilyId = proof.conceptFamilyId.trim();
  final sourceRepairId = proof.repairOutcomeRef.trim();
  final sourceSessionId = proof.repairSessionId.trim();
  final laterSessionId = proof.laterEvidenceSessionId.trim();
  final laterTaskId = proof.laterEvidenceTaskId.trim();
  final observedOrder = proof.laterEvidenceOrder;
  if (!proof.isReinforced ||
      proof.transferVerdict != act0LearningTransferImprovedV1 ||
      conceptFamilyId.isEmpty ||
      sourceRepairId.isEmpty ||
      sourceSessionId.isEmpty ||
      laterSessionId.isEmpty ||
      laterTaskId.isEmpty ||
      observedOrder == null ||
      observedOrder <= proof.bankedAtOrder ||
      laterSessionId == sourceSessionId ||
      proof.sourceTaskId.trim() == laterTaskId ||
      (completedSessionId.isNotEmpty && laterSessionId != completedSessionId)) {
    return null;
  }
  final laterEvidenceId = 'later_evidence_v1|$laterSessionId|$laterTaskId';
  final observationId =
      'sharky_saw_improve_v1|$sourceRepairId|$laterEvidenceId';
  return Act0SharkyImprovementObservationV1(
    observationId: observationId,
    conceptFamilyId: conceptFamilyId,
    sourceRepairId: sourceRepairId,
    sourceSessionId: sourceSessionId,
    laterEvidenceId: laterEvidenceId,
    laterSessionId: laterSessionId,
    observationState: act0SharkyImprovementEligibleV1,
    tier: tier,
    phraseContext: Act0SharkyCoachPhraseContextV1(
      surface: Act0SharkyCoachSurfaceV1.summary,
      momentType: Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
      tier: tier,
      evidenceKind: Act0SharkyCoachEvidenceKindV1.transferEvidence,
      transferState: Act0SharkyCoachTransferStateV1.laterCorrect,
      conceptFamilyId: conceptFamilyId,
    ),
    observedOrder: observedOrder,
    rawSourceReferences: List<String>.unmodifiable(
      <String>[proof.fixProofId.trim(), sourceRepairId, laterEvidenceId]
        ..sort(),
    ),
  );
}

int _observationSort(
  Act0SharkyImprovementObservationV1 a,
  Act0SharkyImprovementObservationV1 b,
) {
  final order = b.observedOrder.compareTo(a.observedOrder);
  if (order != 0) {
    return order;
  }
  return a.observationId.compareTo(b.observationId);
}

bool _sameStrings(List<String> a, List<String> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

bool _samePhraseContext(
  Act0SharkyCoachPhraseContextV1 a,
  Act0SharkyCoachPhraseContextV1 b,
) {
  return a.surface == b.surface &&
      a.momentType == b.momentType &&
      a.tier == b.tier &&
      a.evidenceKind == b.evidenceKind &&
      a.conceptFamilyId == b.conceptFamilyId &&
      a.transferState == b.transferState &&
      a.repairState == b.repairState &&
      a.proofState == b.proofState &&
      a.completionState == b.completionState &&
      a.fallbackKey == b.fallbackKey &&
      a.worldNumber == b.worldNumber &&
      a.nextWorldNumber == b.nextWorldNumber;
}
