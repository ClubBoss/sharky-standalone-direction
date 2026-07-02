import 'dart:convert';

import 'act0_learning_evidence_contract_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';

const String act0ConceptFamilyOutcomeMissedV1 = 'missed';
const String act0ConceptFamilyOutcomeRepairAttemptedV1 = 'repair_attempted';
const String act0ConceptFamilyOutcomeRepairSucceededV1 = 'repair_succeeded';
const String act0ConceptFamilyOutcomeRepairNotYetSucceededV1 =
    'repair_not_yet_succeeded';

class Act0ConceptFamilyStateHistoryV1 {
  const Act0ConceptFamilyStateHistoryV1({
    this.families = const <Act0ConceptFamilyStateV1>[],
    this.appliedSourceIds = const <String>[],
  });

  factory Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    var state = const Act0ConceptFamilyStateHistoryV1();
    for (final record in history.records) {
      state = state.appendLearningEvidence(record);
    }
    return state;
  }

  final List<Act0ConceptFamilyStateV1> families;
  final List<String> appliedSourceIds;

  Act0ConceptFamilyStateV1? familyById(String conceptFamilyId) {
    final id = conceptFamilyId.trim();
    if (id.isEmpty) {
      return null;
    }
    for (final family in families) {
      if (family.conceptFamilyId == id) {
        return family;
      }
    }
    return null;
  }

  List<String> get knownFamilyIds => List<String>.unmodifiable(
    families.map((family) => family.conceptFamilyId).toList(growable: false)
      ..sort(),
  );

  Act0ConceptFamilyStateV1? get mostRecentActiveFamily {
    final active = families.where((family) => family.missCount > 0).toList();
    if (active.isEmpty) {
      return null;
    }
    active.sort((a, b) {
      final seen = b.lastSeenAt.compareTo(a.lastSeenAt);
      return seen != 0 ? seen : a.conceptFamilyId.compareTo(b.conceptFamilyId);
    });
    return active.first;
  }

  Act0ConceptFamilyStateHistoryV1 appendLearningEvidence(
    Act0LearningEvidenceRecordV1 record,
  ) {
    final sourceId = 'learning:${record.recordId.trim()}';
    if (sourceId.trim() == 'learning:' || appliedSourceIds.contains(sourceId)) {
      return this;
    }
    final conceptFamilyId = act0ConceptFamilyIdForEvidenceRecordV1(record);
    if (conceptFamilyId.isEmpty) {
      return this;
    }
    final isRepairAttempt = record.runKind.trim() == 'repair';
    final isMiss = !record.isCorrect;
    final lastOutcome = isRepairAttempt
        ? record.isCorrect
              ? act0ConceptFamilyOutcomeRepairSucceededV1
              : act0ConceptFamilyOutcomeRepairNotYetSucceededV1
        : isMiss
        ? act0ConceptFamilyOutcomeMissedV1
        : null;
    if (lastOutcome == null) {
      return _withAppliedSourceId(sourceId);
    }
    return _upsert(
      conceptFamilyId: conceptFamilyId,
      worldId: record.worldId,
      sourceId: sourceId,
      lastSeenAt: record.createdOrder,
      lastAttemptAt: isRepairAttempt ? record.createdOrder : null,
      lastProofAt: isRepairAttempt && record.isCorrect
          ? record.createdOrder
          : null,
      missDelta: isMiss ? 1 : 0,
      repairAttemptDelta: isRepairAttempt ? 1 : 0,
      successfulRepairDelta: isRepairAttempt && record.isCorrect ? 1 : 0,
      lastOutcome: lastOutcome,
      lastTaskId: record.taskId,
    );
  }

  Act0ConceptFamilyStateHistoryV1 appendRepairOutcome(
    Act0RepairOutcomeV1 outcome, {
    required int sourceOrder,
  }) {
    final sourceId =
        'repair:${outcome.queueItemId.trim()}:${outcome.sequence}:'
        '${outcome.selectedChoiceId.trim()}';
    if (appliedSourceIds.contains(sourceId)) {
      return this;
    }
    final conceptFamilyId = act0ConceptFamilyIdForRepairOutcomeV1(outcome);
    if (conceptFamilyId.isEmpty) {
      return this;
    }
    final isSuccessful = outcome.isCorrect == true;
    final order = sourceOrder < 0 ? 0 : sourceOrder;
    return _upsert(
      conceptFamilyId: conceptFamilyId,
      worldId: outcome.targetWorldId,
      sourceId: sourceId,
      lastSeenAt: order,
      lastAttemptAt: order,
      lastProofAt: isSuccessful ? order : null,
      missDelta: 0,
      repairAttemptDelta: 1,
      successfulRepairDelta: isSuccessful ? 1 : 0,
      lastOutcome: isSuccessful
          ? act0ConceptFamilyOutcomeRepairSucceededV1
          : outcome.isCorrect == false
          ? act0ConceptFamilyOutcomeRepairNotYetSucceededV1
          : act0ConceptFamilyOutcomeRepairAttemptedV1,
      lastTaskId: outcome.targetTaskId,
    );
  }

  List<Map<String, Object?>> toPayload() =>
      families.map((family) => family.toPayload()).toList(growable: false);

  String toStorageString() => jsonEncode(toPayload());

  static Act0ConceptFamilyStateHistoryV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0ConceptFamilyStateHistoryV1();
    }
    final byFamilyId = <String, Act0ConceptFamilyStateV1>{};
    for (final item in raw) {
      final state = Act0ConceptFamilyStateV1.tryParse(item);
      if (state == null) {
        continue;
      }
      final existing = byFamilyId[state.conceptFamilyId];
      if (existing == null || state.lastSeenAt >= existing.lastSeenAt) {
        byFamilyId[state.conceptFamilyId] = state;
      }
    }
    final families = byFamilyId.values.toList(growable: false)
      ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0ConceptFamilyStateHistoryV1(
      families: List<Act0ConceptFamilyStateV1>.unmodifiable(families),
    );
  }

  static Act0ConceptFamilyStateHistoryV1 tryParseStorageString(String raw) {
    try {
      return tryParse(jsonDecode(raw));
    } on FormatException {
      return const Act0ConceptFamilyStateHistoryV1();
    }
  }

  Act0ConceptFamilyStateHistoryV1 _upsert({
    required String conceptFamilyId,
    required String worldId,
    required String sourceId,
    required int lastSeenAt,
    required int? lastAttemptAt,
    required int? lastProofAt,
    required int missDelta,
    required int repairAttemptDelta,
    required int successfulRepairDelta,
    required String lastOutcome,
    required String lastTaskId,
  }) {
    final current = familyById(conceptFamilyId);
    final nextFamily =
        (current ??
                Act0ConceptFamilyStateV1(
                  conceptFamilyId: conceptFamilyId,
                  worldId: worldId.trim(),
                  lastSeenAt: 0,
                  missCount: 0,
                  repairAttemptCount: 0,
                  successfulRepairCount: 0,
                  lastOutcome: lastOutcome,
                ))
            .copyWith(
              worldId: worldId.trim().isEmpty ? null : worldId.trim(),
              lastSeenAt: lastSeenAt,
              lastAttemptAt: lastAttemptAt,
              lastProofAt: lastProofAt,
              missCount: current == null
                  ? missDelta
                  : current.missCount + missDelta,
              repairAttemptCount: current == null
                  ? repairAttemptDelta
                  : current.repairAttemptCount + repairAttemptDelta,
              successfulRepairCount: current == null
                  ? successfulRepairDelta
                  : current.successfulRepairCount + successfulRepairDelta,
              lastOutcome: lastOutcome,
              lastTaskId: lastTaskId.trim().isEmpty ? null : lastTaskId.trim(),
            );
    final next = <Act0ConceptFamilyStateV1>[
      for (final family in families)
        if (family.conceptFamilyId != conceptFamilyId) family,
      nextFamily,
    ]..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0ConceptFamilyStateHistoryV1(
      families: List<Act0ConceptFamilyStateV1>.unmodifiable(next),
      appliedSourceIds: List<String>.unmodifiable(<String>[
        ...appliedSourceIds,
        sourceId,
      ]),
    );
  }

  Act0ConceptFamilyStateHistoryV1 _withAppliedSourceId(String sourceId) {
    return Act0ConceptFamilyStateHistoryV1(
      families: families,
      appliedSourceIds: List<String>.unmodifiable(<String>[
        ...appliedSourceIds,
        sourceId,
      ]),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0ConceptFamilyStateHistoryV1 &&
      _sameFamilies(other.families, families);

  @override
  int get hashCode => Object.hashAll(families);
}

class Act0ConceptFamilyStateV1 {
  const Act0ConceptFamilyStateV1({
    this.schemaVersion = 1,
    required this.conceptFamilyId,
    required this.worldId,
    required this.lastSeenAt,
    this.lastAttemptAt,
    this.lastProofAt,
    required this.missCount,
    required this.repairAttemptCount,
    required this.successfulRepairCount,
    required this.lastOutcome,
    this.lastTaskId,
  });

  final int schemaVersion;
  final String conceptFamilyId;
  final String worldId;
  final int lastSeenAt;
  final int? lastAttemptAt;
  final int? lastProofAt;
  final int missCount;
  final int repairAttemptCount;
  final int successfulRepairCount;
  final String lastOutcome;
  final String? lastTaskId;

  Act0ConceptFamilyStateV1 copyWith({
    String? worldId,
    int? lastSeenAt,
    int? lastAttemptAt,
    int? lastProofAt,
    int? missCount,
    int? repairAttemptCount,
    int? successfulRepairCount,
    String? lastOutcome,
    String? lastTaskId,
  }) {
    return Act0ConceptFamilyStateV1(
      conceptFamilyId: conceptFamilyId,
      worldId: worldId ?? this.worldId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastProofAt: lastProofAt ?? this.lastProofAt,
      missCount: missCount ?? this.missCount,
      repairAttemptCount: repairAttemptCount ?? this.repairAttemptCount,
      successfulRepairCount:
          successfulRepairCount ?? this.successfulRepairCount,
      lastOutcome: lastOutcome ?? this.lastOutcome,
      lastTaskId: lastTaskId ?? this.lastTaskId,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'conceptFamilyId': conceptFamilyId,
    'worldId': worldId,
    'lastSeenAt': lastSeenAt,
    if (lastAttemptAt != null) 'lastAttemptAt': lastAttemptAt,
    if (lastProofAt != null) 'lastProofAt': lastProofAt,
    'missCount': missCount,
    'repairAttemptCount': repairAttemptCount,
    'successfulRepairCount': successfulRepairCount,
    'lastOutcome': lastOutcome,
    if ((lastTaskId ?? '').isNotEmpty) 'lastTaskId': lastTaskId,
  };

  static Act0ConceptFamilyStateV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final conceptFamilyId = _requiredString(map['conceptFamilyId']);
    final worldId = _requiredString(map['worldId']);
    final lastSeenAt = _nonNegativeInt(map['lastSeenAt']);
    final lastAttemptAt = map.containsKey('lastAttemptAt')
        ? _nonNegativeInt(map['lastAttemptAt'])
        : null;
    final lastProofAt = map.containsKey('lastProofAt')
        ? _nonNegativeInt(map['lastProofAt'])
        : null;
    final missCount = _nonNegativeInt(map['missCount']);
    final repairAttemptCount = _nonNegativeInt(map['repairAttemptCount']);
    final successfulRepairCount = _nonNegativeInt(map['successfulRepairCount']);
    final lastOutcome = _requiredString(map['lastOutcome']);
    final lastTaskId = _optionalString(map['lastTaskId']);
    if (schemaVersion != 1 ||
        conceptFamilyId == null ||
        worldId == null ||
        lastSeenAt == null ||
        missCount == null ||
        repairAttemptCount == null ||
        successfulRepairCount == null ||
        lastOutcome == null ||
        !_outcomes.contains(lastOutcome) ||
        successfulRepairCount > repairAttemptCount) {
      return null;
    }
    return Act0ConceptFamilyStateV1(
      conceptFamilyId: conceptFamilyId,
      worldId: worldId,
      lastSeenAt: lastSeenAt,
      lastAttemptAt: lastAttemptAt,
      lastProofAt: lastProofAt,
      missCount: missCount,
      repairAttemptCount: repairAttemptCount,
      successfulRepairCount: successfulRepairCount,
      lastOutcome: lastOutcome,
      lastTaskId: lastTaskId.isEmpty ? null : lastTaskId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0ConceptFamilyStateV1 &&
      other.schemaVersion == schemaVersion &&
      other.conceptFamilyId == conceptFamilyId &&
      other.worldId == worldId &&
      other.lastSeenAt == lastSeenAt &&
      other.lastAttemptAt == lastAttemptAt &&
      other.lastProofAt == lastProofAt &&
      other.missCount == missCount &&
      other.repairAttemptCount == repairAttemptCount &&
      other.successfulRepairCount == successfulRepairCount &&
      other.lastOutcome == lastOutcome &&
      other.lastTaskId == lastTaskId;

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    conceptFamilyId,
    worldId,
    lastSeenAt,
    lastAttemptAt,
    lastProofAt,
    missCount,
    repairAttemptCount,
    successfulRepairCount,
    lastOutcome,
    lastTaskId,
  );
}

String act0ConceptFamilyIdForEvidenceRecordV1(
  Act0LearningEvidenceRecordV1 record,
) {
  final conceptFamilyId = record.conceptFamilyId.trim();
  if (conceptFamilyId.isNotEmpty) {
    return conceptFamilyId;
  }
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

String act0ConceptFamilyIdForRepairOutcomeV1(Act0RepairOutcomeV1 outcome) {
  final repairFocusKey = outcome.repairFocusKey.trim();
  if (repairFocusKey.isNotEmpty) {
    return repairFocusKey;
  }
  return outcome.repairTaskId.trim();
}

const Set<String> _outcomes = <String>{
  act0ConceptFamilyOutcomeMissedV1,
  act0ConceptFamilyOutcomeRepairAttemptedV1,
  act0ConceptFamilyOutcomeRepairSucceededV1,
  act0ConceptFamilyOutcomeRepairNotYetSucceededV1,
};

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

String _optionalString(Object? raw) => raw?.toString().trim() ?? '';

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

bool _sameFamilies(
  List<Act0ConceptFamilyStateV1> a,
  List<Act0ConceptFamilyStateV1> b,
) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}
