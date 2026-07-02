import 'act0_concept_family_state_foundation_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_queue_resolution_contract_v1.dart';
import 'act0_repair_intent_contract_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';
import 'act0_review_mistake_history_v1.dart';
import 'act0_review_resolution_contract_v1.dart';

const String act0ReviewPatternTypeRepeatedMissAcrossSessionsV1 =
    'repeated_miss_across_sessions';
const String act0ReviewPatternTypeRepeatedUnsuccessfulRepairV1 =
    'repeated_unsuccessful_repair';
const String act0ReviewPatternTypeMissThenLaterImprovementV1 =
    'miss_then_later_improvement';
const String act0ReviewPatternTypeInsufficientEvidenceV1 =
    'insufficient_evidence';

const String act0ReviewPatternStateActiveV1 = 'active';
const String act0ReviewPatternStateImprovingV1 = 'improving';
const String act0ReviewPatternStateHistoricalV1 = 'historical';
const String act0ReviewPatternStateInsufficientEvidenceV1 =
    'insufficient_evidence';

const String act0ReviewPatternStrengthTwoSessionSignalV1 = 'two_session_signal';
const String act0ReviewPatternStrengthRepeatedMultiSessionSignalV1 =
    'repeated_multi_session_signal';
const String act0ReviewPatternStrengthImprovementObservedV1 =
    'improvement_observed';
const String act0ReviewPatternStrengthInsufficientEvidenceV1 =
    'insufficient_evidence';

const String _messageRepeatedMissV1 =
    'review_pattern_repeated_miss_across_sessions_v1';
const String _messageRepeatedUnsuccessfulRepairV1 =
    'review_pattern_repeated_unsuccessful_repair_v1';
const String _messageMissThenLaterImprovementV1 =
    'review_pattern_miss_then_later_improvement_v1';

class Act0ReviewPatternCoachingProjectionV1 {
  const Act0ReviewPatternCoachingProjectionV1({
    this.schemaVersion = 1,
    this.patterns = const <Act0ReviewPatternCoachingPatternV1>[],
  });

  final int schemaVersion;
  final List<Act0ReviewPatternCoachingPatternV1> patterns;

  bool get hasPrimaryPattern => primaryPattern != null;

  Act0ReviewPatternCoachingPatternV1? get primaryPattern =>
      patterns.isEmpty ? null : patterns.first;

  String? get copyLine => primaryPattern?.copyLine;

  static Act0ReviewPatternCoachingProjectionV1 fromSources({
    required Act0LearningEvidenceHistoryV1 learningEvidenceHistory,
    Act0ReviewMistakeHistoryV1? reviewMistakeHistory,
    Act0ReviewResolutionStateV1? reviewResolutionState,
    List<Act0RepairIntentV1> activeRepairIntents = const <Act0RepairIntentV1>[],
    Act0RepairOutcomeProjectionV1 repairOutcomeProjection =
        const Act0RepairOutcomeProjectionV1(),
    Act0LearningTransferMeasurementV1? transferMeasurement,
  }) {
    final patterns = <Act0ReviewPatternCoachingPatternV1>[
      ..._patternsFromRepairOutcomes(
        activeRepairIntents,
        repairOutcomeProjection,
      ),
      ..._patternsFromLearningEvidence(
        learningEvidenceHistory,
        reviewMistakeHistory: reviewMistakeHistory,
        reviewResolutionState: reviewResolutionState,
      ),
      ..._patternsFromTransferSignals(
        transferMeasurement ??
            Act0LearningTransferMeasurementV1.fromLearningEvidence(
              learningEvidenceHistory,
            ),
      ),
    ];
    patterns.sort(_comparePatternPriority);
    return Act0ReviewPatternCoachingProjectionV1(
      patterns: List<Act0ReviewPatternCoachingPatternV1>.unmodifiable(patterns),
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'patterns': patterns
        .map((pattern) => pattern.toPayload())
        .toList(growable: false),
  };

  static Act0ReviewPatternCoachingProjectionV1 tryParse(Object? raw) {
    if (raw is! Map) {
      return const Act0ReviewPatternCoachingProjectionV1();
    }
    final map = raw.cast<String, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    if (schemaVersion != 1) {
      return const Act0ReviewPatternCoachingProjectionV1();
    }
    final rawPatterns = map['patterns'];
    if (rawPatterns is! List) {
      return const Act0ReviewPatternCoachingProjectionV1();
    }
    final patterns = <Act0ReviewPatternCoachingPatternV1>[];
    for (final rawPattern in rawPatterns) {
      final pattern = Act0ReviewPatternCoachingPatternV1.tryParse(rawPattern);
      if (pattern != null) {
        patterns.add(pattern);
      }
    }
    patterns.sort(_comparePatternPriority);
    return Act0ReviewPatternCoachingProjectionV1(
      patterns: List<Act0ReviewPatternCoachingPatternV1>.unmodifiable(patterns),
    );
  }
}

class Act0ReviewPatternCoachingPatternV1 {
  const Act0ReviewPatternCoachingPatternV1({
    this.schemaVersion = 1,
    required this.patternId,
    required this.conceptFamilyId,
    required this.patternType,
    required this.sessionCount,
    required this.evidenceCount,
    required this.firstSessionId,
    required this.latestSessionId,
    required this.sourceTaskIds,
    required this.patternState,
    required this.evidenceStrength,
    required this.latestEvidenceOrder,
    required this.exactTaskRepeat,
    required this.sameFamilyDifferentTasks,
    this.latestRepairState = '',
    this.transferVerdict = '',
    required this.messageKey,
  });

  final int schemaVersion;
  final String patternId;
  final String conceptFamilyId;
  final String patternType;
  final int sessionCount;
  final int evidenceCount;
  final String firstSessionId;
  final String latestSessionId;
  final List<String> sourceTaskIds;
  final String patternState;
  final String evidenceStrength;
  final int latestEvidenceOrder;
  final bool exactTaskRepeat;
  final bool sameFamilyDifferentTasks;
  final String latestRepairState;
  final String transferVerdict;
  final String messageKey;

  String get copyLine {
    if (messageKey == _messageRepeatedUnsuccessfulRepairV1) {
      return 'This repair has not landed yet across your recent attempts.';
    }
    if (messageKey == _messageMissThenLaterImprovementV1) {
      return 'You missed this earlier, then handled it correctly on a later hand.';
    }
    return 'This table-reading mistake showed up in more than one session.';
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'patternId': patternId,
    'conceptFamilyId': conceptFamilyId,
    'patternType': patternType,
    'sessionCount': sessionCount,
    'evidenceCount': evidenceCount,
    'firstSessionId': firstSessionId,
    'latestSessionId': latestSessionId,
    'sourceTaskIds': sourceTaskIds,
    'patternState': patternState,
    'evidenceStrength': evidenceStrength,
    'latestEvidenceOrder': latestEvidenceOrder,
    'exactTaskRepeat': exactTaskRepeat,
    'sameFamilyDifferentTasks': sameFamilyDifferentTasks,
    if (latestRepairState.isNotEmpty) 'latestRepairState': latestRepairState,
    if (transferVerdict.isNotEmpty) 'transferVerdict': transferVerdict,
    'messageKey': messageKey,
  };

  static Act0ReviewPatternCoachingPatternV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    if (schemaVersion != 1) {
      return null;
    }
    final patternId = _requiredString(map, 'patternId');
    final conceptFamilyId = _requiredString(map, 'conceptFamilyId');
    final patternType = _requiredString(map, 'patternType');
    final sessionCount = _nonNegativeInt(map['sessionCount']);
    final evidenceCount = _nonNegativeInt(map['evidenceCount']);
    final firstSessionId = _requiredString(map, 'firstSessionId');
    final latestSessionId = _requiredString(map, 'latestSessionId');
    final patternState = _requiredString(map, 'patternState');
    final evidenceStrength = _requiredString(map, 'evidenceStrength');
    final latestEvidenceOrder = _nonNegativeInt(map['latestEvidenceOrder']);
    final exactTaskRepeat = map['exactTaskRepeat'];
    final sameFamilyDifferentTasks = map['sameFamilyDifferentTasks'];
    final messageKey = _requiredString(map, 'messageKey');
    if (patternId == null ||
        conceptFamilyId == null ||
        patternType == null ||
        sessionCount == null ||
        evidenceCount == null ||
        firstSessionId == null ||
        latestSessionId == null ||
        patternState == null ||
        evidenceStrength == null ||
        latestEvidenceOrder == null ||
        exactTaskRepeat is! bool ||
        sameFamilyDifferentTasks is! bool ||
        messageKey == null) {
      return null;
    }
    return Act0ReviewPatternCoachingPatternV1(
      schemaVersion: schemaVersion,
      patternId: patternId,
      conceptFamilyId: conceptFamilyId,
      patternType: patternType,
      sessionCount: sessionCount,
      evidenceCount: evidenceCount,
      firstSessionId: firstSessionId,
      latestSessionId: latestSessionId,
      sourceTaskIds: _stringList(map['sourceTaskIds']),
      patternState: patternState,
      evidenceStrength: evidenceStrength,
      latestEvidenceOrder: latestEvidenceOrder,
      exactTaskRepeat: exactTaskRepeat,
      sameFamilyDifferentTasks: sameFamilyDifferentTasks,
      latestRepairState: map['latestRepairState']?.toString().trim() ?? '',
      transferVerdict: map['transferVerdict']?.toString().trim() ?? '',
      messageKey: messageKey,
    );
  }
}

List<Act0ReviewPatternCoachingPatternV1> _patternsFromLearningEvidence(
  Act0LearningEvidenceHistoryV1 history, {
  required Act0ReviewMistakeHistoryV1? reviewMistakeHistory,
  required Act0ReviewResolutionStateV1? reviewResolutionState,
}) {
  final buckets = <String, List<Act0LearningEvidenceRecordV1>>{};
  for (final record in history.records) {
    if (record.isCorrect || record.createdOrder < 0) {
      continue;
    }
    final sessionId = record.sessionId.trim();
    if (sessionId.isEmpty) {
      continue;
    }
    final conceptFamilyId = act0ConceptFamilyIdForEvidenceRecordV1(record);
    if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
      continue;
    }
    buckets.putIfAbsent(
      conceptFamilyId,
      () => <Act0LearningEvidenceRecordV1>[],
    );
    buckets[conceptFamilyId]!.add(record);
  }
  final patterns = <Act0ReviewPatternCoachingPatternV1>[];
  for (final entry in buckets.entries) {
    final ordered = <Act0LearningEvidenceRecordV1>[...entry.value]
      ..sort((a, b) {
        final orderCompare = a.createdOrder.compareTo(b.createdOrder);
        if (orderCompare != 0) {
          return orderCompare;
        }
        return a.recordId.compareTo(b.recordId);
      });
    final sessionIds = _distinctStrings(
      ordered.map((record) => record.sessionId),
    );
    if (ordered.length < 2 || sessionIds.length < 2) {
      continue;
    }
    final sourceTaskIds = _distinctStrings(
      ordered.map((record) => record.taskId),
    );
    patterns.add(
      Act0ReviewPatternCoachingPatternV1(
        patternId: _patternId(
          act0ReviewPatternTypeRepeatedMissAcrossSessionsV1,
          entry.key,
        ),
        conceptFamilyId: entry.key,
        patternType: act0ReviewPatternTypeRepeatedMissAcrossSessionsV1,
        sessionCount: sessionIds.length,
        evidenceCount: ordered.length,
        firstSessionId: sessionIds.first,
        latestSessionId: ordered.last.sessionId.trim(),
        sourceTaskIds: sourceTaskIds,
        patternState: _stateForFamily(
          entry.key,
          reviewMistakeHistory: reviewMistakeHistory,
          reviewResolutionState: reviewResolutionState,
        ),
        evidenceStrength: sessionIds.length >= 3
            ? act0ReviewPatternStrengthRepeatedMultiSessionSignalV1
            : act0ReviewPatternStrengthTwoSessionSignalV1,
        latestEvidenceOrder: ordered.last.createdOrder,
        exactTaskRepeat: sourceTaskIds.length == 1,
        sameFamilyDifferentTasks: sourceTaskIds.length > 1,
        messageKey: _messageRepeatedMissV1,
      ),
    );
  }
  return patterns;
}

List<Act0ReviewPatternCoachingPatternV1> _patternsFromRepairOutcomes(
  List<Act0RepairIntentV1> intents,
  Act0RepairOutcomeProjectionV1 projection,
) {
  final conceptsByQueueItemId = <String, String>{};
  final tasksByQueueItemId = <String, String>{};
  for (final intent in intents) {
    final queueItemId = queueItemIdForAct0RepairIntentV1(intent);
    if (queueItemId.isEmpty) {
      continue;
    }
    final conceptFamilyId = _conceptFamilyIdForRepairIntent(intent);
    if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
      continue;
    }
    conceptsByQueueItemId[queueItemId] = conceptFamilyId;
    tasksByQueueItemId[queueItemId] = intent.targetTaskId.trim();
  }
  final failedByQueueItemId = <String, List<Act0RepairOutcomeV1>>{};
  for (final outcome in projection.outcomes) {
    final queueItemId = outcome.queueItemId.trim();
    if (!conceptsByQueueItemId.containsKey(queueItemId) ||
        outcome.isCorrect != false ||
        outcome.sessionId.trim().isEmpty) {
      continue;
    }
    failedByQueueItemId.putIfAbsent(queueItemId, () => <Act0RepairOutcomeV1>[]);
    failedByQueueItemId[queueItemId]!.add(outcome);
  }
  final patterns = <Act0ReviewPatternCoachingPatternV1>[];
  for (final entry in failedByQueueItemId.entries) {
    final ordered = <Act0RepairOutcomeV1>[...entry.value]
      ..sort((a, b) {
        final sequenceCompare = a.sequence.compareTo(b.sequence);
        if (sequenceCompare != 0) {
          return sequenceCompare;
        }
        return a.targetTaskId.compareTo(b.targetTaskId);
      });
    final sessionIds = _distinctStrings(
      ordered.map((outcome) => outcome.sessionId),
    );
    if (ordered.length < 2 || sessionIds.length < 2) {
      continue;
    }
    final conceptFamilyId = conceptsByQueueItemId[entry.key]!;
    final sourceTaskIds = _distinctStrings(<String>[
      tasksByQueueItemId[entry.key] ?? '',
      ...ordered.map((outcome) => outcome.targetTaskId),
    ]);
    patterns.add(
      Act0ReviewPatternCoachingPatternV1(
        patternId: _patternId(
          act0ReviewPatternTypeRepeatedUnsuccessfulRepairV1,
          conceptFamilyId,
        ),
        conceptFamilyId: conceptFamilyId,
        patternType: act0ReviewPatternTypeRepeatedUnsuccessfulRepairV1,
        sessionCount: sessionIds.length,
        evidenceCount: ordered.length,
        firstSessionId: sessionIds.first,
        latestSessionId: ordered.last.sessionId.trim(),
        sourceTaskIds: sourceTaskIds,
        patternState: act0ReviewPatternStateActiveV1,
        evidenceStrength: sessionIds.length >= 3
            ? act0ReviewPatternStrengthRepeatedMultiSessionSignalV1
            : act0ReviewPatternStrengthTwoSessionSignalV1,
        latestEvidenceOrder: ordered.last.sequence,
        exactTaskRepeat: sourceTaskIds.length == 1,
        sameFamilyDifferentTasks: sourceTaskIds.length > 1,
        latestRepairState: ordered.last.outcomeState.trim(),
        messageKey: _messageRepeatedUnsuccessfulRepairV1,
      ),
    );
  }
  return patterns;
}

List<Act0ReviewPatternCoachingPatternV1> _patternsFromTransferSignals(
  Act0LearningTransferMeasurementV1 measurement,
) {
  final patterns = <Act0ReviewPatternCoachingPatternV1>[];
  for (final signal in measurement.signals) {
    final conceptFamilyId = signal.conceptFamilyId.trim();
    final baselineOrder = signal.baselineOrder;
    final comparisonOrder = signal.comparisonOrder;
    if (conceptFamilyId.isEmpty ||
        signal.relationship != act0LearningTransferSameFamilyTransferV1 ||
        signal.verdict != act0LearningTransferImprovedV1 ||
        baselineOrder == null ||
        comparisonOrder == null ||
        signal.baselineSessionId.trim().isEmpty ||
        signal.comparisonSessionId.trim().isEmpty ||
        signal.baselineSessionId.trim() == signal.comparisonSessionId.trim()) {
      continue;
    }
    final sourceTaskIds = _distinctStrings(<String>[
      signal.baselineTaskId,
      signal.comparisonTaskId,
    ]);
    patterns.add(
      Act0ReviewPatternCoachingPatternV1(
        patternId: _patternId(
          act0ReviewPatternTypeMissThenLaterImprovementV1,
          conceptFamilyId,
        ),
        conceptFamilyId: conceptFamilyId,
        patternType: act0ReviewPatternTypeMissThenLaterImprovementV1,
        sessionCount: 2,
        evidenceCount: 2,
        firstSessionId: signal.baselineSessionId.trim(),
        latestSessionId: signal.comparisonSessionId.trim(),
        sourceTaskIds: sourceTaskIds,
        patternState: act0ReviewPatternStateImprovingV1,
        evidenceStrength: act0ReviewPatternStrengthImprovementObservedV1,
        latestEvidenceOrder: comparisonOrder,
        exactTaskRepeat: sourceTaskIds.length == 1,
        sameFamilyDifferentTasks: sourceTaskIds.length > 1,
        transferVerdict: signal.verdict,
        messageKey: _messageMissThenLaterImprovementV1,
      ),
    );
  }
  return patterns;
}

String _stateForFamily(
  String conceptFamilyId, {
  required Act0ReviewMistakeHistoryV1? reviewMistakeHistory,
  required Act0ReviewResolutionStateV1? reviewResolutionState,
}) {
  final history = reviewMistakeHistory;
  final state = reviewResolutionState;
  if (history == null || state == null) {
    return act0ReviewPatternStateActiveV1;
  }
  final id = conceptFamilyId.trim();
  var hasMatchingHistory = false;
  for (final record in history.records) {
    if (_conceptFamilyIdForReviewRecord(record) != id) {
      continue;
    }
    hasMatchingHistory = true;
    final resolution = state.resolutionForReviewItemId(record.recordId);
    if (resolution == null || resolution.isVisibleInActiveReview) {
      return act0ReviewPatternStateActiveV1;
    }
  }
  return hasMatchingHistory
      ? act0ReviewPatternStateHistoricalV1
      : act0ReviewPatternStateActiveV1;
}

String _conceptFamilyIdForReviewRecord(Act0ReviewMistakeRecordV1 record) {
  for (final raw in <String>[
    record.repairFocusId,
    record.skillAtomId,
    record.errorType,
  ]) {
    final value = raw.trim();
    if (value.isNotEmpty && value != 'none') {
      return value;
    }
  }
  return '';
}

String _conceptFamilyIdForRepairIntent(Act0RepairIntentV1 intent) {
  for (final raw in <String>[
    intent.missedSignalId,
    intent.skillAtomId,
    intent.errorType,
  ]) {
    final value = raw.trim();
    if (value.isNotEmpty && value != 'none') {
      return value;
    }
  }
  return '';
}

int _comparePatternPriority(
  Act0ReviewPatternCoachingPatternV1 a,
  Act0ReviewPatternCoachingPatternV1 b,
) {
  final priorityCompare = _typePriority(a).compareTo(_typePriority(b));
  if (priorityCompare != 0) {
    return priorityCompare;
  }
  final stateCompare = _statePriority(a).compareTo(_statePriority(b));
  if (stateCompare != 0) {
    return stateCompare;
  }
  final sessionCompare = b.sessionCount.compareTo(a.sessionCount);
  if (sessionCompare != 0) {
    return sessionCompare;
  }
  final orderCompare = b.latestEvidenceOrder.compareTo(a.latestEvidenceOrder);
  if (orderCompare != 0) {
    return orderCompare;
  }
  return a.conceptFamilyId.compareTo(b.conceptFamilyId);
}

int _typePriority(Act0ReviewPatternCoachingPatternV1 pattern) {
  if (pattern.patternType ==
      act0ReviewPatternTypeRepeatedUnsuccessfulRepairV1) {
    return 0;
  }
  if (pattern.patternType ==
      act0ReviewPatternTypeRepeatedMissAcrossSessionsV1) {
    return 1;
  }
  if (pattern.patternType == act0ReviewPatternTypeMissThenLaterImprovementV1) {
    return 2;
  }
  return 3;
}

int _statePriority(Act0ReviewPatternCoachingPatternV1 pattern) {
  if (pattern.patternState == act0ReviewPatternStateActiveV1) {
    return 0;
  }
  if (pattern.patternState == act0ReviewPatternStateImprovingV1) {
    return 1;
  }
  if (pattern.patternState == act0ReviewPatternStateHistoricalV1) {
    return 2;
  }
  return 3;
}

String _patternId(String patternType, String conceptFamilyId) =>
    'review_pattern_v1|${patternType.trim()}|${conceptFamilyId.trim()}';

List<String> _distinctStrings(Iterable<String> values) {
  final seen = <String>{};
  final result = <String>[];
  for (final raw in values) {
    final value = raw.trim();
    if (value.isNotEmpty && seen.add(value)) {
      result.add(value);
    }
  }
  return List<String>.unmodifiable(result);
}

List<String> _stringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return List<String>.unmodifiable(
    raw
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty),
  );
}

String? _requiredString(Map<String, Object?> map, String key) {
  final value = map[key]?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}
