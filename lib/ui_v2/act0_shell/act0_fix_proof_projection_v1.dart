import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';
import 'act0_review_resolution_contract_v1.dart';

const String act0FixProofStateRepairCompletedV1 = 'repair_completed';
const String act0FixProofStateReinforcedByLaterEvidenceV1 =
    'reinforced_by_later_evidence';
const String act0FixProofStateHistoricalCompletedV1 = 'historical_completed';
const String act0FixProofStateInsufficientEvidenceV1 = 'insufficient_evidence';

const String act0FixProofRecentSessionWindowV1 = 'recent_session_window_v1';

const String _messageRepairCompletedV1 = 'fix_proof_repair_completed_v1';
const String _messageReinforcedV1 = 'fix_proof_reinforced_v1';

class Act0FixProofProjectionV1 {
  const Act0FixProofProjectionV1({
    this.schemaVersion = 1,
    this.proofs = const <Act0FixProofItemV1>[],
    this.recentSessionLimit = 7,
  });

  final int schemaVersion;
  final List<Act0FixProofItemV1> proofs;
  final int recentSessionLimit;

  Act0FixProofAggregateV1 get aggregate => Act0FixProofAggregateV1.fromProofs(
    proofs,
    recentSessionLimit: recentSessionLimit,
  );

  static Act0FixProofProjectionV1 fromSources({
    required Act0RepairOutcomeProjectionV1 repairOutcomeProjection,
    required Act0ReviewResolutionReceiptHistoryV1
    reviewResolutionReceiptHistory,
    Act0LearningTransferMeasurementV1? transferMeasurement,
    int recentSessionLimit = 7,
  }) {
    final successfulOutcomesByQueueItemId = <String, Act0RepairOutcomeV1>{};
    for (final outcome in repairOutcomeProjection.outcomes) {
      final queueItemId = outcome.queueItemId.trim();
      if (queueItemId.isEmpty || outcome.isCorrect != true) {
        continue;
      }
      final existing = successfulOutcomesByQueueItemId[queueItemId];
      if (existing == null || _outcomeOrder(outcome, existing) > 0) {
        successfulOutcomesByQueueItemId[queueItemId] = outcome;
      }
    }

    final byQueueItemId = <String, Act0FixProofItemV1>{};
    for (final receipt in reviewResolutionReceiptHistory.receipts) {
      final queueItemId = _queueItemIdFromRepairOutcomeRef(
        receipt.repairOutcomeId ?? '',
      );
      if (queueItemId.isEmpty) {
        continue;
      }
      final outcome = successfulOutcomesByQueueItemId[queueItemId];
      if (outcome == null) {
        continue;
      }
      final bankedAtOrder = receipt.resolvedAtOrder ?? outcome.sequence;
      final conceptFamilyId = receipt.conceptFamilyId.trim().isNotEmpty
          ? receipt.conceptFamilyId.trim()
          : outcome.repairFocusKey.trim();
      if (conceptFamilyId.isEmpty) {
        continue;
      }
      final base = Act0FixProofItemV1(
        fixProofId: 'fix_proof_v1|$queueItemId',
        queueItemId: queueItemId,
        conceptFamilyId: conceptFamilyId,
        repairFocusId: outcome.repairFocusKey.trim(),
        sourceTaskId: receipt.sourceTaskId ?? outcome.sourceTaskId,
        repairSessionId: outcome.sessionId.trim().isNotEmpty
            ? outcome.sessionId.trim()
            : receipt.sourceSessionId ?? '',
        repairOutcomeRef: receipt.repairOutcomeId ?? '',
        proofState: act0FixProofStateRepairCompletedV1,
        bankedAtOrder: bankedAtOrder,
        messageKey: _messageRepairCompletedV1,
      );
      final proof = _reinforcedIfEligible(base, transferMeasurement);
      final existing = byQueueItemId[queueItemId];
      if (existing == null || _proofOrder(proof, existing) < 0) {
        byQueueItemId[queueItemId] = proof;
      }
    }

    final proofs = byQueueItemId.values.toList(growable: false)
      ..sort(_proofOrder);
    return Act0FixProofProjectionV1(
      proofs: List<Act0FixProofItemV1>.unmodifiable(proofs),
      recentSessionLimit: _safeRecentSessionLimit(recentSessionLimit),
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'recentSessionLimit': recentSessionLimit,
    'proofs': proofs.map((proof) => proof.toPayload()).toList(growable: false),
  };

  static Act0FixProofProjectionV1 tryParse(Object? raw) {
    if (raw is! Map) {
      return const Act0FixProofProjectionV1();
    }
    final map = raw.cast<String, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    if (schemaVersion != 1) {
      return const Act0FixProofProjectionV1();
    }
    final rawProofs = map['proofs'];
    if (rawProofs is! List) {
      return const Act0FixProofProjectionV1();
    }
    final byQueueItemId = <String, Act0FixProofItemV1>{};
    for (final rawProof in rawProofs) {
      final proof = Act0FixProofItemV1.tryParse(rawProof);
      if (proof == null) {
        continue;
      }
      final existing = byQueueItemId[proof.queueItemId];
      if (existing == null || _proofOrder(proof, existing) < 0) {
        byQueueItemId[proof.queueItemId] = proof;
      }
    }
    final proofs = byQueueItemId.values.toList(growable: false)
      ..sort(_proofOrder);
    return Act0FixProofProjectionV1(
      proofs: List<Act0FixProofItemV1>.unmodifiable(proofs),
      recentSessionLimit: _safeRecentSessionLimit(
        _nonNegativeInt(map['recentSessionLimit']) ?? 7,
      ),
    );
  }
}

class Act0FixProofItemV1 {
  const Act0FixProofItemV1({
    this.schemaVersion = 1,
    required this.fixProofId,
    required this.queueItemId,
    required this.conceptFamilyId,
    this.repairFocusId = '',
    this.sourceTaskId = '',
    required this.repairSessionId,
    required this.repairOutcomeRef,
    required this.proofState,
    this.laterEvidenceSessionId = '',
    this.laterEvidenceTaskId = '',
    this.transferVerdict = '',
    required this.bankedAtOrder,
    required this.messageKey,
  });

  final int schemaVersion;
  final String fixProofId;
  final String queueItemId;
  final String conceptFamilyId;
  final String repairFocusId;
  final String sourceTaskId;
  final String repairSessionId;
  final String repairOutcomeRef;
  final String proofState;
  final String laterEvidenceSessionId;
  final String laterEvidenceTaskId;
  final String transferVerdict;
  final int bankedAtOrder;
  final String messageKey;

  bool get isReinforced =>
      proofState == act0FixProofStateReinforcedByLaterEvidenceV1;

  String get copyLine {
    if (isReinforced) {
      return 'You later handled this clue correctly on another hand.';
    }
    return '1 repair completed';
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'fixProofId': fixProofId,
    'queueItemId': queueItemId,
    'conceptFamilyId': conceptFamilyId,
    if (repairFocusId.isNotEmpty) 'repairFocusId': repairFocusId,
    if (sourceTaskId.isNotEmpty) 'sourceTaskId': sourceTaskId,
    'repairSessionId': repairSessionId,
    'repairOutcomeRef': repairOutcomeRef,
    'proofState': proofState,
    if (laterEvidenceSessionId.isNotEmpty)
      'laterEvidenceSessionId': laterEvidenceSessionId,
    if (laterEvidenceTaskId.isNotEmpty)
      'laterEvidenceTaskId': laterEvidenceTaskId,
    if (transferVerdict.isNotEmpty) 'transferVerdict': transferVerdict,
    'bankedAtOrder': bankedAtOrder,
    'messageKey': messageKey,
  };

  static Act0FixProofItemV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    final fixProofId = _requiredString(map, 'fixProofId');
    final queueItemId = _requiredString(map, 'queueItemId');
    final conceptFamilyId = _requiredString(map, 'conceptFamilyId');
    final repairSessionId = _requiredString(map, 'repairSessionId');
    final repairOutcomeRef = _requiredString(map, 'repairOutcomeRef');
    final proofState = _requiredString(map, 'proofState');
    final bankedAtOrder = _nonNegativeInt(map['bankedAtOrder']);
    final messageKey = _requiredString(map, 'messageKey');
    if (schemaVersion != 1 ||
        fixProofId == null ||
        queueItemId == null ||
        conceptFamilyId == null ||
        repairSessionId == null ||
        repairOutcomeRef == null ||
        proofState == null ||
        !_proofStates.contains(proofState) ||
        bankedAtOrder == null ||
        messageKey == null) {
      return null;
    }
    return Act0FixProofItemV1(
      fixProofId: fixProofId,
      queueItemId: queueItemId,
      conceptFamilyId: conceptFamilyId,
      repairFocusId: map['repairFocusId']?.toString().trim() ?? '',
      sourceTaskId: map['sourceTaskId']?.toString().trim() ?? '',
      repairSessionId: repairSessionId,
      repairOutcomeRef: repairOutcomeRef,
      proofState: proofState,
      laterEvidenceSessionId:
          map['laterEvidenceSessionId']?.toString().trim() ?? '',
      laterEvidenceTaskId: map['laterEvidenceTaskId']?.toString().trim() ?? '',
      transferVerdict: map['transferVerdict']?.toString().trim() ?? '',
      bankedAtOrder: bankedAtOrder,
      messageKey: messageKey,
    );
  }
}

class Act0FixProofAggregateV1 {
  const Act0FixProofAggregateV1({
    required this.completedFixCount,
    required this.reinforcedFixCount,
    required this.distinctConceptFamilyCount,
    required this.windowDescriptor,
    required this.recentProofItems,
  });

  final int completedFixCount;
  final int reinforcedFixCount;
  final int distinctConceptFamilyCount;
  final String windowDescriptor;
  final List<Act0FixProofItemV1> recentProofItems;

  List<String> get lines {
    if (completedFixCount <= 0) {
      return const <String>[];
    }
    return List<String>.unmodifiable(<String>[
      completedFixCount == 1
          ? '1 repair completed'
          : '$completedFixCount fixes banked across your recent sessions',
      if (reinforcedFixCount == 1)
        '1 completed repair now has later supporting evidence'
      else if (reinforcedFixCount > 1)
        '$reinforcedFixCount completed repairs now have later supporting evidence',
    ]);
  }

  static Act0FixProofAggregateV1 fromProofs(
    List<Act0FixProofItemV1> proofs, {
    required int recentSessionLimit,
  }) {
    final recentProofs = _recentSessionWindowProofs(
      proofs,
      recentSessionLimit: recentSessionLimit,
    );
    final familyIds = <String>{
      for (final proof in recentProofs) proof.conceptFamilyId,
    };
    final visibleItems = recentProofs.take(3).toList(growable: false);
    return Act0FixProofAggregateV1(
      completedFixCount: recentProofs.length,
      reinforcedFixCount: recentProofs
          .where((proof) => proof.isReinforced)
          .length,
      distinctConceptFamilyCount: familyIds.length,
      windowDescriptor: act0FixProofRecentSessionWindowV1,
      recentProofItems: List<Act0FixProofItemV1>.unmodifiable(visibleItems),
    );
  }
}

Act0FixProofItemV1 _reinforcedIfEligible(
  Act0FixProofItemV1 proof,
  Act0LearningTransferMeasurementV1? measurement,
) {
  if (measurement == null) {
    return proof;
  }
  for (final signal in measurement.signals) {
    if (signal.conceptFamilyId.trim() != proof.conceptFamilyId ||
        signal.relationship != act0LearningTransferSameFamilyTransferV1 ||
        signal.verdict != act0LearningTransferImprovedV1 ||
        signal.comparisonOrder == null ||
        signal.comparisonOrder! <= proof.bankedAtOrder ||
        signal.comparisonSessionId.trim().isEmpty ||
        signal.comparisonSessionId.trim() == proof.repairSessionId ||
        signal.comparisonTaskId.trim().isEmpty) {
      continue;
    }
    return Act0FixProofItemV1(
      fixProofId: proof.fixProofId,
      queueItemId: proof.queueItemId,
      conceptFamilyId: proof.conceptFamilyId,
      repairFocusId: proof.repairFocusId,
      sourceTaskId: proof.sourceTaskId,
      repairSessionId: proof.repairSessionId,
      repairOutcomeRef: proof.repairOutcomeRef,
      proofState: act0FixProofStateReinforcedByLaterEvidenceV1,
      laterEvidenceSessionId: signal.comparisonSessionId.trim(),
      laterEvidenceTaskId: signal.comparisonTaskId.trim(),
      transferVerdict: signal.verdict,
      bankedAtOrder: proof.bankedAtOrder,
      messageKey: _messageReinforcedV1,
    );
  }
  return proof;
}

List<Act0FixProofItemV1> _recentSessionWindowProofs(
  List<Act0FixProofItemV1> proofs, {
  required int recentSessionLimit,
}) {
  final ordered = <Act0FixProofItemV1>[...proofs]..sort(_proofOrder);
  final safeLimit = _safeRecentSessionLimit(recentSessionLimit);
  final sessionIds = <String>[];
  for (final proof in ordered) {
    final sessionId = proof.repairSessionId.trim();
    if (sessionId.isNotEmpty && !sessionIds.contains(sessionId)) {
      sessionIds.add(sessionId);
    }
    if (sessionIds.length >= safeLimit) {
      break;
    }
  }
  if (sessionIds.isEmpty) {
    return ordered;
  }
  final sessionSet = sessionIds.toSet();
  return List<Act0FixProofItemV1>.unmodifiable(
    ordered.where((proof) => sessionSet.contains(proof.repairSessionId.trim())),
  );
}

int _proofOrder(Act0FixProofItemV1 a, Act0FixProofItemV1 b) {
  final reinforced = _reinforcedRank(a).compareTo(_reinforcedRank(b));
  if (reinforced != 0) {
    return reinforced;
  }
  final order = b.bankedAtOrder.compareTo(a.bankedAtOrder);
  if (order != 0) {
    return order;
  }
  return a.fixProofId.compareTo(b.fixProofId);
}

int _reinforcedRank(Act0FixProofItemV1 proof) => proof.isReinforced ? 0 : 1;

int _outcomeOrder(Act0RepairOutcomeV1 a, Act0RepairOutcomeV1 b) {
  final sequence = a.sequence.compareTo(b.sequence);
  if (sequence != 0) {
    return sequence;
  }
  return a.queueItemId.compareTo(b.queueItemId);
}

String _queueItemIdFromRepairOutcomeRef(String raw) {
  final value = raw.trim();
  final first = value.indexOf('|');
  if (first < 0) {
    return '';
  }
  final second = value.indexOf('|', first + 1);
  if (second < 0 || second == value.length - 1) {
    return '';
  }
  final prefix = value.substring(0, first);
  final sequence = value.substring(first + 1, second);
  if (prefix != 'repair_outcome_v1' || int.tryParse(sequence) == null) {
    return '';
  }
  return value.substring(second + 1).trim();
}

int _safeRecentSessionLimit(int limit) => limit < 1 ? 7 : limit;

String? _requiredString(Map<String, Object?> map, String key) {
  final value = map[key]?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

const Set<String> _proofStates = <String>{
  act0FixProofStateRepairCompletedV1,
  act0FixProofStateReinforcedByLaterEvidenceV1,
  act0FixProofStateHistoricalCompletedV1,
  act0FixProofStateInsufficientEvidenceV1,
};
