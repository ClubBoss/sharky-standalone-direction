import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

class Act0RepairOutcomeConsumerV1 {
  const Act0RepairOutcomeConsumerV1({this.proof});

  final Act0RepairOutcomeProofV1? proof;

  bool get hasProof => proof != null;

  static Act0RepairOutcomeConsumerV1 fromProjection(
    Act0RepairOutcomeProjectionV1 projection,
  ) {
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
    if (detail.isEmpty) {
      return const Act0RepairOutcomeConsumerV1();
    }
    return Act0RepairOutcomeConsumerV1(
      proof: Act0RepairOutcomeProofV1(
        title: 'Repair rep',
        detail: detail,
        outcomeState: latest.outcomeState,
        sequence: latest.sequence,
      ),
    );
  }
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

String _detailForOutcomeStateV1(String outcomeState) {
  return switch (outcomeState) {
    act0RepairOutcomeStateCorrectV1 =>
      'Good rep - you chose the better action.',
    act0RepairOutcomeStateStillNeedsRepV1 => 'Still worth repeating.',
    act0RepairOutcomeStateAttemptedV1 => 'Repair rep attempted.',
    _ => '',
  };
}
