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
  }) {
    if (projection.outcomes.isEmpty) {
      return const Act0RepairOutcomeConsumerV1();
    }
    final ordered = <Act0RepairOutcomeV1>[...projection.outcomes]
      ..sort((a, b) {
        final sequenceCompare = a.sequence.compareTo(b.sequence);
        if (sequenceCompare != 0) {
          return sequenceCompare;
        }
        return a.queueItemId.compareTo(b.queueItemId);
      });
    final latest = ordered.last;
    final detail = _detailForOutcomeStateV1(latest.outcomeState);
    final receipt =
        _sessionReceiptForFixProofV1(
          fixProofProjection,
          improvementObservationProjection: improvementObservationProjection,
        ) ??
        _sessionReceiptForOutcomesV1(ordered);
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
  final improvementLine =
      improvementObservationProjection?.latestObservation?.line.trim() ?? '';
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
    if (correctCount > 0) 'Good fixes: $correctCount',
    if (stillNeedsRepCount > 0) 'Still to fix: $stillNeedsRepCount',
    if (correctCount == 0 && stillNeedsRepCount == 0 && attemptedCount > 0)
      'Fixes tried: $attemptedCount',
  ];
  if (lines.isEmpty) {
    return null;
  }
  return Act0RepairOutcomeSessionReceiptV1(
    title: "Fixes you've banked",
    lines: List<String>.unmodifiable(lines),
  );
}
