import 'act0_concept_family_state_foundation_v1.dart';
import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_repair_intent_contract_v1.dart';

const String act0SpacedRepStateDueNowV1 = 'due_now';
const String act0SpacedRepStateDueNextSessionV1 = 'due_next_session';
const String act0SpacedRepStateNotDueV1 = 'not_due';
const String act0SpacedRepStateInsufficientEvidenceV1 = 'insufficient_evidence';

const String act0SpacedRepReasonUnresolvedMissV1 = 'unresolved_miss';
const String act0SpacedRepReasonRepairNotYetSucceededV1 =
    'repair_not_yet_succeeded';
const String act0SpacedRepReasonRepairSucceededV1 = 'repair_succeeded';
const String act0SpacedRepReasonRecentImprovementReinforcementV1 =
    'recent_improvement_reinforcement';
const String act0SpacedRepReasonStableCorrectEvidenceV1 =
    'stable_correct_evidence';
const String act0SpacedRepReasonInsufficientEvidenceV1 =
    'insufficient_evidence';

class Act0SpacedRepetitionScheduleV1 {
  const Act0SpacedRepetitionScheduleV1({
    this.schedules = const <Act0SpacedRepetitionFamilyScheduleV1>[],
  });

  factory Act0SpacedRepetitionScheduleV1.fromSources({
    required int currentSessionOrdinal,
    List<Act0RepairIntentV1> activeRepairIntents = const <Act0RepairIntentV1>[],
    Act0ConceptFamilyStateHistoryV1 conceptFamilyStateHistory =
        const Act0ConceptFamilyStateHistoryV1(),
    Act0LearningTransferMeasurementV1 transferMeasurement =
        const Act0LearningTransferMeasurementV1(
          signals: <Act0LearningTransferSignalV1>[],
        ),
  }) {
    final current = currentSessionOrdinal < 0 ? 0 : currentSessionOrdinal;
    final byFamilyId = <String, Act0SpacedRepetitionFamilyScheduleV1>{};

    for (final intent in activeRepairIntents) {
      final conceptFamilyId = _conceptFamilyIdForIntent(intent);
      _upsertBest(
        byFamilyId,
        Act0SpacedRepetitionFamilyScheduleV1(
          conceptFamilyId: conceptFamilyId,
          scheduleState: act0SpacedRepStateDueNowV1,
          dueReason: act0SpacedRepReasonUnresolvedMissV1,
          lastEvidenceSessionId: null,
          lastEvidenceOrder: 0,
          dueAfterSessionOrdinal: current,
          sourceTaskId: intent.sourceTaskId,
          sourceEvidenceRef:
              'active_repair:${intent.sourceTaskId}:${intent.choiceId}',
          priorityClass: 0,
        ),
        current,
      );
    }

    for (final family in conceptFamilyStateHistory.families) {
      _upsertBest(byFamilyId, _fromConceptFamily(family, current), current);
    }

    for (final signal in transferMeasurement.signals) {
      _upsertBest(byFamilyId, _fromTransferSignal(signal, current), current);
    }

    final schedules = byFamilyId.values.toList(growable: false)
      ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0SpacedRepetitionScheduleV1(
      schedules: List<Act0SpacedRepetitionFamilyScheduleV1>.unmodifiable(
        schedules,
      ),
    );
  }

  final List<Act0SpacedRepetitionFamilyScheduleV1> schedules;

  List<Act0SpacedRepetitionFamilyScheduleV1> get dueFamilies {
    final due = schedules.where((schedule) => schedule.isDueNow).toList();
    due.sort(_compareDueFamily);
    return List<Act0SpacedRepetitionFamilyScheduleV1>.unmodifiable(due);
  }

  Act0SpacedRepetitionFamilyScheduleV1? get nextDueFamily {
    final due = dueFamilies;
    return due.isEmpty ? null : due.first;
  }

  Act0SpacedRepetitionFamilyScheduleV1? scheduleForConceptFamily(
    String conceptFamilyId,
  ) {
    final id = conceptFamilyId.trim();
    if (id.isEmpty) {
      return null;
    }
    for (final schedule in schedules) {
      if (schedule.conceptFamilyId == id) {
        return schedule;
      }
    }
    return null;
  }

  List<Map<String, Object?>> toPayload() =>
      schedules.map((schedule) => schedule.toPayload()).toList(growable: false);

  static Act0SpacedRepetitionScheduleV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0SpacedRepetitionScheduleV1();
    }
    final byFamilyId = <String, Act0SpacedRepetitionFamilyScheduleV1>{};
    for (final item in raw) {
      final schedule = Act0SpacedRepetitionFamilyScheduleV1.tryParse(item);
      if (schedule == null) {
        continue;
      }
      final existing = byFamilyId[schedule.conceptFamilyId];
      if (existing == null || _compareStoredSchedule(schedule, existing) < 0) {
        byFamilyId[schedule.conceptFamilyId] = schedule;
      }
    }
    final schedules = byFamilyId.values.toList(growable: false)
      ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0SpacedRepetitionScheduleV1(
      schedules: List<Act0SpacedRepetitionFamilyScheduleV1>.unmodifiable(
        schedules,
      ),
    );
  }
}

class Act0SpacedRepetitionFamilyScheduleV1 {
  const Act0SpacedRepetitionFamilyScheduleV1({
    this.schemaVersion = 1,
    required this.conceptFamilyId,
    required this.scheduleState,
    required this.dueReason,
    required this.lastEvidenceSessionId,
    required this.lastEvidenceOrder,
    required this.dueAfterSessionOrdinal,
    required this.sourceTaskId,
    required this.sourceEvidenceRef,
    required this.priorityClass,
  });

  final int schemaVersion;
  final String conceptFamilyId;
  final String scheduleState;
  final String dueReason;
  final String? lastEvidenceSessionId;
  final int? lastEvidenceOrder;
  final int? dueAfterSessionOrdinal;
  final String? sourceTaskId;
  final String? sourceEvidenceRef;
  final int priorityClass;

  bool get isDueNow => scheduleState == act0SpacedRepStateDueNowV1;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'conceptFamilyId': conceptFamilyId,
    'scheduleState': scheduleState,
    'dueReason': dueReason,
    if ((lastEvidenceSessionId ?? '').isNotEmpty)
      'lastEvidenceSessionId': lastEvidenceSessionId,
    if (lastEvidenceOrder != null) 'lastEvidenceOrder': lastEvidenceOrder,
    if (dueAfterSessionOrdinal != null)
      'dueAfterSessionOrdinal': dueAfterSessionOrdinal,
    if ((sourceTaskId ?? '').isNotEmpty) 'sourceTaskId': sourceTaskId,
    if ((sourceEvidenceRef ?? '').isNotEmpty)
      'sourceEvidenceRef': sourceEvidenceRef,
    'priorityClass': priorityClass,
  };

  static Act0SpacedRepetitionFamilyScheduleV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final conceptFamilyId = _requiredString(map['conceptFamilyId']);
    final scheduleState = _requiredString(map['scheduleState']);
    final dueReason = _requiredString(map['dueReason']);
    final dueAfterSessionOrdinal = map.containsKey('dueAfterSessionOrdinal')
        ? _nonNegativeInt(map['dueAfterSessionOrdinal'])
        : null;
    final lastEvidenceOrder = map.containsKey('lastEvidenceOrder')
        ? _nonNegativeInt(map['lastEvidenceOrder'])
        : null;
    final priorityClass = _nonNegativeInt(map['priorityClass']);
    if (schemaVersion != 1 ||
        conceptFamilyId == null ||
        scheduleState == null ||
        dueReason == null ||
        priorityClass == null ||
        !_scheduleStates.contains(scheduleState) ||
        !_dueReasons.contains(dueReason)) {
      return null;
    }
    return Act0SpacedRepetitionFamilyScheduleV1(
      schemaVersion: 1,
      conceptFamilyId: conceptFamilyId,
      scheduleState: scheduleState,
      dueReason: dueReason,
      lastEvidenceSessionId: _optionalString(map['lastEvidenceSessionId']),
      lastEvidenceOrder: lastEvidenceOrder,
      dueAfterSessionOrdinal: dueAfterSessionOrdinal,
      sourceTaskId: _optionalString(map['sourceTaskId']),
      sourceEvidenceRef: _optionalString(map['sourceEvidenceRef']),
      priorityClass: priorityClass,
    );
  }
}

Act0SpacedRepetitionFamilyScheduleV1 _fromConceptFamily(
  Act0ConceptFamilyStateV1 family,
  int currentSessionOrdinal,
) {
  final conceptFamilyId = family.conceptFamilyId.trim();
  if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
    return _insufficient(conceptFamilyId);
  }
  final lastSessionOrdinal = _sessionOrdinal(family.lastSessionId);
  final lastEvidenceOrder = family.lastAttemptAt ?? family.lastSeenAt;
  if (family.lastOutcome == act0ConceptFamilyOutcomeMissedV1) {
    return Act0SpacedRepetitionFamilyScheduleV1(
      conceptFamilyId: conceptFamilyId,
      scheduleState: act0SpacedRepStateDueNowV1,
      dueReason: act0SpacedRepReasonUnresolvedMissV1,
      lastEvidenceSessionId: family.lastSessionId,
      lastEvidenceOrder: lastEvidenceOrder,
      dueAfterSessionOrdinal: currentSessionOrdinal,
      sourceTaskId: family.lastTaskId,
      sourceEvidenceRef: 'concept_family:$conceptFamilyId:missed',
      priorityClass: 1,
    );
  }
  if (family.lastOutcome == act0ConceptFamilyOutcomeRepairNotYetSucceededV1 ||
      family.lastOutcome == act0ConceptFamilyOutcomeRepairAttemptedV1) {
    return Act0SpacedRepetitionFamilyScheduleV1(
      conceptFamilyId: conceptFamilyId,
      scheduleState: act0SpacedRepStateDueNowV1,
      dueReason: act0SpacedRepReasonRepairNotYetSucceededV1,
      lastEvidenceSessionId: family.lastSessionId,
      lastEvidenceOrder: lastEvidenceOrder,
      dueAfterSessionOrdinal: currentSessionOrdinal,
      sourceTaskId: family.lastTaskId,
      sourceEvidenceRef: 'concept_family:$conceptFamilyId:repair_open',
      priorityClass: 1,
    );
  }
  if (family.lastOutcome == act0ConceptFamilyOutcomeRepairSucceededV1 &&
      lastSessionOrdinal != null) {
    final dueAfter = lastSessionOrdinal + 1;
    return Act0SpacedRepetitionFamilyScheduleV1(
      conceptFamilyId: conceptFamilyId,
      scheduleState: _stateForDueAfter(dueAfter, currentSessionOrdinal),
      dueReason: act0SpacedRepReasonRepairSucceededV1,
      lastEvidenceSessionId: family.lastSessionId,
      lastEvidenceOrder: lastEvidenceOrder,
      dueAfterSessionOrdinal: dueAfter,
      sourceTaskId: family.lastTaskId,
      sourceEvidenceRef: 'concept_family:$conceptFamilyId:repair_succeeded',
      priorityClass: 2,
    );
  }
  return _insufficient(conceptFamilyId);
}

Act0SpacedRepetitionFamilyScheduleV1 _fromTransferSignal(
  Act0LearningTransferSignalV1 signal,
  int currentSessionOrdinal,
) {
  final conceptFamilyId = signal.conceptFamilyId.trim();
  if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
    return _insufficient(conceptFamilyId);
  }
  final baselineOrdinal = _sessionOrdinal(signal.baselineSessionId);
  final comparisonOrdinal = _sessionOrdinal(signal.comparisonSessionId);
  if (baselineOrdinal == null ||
      comparisonOrdinal == null ||
      baselineOrdinal == comparisonOrdinal ||
      signal.relationship != act0LearningTransferSameFamilyTransferV1) {
    return _insufficient(conceptFamilyId);
  }
  final interval = switch (signal.verdict) {
    act0LearningTransferImprovedV1 => 1,
    act0LearningTransferHeldV1 => 2,
    _ => null,
  };
  if (interval == null) {
    return _insufficient(conceptFamilyId);
  }
  final dueAfter = comparisonOrdinal + interval;
  final isImproved = signal.verdict == act0LearningTransferImprovedV1;
  return Act0SpacedRepetitionFamilyScheduleV1(
    conceptFamilyId: conceptFamilyId,
    scheduleState: _stateForDueAfter(dueAfter, currentSessionOrdinal),
    dueReason: isImproved
        ? act0SpacedRepReasonRecentImprovementReinforcementV1
        : act0SpacedRepReasonStableCorrectEvidenceV1,
    lastEvidenceSessionId: signal.comparisonSessionId,
    lastEvidenceOrder: signal.comparisonOrder,
    dueAfterSessionOrdinal: dueAfter,
    sourceTaskId: signal.comparisonTaskId,
    sourceEvidenceRef:
        'transfer:$conceptFamilyId:${signal.baselineTaskId}:'
        '${signal.comparisonTaskId}',
    priorityClass: isImproved ? 3 : 4,
  );
}

Act0SpacedRepetitionFamilyScheduleV1 _insufficient(String conceptFamilyId) {
  return Act0SpacedRepetitionFamilyScheduleV1(
    conceptFamilyId: conceptFamilyId.trim(),
    scheduleState: act0SpacedRepStateInsufficientEvidenceV1,
    dueReason: act0SpacedRepReasonInsufficientEvidenceV1,
    lastEvidenceSessionId: null,
    lastEvidenceOrder: null,
    dueAfterSessionOrdinal: null,
    sourceTaskId: null,
    sourceEvidenceRef: null,
    priorityClass: 99,
  );
}

void _upsertBest(
  Map<String, Act0SpacedRepetitionFamilyScheduleV1> byFamilyId,
  Act0SpacedRepetitionFamilyScheduleV1 schedule,
  int currentSessionOrdinal,
) {
  if (schedule.conceptFamilyId.isEmpty || schedule.conceptFamilyId == 'none') {
    return;
  }
  final existing = byFamilyId[schedule.conceptFamilyId];
  if (existing == null ||
      _compareScheduleForCurrent(schedule, existing, currentSessionOrdinal) <
          0) {
    byFamilyId[schedule.conceptFamilyId] = schedule;
  }
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

String _stateForDueAfter(
  int dueAfterSessionOrdinal,
  int currentSessionOrdinal,
) {
  if (currentSessionOrdinal >= dueAfterSessionOrdinal) {
    return act0SpacedRepStateDueNowV1;
  }
  if (currentSessionOrdinal + 1 == dueAfterSessionOrdinal) {
    return act0SpacedRepStateDueNextSessionV1;
  }
  return act0SpacedRepStateNotDueV1;
}

int _compareDueFamily(
  Act0SpacedRepetitionFamilyScheduleV1 a,
  Act0SpacedRepetitionFamilyScheduleV1 b,
) {
  final priority = a.priorityClass.compareTo(b.priorityClass);
  if (priority != 0) {
    return priority;
  }
  final dueAfter = (a.dueAfterSessionOrdinal ?? 1 << 30).compareTo(
    b.dueAfterSessionOrdinal ?? 1 << 30,
  );
  if (dueAfter != 0) {
    return dueAfter;
  }
  final evidence = (b.lastEvidenceOrder ?? -1).compareTo(
    a.lastEvidenceOrder ?? -1,
  );
  if (evidence != 0) {
    return evidence;
  }
  return a.conceptFamilyId.compareTo(b.conceptFamilyId);
}

int _compareScheduleForCurrent(
  Act0SpacedRepetitionFamilyScheduleV1 a,
  Act0SpacedRepetitionFamilyScheduleV1 b,
  int currentSessionOrdinal,
) {
  final dueState = _stateRank(
    a,
    currentSessionOrdinal,
  ).compareTo(_stateRank(b, currentSessionOrdinal));
  if (dueState != 0) {
    return dueState;
  }
  return _compareDueFamily(a, b);
}

int _compareStoredSchedule(
  Act0SpacedRepetitionFamilyScheduleV1 a,
  Act0SpacedRepetitionFamilyScheduleV1 b,
) {
  final state = _storedStateRank(
    a.scheduleState,
  ).compareTo(_storedStateRank(b.scheduleState));
  if (state != 0) {
    return state;
  }
  return _compareDueFamily(a, b);
}

int _stateRank(
  Act0SpacedRepetitionFamilyScheduleV1 schedule,
  int currentSessionOrdinal,
) {
  if (schedule.dueAfterSessionOrdinal != null &&
      currentSessionOrdinal >= schedule.dueAfterSessionOrdinal!) {
    return 0;
  }
  return _storedStateRank(schedule.scheduleState);
}

int _storedStateRank(String state) => switch (state) {
  act0SpacedRepStateDueNowV1 => 0,
  act0SpacedRepStateDueNextSessionV1 => 1,
  act0SpacedRepStateNotDueV1 => 2,
  _ => 3,
};

int? _sessionOrdinal(String? sessionId) {
  final value = sessionId?.trim() ?? '';
  const prefix = 'session_v1|';
  if (!value.startsWith(prefix)) {
    return null;
  }
  final ordinal = int.tryParse(value.substring(prefix.length));
  return ordinal == null || ordinal < 0 ? null : ordinal;
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

const Set<String> _scheduleStates = <String>{
  act0SpacedRepStateDueNowV1,
  act0SpacedRepStateDueNextSessionV1,
  act0SpacedRepStateNotDueV1,
  act0SpacedRepStateInsufficientEvidenceV1,
};

const Set<String> _dueReasons = <String>{
  act0SpacedRepReasonUnresolvedMissV1,
  act0SpacedRepReasonRepairNotYetSucceededV1,
  act0SpacedRepReasonRepairSucceededV1,
  act0SpacedRepReasonRecentImprovementReinforcementV1,
  act0SpacedRepReasonStableCorrectEvidenceV1,
  act0SpacedRepReasonInsufficientEvidenceV1,
};
