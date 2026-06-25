import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';

class Act0ProfileEvidenceConsumerV1 {
  const Act0ProfileEvidenceConsumerV1({this.signal});

  final Act0ProfileEvidenceSignalViewModelV1? signal;

  bool get hasSignal => signal != null;

  static Act0ProfileEvidenceConsumerV1 fromProjection(
    Act0ProfileEvidenceProjectionV1 projection,
  ) {
    for (final signal in projection.signals) {
      if (!signal.isCapabilityEligible) {
        continue;
      }
      final label = act0ProfileEvidenceSkillLabelV1(signal.skillAtomId);
      if (label == null) {
        continue;
      }
      return Act0ProfileEvidenceConsumerV1(
        signal: Act0ProfileEvidenceSignalViewModelV1(
          signalId: signal.signalId,
          skillAtomId: signal.skillAtomId,
          skillLabel: label,
          correctCount: signal.correctCount,
          attemptCount: signal.attemptCount,
          proofLine:
              '${signal.correctCount}/${signal.attemptCount} correct in $label',
        ),
      );
    }
    return const Act0ProfileEvidenceConsumerV1();
  }
}

class Act0ProfileEvidenceSignalViewModelV1 {
  const Act0ProfileEvidenceSignalViewModelV1({
    required this.signalId,
    required this.skillAtomId,
    required this.skillLabel,
    required this.correctCount,
    required this.attemptCount,
    required this.proofLine,
  });

  final String signalId;
  final String skillAtomId;
  final String skillLabel;
  final int correctCount;
  final int attemptCount;
  final String proofLine;
}

String? act0ProfileEvidenceSkillLabelV1(String skillAtomId) {
  switch (skillAtomId.trim()) {
    case 'action_read':
      return 'Action reading';
    case 'position_read':
    case 'table_position_read':
      return 'Position reading';
    case 'board_read':
      return 'Board reading';
    case 'price_read':
      return 'Price reading';
    case 'table_read':
      return 'Table reading';
    case 'starting_hand_read':
      return 'Starting hand reading';
  }
  return null;
}
