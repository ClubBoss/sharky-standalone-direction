import 'act0_queue_resolution_contract_v1.dart';
import 'act0_repair_intent_contract_v1.dart';

const String act0MultiRepairQueueStateUnresolvedV1 = 'unresolved';
const String act0MultiRepairQueueStateAttemptedNotResolvedV1 =
    'attempted_not_resolved';

class Act0MultiRepairQueueV1 {
  const Act0MultiRepairQueueV1({
    this.schemaVersion = 1,
    this.entries = const <Act0MultiRepairQueueEntryV1>[],
  });

  static const int maxActiveItems = 3;

  final int schemaVersion;
  final List<Act0MultiRepairQueueEntryV1> entries;

  bool get hasItems => entries.isNotEmpty;

  Act0MultiRepairQueueV1 upsertIntent(
    Act0RepairIntentV1 intent, {
    required int order,
  }) {
    final queueItemId = queueItemIdForAct0RepairIntentV1(intent);
    final identity = repairQueueIdentityKeyForAct0RepairIntentV1(intent);
    if (queueItemId.isEmpty || identity.isEmpty || _hasMissingTarget(intent)) {
      return this;
    }

    final normalizedOrder = order < 0 ? 0 : order;
    final next = <Act0MultiRepairQueueEntryV1>[];
    var updated = false;
    for (final entry in entries) {
      if (entry.queueItemId == queueItemId ||
          entry.sourceRepairIdentity == identity) {
        next.add(
          entry.copyWith(
            repairIntent: intent,
            queueItemId: queueItemId,
            sourceRepairIdentity: identity,
            conceptFamilyId: _conceptFamilyIdForIntent(intent),
            sourceTaskId: intent.sourceTaskId.trim(),
            lastUpdatedAtOrder: normalizedOrder,
            attemptCount: entry.attemptCount + 1,
            resolutionState: act0MultiRepairQueueStateUnresolvedV1,
          ),
        );
        updated = true;
      } else {
        next.add(entry);
      }
    }

    if (!updated) {
      if (next.length >= maxActiveItems) {
        return Act0MultiRepairQueueV1(
          entries: List<Act0MultiRepairQueueEntryV1>.unmodifiable(
            _orderedEntries(next),
          ),
        );
      }
      next.add(
        Act0MultiRepairQueueEntryV1(
          queueItemId: queueItemId,
          sourceRepairIdentity: identity,
          conceptFamilyId: _conceptFamilyIdForIntent(intent),
          sourceTaskId: intent.sourceTaskId.trim(),
          createdAtOrder: normalizedOrder,
          lastUpdatedAtOrder: normalizedOrder,
          attemptCount: 1,
          resolutionState: act0MultiRepairQueueStateUnresolvedV1,
          repairIntent: intent,
        ),
      );
    }

    return Act0MultiRepairQueueV1(
      entries: List<Act0MultiRepairQueueEntryV1>.unmodifiable(
        _orderedEntries(next).take(maxActiveItems),
      ),
    );
  }

  Act0MultiRepairQueueV1 prunedWithResolution(
    Act0QueueResolutionStateV1 resolutionState,
  ) {
    final next = <Act0MultiRepairQueueEntryV1>[];
    for (final entry in entries) {
      final resolution = resolutionState.resolutionForQueueItemId(
        entry.queueItemId,
      );
      if (resolution != null && !resolution.isActionable) {
        continue;
      }
      next.add(
        entry.copyWith(
          sourceSessionId: resolution?.sourceSessionId,
          resolutionState:
              resolution?.resolutionState ==
                  act0QueueResolutionStateAttemptedNotResolvedV1
              ? act0MultiRepairQueueStateAttemptedNotResolvedV1
              : act0MultiRepairQueueStateUnresolvedV1,
        ),
      );
    }
    return Act0MultiRepairQueueV1(
      entries: List<Act0MultiRepairQueueEntryV1>.unmodifiable(
        _orderedEntries(next, resolutionState: resolutionState),
      ),
    );
  }

  List<Act0RepairIntentV1> activeRepairIntents({
    Act0QueueResolutionStateV1? resolutionState,
  }) {
    final ordered = _orderedEntries(entries, resolutionState: resolutionState);
    return List<Act0RepairIntentV1>.unmodifiable(
      ordered
          .where((entry) {
            final resolution = resolutionState?.resolutionForQueueItemId(
              entry.queueItemId,
            );
            return resolution == null || resolution.isActionable;
          })
          .take(maxActiveItems)
          .map((entry) => entry.repairIntent),
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'maxActiveItems': maxActiveItems,
    'entries': <Map<String, Object?>>[
      for (final entry in _orderedEntries(entries)) entry.toPayload(),
    ],
  };

  static Act0MultiRepairQueueV1 fromLegacyOpenRepairIntents(
    List<Act0RepairIntentV1> intents,
  ) {
    var queue = const Act0MultiRepairQueueV1();
    var order = 0;
    for (final intent in intents) {
      order += 1;
      queue = queue.upsertIntent(intent, order: order);
    }
    return queue;
  }

  static Act0MultiRepairQueueV1 tryParse(
    Object? raw, {
    List<Act0RepairIntentV1> legacyOpenRepairIntents =
        const <Act0RepairIntentV1>[],
  }) {
    if (raw is! Map) {
      return fromLegacyOpenRepairIntents(legacyOpenRepairIntents);
    }
    final map = raw.cast<Object?, Object?>();
    if (_nonNegativeInt(map['schemaVersion']) != 1) {
      return fromLegacyOpenRepairIntents(legacyOpenRepairIntents);
    }
    final rawEntries = map['entries'];
    if (rawEntries is! List) {
      return const Act0MultiRepairQueueV1();
    }
    final byIdentity = <String, Act0MultiRepairQueueEntryV1>{};
    for (final item in rawEntries) {
      final parsed = Act0MultiRepairQueueEntryV1.tryParse(item);
      if (parsed == null) {
        continue;
      }
      final existing = byIdentity[parsed.sourceRepairIdentity];
      if (existing == null || _storedEntryWins(parsed, existing) < 0) {
        byIdentity[parsed.sourceRepairIdentity] = parsed;
      }
    }
    return Act0MultiRepairQueueV1(
      entries: List<Act0MultiRepairQueueEntryV1>.unmodifiable(
        _orderedEntries(byIdentity.values).take(maxActiveItems),
      ),
    );
  }
}

class Act0MultiRepairQueueEntryV1 {
  const Act0MultiRepairQueueEntryV1({
    this.schemaVersion = 1,
    required this.queueItemId,
    required this.sourceRepairIdentity,
    required this.conceptFamilyId,
    required this.sourceTaskId,
    this.sourceSessionId,
    required this.createdAtOrder,
    required this.lastUpdatedAtOrder,
    required this.attemptCount,
    required this.resolutionState,
    required this.repairIntent,
  });

  final int schemaVersion;
  final String queueItemId;
  final String sourceRepairIdentity;
  final String conceptFamilyId;
  final String sourceTaskId;
  final String? sourceSessionId;
  final int createdAtOrder;
  final int lastUpdatedAtOrder;
  final int attemptCount;
  final String resolutionState;
  final Act0RepairIntentV1 repairIntent;

  Act0MultiRepairQueueEntryV1 copyWith({
    String? queueItemId,
    String? sourceRepairIdentity,
    String? conceptFamilyId,
    String? sourceTaskId,
    String? sourceSessionId,
    int? lastUpdatedAtOrder,
    int? attemptCount,
    String? resolutionState,
    Act0RepairIntentV1? repairIntent,
  }) {
    return Act0MultiRepairQueueEntryV1(
      schemaVersion: schemaVersion,
      queueItemId: queueItemId ?? this.queueItemId,
      sourceRepairIdentity: sourceRepairIdentity ?? this.sourceRepairIdentity,
      conceptFamilyId: conceptFamilyId ?? this.conceptFamilyId,
      sourceTaskId: sourceTaskId ?? this.sourceTaskId,
      sourceSessionId: sourceSessionId ?? this.sourceSessionId,
      createdAtOrder: createdAtOrder,
      lastUpdatedAtOrder: lastUpdatedAtOrder ?? this.lastUpdatedAtOrder,
      attemptCount: attemptCount ?? this.attemptCount,
      resolutionState: resolutionState ?? this.resolutionState,
      repairIntent: repairIntent ?? this.repairIntent,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'queueItemId': queueItemId,
    'sourceRepairIdentity': sourceRepairIdentity,
    'conceptFamilyId': conceptFamilyId,
    'sourceTaskId': sourceTaskId,
    if ((sourceSessionId ?? '').isNotEmpty) 'sourceSessionId': sourceSessionId,
    'createdAtOrder': createdAtOrder,
    'lastUpdatedAtOrder': lastUpdatedAtOrder,
    'attemptCount': attemptCount,
    'resolutionState': resolutionState,
    'repairIntent': repairIntent.toPayload(),
  };

  static Act0MultiRepairQueueEntryV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final queueItemId = _requiredString(map['queueItemId']);
    final sourceRepairIdentity = _requiredString(map['sourceRepairIdentity']);
    final conceptFamilyId = _requiredString(map['conceptFamilyId']);
    final sourceTaskId = _requiredString(map['sourceTaskId']);
    final createdAtOrder = _nonNegativeInt(map['createdAtOrder']);
    final lastUpdatedAtOrder = _nonNegativeInt(map['lastUpdatedAtOrder']);
    final attemptCount = _positiveInt(map['attemptCount']);
    final resolutionState = _requiredString(map['resolutionState']);
    final repairIntent = Act0RepairIntentV1.tryParse(map['repairIntent']);
    if (schemaVersion != 1 ||
        queueItemId == null ||
        sourceRepairIdentity == null ||
        conceptFamilyId == null ||
        sourceTaskId == null ||
        createdAtOrder == null ||
        lastUpdatedAtOrder == null ||
        attemptCount == null ||
        resolutionState == null ||
        repairIntent == null ||
        !_storedResolutionStates.contains(resolutionState)) {
      return null;
    }
    final computedIdentity = repairQueueIdentityKeyForAct0RepairIntentV1(
      repairIntent,
    );
    final computedQueueItemId = queueItemIdForAct0RepairIntentV1(repairIntent);
    if (computedIdentity != sourceRepairIdentity ||
        computedQueueItemId != queueItemId ||
        repairIntent.sourceTaskId.trim() != sourceTaskId) {
      return null;
    }
    return Act0MultiRepairQueueEntryV1(
      queueItemId: queueItemId,
      sourceRepairIdentity: sourceRepairIdentity,
      conceptFamilyId: conceptFamilyId,
      sourceTaskId: sourceTaskId,
      sourceSessionId: _optionalString(map['sourceSessionId']),
      createdAtOrder: createdAtOrder,
      lastUpdatedAtOrder: lastUpdatedAtOrder,
      attemptCount: attemptCount,
      resolutionState: resolutionState,
      repairIntent: repairIntent,
    );
  }
}

List<Act0MultiRepairQueueEntryV1> _orderedEntries(
  Iterable<Act0MultiRepairQueueEntryV1> entries, {
  Act0QueueResolutionStateV1? resolutionState,
}) {
  final ordered = entries.toList(growable: false)
    ..sort((a, b) {
      final stateCompare = _entryStateRank(
        a,
        resolutionState,
      ).compareTo(_entryStateRank(b, resolutionState));
      if (stateCompare != 0) {
        return stateCompare;
      }
      final createdCompare = a.createdAtOrder.compareTo(b.createdAtOrder);
      if (createdCompare != 0) {
        return createdCompare;
      }
      final updatedCompare = b.lastUpdatedAtOrder.compareTo(
        a.lastUpdatedAtOrder,
      );
      if (updatedCompare != 0) {
        return updatedCompare;
      }
      return a.queueItemId.compareTo(b.queueItemId);
    });
  return ordered;
}

int _entryStateRank(
  Act0MultiRepairQueueEntryV1 entry,
  Act0QueueResolutionStateV1? resolutionState,
) {
  final state =
      resolutionState
          ?.resolutionForQueueItemId(entry.queueItemId)
          ?.resolutionState ??
      entry.resolutionState;
  if (state == act0QueueResolutionStateAttemptedNotResolvedV1 ||
      state == act0MultiRepairQueueStateAttemptedNotResolvedV1) {
    return 0;
  }
  return 1;
}

int _storedEntryWins(
  Act0MultiRepairQueueEntryV1 a,
  Act0MultiRepairQueueEntryV1 b,
) {
  final created = a.createdAtOrder.compareTo(b.createdAtOrder);
  if (created != 0) {
    return created;
  }
  final updated = b.lastUpdatedAtOrder.compareTo(a.lastUpdatedAtOrder);
  if (updated != 0) {
    return updated;
  }
  return a.queueItemId.compareTo(b.queueItemId);
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

int? _positiveInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 1 ? null : value;
}

const Set<String> _storedResolutionStates = <String>{
  act0MultiRepairQueueStateUnresolvedV1,
  act0MultiRepairQueueStateAttemptedNotResolvedV1,
};
