import 'package:poker_analyzer/services/session_drill_repair_receipt_consumer_v1.dart';

class SessionDrillRecheckLaunchQueueItemV1 {
  const SessionDrillRecheckLaunchQueueItemV1({
    required this.queueKind,
    required this.jobId,
    required this.launchSessionId,
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

  final String queueKind;
  final String jobId;
  final String launchSessionId;
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
    'queueKind': queueKind,
    'jobId': jobId,
    'launchSessionId': launchSessionId,
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

class SessionDrillRecheckLaunchQueueV1 {
  const SessionDrillRecheckLaunchQueueV1({
    this.consumer = const SessionDrillRepairReceiptConsumerV1(),
  });

  final SessionDrillRepairReceiptConsumerV1 consumer;

  Future<List<SessionDrillRecheckLaunchQueueItemV1>>
  loadRangeBucketLaunchQueueItems() async {
    final candidates = await consumer.loadRangeBucketRecheckCandidates();
    return candidates
        .map(buildSessionDrillRecheckLaunchQueueItemV1)
        .whereType<SessionDrillRecheckLaunchQueueItemV1>()
        .toList(growable: false);
  }
}

SessionDrillRecheckLaunchQueueItemV1? buildSessionDrillRecheckLaunchQueueItemV1(
  SessionDrillRepairRecheckCandidateV1 candidate,
) {
  if (candidate.schemaVersion != 1 ||
      candidate.consumerKind.trim() != 'session_drill_recheck' ||
      candidate.sourceWorldId.trim() != 'world_6' ||
      candidate.sourceSessionId.trim() != 'w6.s01' ||
      candidate.targetSessionId.trim() != 'w6.s01' ||
      candidate.drillFamilyId.trim() != 'range_bucket_classifier_v1' ||
      !candidate.missedSignalId.trim().startsWith('range_bucket_') ||
      !_supportedTargetKindsV1.contains(candidate.targetKind.trim())) {
    return null;
  }

  final requiredValues = <String>[
    candidate.sourceDrillId,
    candidate.missedSignalLabel,
    candidate.chosenActionId,
    candidate.expectedActionId,
    candidate.targetDrillId,
    candidate.errorClass,
  ];
  if (requiredValues.any((value) => value.trim().isEmpty)) {
    return null;
  }

  final targetSessionId = candidate.targetSessionId.trim();
  final targetDrillId = candidate.targetDrillId.trim();
  return SessionDrillRecheckLaunchQueueItemV1(
    queueKind: 'session_drill_recheck',
    jobId: 'session_drill_recheck:$targetSessionId:$targetDrillId',
    launchSessionId: targetSessionId,
    sourceWorldId: candidate.sourceWorldId.trim(),
    sourceSessionId: candidate.sourceSessionId.trim(),
    sourceDrillId: candidate.sourceDrillId.trim(),
    drillFamilyId: candidate.drillFamilyId.trim(),
    missedSignalId: candidate.missedSignalId.trim(),
    missedSignalLabel: candidate.missedSignalLabel.trim(),
    chosenActionId: candidate.chosenActionId.trim(),
    expectedActionId: candidate.expectedActionId.trim(),
    targetSessionId: targetSessionId,
    targetDrillId: targetDrillId,
    targetKind: candidate.targetKind.trim(),
    errorClass: candidate.errorClass.trim(),
  );
}

const Set<String> _supportedTargetKindsV1 = <String>{
  'exact_replay',
  'same_signal_recheck',
};
