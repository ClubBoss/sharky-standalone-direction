import 'act0_learning_evidence_contract_v1.dart';
import 'act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_improvement_observation_v1.dart';

class Act0RepairOutcomeConsumerV1 {
  const Act0RepairOutcomeConsumerV1({this.proof, this.sessionReceipt});

  final Act0RepairOutcomeProofV1? proof;
  final Act0RepairOutcomeSessionReceiptV1? sessionReceipt;

  bool get hasProof => proof != null;
  bool get hasSessionReceipt => sessionReceipt != null;

  static Act0RepairOutcomeConsumerV1 fromProjection(
    Act0RepairOutcomeProjectionV1 projection, {
    Act0FixProofProjectionV1? fixProofProjection,
    Act0SharkyImprovementObservationProjectionV1?
    improvementObservationProjection,
    Act0LearningEvidenceHistoryV1 learningEvidenceHistory =
        const Act0LearningEvidenceHistoryV1(),
    Act0RepairFingerprintResolverV1? currentFingerprintForIdentity,
    Iterable<Act0RepairIntentV1> repairIntents = const <Act0RepairIntentV1>[],
  }) {
    if (projection.outcomes.isEmpty) {
      return const Act0RepairOutcomeConsumerV1();
    }
    final ordered = <Act0RepairOutcomeV1>[...projection.outcomes]
      ..sort((a, b) {
        final sequenceCompare = a.sequence.compareTo(b.sequence);
        return sequenceCompare != 0
            ? sequenceCompare
            : a.queueItemId.compareTo(b.queueItemId);
      });
    final eligible = <Act0RepairOutcomeV1>[];
    final eligibleIntents = <Act0RepairOutcomeV1, Act0RepairIntentV1>{};
    final successfulByRef = <String, Act0RepairOutcomeV1>{};
    final intentByRef = <String, Act0RepairIntentV1>{};
    final resolver = currentFingerprintForIdentity;
    if (resolver != null) {
      for (final outcome in ordered) {
        final intent = act0RepairIntentForRecordedOutcomeV1(
          outcome: outcome,
          learningEvidence: learningEvidenceHistory,
          currentFingerprintForIdentity: resolver,
          repairIntents: repairIntents,
        );
        if (intent == null ||
            !act0RepairGoalOutcomeIsEligibleV1(
              intent: intent,
              outcome: outcome,
              learningEvidence: learningEvidenceHistory,
              currentFingerprintForIdentity: resolver,
            ))
          continue;
        eligible.add(outcome);
        eligibleIntents[outcome] = intent;
        if (outcome.isCorrect == true) {
          final ref =
              'repair_outcome_v1|${outcome.sequence}|${outcome.queueItemId}';
          successfulByRef[ref] = outcome;
          intentByRef[ref] = intent;
        }
      }
    }
    final currentProofs = <Act0FixProofItemV1>[];
    if (fixProofProjection != null && resolver != null) {
      for (final proof in fixProofProjection.proofs) {
        final outcome = successfulByRef[proof.repairOutcomeRef];
        if (outcome == null ||
            proof.queueItemId != outcome.queueItemId ||
            proof.sourceTaskId != outcome.sourceTaskId)
          continue;
        final relation = act0RepairGoalResolutionForIntentV1(
          intentByRef[proof.repairOutcomeRef]!,
          learningEvidence: learningEvidenceHistory,
          currentFingerprintForIdentity: resolver,
        );
        currentProofs.add(
          relation.canClaimIndependentApplication
              ? proof
              : proof.withoutIndependentApplicationClaimV1(),
        );
      }
    }
    final currentFixProof = Act0FixProofProjectionV1(
      proofs: List.unmodifiable(currentProofs),
      recentSessionLimit: fixProofProjection?.recentSessionLimit ?? 7,
    );
    final latest = ordered.last;
    final currentViewUnconfirmed =
        !eligible.contains(latest) ||
        resolver == null ||
        act0RepairCurrentViewHasUnconfirmedLaterSourceAttemptV1(
          intent: eligibleIntents[latest]!,
          outcome: latest,
          learningEvidence: learningEvidenceHistory,
          currentFingerprintForIdentity: resolver,
        );
    final detail = currentViewUnconfirmed
        ? ''
        : _detailForOutcomeStateV1(latest.outcomeState);
    final receipt =
        _sessionReceiptForFixProofV1(
          currentFixProof,
          improvementObservationProjection: improvementObservationProjection,
        ) ??
        _sessionReceiptForOutcomesV1(eligible);
    if (detail.isEmpty && receipt == null) {
      return const Act0RepairOutcomeConsumerV1();
    }
    return Act0RepairOutcomeConsumerV1(
      proof: detail.isEmpty
          ? null
          : Act0RepairOutcomeProofV1(
              title: latest.outcomeState == act0RepairOutcomeStateCorrectV1
                  ? 'Fix landed'
                  : 'Fix attempt',
              detail: detail,
              outcomeState: latest.outcomeState,
              sequence: latest.sequence,
            ),
      sessionReceipt: receipt,
    );
  }
}

Act0RepairOutcomeSessionReceiptV1? _sessionReceiptForFixProofV1(
  Act0FixProofProjectionV1? projection, {
  Act0SharkyImprovementObservationProjectionV1?
  improvementObservationProjection,
}) {
  final aggregate = projection?.aggregate;
  final lines = aggregate?.lines ?? const <String>[];
  if (lines.isEmpty) {
    return null;
  }
  String improvementLine = '';
  for (final observation
      in improvementObservationProjection?.observations ??
          const <Act0SharkyImprovementObservationV1>[]) {
    if (projection!.proofs.any(
      (proof) =>
          proof.isReinforced &&
          proof.repairOutcomeRef == observation.sourceRepairId &&
          proof.conceptFamilyId == observation.conceptFamilyId &&
          proof.repairSessionId == observation.sourceSessionId,
    )) {
      improvementLine = observation.line.trim();
      break;
    }
  }
  final receiptLines = <String>[
    ...lines,
    if (improvementLine.isNotEmpty && !lines.contains(improvementLine))
      improvementLine,
  ];
  return Act0RepairOutcomeSessionReceiptV1(
    title: "Fixes you've banked",
    lines: List<String>.unmodifiable(receiptLines),
    isBankedFixProof: true,
    hasReinforcedEvidence: (aggregate?.reinforcedFixCount ?? 0) > 0,
    hasImprovementObservation: improvementLine.isNotEmpty,
  );
}

class Act0RepairOutcomeProofV1 {
  const Act0RepairOutcomeProofV1({
    required this.title,
    required this.detail,
    required this.outcomeState,
    required this.sequence,
  });

  final String title;
  final String detail;
  final String outcomeState;
  final int sequence;
}

class Act0RepairOutcomeSessionReceiptV1 {
  const Act0RepairOutcomeSessionReceiptV1({
    required this.title,
    required this.lines,
    this.isBankedFixProof = false,
    this.hasReinforcedEvidence = false,
    this.hasImprovementObservation = false,
  });

  final String title;
  final List<String> lines;

  /// True only when this receipt is sourced from the structured banked-fix
  /// projection (Review resolution receipts), not the raw activity fallback.
  final bool isBankedFixProof;

  /// True only when a banked fix in this receipt has later transfer
  /// evidence. Meaningless unless [isBankedFixProof] is true.
  final bool hasReinforcedEvidence;

  /// True only when the receipt includes a read-only Sharky companion
  /// observation derived from source-backed reinforced Fix Proof.
  final bool hasImprovementObservation;
}

String _detailForOutcomeStateV1(String outcomeState) {
  return switch (outcomeState) {
    act0RepairOutcomeStateCorrectV1 =>
      'Nice repair. Same spot, cleaner decision.',
    act0RepairOutcomeStateStillNeedsRepV1 => 'Not landed yet. One more rep.',
    act0RepairOutcomeStateAttemptedV1 => 'You gave the repair a try.',
    _ => '',
  };
}

Act0RepairOutcomeSessionReceiptV1? _sessionReceiptForOutcomesV1(
  List<Act0RepairOutcomeV1> outcomes,
) {
  var correctCount = 0;
  var stillNeedsRepCount = 0;
  var attemptedCount = 0;
  for (final outcome in outcomes) {
    switch (outcome.outcomeState) {
      case act0RepairOutcomeStateCorrectV1:
        correctCount += 1;
      case act0RepairOutcomeStateStillNeedsRepV1:
        stillNeedsRepCount += 1;
      case act0RepairOutcomeStateAttemptedV1:
        attemptedCount += 1;
    }
  }
  final lines = <String>[
    if (correctCount > 0) 'Correct repair answers: $correctCount',
    if (stillNeedsRepCount > 0) 'Still to repair: $stillNeedsRepCount',
    if (correctCount == 0 && stillNeedsRepCount == 0 && attemptedCount > 0)
      'Repair attempts: $attemptedCount',
  ];
  if (lines.isEmpty) {
    return null;
  }
  return Act0RepairOutcomeSessionReceiptV1(
    title: 'Repair activity',
    lines: List<String>.unmodifiable(lines),
  );
}
