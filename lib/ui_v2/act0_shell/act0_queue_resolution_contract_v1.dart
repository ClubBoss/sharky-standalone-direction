import 'act0_repair_intent_contract_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';

const String act0QueueResolutionStateUnresolvedV1 = 'unresolved';
const String act0QueueResolutionStateAttemptedNotResolvedV1 =
    'attempted_not_resolved';
const String act0QueueResolutionStateResolvedV1 = 'resolved';
const String act0QueueResolutionStateNotActionableV1 = 'not_actionable';
const String act0QueueResolutionStateInsufficientEvidenceV1 =
    'insufficient_evidence';

const String act0QueueResolutionReasonRepairSucceededV1 = 'repair_succeeded';
const String act0QueueResolutionReasonRepairFailedV1 = 'repair_failed';
const String act0QueueResolutionReasonTargetMissingV1 = 'target_missing';
const String act0QueueResolutionReasonRouteUnavailableV1 = 'route_unavailable';
const String act0QueueResolutionReasonMalformedIntentV1 = 'malformed_intent';
const String act0QueueResolutionReasonSupersededV1 = 'superseded';
const String act0QueueResolutionReasonNoOutcomeYetV1 = 'no_outcome_yet';

class Act0QueueResolutionStateV1 {
  const Act0QueueResolutionStateV1({
    this.resolutions = const <Act0QueueItemResolutionV1>[],
  });

  factory Act0QueueResolutionStateV1.fromSources({
    List<Act0RepairIntentV1> activeRepairIntents = const <Act0RepairIntentV1>[],
    Act0RepairOutcomeProjectionV1 repairOutcomeProjection =
        const Act0RepairOutcomeProjectionV1(),
  }) {
    final byQueueItemId = <String, Act0QueueItemResolutionV1>{};
    final sortedIntents = <Act0RepairIntentV1>[...activeRepairIntents]
      ..sort((a, b) => _intentSortKey(a).compareTo(_intentSortKey(b)));
    for (final intent in sortedIntents) {
      final resolution = _resolutionForIntent(intent, repairOutcomeProjection);
      if (resolution == null) {
        continue;
      }
      byQueueItemId[resolution.queueItemId] = resolution;
    }
    final resolutions = byQueueItemId.values.toList(growable: false)
      ..sort((a, b) => a.queueItemId.compareTo(b.queueItemId));
    return Act0QueueResolutionStateV1(
      resolutions: List<Act0QueueItemResolutionV1>.unmodifiable(resolutions),
    );
  }

  final List<Act0QueueItemResolutionV1> resolutions;

  List<String> get actionableQueueItemIds {
    final ids = <String>[
      for (final resolution in resolutions)
        if (resolution.isActionable) resolution.queueItemId,
    ]..sort();
    return List<String>.unmodifiable(ids);
  }

  Act0QueueItemResolutionV1? resolutionForQueueItemId(String queueItemId) {
    final id = queueItemId.trim();
    if (id.isEmpty) {
      return null;
    }
    for (final resolution in resolutions) {
      if (resolution.queueItemId == id) {
        return resolution;
      }
    }
    return null;
  }

  List<Map<String, Object?>> toPayload() => resolutions
      .map((resolution) => resolution.toPayload())
      .toList(growable: false);

  static Act0QueueResolutionStateV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0QueueResolutionStateV1();
    }
    final byQueueItemId = <String, Act0QueueItemResolutionV1>{};
    for (final item in raw) {
      final resolution = Act0QueueItemResolutionV1.tryParse(item);
      if (resolution == null) {
        continue;
      }
      final existing = byQueueItemId[resolution.queueItemId];
      if (existing == null || _resolutionOrder(resolution, existing) < 0) {
        byQueueItemId[resolution.queueItemId] = resolution;
      }
    }
    final resolutions = byQueueItemId.values.toList(growable: false)
      ..sort((a, b) => a.queueItemId.compareTo(b.queueItemId));
    return Act0QueueResolutionStateV1(
      resolutions: List<Act0QueueItemResolutionV1>.unmodifiable(resolutions),
    );
  }
}

class Act0QueueItemResolutionV1 {
  const Act0QueueItemResolutionV1({
    this.schemaVersion = 1,
    required this.queueItemId,
    required this.repairIntentId,
    required this.conceptFamilyId,
    this.sourceTaskId,
    this.sourceSessionId,
    required this.resolutionState,
    required this.resolutionReason,
    this.outcomeId,
    this.resolvedAtOrder,
  });

  final int schemaVersion;
  final String queueItemId;
  final String repairIntentId;
  final String conceptFamilyId;
  final String? sourceTaskId;
  final String? sourceSessionId;
  final String resolutionState;
  final String resolutionReason;
  final String? outcomeId;
  final int? resolvedAtOrder;

  bool get isActionable =>
      resolutionState == act0QueueResolutionStateUnresolvedV1 ||
      resolutionState == act0QueueResolutionStateAttemptedNotResolvedV1;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'queueItemId': queueItemId,
    'repairIntentId': repairIntentId,
    'conceptFamilyId': conceptFamilyId,
    if ((sourceTaskId ?? '').isNotEmpty) 'sourceTaskId': sourceTaskId,
    if ((sourceSessionId ?? '').isNotEmpty) 'sourceSessionId': sourceSessionId,
    'resolutionState': resolutionState,
    'resolutionReason': resolutionReason,
    if ((outcomeId ?? '').isNotEmpty) 'outcomeId': outcomeId,
    if (resolvedAtOrder != null) 'resolvedAtOrder': resolvedAtOrder,
  };

  static Act0QueueItemResolutionV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final queueItemId = _requiredString(map['queueItemId']);
    final repairIntentId = _requiredString(map['repairIntentId']);
    final conceptFamilyId = _requiredString(map['conceptFamilyId']);
    final resolutionState = _requiredString(map['resolutionState']);
    final resolutionReason = _requiredString(map['resolutionReason']);
    final resolvedAtOrder = map.containsKey('resolvedAtOrder')
        ? _nonNegativeInt(map['resolvedAtOrder'])
        : null;
    if (schemaVersion != 1 ||
        queueItemId == null ||
        repairIntentId == null ||
        conceptFamilyId == null ||
        resolutionState == null ||
        resolutionReason == null ||
        !_resolutionStates.contains(resolutionState) ||
        !_resolutionReasons.contains(resolutionReason)) {
      return null;
    }
    return Act0QueueItemResolutionV1(
      queueItemId: queueItemId,
      repairIntentId: repairIntentId,
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: _optionalString(map['sourceTaskId']),
      sourceSessionId: _optionalString(map['sourceSessionId']),
      resolutionState: resolutionState,
      resolutionReason: resolutionReason,
      outcomeId: _optionalString(map['outcomeId']),
      resolvedAtOrder: resolvedAtOrder,
    );
  }
}

Act0QueueItemResolutionV1? _resolutionForIntent(
  Act0RepairIntentV1 intent,
  Act0RepairOutcomeProjectionV1 repairOutcomeProjection,
) {
  final sourceTaskId = intent.sourceTaskId.trim();
  final queueItemId = queueItemIdForAct0RepairIntentV1(intent);
  if (sourceTaskId.isEmpty || queueItemId.isEmpty) {
    return null;
  }
  final conceptFamilyId = _conceptFamilyIdForIntent(intent);
  if (conceptFamilyId.isEmpty) {
    return Act0QueueItemResolutionV1(
      queueItemId: queueItemId,
      repairIntentId: _repairIntentId(intent),
      conceptFamilyId: sourceTaskId,
      sourceTaskId: sourceTaskId,
      resolutionState: act0QueueResolutionStateInsufficientEvidenceV1,
      resolutionReason: act0QueueResolutionReasonMalformedIntentV1,
    );
  }
  if (_hasMissingTarget(intent)) {
    return Act0QueueItemResolutionV1(
      queueItemId: queueItemId,
      repairIntentId: _repairIntentId(intent),
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: sourceTaskId,
      resolutionState: act0QueueResolutionStateNotActionableV1,
      resolutionReason: act0QueueResolutionReasonTargetMissingV1,
    );
  }
  final matchingOutcomes =
      repairOutcomeProjection.outcomes
          .where((outcome) => outcome.queueItemId.trim() == queueItemId)
          .toList(growable: false)
        ..sort((a, b) {
          final sequence = a.sequence.compareTo(b.sequence);
          return sequence != 0
              ? sequence
              : a.outcomeState.compareTo(b.outcomeState);
        });
  if (matchingOutcomes.isEmpty) {
    return Act0QueueItemResolutionV1(
      queueItemId: queueItemId,
      repairIntentId: _repairIntentId(intent),
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: sourceTaskId,
      resolutionState: act0QueueResolutionStateUnresolvedV1,
      resolutionReason: act0QueueResolutionReasonNoOutcomeYetV1,
    );
  }
  for (final outcome in matchingOutcomes) {
    if (outcome.isCorrect == true) {
      return Act0QueueItemResolutionV1(
        queueItemId: queueItemId,
        repairIntentId: _repairIntentId(intent),
        conceptFamilyId: conceptFamilyId,
        sourceTaskId: sourceTaskId,
        sourceSessionId: outcome.sessionId.isEmpty ? null : outcome.sessionId,
        resolutionState: act0QueueResolutionStateResolvedV1,
        resolutionReason: act0QueueResolutionReasonRepairSucceededV1,
        outcomeId: _outcomeId(outcome),
        resolvedAtOrder: outcome.sequence,
      );
    }
  }
  final latest = matchingOutcomes.last;
  return Act0QueueItemResolutionV1(
    queueItemId: queueItemId,
    repairIntentId: _repairIntentId(intent),
    conceptFamilyId: conceptFamilyId,
    sourceTaskId: sourceTaskId,
    sourceSessionId: latest.sessionId.isEmpty ? null : latest.sessionId,
    resolutionState: act0QueueResolutionStateAttemptedNotResolvedV1,
    resolutionReason: act0QueueResolutionReasonRepairFailedV1,
    outcomeId: _outcomeId(latest),
    resolvedAtOrder: latest.sequence,
  );
}

String queueItemIdForAct0RepairIntentV1(Act0RepairIntentV1 intent) {
  final key = repairQueueIdentityKeyForAct0RepairIntentV1(intent);
  if (key.isEmpty) {
    return '';
  }
  return 'practice_repair_queue_v1|active|${_keyPart(key)}';
}

String repairQueueIdentityKeyForAct0RepairIntentV1(Act0RepairIntentV1 intent) {
  final parts = <String>[
    intent.sourceTaskId.trim(),
    intent.missedSignalId.trim(),
    intent.skillAtomId.trim(),
    intent.errorType.trim(),
  ];
  if (parts.every((part) => part.isEmpty)) {
    return '';
  }
  return parts.map(_keyPart).join('|');
}

String _conceptFamilyIdForIntent(Act0RepairIntentV1 intent) {
  final missedSignalId = intent.missedSignalId.trim();
  if (missedSignalId.isNotEmpty) {
    return missedSignalId;
  }
  final skillAtomId = intent.skillAtomId.trim();
  if (skillAtomId.isNotEmpty) {
    return skillAtomId;
  }
  return intent.errorType.trim();
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

String _intentSortKey(Act0RepairIntentV1 intent) =>
    repairQueueIdentityKeyForAct0RepairIntentV1(intent);

int _resolutionOrder(Act0QueueItemResolutionV1 a, Act0QueueItemResolutionV1 b) {
  final state = _stateRank(
    a.resolutionState,
  ).compareTo(_stateRank(b.resolutionState));
  if (state != 0) {
    return state;
  }
  final order = (a.resolvedAtOrder ?? 1 << 30).compareTo(
    b.resolvedAtOrder ?? 1 << 30,
  );
  if (order != 0) {
    return order;
  }
  return a.queueItemId.compareTo(b.queueItemId);
}

int _stateRank(String state) => switch (state) {
  act0QueueResolutionStateResolvedV1 => 0,
  act0QueueResolutionStateAttemptedNotResolvedV1 => 1,
  act0QueueResolutionStateUnresolvedV1 => 2,
  act0QueueResolutionStateNotActionableV1 => 3,
  _ => 4,
};

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

const Set<String> _resolutionStates = <String>{
  act0QueueResolutionStateUnresolvedV1,
  act0QueueResolutionStateAttemptedNotResolvedV1,
  act0QueueResolutionStateResolvedV1,
  act0QueueResolutionStateNotActionableV1,
  act0QueueResolutionStateInsufficientEvidenceV1,
};

const Set<String> _resolutionReasons = <String>{
  act0QueueResolutionReasonRepairSucceededV1,
  act0QueueResolutionReasonRepairFailedV1,
  act0QueueResolutionReasonTargetMissingV1,
  act0QueueResolutionReasonRouteUnavailableV1,
  act0QueueResolutionReasonMalformedIntentV1,
  act0QueueResolutionReasonSupersededV1,
  act0QueueResolutionReasonNoOutcomeYetV1,
};
