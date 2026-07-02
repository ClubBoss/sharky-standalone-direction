import 'act0_fix_proof_projection_v1.dart';

const String act0CrossSessionProfileRecentWindowV1 =
    act0FixProofRecentSessionWindowV1;
const String act0CrossSessionProfileRepairCompletedMessageV1 =
    'profile_proof_repair_completed_v1';
const String act0CrossSessionProfileReinforcedMessageV1 =
    'profile_proof_reinforced_v1';

class Act0CrossSessionProfileProofV1 {
  const Act0CrossSessionProfileProofV1({
    this.schemaVersion = 1,
    this.totalBankedFixCount = 0,
    this.reinforcedFixCount = 0,
    this.distinctConceptFamilyCount = 0,
    this.recentWindowDescriptor = act0CrossSessionProfileRecentWindowV1,
    this.recentProofItems = const <Act0CrossSessionProfileProofItemV1>[],
    this.latestProofSessionId = '',
    this.latestProofOrder,
    this.rawProofReferences = const <String>[],
  });

  final int schemaVersion;
  final int totalBankedFixCount;
  final int reinforcedFixCount;
  final int distinctConceptFamilyCount;
  final String recentWindowDescriptor;
  final List<Act0CrossSessionProfileProofItemV1> recentProofItems;
  final String latestProofSessionId;
  final int? latestProofOrder;
  final List<String> rawProofReferences;

  bool get hasProof => totalBankedFixCount > 0;

  static Act0CrossSessionProfileProofV1 fromFixProof(
    Act0FixProofProjectionV1 source,
  ) {
    final byProofId = <String, Act0FixProofItemV1>{};
    for (final proof in source.proofs) {
      final proofId = proof.fixProofId.trim();
      if (proofId.isEmpty ||
          proof.conceptFamilyId.trim().isEmpty ||
          proof.repairOutcomeRef.trim().isEmpty) {
        continue;
      }
      final existing = byProofId[proofId];
      if (existing == null || _preferProof(proof, existing)) {
        byProofId[proofId] = proof;
      }
    }

    final lifetimeProofs = byProofId.values.toList(growable: false);
    if (lifetimeProofs.isEmpty) {
      return const Act0CrossSessionProfileProofV1();
    }

    final normalized = Act0FixProofProjectionV1(
      proofs: lifetimeProofs,
      recentSessionLimit: source.recentSessionLimit,
    );
    final recent = normalized.aggregate.recentProofItems
        .map(Act0CrossSessionProfileProofItemV1.fromFixProof)
        .take(3)
        .toList(growable: false);
    final latest = lifetimeProofs.reduce(
      (current, candidate) =>
          candidate.bankedAtOrder > current.bankedAtOrder ? candidate : current,
    );
    final familyIds = <String>{
      for (final proof in lifetimeProofs) proof.conceptFamilyId.trim(),
    };
    final rawReferences = <String>{
      for (final proof in lifetimeProofs) proof.repairOutcomeRef.trim(),
    }.toList(growable: false)..sort();

    return Act0CrossSessionProfileProofV1(
      totalBankedFixCount: lifetimeProofs.length,
      reinforcedFixCount: lifetimeProofs
          .where((proof) => proof.isReinforced)
          .length,
      distinctConceptFamilyCount: familyIds.length,
      recentProofItems: List<Act0CrossSessionProfileProofItemV1>.unmodifiable(
        recent,
      ),
      latestProofSessionId: latest.repairSessionId.trim(),
      latestProofOrder: latest.bankedAtOrder,
      rawProofReferences: List<String>.unmodifiable(rawReferences),
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'totalBankedFixCount': totalBankedFixCount,
    'reinforcedFixCount': reinforcedFixCount,
    'distinctConceptFamilyCount': distinctConceptFamilyCount,
    'recentWindowDescriptor': recentWindowDescriptor,
    'recentProofItems': recentProofItems
        .map((item) => item.toPayload())
        .toList(growable: false),
    if (latestProofSessionId.isNotEmpty)
      'latestProofSessionId': latestProofSessionId,
    if (latestProofOrder != null) 'latestProofOrder': latestProofOrder,
    'rawProofReferences': rawProofReferences,
  };
}

class Act0CrossSessionProfileProofItemV1 {
  const Act0CrossSessionProfileProofItemV1({
    this.schemaVersion = 1,
    required this.proofId,
    required this.conceptFamilyId,
    required this.proofState,
    required this.sourceRepairReference,
    this.laterEvidenceReference = '',
    required this.bankedOrder,
    required this.conceptLabelKey,
    required this.messageKey,
  });

  final int schemaVersion;
  final String proofId;
  final String conceptFamilyId;
  final String proofState;
  final String sourceRepairReference;
  final String laterEvidenceReference;
  final int bankedOrder;
  final String conceptLabelKey;
  final String messageKey;

  bool get isReinforced =>
      proofState == act0FixProofStateReinforcedByLaterEvidenceV1;

  static Act0CrossSessionProfileProofItemV1 fromFixProof(
    Act0FixProofItemV1 proof,
  ) {
    final laterReference =
        proof.laterEvidenceSessionId.trim().isNotEmpty &&
            proof.laterEvidenceTaskId.trim().isNotEmpty
        ? 'later_evidence_v1|${proof.laterEvidenceSessionId.trim()}|${proof.laterEvidenceTaskId.trim()}'
        : '';
    return Act0CrossSessionProfileProofItemV1(
      proofId: proof.fixProofId.trim(),
      conceptFamilyId: proof.conceptFamilyId.trim(),
      proofState: proof.proofState,
      sourceRepairReference: proof.repairOutcomeRef.trim(),
      laterEvidenceReference: laterReference,
      bankedOrder: proof.bankedAtOrder,
      conceptLabelKey: 'profile_proof_concept_${proof.conceptFamilyId.trim()}',
      messageKey: proof.isReinforced
          ? act0CrossSessionProfileReinforcedMessageV1
          : act0CrossSessionProfileRepairCompletedMessageV1,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'proofId': proofId,
    'conceptFamilyId': conceptFamilyId,
    'proofState': proofState,
    'sourceRepairReference': sourceRepairReference,
    if (laterEvidenceReference.isNotEmpty)
      'laterEvidenceReference': laterEvidenceReference,
    'bankedOrder': bankedOrder,
    'conceptLabelKey': conceptLabelKey,
    'messageKey': messageKey,
  };
}

bool _preferProof(Act0FixProofItemV1 candidate, Act0FixProofItemV1 existing) {
  if (candidate.isReinforced != existing.isReinforced) {
    return candidate.isReinforced;
  }
  if (candidate.bankedAtOrder != existing.bankedAtOrder) {
    return candidate.bankedAtOrder > existing.bankedAtOrder;
  }
  return candidate.repairOutcomeRef.compareTo(existing.repairOutcomeRef) < 0;
}
