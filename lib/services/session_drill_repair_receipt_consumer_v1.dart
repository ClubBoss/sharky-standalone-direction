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
    return _loadCandidatesWhere(buildSessionDrillRepairRecheckCandidateV1);
  }

  Future<List<SessionDrillRepairRecheckCandidateV1>>
  loadBoardTextureRecheckCandidates() async {
    return _loadCandidatesWhere(buildBoardTextureRepairRecheckCandidateV1);
  }

  Future<List<SessionDrillRepairRecheckCandidateV1>>
  loadRangeWidthRecheckCandidates() async {
    return _loadCandidatesWhere(buildRangeWidthRepairRecheckCandidateV1);
  }

  Future<List<SessionDrillRepairRecheckCandidateV1>>
  loadDenialRecheckCandidates() async {
    return _loadCandidatesWhere(buildDenialRepairRecheckCandidateV1);
  }

  Future<List<SessionDrillRepairRecheckCandidateV1>> _loadCandidatesWhere(
    SessionDrillRepairRecheckCandidateV1? Function(
      SessionDrillRepairReceiptCandidateV1 receipt,
    )
    buildCandidate,
  ) async {
    final receipts = await persistence.loadCandidates();
    final seenSourceDrills = <String>{};
    final candidates = <SessionDrillRepairRecheckCandidateV1>[];
    for (final receipt in receipts) {
      final candidate = buildCandidate(receipt);
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
  if (!_isSupportedRangeBucketReceiptV1(receipt)) {
    return null;
  }
  return _buildRecheckCandidateV1(receipt);
}

SessionDrillRepairRecheckCandidateV1? buildBoardTextureRepairRecheckCandidateV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  if (!_isSupportedBoardTextureReceiptV1(receipt)) {
    return null;
  }
  return _buildRecheckCandidateV1(receipt);
}

SessionDrillRepairRecheckCandidateV1? buildRangeWidthRepairRecheckCandidateV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  if (!_isSupportedRangeWidthReceiptV1(receipt)) {
    return null;
  }
  return _buildRecheckCandidateV1(receipt);
}

SessionDrillRepairRecheckCandidateV1? buildDenialRepairRecheckCandidateV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  if (!_isSupportedDenialReceiptV1(receipt)) {
    return null;
  }
  return _buildRecheckCandidateV1(receipt);
}

SessionDrillRepairRecheckCandidateV1? _buildRecheckCandidateV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  final targetKind = receipt.targetKind.trim();
  if (!_supportedTargetKindsV1.contains(targetKind)) {
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

bool _isSupportedRangeBucketReceiptV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  return receipt.schemaVersion == 1 &&
      receipt.sourceWorldId.trim() == 'world_6' &&
      receipt.sourceSessionId.trim() == 'w6.s01' &&
      receipt.targetSessionId.trim() == 'w6.s01' &&
      receipt.drillFamilyId.trim() == 'range_bucket_board_fit_classifier_v1' &&
      receipt.missedSignalId.trim().startsWith('range_bucket_') &&
      _supportedTargetKindsV1.contains(receipt.targetKind.trim());
}

bool _isSupportedBoardTextureReceiptV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  return receipt.schemaVersion == 1 &&
      receipt.sourceWorldId.trim() == 'world_5' &&
      receipt.drillFamilyId.trim() == 'board_texture_classifier_v1' &&
      _reviewedBoardTextureReceiptKeysV1.contains(
        _receiptMappingKeyV1(receipt),
      ) &&
      _supportedTargetKindsV1.contains(receipt.targetKind.trim());
}

bool _isSupportedRangeWidthReceiptV1(
  SessionDrillRepairReceiptCandidateV1 receipt,
) {
  return receipt.schemaVersion == 1 &&
      receipt.sourceWorldId.trim() == 'world_6' &&
      receipt.sourceSessionId.trim() == 'w6.s02' &&
      receipt.targetSessionId.trim() == 'w6.s02' &&
      receipt.drillFamilyId.trim() == 'range_width_classifier_v1' &&
      _reviewedRangeWidthReceiptKeysV1.contains(
        _receiptMappingKeyV1(receipt),
      ) &&
      receipt.targetKind.trim() == 'same_signal_recheck';
}

bool _isSupportedDenialReceiptV1(SessionDrillRepairReceiptCandidateV1 receipt) {
  return receipt.schemaVersion == 1 &&
      receipt.sourceWorldId.trim() == 'world_4' &&
      receipt.sourceSessionId.trim() == 'w4.s02' &&
      receipt.targetSessionId.trim() == 'w4.s06' &&
      receipt.drillFamilyId.trim() == 'denial_action_choice_v1' &&
      _reviewedDenialReceiptKeysV1.contains(_receiptMappingKeyV1(receipt)) &&
      receipt.targetKind.trim() == 'same_signal_recheck';
}

String _receiptMappingKeyV1(SessionDrillRepairReceiptCandidateV1 receipt) =>
    '${receipt.sourceSessionId.trim()}:${receipt.sourceDrillId.trim()}->'
    '${receipt.targetSessionId.trim()}:${receipt.targetDrillId.trim()}:'
    '${receipt.missedSignalId.trim()}';

const Set<String> _reviewedBoardTextureReceiptKeysV1 = <String>{
  'w5.s01:classify_texture_intro_dry_raise_v1->w5.s01:classify_texture_intro_dry_raise_v1:board_texture_dry',
  'w5.s01:classify_texture_intro_wet_call_v1->w5.s01:classify_texture_intro_wet_call_v1:board_texture_wet',
  'w5.s01:classify_texture_intro_paired_fold_v1->w5.s01:classify_texture_intro_paired_fold_v1:board_texture_paired',
  'w5.s06:classify_in_position_dry_raise_v1->w5.s10:classify_texture_synthesis_dry_raise_v1:board_texture_dry',
  'w5.s10:classify_texture_synthesis_dry_raise_v1->w5.s06:classify_in_position_dry_raise_v1:board_texture_dry',
};

const Set<String> _reviewedRangeWidthReceiptKeysV1 = <String>{
  'w6.s02:classify_button_range_wider->w6.s02:classify_late_position_more_hands:range_width_wider',
  'w6.s02:classify_late_position_more_hands->w6.s02:classify_button_range_wider:range_width_wider',
  'w6.s02:classify_continue_range_narrower->w6.s02:classify_big_blind_continue_narrower:range_width_narrower',
  'w6.s02:classify_big_blind_continue_narrower->w6.s02:classify_continue_range_narrower:range_width_narrower',
};

const Set<String> _reviewedDenialReceiptKeysV1 = <String>{
  'w4.s02:choose_raise_denial->w4.s06:choose_raise_repeat:denial_equity_charge',
};

const Set<String> _supportedTargetKindsV1 = <String>{
  'exact_replay',
  'same_signal_recheck',
};
