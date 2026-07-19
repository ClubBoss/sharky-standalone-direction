import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';

enum Act0LearningReceiptLevelV1 {
  attempted,
  sameClueRepaired,
  laterRecheckHeld,
  differentSpotImproved,
}

/// Claim-safe, recomputed learner receipt. Underlying repair and learning
/// evidence remains canonical; this class neither persists copy nor derives a
/// second transfer algorithm.
class Act0LearningReceiptV1 {
  const Act0LearningReceiptV1({
    required this.focusLabel,
    required this.level,
    required this.previousIssue,
    required this.latestOutcome,
    required this.remainingStatus,
    required this.nextEvidenceRequirement,
    required this.sourceReferences,
    this.transferVerdict = '',
    this.isExactReplay = false,
  });

  final String focusLabel;
  final Act0LearningReceiptLevelV1 level;
  final String previousIssue;
  final String latestOutcome;
  final String remainingStatus;
  final String nextEvidenceRequirement;
  final List<String> sourceReferences;
  final String transferVerdict;
  final bool isExactReplay;

  String get telemetryLevel => switch (level) {
    Act0LearningReceiptLevelV1.attempted => 'attempted',
    Act0LearningReceiptLevelV1.sameClueRepaired => 'same_clue_repaired',
    Act0LearningReceiptLevelV1.laterRecheckHeld => 'later_recheck_held',
    Act0LearningReceiptLevelV1.differentSpotImproved =>
      'different_spot_improved',
  };

  String get visibleCopy {
    if (isExactReplay) {
      return level == Act0LearningReceiptLevelV1.attempted
          ? 'This spot still needs one more careful rep.'
          : 'Fix landed: you handled this spot correctly.';
    }
    return switch (level) {
      Act0LearningReceiptLevelV1.attempted =>
        '$focusLabel was attempted and still needs a clean repair.',
      Act0LearningReceiptLevelV1.sameClueRepaired =>
        'You corrected $focusLabel on the same clue. A later check will show whether it holds.',
      Act0LearningReceiptLevelV1.laterRecheckHeld =>
        '$focusLabel held on a later check. A different spot is the next proof.',
      Act0LearningReceiptLevelV1.differentSpotImproved =>
        transferVerdict == act0LearningTransferImprovingV1
            ? 'The read improved on a different hand.'
            : 'The read held on a different hand.',
    };
  }

  List<String> get sessionSummaryLines => isExactReplay
      ? const <String>['Continue with normal review evidence.']
      : <String>[latestOutcome, nextEvidenceRequirement];

  factory Act0LearningReceiptV1.fromEvidence({
    required String focusLabel,
    required String sourceTaskId,
    required Iterable<Act0RepairOutcomeV1> repairOutcomes,
    required Act0LearningEvidenceHistoryV1 learningEvidence,
    String conceptFamilyId = '',
    bool isExactReplay = false,
  }) {
    final source = sourceTaskId.trim();
    final repairs =
        repairOutcomes
            .where((outcome) => outcome.sourceTaskId.trim() == source)
            .toList()
          ..sort(
            (a, b) => a.sequence != b.sequence
                ? a.sequence.compareTo(b.sequence)
                : a.queueItemId.compareTo(b.queueItemId),
          );
    final lastRepair = repairs.isEmpty ? null : repairs.last;
    final repaired = lastRepair?.isCorrect == true;
    final evidence =
        learningEvidence.records
            .where(
              (record) =>
                  record.sourceTaskId.trim() == source ||
                  record.taskId.trim() == source,
            )
            .toList()
          ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
    final family = conceptFamilyId.trim().isNotEmpty
        ? conceptFamilyId.trim()
        : evidence
              .map((record) => record.conceptFamilyId.trim())
              .lastWhere(
                (id) => id.isNotEmpty && id != 'none',
                orElse: () => '',
              );
    final successfulRepairEvidence = evidence.where(
      (record) =>
          record.isCorrect &&
          (record.reviewKind == Act0ReviewKindV1.alternateSameSignal ||
              record.reviewKind == Act0ReviewKindV1.immediateRepair),
    );
    final repairEvidence = successfulRepairEvidence.isEmpty
        ? null
        : successfulRepairEvidence.last;
    final recheck = repairEvidence == null
        ? null
        : evidence.cast<Act0LearningEvidenceRecordV1?>().lastWhere(
            (record) =>
                record != null &&
                record.isCorrect &&
                record.reviewKind == Act0ReviewKindV1.originalSourceRecheck &&
                record.createdOrder > repairEvidence.createdOrder &&
                record.sessionId.trim().isNotEmpty &&
                repairEvidence.sessionId.trim().isNotEmpty &&
                record.sessionId != repairEvidence.sessionId,
            orElse: () => null,
          );
    final transfer = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      learningEvidence,
    ).signalForConcept(family);
    final hasCanonicalTransfer =
        family.isNotEmpty &&
        transfer.conceptFamilyId == family &&
        transfer.relationship == act0LearningTransferSameFamilyTransferV1 &&
        transfer.baselineTaskId.isNotEmpty &&
        transfer.comparisonTaskId.isNotEmpty &&
        transfer.baselineTaskId != transfer.comparisonTaskId &&
        transfer.baselineOrder != null &&
        transfer.comparisonOrder != null &&
        transfer.comparisonOrder! > transfer.baselineOrder! &&
        (transfer.verdict == act0LearningTransferImprovingV1 ||
            transfer.verdict == act0LearningTransferStableV1);
    // The latest repair is current evidence and caps older proof when failed.
    final level = !repaired
        ? Act0LearningReceiptLevelV1.attempted
        : hasCanonicalTransfer
        ? Act0LearningReceiptLevelV1.differentSpotImproved
        : recheck != null
        ? Act0LearningReceiptLevelV1.laterRecheckHeld
        : Act0LearningReceiptLevelV1.sameClueRepaired;
    final label = focusLabel.trim().isEmpty ? 'This clue' : focusLabel.trim();
    final verdict = hasCanonicalTransfer ? transfer.verdict : '';
    return Act0LearningReceiptV1(
      focusLabel: label,
      level: level,
      previousIssue: '$label was missed earlier.',
      latestOutcome: switch (level) {
        Act0LearningReceiptLevelV1.attempted => 'The repair did not land yet.',
        Act0LearningReceiptLevelV1.sameClueRepaired =>
          'The same clue was repaired.',
        Act0LearningReceiptLevelV1.laterRecheckHeld =>
          'A later recheck was correct.',
        Act0LearningReceiptLevelV1.differentSpotImproved =>
          verdict == act0LearningTransferImprovingV1
              ? 'The read improved on a different hand.'
              : 'The read held on a different hand.',
      },
      remainingStatus: switch (level) {
        Act0LearningReceiptLevelV1.attempted => 'Repair remains unresolved.',
        Act0LearningReceiptLevelV1.sameClueRepaired => 'Later proof remains.',
        Act0LearningReceiptLevelV1.laterRecheckHeld =>
          'Different-spot proof remains.',
        Act0LearningReceiptLevelV1.differentSpotImproved =>
          'No stronger claim is made.',
      },
      nextEvidenceRequirement: switch (level) {
        Act0LearningReceiptLevelV1.attempted => 'Answer the repair correctly.',
        Act0LearningReceiptLevelV1.sameClueRepaired => 'Pass a later recheck.',
        Act0LearningReceiptLevelV1.laterRecheckHeld =>
          'Hold the clue on a different spot.',
        Act0LearningReceiptLevelV1.differentSpotImproved =>
          'Continue with normal review evidence.',
      },
      sourceReferences: List<String>.unmodifiable(<String>[
        if (source.isNotEmpty) source,
        if (lastRepair != null) lastRepair.repairTaskId,
        if (recheck != null) recheck.taskId,
        if (hasCanonicalTransfer) transfer.comparisonTaskId,
      ]),
      transferVerdict: verdict,
      isExactReplay: isExactReplay,
    );
  }
}
