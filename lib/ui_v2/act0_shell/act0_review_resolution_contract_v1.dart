import 'act0_practice_repair_queue_projection_v1.dart';
import 'act0_queue_resolution_contract_v1.dart';
import 'act0_repair_intent_contract_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';
import 'act0_review_mistake_history_v1.dart';

const String act0ReviewResolutionStateUnresolvedV1 = 'unresolved';
const String act0ReviewResolutionStateRepairAttemptedNotResolvedV1 =
    'repair_attempted_not_resolved';
const String act0ReviewResolutionStateResolvedV1 = 'resolved';
const String act0ReviewResolutionStateHistoricalV1 = 'historical';
const String act0ReviewResolutionStateNotActionableV1 = 'not_actionable';
const String act0ReviewResolutionStateInsufficientEvidenceV1 =
    'insufficient_evidence';

const String act0ReviewResolutionReasonNoRepairOutcomeV1 = 'no_repair_outcome';
const String act0ReviewResolutionReasonRepairFailedV1 = 'repair_failed';
const String act0ReviewResolutionReasonRepairSucceededV1 = 'repair_succeeded';
const String act0ReviewResolutionReasonNoMatchingRepairV1 =
    'no_matching_repair';
const String act0ReviewResolutionReasonTargetMissingV1 = 'target_missing';
const String act0ReviewResolutionReasonMalformedEvidenceV1 =
    'malformed_evidence';
const String act0ReviewResolutionReasonHistoricalOnlyV1 = 'historical_only';

class Act0ReviewResolutionStateV1 {
  const Act0ReviewResolutionStateV1({
    this.resolutions = const <Act0ReviewItemResolutionV1>[],
  });

  factory Act0ReviewResolutionStateV1.fromSources({
    Act0ReviewMistakeHistoryV1 reviewMistakeHistory =
        const Act0ReviewMistakeHistoryV1(),
    List<Act0RepairIntentV1> activeRepairIntents = const <Act0RepairIntentV1>[],
    Act0RepairOutcomeProjectionV1 repairOutcomeProjection =
        const Act0RepairOutcomeProjectionV1(),
    Act0ReviewResolutionReceiptHistoryV1 receiptHistory =
        const Act0ReviewResolutionReceiptHistoryV1(),
  }) {
    final intentsByKey = <String, Act0RepairIntentV1>{};
    for (final intent in activeRepairIntents) {
      final key = repairQueueIdentityKeyForAct0RepairIntentV1(intent);
      if (key.isNotEmpty) {
        intentsByKey[key] = intent;
      }
    }
    final byReviewItemId = <String, Act0ReviewItemResolutionV1>{};
    final sortedRecords =
        <Act0ReviewMistakeRecordV1>[...reviewMistakeHistory.records]
          ..sort((a, b) {
            final updated = a.updatedOrder.compareTo(b.updatedOrder);
            return updated != 0 ? updated : a.recordId.compareTo(b.recordId);
          });
    for (final record in sortedRecords) {
      final receipt = receiptHistory.receiptForReviewItemId(record.recordId);
      final resolution =
          receipt?._toResolution(record) ??
          _resolutionForRecord(
            record: record,
            matchingIntent: intentsByKey[_reviewIdentityKey(record)],
            repairOutcomeProjection: repairOutcomeProjection,
          );
      if (resolution != null) {
        byReviewItemId[resolution.reviewItemId] = resolution;
      }
    }
    final resolutions = byReviewItemId.values.toList(growable: false)
      ..sort((a, b) => a.reviewItemId.compareTo(b.reviewItemId));
    return Act0ReviewResolutionStateV1(
      resolutions: List<Act0ReviewItemResolutionV1>.unmodifiable(resolutions),
    );
  }

  final List<Act0ReviewItemResolutionV1> resolutions;

  List<String> get visibleReviewItemIds {
    final ids = <String>[
      for (final resolution in resolutions)
        if (resolution.isVisibleInActiveReview) resolution.reviewItemId,
    ]..sort();
    return List<String>.unmodifiable(ids);
  }

  Act0ReviewItemResolutionV1? resolutionForReviewItemId(String reviewItemId) {
    final id = reviewItemId.trim();
    if (id.isEmpty) {
      return null;
    }
    for (final resolution in resolutions) {
      if (resolution.reviewItemId == id) {
        return resolution;
      }
    }
    return null;
  }

  List<Map<String, Object?>> toPayload() => resolutions
      .map((resolution) => resolution.toPayload())
      .toList(growable: false);
}

class Act0ReviewItemResolutionV1 {
  const Act0ReviewItemResolutionV1({
    this.schemaVersion = 1,
    required this.reviewItemId,
    this.learningEvidenceId,
    this.repairIntentId,
    required this.conceptFamilyId,
    this.sourceTaskId,
    this.sourceSessionId,
    required this.reviewState,
    required this.resolutionReason,
    this.repairOutcomeId,
    this.resolvedAtOrder,
  });

  final int schemaVersion;
  final String reviewItemId;
  final String? learningEvidenceId;
  final String? repairIntentId;
  final String conceptFamilyId;
  final String? sourceTaskId;
  final String? sourceSessionId;
  final String reviewState;
  final String resolutionReason;
  final String? repairOutcomeId;
  final int? resolvedAtOrder;

  bool get isVisibleInActiveReview =>
      reviewState == act0ReviewResolutionStateUnresolvedV1 ||
      reviewState == act0ReviewResolutionStateRepairAttemptedNotResolvedV1;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'reviewItemId': reviewItemId,
    if ((learningEvidenceId ?? '').isNotEmpty)
      'learningEvidenceId': learningEvidenceId,
    if ((repairIntentId ?? '').isNotEmpty) 'repairIntentId': repairIntentId,
    'conceptFamilyId': conceptFamilyId,
    if ((sourceTaskId ?? '').isNotEmpty) 'sourceTaskId': sourceTaskId,
    if ((sourceSessionId ?? '').isNotEmpty) 'sourceSessionId': sourceSessionId,
    'reviewState': reviewState,
    'resolutionReason': resolutionReason,
    if ((repairOutcomeId ?? '').isNotEmpty) 'repairOutcomeId': repairOutcomeId,
    if (resolvedAtOrder != null) 'resolvedAtOrder': resolvedAtOrder,
  };

  static Act0ReviewItemResolutionV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final reviewItemId = _requiredString(map['reviewItemId']);
    final conceptFamilyId = _requiredString(map['conceptFamilyId']);
    final reviewState = _requiredString(map['reviewState']);
    final resolutionReason = _requiredString(map['resolutionReason']);
    final resolvedAtOrder = map.containsKey('resolvedAtOrder')
        ? _nonNegativeInt(map['resolvedAtOrder'])
        : null;
    if (schemaVersion != 1 ||
        reviewItemId == null ||
        conceptFamilyId == null ||
        reviewState == null ||
        resolutionReason == null ||
        !_reviewStates.contains(reviewState) ||
        !_resolutionReasons.contains(resolutionReason)) {
      return null;
    }
    return Act0ReviewItemResolutionV1(
      reviewItemId: reviewItemId,
      learningEvidenceId: _optionalString(map['learningEvidenceId']),
      repairIntentId: _optionalString(map['repairIntentId']),
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: _optionalString(map['sourceTaskId']),
      sourceSessionId: _optionalString(map['sourceSessionId']),
      reviewState: reviewState,
      resolutionReason: resolutionReason,
      repairOutcomeId: _optionalString(map['repairOutcomeId']),
      resolvedAtOrder: resolvedAtOrder,
    );
  }
}

class Act0ReviewResolutionReceiptHistoryV1 {
  const Act0ReviewResolutionReceiptHistoryV1({
    this.receipts = const <Act0ReviewResolutionReceiptV1>[],
  });

  static const int maxReceipts = 200;

  final List<Act0ReviewResolutionReceiptV1> receipts;

  Act0ReviewResolutionReceiptHistoryV1 appendFromResolution(
    Act0ReviewItemResolutionV1 resolution,
  ) {
    if (resolution.reviewState != act0ReviewResolutionStateResolvedV1) {
      return this;
    }
    final receipt = Act0ReviewResolutionReceiptV1.fromResolution(resolution);
    if (receipt == null) {
      return this;
    }
    final next = <Act0ReviewResolutionReceiptV1>[
      for (final current in receipts)
        if (current.reviewItemId != receipt.reviewItemId) current,
      receipt,
    ]..sort(_receiptSort);
    return Act0ReviewResolutionReceiptHistoryV1(
      receipts: List<Act0ReviewResolutionReceiptV1>.unmodifiable(
        next.take(maxReceipts),
      ),
    );
  }

  Act0ReviewResolutionReceiptV1? receiptForReviewItemId(String reviewItemId) {
    final id = reviewItemId.trim();
    if (id.isEmpty) {
      return null;
    }
    for (final receipt in receipts) {
      if (receipt.reviewItemId == id) {
        return receipt;
      }
    }
    return null;
  }

  List<Map<String, Object?>> toPayload() =>
      receipts.map((receipt) => receipt.toPayload()).toList(growable: false);

  static Act0ReviewResolutionReceiptHistoryV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0ReviewResolutionReceiptHistoryV1();
    }
    final byReviewItemId = <String, Act0ReviewResolutionReceiptV1>{};
    for (final item in raw) {
      final receipt = Act0ReviewResolutionReceiptV1.tryParse(item);
      if (receipt == null) {
        continue;
      }
      final existing = byReviewItemId[receipt.reviewItemId];
      if (existing == null || _receiptSort(receipt, existing) < 0) {
        byReviewItemId[receipt.reviewItemId] = receipt;
      }
    }
    final receipts = byReviewItemId.values.toList(growable: false)
      ..sort(_receiptSort);
    return Act0ReviewResolutionReceiptHistoryV1(
      receipts: List<Act0ReviewResolutionReceiptV1>.unmodifiable(
        receipts.take(maxReceipts),
      ),
    );
  }
}

class Act0ReviewResolutionReceiptV1 {
  const Act0ReviewResolutionReceiptV1({
    this.schemaVersion = 1,
    required this.reviewItemId,
    this.learningEvidenceId,
    this.repairIntentId,
    required this.conceptFamilyId,
    this.sourceTaskId,
    this.sourceSessionId,
    required this.reviewState,
    required this.resolutionReason,
    this.repairOutcomeId,
    this.resolvedAtOrder,
  });

  final int schemaVersion;
  final String reviewItemId;
  final String? learningEvidenceId;
  final String? repairIntentId;
  final String conceptFamilyId;
  final String? sourceTaskId;
  final String? sourceSessionId;
  final String reviewState;
  final String resolutionReason;
  final String? repairOutcomeId;
  final int? resolvedAtOrder;

  static Act0ReviewResolutionReceiptV1? fromResolution(
    Act0ReviewItemResolutionV1 resolution,
  ) {
    if (resolution.reviewState != act0ReviewResolutionStateResolvedV1 ||
        resolution.resolutionReason !=
            act0ReviewResolutionReasonRepairSucceededV1 ||
        (resolution.repairOutcomeId ?? '').isEmpty) {
      return null;
    }
    return Act0ReviewResolutionReceiptV1(
      reviewItemId: resolution.reviewItemId,
      learningEvidenceId: resolution.learningEvidenceId,
      repairIntentId: resolution.repairIntentId,
      conceptFamilyId: resolution.conceptFamilyId,
      sourceTaskId: resolution.sourceTaskId,
      sourceSessionId: resolution.sourceSessionId,
      reviewState: resolution.reviewState,
      resolutionReason: resolution.resolutionReason,
      repairOutcomeId: resolution.repairOutcomeId,
      resolvedAtOrder: resolution.resolvedAtOrder,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'reviewItemId': reviewItemId,
    if ((learningEvidenceId ?? '').isNotEmpty)
      'learningEvidenceId': learningEvidenceId,
    if ((repairIntentId ?? '').isNotEmpty) 'repairIntentId': repairIntentId,
    'conceptFamilyId': conceptFamilyId,
    if ((sourceTaskId ?? '').isNotEmpty) 'sourceTaskId': sourceTaskId,
    if ((sourceSessionId ?? '').isNotEmpty) 'sourceSessionId': sourceSessionId,
    'reviewState': reviewState,
    'resolutionReason': resolutionReason,
    if ((repairOutcomeId ?? '').isNotEmpty) 'repairOutcomeId': repairOutcomeId,
    if (resolvedAtOrder != null) 'resolvedAtOrder': resolvedAtOrder,
  };

  static Act0ReviewResolutionReceiptV1? tryParse(Object? raw) {
    final resolution = Act0ReviewItemResolutionV1.tryParse(raw);
    if (resolution == null ||
        resolution.reviewState != act0ReviewResolutionStateResolvedV1 ||
        resolution.resolutionReason !=
            act0ReviewResolutionReasonRepairSucceededV1 ||
        (resolution.repairOutcomeId ?? '').isEmpty) {
      return null;
    }
    return fromResolution(resolution);
  }

  Act0ReviewItemResolutionV1 _toResolution(Act0ReviewMistakeRecordV1 record) {
    return Act0ReviewItemResolutionV1(
      reviewItemId: record.recordId,
      learningEvidenceId: learningEvidenceId ?? record.sourceDecisionId,
      repairIntentId: repairIntentId,
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: sourceTaskId ?? record.sourceTaskId,
      sourceSessionId: sourceSessionId,
      reviewState: reviewState,
      resolutionReason: resolutionReason,
      repairOutcomeId: repairOutcomeId,
      resolvedAtOrder: resolvedAtOrder,
    );
  }
}

Act0ReviewResolutionReceiptHistoryV1
reviewResolutionReceiptHistoryFromSourcesV1({
  required Act0ReviewMistakeHistoryV1 reviewMistakeHistory,
  required List<Act0RepairIntentV1> activeRepairIntents,
  required Act0RepairOutcomeProjectionV1 repairOutcomeProjection,
  required Act0ReviewResolutionReceiptHistoryV1 existingReceiptHistory,
}) {
  var next = existingReceiptHistory;
  final resolutionState = Act0ReviewResolutionStateV1.fromSources(
    reviewMistakeHistory: reviewMistakeHistory,
    activeRepairIntents: activeRepairIntents,
    repairOutcomeProjection: repairOutcomeProjection,
    receiptHistory: existingReceiptHistory,
  );
  for (final resolution in resolutionState.resolutions) {
    next = next.appendFromResolution(resolution);
  }
  return next;
}

Act0ReviewItemResolutionV1? _resolutionForRecord({
  required Act0ReviewMistakeRecordV1 record,
  required Act0RepairIntentV1? matchingIntent,
  required Act0RepairOutcomeProjectionV1 repairOutcomeProjection,
}) {
  final reviewItemId = record.recordId.trim();
  if (reviewItemId.isEmpty) {
    return null;
  }
  final conceptFamilyId = _conceptFamilyIdForRecord(record);
  if (conceptFamilyId.isEmpty || record.dedupUsesFallback) {
    return Act0ReviewItemResolutionV1(
      reviewItemId: reviewItemId,
      learningEvidenceId: record.sourceDecisionId,
      conceptFamilyId: record.sourceTaskId.trim().isEmpty
          ? reviewItemId
          : record.sourceTaskId.trim(),
      sourceTaskId: _optionalString(record.sourceTaskId),
      reviewState: act0ReviewResolutionStateInsufficientEvidenceV1,
      resolutionReason: act0ReviewResolutionReasonMalformedEvidenceV1,
    );
  }
  final intent = matchingIntent;
  if (intent == null) {
    return Act0ReviewItemResolutionV1(
      reviewItemId: reviewItemId,
      learningEvidenceId: record.sourceDecisionId,
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: _optionalString(record.sourceTaskId),
      sourceSessionId: _optionalString(record.runId),
      reviewState: act0ReviewResolutionStateUnresolvedV1,
      resolutionReason: act0ReviewResolutionReasonNoRepairOutcomeV1,
    );
  }
  final queueItemId = queueItemIdForAct0RepairIntentV1(intent);
  if (queueItemId.isEmpty || _hasMissingTarget(intent)) {
    return Act0ReviewItemResolutionV1(
      reviewItemId: reviewItemId,
      learningEvidenceId: record.sourceDecisionId,
      repairIntentId: _repairIntentId(intent),
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: _optionalString(record.sourceTaskId),
      sourceSessionId: _optionalString(record.runId),
      reviewState: act0ReviewResolutionStateNotActionableV1,
      resolutionReason: act0ReviewResolutionReasonTargetMissingV1,
    );
  }
  final matchingOutcomes =
      repairOutcomeProjection.outcomes
          .where(
            (outcome) =>
                outcome.queueItemId.trim() == queueItemId &&
                outcome.sourceType ==
                    act0PracticeRepairQueueSourceActiveRepairV1,
          )
          .toList(growable: false)
        ..sort((a, b) {
          final sequence = a.sequence.compareTo(b.sequence);
          return sequence != 0
              ? sequence
              : a.outcomeState.compareTo(b.outcomeState);
        });
  if (matchingOutcomes.isEmpty) {
    return Act0ReviewItemResolutionV1(
      reviewItemId: reviewItemId,
      learningEvidenceId: record.sourceDecisionId,
      repairIntentId: _repairIntentId(intent),
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: _optionalString(record.sourceTaskId),
      sourceSessionId: _optionalString(record.runId),
      reviewState: act0ReviewResolutionStateUnresolvedV1,
      resolutionReason: act0ReviewResolutionReasonNoRepairOutcomeV1,
    );
  }
  for (final outcome in matchingOutcomes) {
    if (outcome.isCorrect == true) {
      return Act0ReviewItemResolutionV1(
        reviewItemId: reviewItemId,
        learningEvidenceId: record.sourceDecisionId,
        repairIntentId: _repairIntentId(intent),
        conceptFamilyId: conceptFamilyId,
        sourceTaskId: _optionalString(record.sourceTaskId),
        sourceSessionId: _optionalString(outcome.sessionId),
        reviewState: act0ReviewResolutionStateResolvedV1,
        resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
        repairOutcomeId: _outcomeId(outcome),
        resolvedAtOrder: outcome.sequence,
      );
    }
  }
  final latest = matchingOutcomes.last;
  return Act0ReviewItemResolutionV1(
    reviewItemId: reviewItemId,
    learningEvidenceId: record.sourceDecisionId,
    repairIntentId: _repairIntentId(intent),
    conceptFamilyId: conceptFamilyId,
    sourceTaskId: _optionalString(record.sourceTaskId),
    sourceSessionId: _optionalString(latest.sessionId),
    reviewState: act0ReviewResolutionStateRepairAttemptedNotResolvedV1,
    resolutionReason: act0ReviewResolutionReasonRepairFailedV1,
    repairOutcomeId: _outcomeId(latest),
    resolvedAtOrder: latest.sequence,
  );
}

String _reviewIdentityKey(Act0ReviewMistakeRecordV1 record) {
  final parts = <String>[
    record.sourceTaskId.trim(),
    record.repairFocusId.trim(),
    record.skillAtomId.trim(),
    record.errorType.trim(),
  ];
  if (parts.every((part) => part.isEmpty)) {
    return '';
  }
  return parts.map(_keyPart).join('|');
}

String _conceptFamilyIdForRecord(Act0ReviewMistakeRecordV1 record) {
  final repairFocusId = record.repairFocusId.trim();
  if (repairFocusId.isNotEmpty) {
    return repairFocusId;
  }
  final skillAtomId = record.skillAtomId.trim();
  if (skillAtomId.isNotEmpty) {
    return skillAtomId;
  }
  return record.errorType.trim();
}

bool _hasMissingTarget(Act0RepairIntentV1 intent) =>
    intent.targetWorldId.trim().isEmpty ||
    intent.targetLessonId.trim().isEmpty ||
    intent.targetTaskId.trim().isEmpty;

String _repairIntentId(Act0RepairIntentV1 intent) {
  final reasonCode = intent.reasonCode.trim();
  if (reasonCode.isNotEmpty) {
    return reasonCode;
  }
  return repairQueueIdentityKeyForAct0RepairIntentV1(intent);
}

String _outcomeId(Act0RepairOutcomeV1 outcome) =>
    'repair_outcome_v1|${outcome.sequence}|${outcome.queueItemId}';

int _receiptSort(
  Act0ReviewResolutionReceiptV1 a,
  Act0ReviewResolutionReceiptV1 b,
) {
  final order = (a.resolvedAtOrder ?? 1 << 30).compareTo(
    b.resolvedAtOrder ?? 1 << 30,
  );
  if (order != 0) {
    return order;
  }
  return a.reviewItemId.compareTo(b.reviewItemId);
}

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

String? _optionalString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

String _keyPart(String value) => '${value.length}:$value';

const Set<String> _reviewStates = <String>{
  act0ReviewResolutionStateUnresolvedV1,
  act0ReviewResolutionStateRepairAttemptedNotResolvedV1,
  act0ReviewResolutionStateResolvedV1,
  act0ReviewResolutionStateHistoricalV1,
  act0ReviewResolutionStateNotActionableV1,
  act0ReviewResolutionStateInsufficientEvidenceV1,
};

const Set<String> _resolutionReasons = <String>{
  act0ReviewResolutionReasonNoRepairOutcomeV1,
  act0ReviewResolutionReasonRepairFailedV1,
  act0ReviewResolutionReasonRepairSucceededV1,
  act0ReviewResolutionReasonNoMatchingRepairV1,
  act0ReviewResolutionReasonTargetMissingV1,
  act0ReviewResolutionReasonMalformedEvidenceV1,
  act0ReviewResolutionReasonHistoricalOnlyV1,
};
