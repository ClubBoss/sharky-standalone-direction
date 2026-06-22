import 'package:poker_analyzer/services/session_drill_repair_receipt_adapter_v1.dart';
import 'package:poker_analyzer/services/session_drill_repair_receipt_persistence_v1.dart';

class SessionDrillRepairRecheckCandidateV1 {
  const SessionDrillRepairRecheckCandidateV1({
    required this.schemaVersion,
    required this.consumerKind,
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
  final String consumerKind;
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
    'consumerKind': consumerKind,
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

class SessionDrillRepairReceiptConsumerV1 {
  const SessionDrillRepairReceiptConsumerV1({
    this.persistence = const SessionDrillRepairReceiptPersistenceV1(),
  });

  final SessionDrillRepairReceiptPersistenceV1 persistence;

  Future<List<SessionDrillRepairRecheckCandidateV1>>
  loadRangeBucketRecheckCandidates() async {
    final receipts = await persistence.loadCandidates();
    final seenSourceDrills = <String>{};
    final candidates = <SessionDrillRepairRecheckCandidateV1>[];
    for (final receipt in receipts) {
      final candidate = buildSessionDrillRepairRecheckCandidateV1(receipt);
      if (candidate == null) {
        continue;
      }
      final sourceKey =
          '${candidate.sourceSessionId}:${candidate.sourceDrillId}';
      if (!seenSourceDrills.add(sourceKey)) {
        continue;
      }
      candidates.add(candidate);
    }
    candidates.sort((a, b) {
      final sessionOrder = a.sourceSessionId.compareTo(b.sourceSessionId);
      if (sessionOrder != 0) {
        return sessionOrder;
      }
      return a.sourceDrillId.compareTo(b.sourceDrillId);
    });
    return candidates;
  }
}

SessionDrillRepairRecheckCandidateV1? buildSessionDrillRepairRecheckCandidateV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  final targetKind = receipt.targetKind.trim();
  if (receipt.schemaVersion != 1 ||
      receipt.sourceWorldId.trim() != 'world_6' ||
      receipt.sourceSessionId.trim() != 'w6.s01' ||
      receipt.targetSessionId.trim() != 'w6.s01' ||
      receipt.drillFamilyId.trim() != 'range_bucket_classifier_v1' ||
      !receipt.missedSignalId.trim().startsWith('range_bucket_') ||
      !_supportedTargetKindsV1.contains(targetKind)) {
    return null;
  }

  final requiredValues = <String>[
    receipt.sourceDrillId,
    receipt.missedSignalLabel,
    receipt.chosenActionId,
    receipt.expectedActionId,
    receipt.targetDrillId,
    receipt.errorClass,
  ];
  if (requiredValues.any((value) => value.trim().isEmpty)) {
    return null;
  }

  return SessionDrillRepairRecheckCandidateV1(
    schemaVersion: 1,
    consumerKind: 'session_drill_recheck',
    sourceWorldId: receipt.sourceWorldId.trim(),
    sourceSessionId: receipt.sourceSessionId.trim(),
    sourceDrillId: receipt.sourceDrillId.trim(),
    drillFamilyId: receipt.drillFamilyId.trim(),
    missedSignalId: receipt.missedSignalId.trim(),
    missedSignalLabel: receipt.missedSignalLabel.trim(),
    chosenActionId: receipt.chosenActionId.trim(),
    expectedActionId: receipt.expectedActionId.trim(),
    targetSessionId: receipt.targetSessionId.trim(),
    targetDrillId: receipt.targetDrillId.trim(),
    targetKind: targetKind,
    errorClass: receipt.errorClass.trim(),
  );
}

const Set<String> _supportedTargetKindsV1 = <String>{
  'exact_replay',
  'same_signal_recheck',
};
