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

/// Creates provenance for an authored W6 range-bucket miss only.
///
/// This is intentionally not wired to Act0 repair intents or Review. A later
/// bridge may consume this candidate after it owns the session-drill launch
/// contract.
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
  final expectedActionId = spec.expectedActionV1?.trim().toLowerCase() ?? '';
  final bucket = spec.rangeBucketV1?.trim().toLowerCase() ?? '';
  final targetDrillId = _rangeBucketRepairTargetBySourceDrillIdV1[drillId];

  if (sessionId != 'w6.s01' ||
      drillId.isEmpty ||
      drillId != spec.id.trim() ||
      spec.kind != DrillKindV1.rangeBucketClassifier ||
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
    drillFamilyId: 'range_bucket_classifier_v1',
    missedSignalId: 'range_bucket_$bucket',
    missedSignalLabel: _rangeBucketSignalLabelV1(bucket),
    chosenActionId: actionId,
    expectedActionId: expectedActionId,
    targetSessionId: sessionId,
    targetDrillId: targetDrillId,
    targetKind: targetDrillId == drillId
        ? 'exact_replay'
        : 'same_signal_recheck',
    errorClass: evaluation.errorClass?.trim() ?? 'range_bucket_miss',
  );
}

const Map<String, String> _rangeBucketRepairTargetBySourceDrillIdV1 =
    <String, String>{
      'classify_strong_raise': 'classify_strong_call_control',
      'classify_strong_call_control': 'classify_strong_raise',
      'classify_medium_call_control': 'classify_medium_call_control',
      'classify_weak_fold_pressure': 'classify_weak_fold_pressure',
      'classify_missed_fold': 'classify_missed_fold_recheck',
      'classify_missed_fold_recheck': 'classify_missed_fold',
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
