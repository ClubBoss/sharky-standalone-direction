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

  Future<List<SessionDrillRecheckLaunchQueueItemV1>>
  loadBoardTextureLaunchQueueItems() async {
    final candidates = await consumer.loadBoardTextureRecheckCandidates();
    return candidates
        .map(buildSessionDrillRecheckLaunchQueueItemV1)
        .whereType<SessionDrillRecheckLaunchQueueItemV1>()
        .toList(growable: false);
  }

  Future<List<SessionDrillRecheckLaunchQueueItemV1>>
  loadSupportedLaunchQueueItems() async {
    final items = <SessionDrillRecheckLaunchQueueItemV1>[
      ...await loadRangeBucketLaunchQueueItems(),
      ...await loadBoardTextureLaunchQueueItems(),
    ];
    final seenJobIds = <String>{};
    return <SessionDrillRecheckLaunchQueueItemV1>[
      for (final item in items)
        if (seenJobIds.add(item.jobId)) item,
    ];
  }
}

SessionDrillRecheckLaunchQueueItemV1? buildSessionDrillRecheckLaunchQueueItemV1(
  SessionDrillRepairRecheckCandidateV1 candidate,
) {
  if (candidate.schemaVersion != 1 ||
      candidate.consumerKind.trim() != 'session_drill_recheck' ||
      !_isSupportedRepairFamilyCandidateV1(candidate) ||
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

bool _isSupportedRepairFamilyCandidateV1(
  SessionDrillRepairRecheckCandidateV1 candidate,
) {
  final sourceWorldId = candidate.sourceWorldId.trim();
  final sourceSessionId = candidate.sourceSessionId.trim();
  final targetSessionId = candidate.targetSessionId.trim();
  final drillFamilyId = candidate.drillFamilyId.trim();
  final missedSignalId = candidate.missedSignalId.trim();
  final isRangeBucket =
      sourceWorldId == 'world_6' &&
      sourceSessionId == 'w6.s01' &&
      targetSessionId == 'w6.s01' &&
      drillFamilyId == 'range_bucket_classifier_v1' &&
      missedSignalId.startsWith('range_bucket_');
  final isBoardTexture =
      sourceWorldId == 'world_5' &&
      sourceSessionId == 'w5.s01' &&
      targetSessionId == 'w5.s01' &&
      drillFamilyId == 'board_texture_classifier_v1' &&
      missedSignalId.startsWith('board_texture_');
  return isRangeBucket || isBoardTexture;
}

const Set<String> _supportedTargetKindsV1 = <String>{
  'exact_replay',
  'same_signal_recheck',
};
