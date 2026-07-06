import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';

class SessionDrillRepairReceiptCandidateV1 {
  const SessionDrillRepairReceiptCandidateV1({
    required this.schemaVersion,
    required this.sourceWorldId,
    required this.sourceSessionId,
    required this.sourceDrillId,
    required this.drillFamilyId,
    required this.missedSignalId,
    required this.missedSignalLabel,
    required this.chosenActionId,
    required this.expectedActionId,
    required this.targetSessionId,
    required this.targetDrillId,
    required this.targetKind,
    required this.errorClass,
  });

  final int schemaVersion;
  final String sourceWorldId;
  final String sourceSessionId;
  final String sourceDrillId;
  final String drillFamilyId;
  final String missedSignalId;
  final String missedSignalLabel;
  final String chosenActionId;
  final String expectedActionId;
  final String targetSessionId;
  final String targetDrillId;
  final String targetKind;
  final String errorClass;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'sourceWorldId': sourceWorldId,
    'sourceSessionId': sourceSessionId,
    'sourceDrillId': sourceDrillId,
    'drillFamilyId': drillFamilyId,
    'missedSignalId': missedSignalId,
    'missedSignalLabel': missedSignalLabel,
    'chosenActionId': chosenActionId,
    'expectedActionId': expectedActionId,
    'targetSessionId': targetSessionId,
    'targetDrillId': targetDrillId,
    'targetKind': targetKind,
    'errorClass': errorClass,
  };
}

/// Creates provenance for reviewed W4/W6 same-signal misses only.
///
/// The existing persistence/consumer/queue path admits only the exact reviewed
/// tuples declared below; unknown same-family rows fail closed.
SessionDrillRepairReceiptCandidateV1?
buildSessionDrillRepairReceiptCandidateV1({
  required String sourceSessionId,
  required SessionDrillItemV1 sourceDrill,
  required DrillEvalResultV1 evaluation,
  required String chosenActionId,
}) {
  final sessionId = sourceSessionId.trim().toLowerCase();
  final drillId = sourceDrill.drillId.trim();
  final spec = sourceDrill.spec;
  final actionId = chosenActionId.trim().toLowerCase();
  final expectedActionId =
      (spec.expected.actionId ?? spec.expectedActionV1)?.trim().toLowerCase() ??
      '';
  final reviewedTarget = _reviewedRepairTargetBySourceV1['$sessionId:$drillId'];

  if (reviewedTarget != null) {
    if (drillId.isEmpty ||
        drillId != spec.id.trim() ||
        spec.kind != DrillKindV1.actionChoice ||
        spec.intentV1?.trim() != reviewedTarget.requiredIntent ||
        evaluation.isPass ||
        actionId.isEmpty ||
        expectedActionId != reviewedTarget.expectedActionId) {
      return null;
    }
    return SessionDrillRepairReceiptCandidateV1(
      schemaVersion: 1,
      sourceWorldId: reviewedTarget.sourceWorldId,
      sourceSessionId: sessionId,
      sourceDrillId: drillId,
      drillFamilyId: reviewedTarget.drillFamilyId,
      missedSignalId: reviewedTarget.missedSignalId,
      missedSignalLabel: reviewedTarget.missedSignalLabel,
      chosenActionId: actionId,
      expectedActionId: expectedActionId,
      targetSessionId: reviewedTarget.targetSessionId,
      targetDrillId: reviewedTarget.targetDrillId,
      targetKind: 'same_signal_recheck',
      errorClass: evaluation.errorClass?.trim() ?? reviewedTarget.errorClass,
    );
  }

  final bucket = spec.rangeBucketV1?.trim().toLowerCase() ?? '';
  final targetDrillId = _rangeBucketRepairTargetBySourceDrillIdV1[drillId];

  if (sessionId != 'w6.s01' ||
      drillId.isEmpty ||
      drillId != spec.id.trim() ||
      spec.kind != DrillKindV1.actionChoice ||
      evaluation.isPass ||
      actionId.isEmpty ||
      expectedActionId.isEmpty ||
      bucket.isEmpty ||
      targetDrillId == null) {
    return null;
  }

  return SessionDrillRepairReceiptCandidateV1(
    schemaVersion: 1,
    sourceWorldId: 'world_6',
    sourceSessionId: sessionId,
    sourceDrillId: drillId,
    drillFamilyId: 'range_bucket_board_fit_classifier_v1',
    missedSignalId: 'range_bucket_$bucket',
    missedSignalLabel: _rangeBucketSignalLabelV1(bucket),
    chosenActionId: actionId,
    expectedActionId: expectedActionId,
    targetSessionId: sessionId,
    targetDrillId: targetDrillId,
    targetKind: 'same_signal_recheck',
    errorClass: evaluation.errorClass?.trim() ?? 'range_bucket_miss',
  );
}

typedef _ReviewedSessionDrillRepairTargetV1 = ({
  String sourceWorldId,
  String requiredIntent,
  String expectedActionId,
  String drillFamilyId,
  String missedSignalId,
  String missedSignalLabel,
  String targetSessionId,
  String targetDrillId,
  String errorClass,
});

const Map<String, _ReviewedSessionDrillRepairTargetV1>
_reviewedRepairTargetBySourceV1 = <String, _ReviewedSessionDrillRepairTargetV1>{
  'w6.s02:classify_button_range_wider': (
    sourceWorldId: 'world_6',
    requiredIntent: 'position_and_range_width',
    expectedActionId: 'wider',
    drillFamilyId: 'range_width_classifier_v1',
    missedSignalId: 'range_width_wider',
    missedSignalLabel: 'Wider range',
    targetSessionId: 'w6.s02',
    targetDrillId: 'classify_late_position_more_hands',
    errorClass: 'range_width_mismatch',
  ),
  'w6.s02:classify_late_position_more_hands': (
    sourceWorldId: 'world_6',
    requiredIntent: 'position_and_range_width',
    expectedActionId: 'wider',
    drillFamilyId: 'range_width_classifier_v1',
    missedSignalId: 'range_width_wider',
    missedSignalLabel: 'Wider range',
    targetSessionId: 'w6.s02',
    targetDrillId: 'classify_button_range_wider',
    errorClass: 'range_width_mismatch',
  ),
  'w6.s02:classify_continue_range_narrower': (
    sourceWorldId: 'world_6',
    requiredIntent: 'position_and_range_width',
    expectedActionId: 'narrower',
    drillFamilyId: 'range_width_classifier_v1',
    missedSignalId: 'range_width_narrower',
    missedSignalLabel: 'Narrower range',
    targetSessionId: 'w6.s02',
    targetDrillId: 'classify_big_blind_continue_narrower',
    errorClass: 'range_width_mismatch',
  ),
  'w6.s02:classify_big_blind_continue_narrower': (
    sourceWorldId: 'world_6',
    requiredIntent: 'position_and_range_width',
    expectedActionId: 'narrower',
    drillFamilyId: 'range_width_classifier_v1',
    missedSignalId: 'range_width_narrower',
    missedSignalLabel: 'Narrower range',
    targetSessionId: 'w6.s02',
    targetDrillId: 'classify_continue_range_narrower',
    errorClass: 'range_width_mismatch',
  ),
  'w4.s02:choose_raise_denial': (
    sourceWorldId: 'world_4',
    requiredIntent: 'bet_for_denial',
    expectedActionId: 'raise',
    drillFamilyId: 'denial_action_choice_v1',
    missedSignalId: 'denial_equity_charge',
    missedSignalLabel: 'Charge live overcards and draws',
    targetSessionId: 'w4.s06',
    targetDrillId: 'choose_raise_repeat',
    errorClass: 'expected_action_mismatch',
  ),
};

const Map<String, String> _rangeBucketRepairTargetBySourceDrillIdV1 =
    <String, String>{
      'classify_strong_clean_fit': 'classify_strong_overpair_fit',
      'classify_strong_overpair_fit': 'classify_strong_clean_fit',
      'classify_missed_overcards_no_draw': 'classify_missed_low_cards_no_draw',
      'classify_missed_low_cards_no_draw': 'classify_missed_overcards_no_draw',
    };

String _rangeBucketSignalLabelV1(String bucket) {
  return switch (bucket) {
    'strong' => 'Strong range bucket',
    'medium' => 'Medium range bucket',
    'weak' => 'Weak range bucket',
    'missed' => 'Missed range bucket',
    _ => 'Range bucket',
  };
}
