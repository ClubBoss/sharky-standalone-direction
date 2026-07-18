import 'act0_learning_evidence_contract_v1.dart';
import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';

enum Act0LearningReceiptLevelV1 {
  attempted,
  sameClueRepaired,
  laterRecheckHeld,
  differentSpotImproved,
}

/// A conservative, recomputed receipt. The persisted repair and learning
/// evidence remain its only sources; no rendered copy or duplicate receipt is
/// stored.
class Act0LearningReceiptV1 {
  const Act0LearningReceiptV1({
    required this.focusLabel,
    required this.level,
    required this.previousIssue,
    required this.latestOutcome,
    required this.remainingStatus,
    required this.nextEvidenceRequirement,
    required this.sourceReferences,
  });

  final String focusLabel;
  final Act0LearningReceiptLevelV1 level;
  final String previousIssue;
  final String latestOutcome;
  final String remainingStatus;
  final String nextEvidenceRequirement;
  final List<String> sourceReferences;

  String get telemetryLevel => switch (level) {
    Act0LearningReceiptLevelV1.attempted => 'attempted',
    Act0LearningReceiptLevelV1.sameClueRepaired => 'same_clue_repaired',
    Act0LearningReceiptLevelV1.laterRecheckHeld => 'later_recheck_held',
    Act0LearningReceiptLevelV1.differentSpotImproved =>
      'different_spot_improved',
  };

  String get visibleCopy => switch (level) {
    Act0LearningReceiptLevelV1.attempted =>
      '$focusLabel was attempted and still needs a clean repair.',
    Act0LearningReceiptLevelV1.sameClueRepaired =>
      'You corrected $focusLabel on the same clue. A later check will show whether it holds.',
    Act0LearningReceiptLevelV1.laterRecheckHeld =>
      '$focusLabel held on a later check. A different spot is the next proof.',
    Act0LearningReceiptLevelV1.differentSpotImproved =>
      '$focusLabel held on a different hand.',
  };

  factory Act0LearningReceiptV1.fromEvidence({
    required String focusLabel,
    required String sourceTaskId,
    required Iterable<Act0RepairOutcomeV1> repairOutcomes,
    required Act0LearningEvidenceHistoryV1 learningEvidence,
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
    final recheck = evidence.where(
      (record) =>
          record.isCorrect &&
          record.reviewKind == Act0ReviewKindV1.originalSourceRecheck,
    );
    final transfer = evidence.where(
      (record) =>
          record.isCorrect &&
          record.reviewKind == Act0ReviewKindV1.unseenTransfer &&
          record.taskId.trim() != source,
    );
    final level = transfer.isNotEmpty
        ? Act0LearningReceiptLevelV1.differentSpotImproved
        : recheck.isNotEmpty && repaired
        ? Act0LearningReceiptLevelV1.laterRecheckHeld
        : repaired
        ? Act0LearningReceiptLevelV1.sameClueRepaired
        : Act0LearningReceiptLevelV1.attempted;
    final label = focusLabel.trim().isEmpty ? 'This clue' : focusLabel.trim();
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
          'A different transfer spot was correct.',
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
        if (recheck.isNotEmpty) recheck.last.taskId,
        if (transfer.isNotEmpty) transfer.last.taskId,
      ]),
    );
  }
}
