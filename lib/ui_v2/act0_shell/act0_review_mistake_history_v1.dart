import 'dart:convert';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

const String act0ReviewMistakeStateUnresolvedOnlyV1 = 'unresolved_only_v1';

class Act0ReviewMistakeRecordV1 {
  const Act0ReviewMistakeRecordV1({
    this.schemaVersion = 1,
    required this.recordId,
    required this.sourceDecisionId,
    required this.createdOrder,
    required this.updatedOrder,
    required this.worldId,
    required this.lessonId,
    required this.decisionTaskId,
    required this.sourceTaskId,
    required this.decisionKind,
    required this.selectedId,
    required this.expectedId,
    required this.resultKind,
    required this.errorType,
    required this.skillAtomId,
    required this.repairFocusId,
    required this.runId,
    required this.runKind,
    required this.runOrdinal,
    required this.attemptRecordIds,
    required this.dedupUsesFallback,
    this.state = act0ReviewMistakeStateUnresolvedOnlyV1,
  });

  final int schemaVersion;
  final String recordId;
  final String sourceDecisionId;
  final int createdOrder;
  final int updatedOrder;
  final String worldId;
  final String lessonId;
  final String decisionTaskId;
  final String sourceTaskId;
  final String decisionKind;
  final String selectedId;
  final String expectedId;
  final String resultKind;
  final String errorType;
  final String skillAtomId;
  final String repairFocusId;
  final String runId;
  final String runKind;
  final int? runOrdinal;
  final List<String> attemptRecordIds;
  final bool dedupUsesFallback;
  final String state;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'recordId': recordId,
    'sourceDecisionId': sourceDecisionId,
    'createdOrder': createdOrder,
    'updatedOrder': updatedOrder,
    'worldId': worldId,
    'lessonId': lessonId,
    'decisionTaskId': decisionTaskId,
    'sourceTaskId': sourceTaskId,
    'decisionKind': decisionKind,
    'selectedId': selectedId,
    'expectedId': expectedId,
    'resultKind': resultKind,
    'errorType': errorType,
    'skillAtomId': skillAtomId,
    'repairFocusId': repairFocusId,
    'runId': runId,
    'runKind': runKind,
    if (runOrdinal != null) 'runOrdinal': runOrdinal,
    'attemptRecordIds': attemptRecordIds,
    'dedupUsesFallback': dedupUsesFallback,
    'state': state,
  };

  static Act0ReviewMistakeRecordV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final recordId = _requiredString(map['recordId']);
    final sourceDecisionId = _requiredString(map['sourceDecisionId']);
    final createdOrder = _positiveInt(map['createdOrder']);
    final updatedOrder = _positiveInt(map['updatedOrder']);
    final worldId = _requiredString(map['worldId']);
    final lessonId = _requiredString(map['lessonId']);
    final decisionTaskId = _requiredString(map['decisionTaskId']);
    final sourceTaskId = _requiredString(map['sourceTaskId']);
    final decisionKind = _requiredString(map['decisionKind']);
    final selectedId = _requiredString(map['selectedId']);
    final expectedId = _requiredString(map['expectedId']);
    final resultKind = _requiredString(map['resultKind']);
    final errorType = _optionalString(map['errorType']);
    final skillAtomId = _optionalString(map['skillAtomId']);
    final repairFocusId = _optionalString(map['repairFocusId']);
    final runId = _optionalString(map['runId']);
    final runKind = _optionalString(map['runKind']);
    final runOrdinal = map.containsKey('runOrdinal')
        ? _nonNegativeInt(map['runOrdinal'])
        : null;
    final attemptRecordIds = _uniqueStringList(map['attemptRecordIds']);
    final dedupUsesFallback = map['dedupUsesFallback'];
    final state = _requiredString(map['state']);
    if (schemaVersion != 1 ||
        recordId == null ||
        sourceDecisionId == null ||
        createdOrder == null ||
        updatedOrder == null ||
        updatedOrder < createdOrder ||
        worldId == null ||
        lessonId == null ||
        decisionTaskId == null ||
        sourceTaskId == null ||
        decisionKind == null ||
        !_decisionKinds.contains(decisionKind) ||
        selectedId == null ||
        expectedId == null ||
        resultKind == null ||
        !_mistakeResultKinds.contains(resultKind) ||
        attemptRecordIds.isEmpty ||
        !attemptRecordIds.contains(sourceDecisionId) ||
        dedupUsesFallback is! bool ||
        state != act0ReviewMistakeStateUnresolvedOnlyV1) {
      return null;
    }
    return Act0ReviewMistakeRecordV1(
      recordId: recordId,
      sourceDecisionId: sourceDecisionId,
      createdOrder: createdOrder,
      updatedOrder: updatedOrder,
      worldId: worldId,
      lessonId: lessonId,
      decisionTaskId: decisionTaskId,
      sourceTaskId: sourceTaskId,
      decisionKind: decisionKind,
      selectedId: selectedId,
      expectedId: expectedId,
      resultKind: resultKind,
      errorType: errorType,
      skillAtomId: skillAtomId,
      repairFocusId: repairFocusId,
      runId: runId,
      runKind: runKind,
      runOrdinal: runOrdinal,
      attemptRecordIds: List<String>.unmodifiable(attemptRecordIds),
      dedupUsesFallback: dedupUsesFallback,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0ReviewMistakeRecordV1 &&
      other.schemaVersion == schemaVersion &&
      other.recordId == recordId &&
      other.sourceDecisionId == sourceDecisionId &&
      other.createdOrder == createdOrder &&
      other.updatedOrder == updatedOrder &&
      other.worldId == worldId &&
      other.lessonId == lessonId &&
      other.decisionTaskId == decisionTaskId &&
      other.sourceTaskId == sourceTaskId &&
      other.decisionKind == decisionKind &&
      other.selectedId == selectedId &&
      other.expectedId == expectedId &&
      other.resultKind == resultKind &&
      other.errorType == errorType &&
      other.skillAtomId == skillAtomId &&
      other.repairFocusId == repairFocusId &&
      other.runId == runId &&
      other.runKind == runKind &&
      other.runOrdinal == runOrdinal &&
      _sameStrings(other.attemptRecordIds, attemptRecordIds) &&
      other.dedupUsesFallback == dedupUsesFallback &&
      other.state == state;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    schemaVersion,
    recordId,
    sourceDecisionId,
    createdOrder,
    updatedOrder,
    worldId,
    lessonId,
    decisionTaskId,
    sourceTaskId,
    decisionKind,
    selectedId,
    expectedId,
    resultKind,
    errorType,
    skillAtomId,
    repairFocusId,
    runId,
    runKind,
    runOrdinal,
    ...attemptRecordIds,
    dedupUsesFallback,
    state,
  ]);
}

class Act0ReviewMistakeHistoryV1 {
  const Act0ReviewMistakeHistoryV1({
    this.records = const <Act0ReviewMistakeRecordV1>[],
  });

  static const int maxRecords = 200;

  /// Records are stored newest first by [Act0ReviewMistakeRecordV1.updatedOrder].
  final List<Act0ReviewMistakeRecordV1> records;

  Act0ReviewMistakeHistoryV1 appendCompletedDecision(
    Act0CompletedDecisionV1 decision, {
    String runId = '',
    String runKind = '',
    int? runOrdinal,
  }) {
    if (!_isCompleteMistakeDecision(decision) ||
        records.any(
          (record) => record.attemptRecordIds.contains(decision.attemptKey),
        )) {
      return this;
    }
    final sourceTaskId = decision.sourceTaskId.trim().isEmpty
        ? decision.taskId.trim()
        : decision.sourceTaskId.trim();
    final repairFocusId = _firstNonEmpty(<String?>[
      decision.repairFocusId,
      decision.missedSignalId,
    ]);
    final skillAtomId = _optionalString(decision.skillAtomId);
    final errorType = _optionalString(decision.errorType);
    final dedupUsesFallback =
        repairFocusId.isEmpty || skillAtomId.isEmpty || errorType.isEmpty;
    final recordId = _recordId(
      sourceTaskId: sourceTaskId,
      repairFocusId: repairFocusId,
      skillAtomId: skillAtomId,
      errorType: errorType,
    );
    final nextOrder =
        records.fold<int>(
          0,
          (latest, record) =>
              record.updatedOrder > latest ? record.updatedOrder : latest,
        ) +
        1;
    final existing = records.cast<Act0ReviewMistakeRecordV1?>().firstWhere(
      (record) => record?.recordId == recordId,
      orElse: () => null,
    );
    final nextRecord = Act0ReviewMistakeRecordV1(
      recordId: recordId,
      sourceDecisionId: decision.attemptKey,
      createdOrder: existing?.createdOrder ?? nextOrder,
      updatedOrder: nextOrder,
      worldId: decision.worldId!.trim(),
      lessonId: decision.lessonId.trim(),
      decisionTaskId: decision.taskId.trim(),
      sourceTaskId: sourceTaskId,
      decisionKind: decision.decisionKind.name,
      selectedId: decision.selectedId.trim(),
      expectedId: decision.expectedId!.trim(),
      resultKind: decision.resultKind.trim(),
      errorType: errorType,
      skillAtomId: skillAtomId,
      repairFocusId: repairFocusId,
      runId: runId.trim(),
      runKind: runKind.trim(),
      runOrdinal: runOrdinal,
      attemptRecordIds: List<String>.unmodifiable(<String>[
        ...?existing?.attemptRecordIds,
        decision.attemptKey,
      ]),
      dedupUsesFallback:
          dedupUsesFallback || (existing?.dedupUsesFallback ?? false),
    );
    final next = <Act0ReviewMistakeRecordV1>[
      for (final record in records)
        if (record.recordId != recordId) record,
      nextRecord,
    ]..sort(_newestFirst);
    return Act0ReviewMistakeHistoryV1(
      records: List<Act0ReviewMistakeRecordV1>.unmodifiable(
        next.take(maxRecords),
      ),
    );
  }

  List<Map<String, Object?>> toPayload() =>
      records.map((record) => record.toPayload()).toList(growable: false);

  String toStorageString() => jsonEncode(toPayload());

  static Act0ReviewMistakeHistoryV1? tryParse(Object? raw) {
    if (raw is! List) {
      return null;
    }
    final byRecordId = <String, Act0ReviewMistakeRecordV1>{};
    for (final item in raw) {
      final record = Act0ReviewMistakeRecordV1.tryParse(item);
      if (record == null) {
        continue;
      }
      final existing = byRecordId[record.recordId];
      if (existing == null || record.updatedOrder > existing.updatedOrder) {
        byRecordId[record.recordId] = record;
      }
    }
    final records = byRecordId.values.toList(growable: false)
      ..sort(_newestFirst);
    return Act0ReviewMistakeHistoryV1(
      records: List<Act0ReviewMistakeRecordV1>.unmodifiable(
        records.take(maxRecords),
      ),
    );
  }

  static Act0ReviewMistakeHistoryV1? tryParseStorageString(String raw) {
    try {
      return tryParse(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Act0ReviewMistakeHistoryV1 &&
      _sameRecords(other.records, records);

  @override
  int get hashCode => Object.hashAll(records);
}

bool _isCompleteMistakeDecision(Act0CompletedDecisionV1 decision) {
  final worldId = decision.worldId?.trim() ?? '';
  final expectedId = decision.expectedId?.trim() ?? '';
  return !decision.isCorrect &&
      _mistakeResultKinds.contains(decision.resultKind.trim()) &&
      decision.attemptKey.trim().isNotEmpty &&
      worldId.isNotEmpty &&
      decision.lessonId.trim().isNotEmpty &&
      decision.taskId.trim().isNotEmpty &&
      (decision.sourceTaskId.trim().isNotEmpty ||
          decision.taskId.trim().isNotEmpty) &&
      decision.selectedId.trim().isNotEmpty &&
      expectedId.isNotEmpty;
}

String _recordId({
  required String sourceTaskId,
  required String repairFocusId,
  required String skillAtomId,
  required String errorType,
}) {
  return 'review_mistake_v1|${_keyPart(sourceTaskId)}|'
      '${_keyPart(repairFocusId)}|${_keyPart(skillAtomId)}|'
      '${_keyPart(errorType)}';
}

String _keyPart(String value) => '${value.length}:$value';

String _firstNonEmpty(List<String?> values) {
  for (final raw in values) {
    final value = raw?.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
  }
  return '';
}

int _newestFirst(Act0ReviewMistakeRecordV1 a, Act0ReviewMistakeRecordV1 b) {
  final order = b.updatedOrder.compareTo(a.updatedOrder);
  return order != 0 ? order : a.recordId.compareTo(b.recordId);
}

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

String _optionalString(Object? raw) => raw?.toString().trim() ?? '';

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

int? _positiveInt(Object? raw) {
  final value = _nonNegativeInt(raw);
  return value == null || value == 0 ? null : value;
}

List<String> _uniqueStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  final seen = <String>{};
  return <String>[
    for (final item in raw)
      if (_optionalString(item).isNotEmpty && seen.add(_optionalString(item)))
        _optionalString(item),
  ];
}

bool _sameStrings(List<String> a, List<String> b) {
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

bool _sameRecords(
  List<Act0ReviewMistakeRecordV1> a,
  List<Act0ReviewMistakeRecordV1> b,
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

const Set<String> _mistakeResultKinds = <String>{'incorrect', 'suboptimal'};

const Set<String> _decisionKinds = <String>{'actionList', 'seat', 'sizing'};
