import 'dart:convert';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';

/// Converts the normalized internal completion payload into a durable record.
///
/// Incomplete payloads are deliberately skipped rather than populated from UI
/// state or guessed fallbacks.
Act0LearningEvidenceRecordV1? act0LearningEvidenceRecordFromCompletedDecisionV1(
  Act0CompletedDecisionV1 decision, {
  required int createdOrder,
  Act0EvidenceRunKeyV1? runKey,
}) {
  final worldId = decision.worldId?.trim();
  final lessonId = decision.lessonId.trim();
  final taskId = decision.taskId.trim();
  final choiceId = decision.selectedId.trim();
  final expectedChoiceId = decision.expectedId?.trim();
  final errorType = decision.errorType?.trim();
  final skillAtomId = decision.skillAtomId?.trim();
  final decisionTimeBucket = decision.decisionTimeBucket.trim();
  final resultKind = decision.resultKind.trim();
  if (createdOrder < 0 ||
      worldId == null ||
      worldId.isEmpty ||
      lessonId.isEmpty ||
      taskId.isEmpty ||
      choiceId.isEmpty ||
      expectedChoiceId == null ||
      expectedChoiceId.isEmpty ||
      errorType == null ||
      errorType.isEmpty ||
      skillAtomId == null ||
      skillAtomId.isEmpty ||
      decisionTimeBucket.isEmpty ||
      resultKind.isEmpty) {
    return null;
  }
  return Act0LearningEvidenceRecordV1(
    recordId: decision.attemptKey,
    createdOrder: createdOrder,
    worldId: worldId,
    lessonId: lessonId,
    taskId: taskId,
    choiceId: choiceId,
    expectedChoiceId: expectedChoiceId,
    isCorrect: decision.isCorrect,
    errorType: errorType,
    repairFocusId: decision.repairFocusId?.trim() ?? '',
    skillAtomId: skillAtomId,
    decisionTimeBucket: decisionTimeBucket,
    resultKind: resultKind,
    runId: runKey?.runId ?? '',
    runKind: runKey?.runKind ?? '',
    runOrdinal: runKey?.runOrdinal,
    sourceWorldId: runKey?.worldId ?? '',
    sourceLessonId: runKey?.lessonId ?? '',
  );
}

/// Evidence-only record for a completed Act0 decision.
///
/// This contract deliberately has no learner-facing interpretation fields.
/// Persistence and UI consumption are separate, future decisions.
class Act0EvidenceRunKeyV1 {
  const Act0EvidenceRunKeyV1({
    this.schemaVersion = 1,
    required this.runId,
    required this.worldId,
    required this.lessonId,
    required this.runOrdinal,
    required this.runKind,
    required this.startedBy,
  });

  final int schemaVersion;
  final String runId;
  final String worldId;
  final String lessonId;
  final int runOrdinal;
  final String runKind;
  final String startedBy;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'runId': runId,
    'worldId': worldId,
    'lessonId': lessonId,
    'runOrdinal': runOrdinal,
    'runKind': runKind,
    'startedBy': startedBy,
  };

  static Act0EvidenceRunKeyV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final runId = _requiredString(map['runId']);
    final worldId = _requiredString(map['worldId']);
    final lessonId = _requiredString(map['lessonId']);
    final runOrdinal = _nonNegativeInt(map['runOrdinal']);
    final runKind = _requiredString(map['runKind']);
    final startedBy = _requiredString(map['startedBy']);
    if (schemaVersion != 1 ||
        runId == null ||
        worldId == null ||
        lessonId == null ||
        runOrdinal == null ||
        runKind == null ||
        startedBy == null) {
      return null;
    }
    return Act0EvidenceRunKeyV1(
      runId: runId,
      worldId: worldId,
      lessonId: lessonId,
      runOrdinal: runOrdinal,
      runKind: runKind,
      startedBy: startedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0EvidenceRunKeyV1 &&
      other.schemaVersion == schemaVersion &&
      other.runId == runId &&
      other.worldId == worldId &&
      other.lessonId == lessonId &&
      other.runOrdinal == runOrdinal &&
      other.runKind == runKind &&
      other.startedBy == startedBy;

  @override
  int get hashCode => Object.hash(
    schemaVersion,
    runId,
    worldId,
    lessonId,
    runOrdinal,
    runKind,
    startedBy,
  );
}

class Act0LearningEvidenceRecordV1 {
  const Act0LearningEvidenceRecordV1({
    this.schemaVersion = 1,
    required this.recordId,
    required this.createdOrder,
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.choiceId,
    required this.expectedChoiceId,
    required this.isCorrect,
    required this.errorType,
    required this.repairFocusId,
    required this.skillAtomId,
    required this.decisionTimeBucket,
    required this.resultKind,
    this.runId = '',
    this.runKind = '',
    this.runOrdinal,
    this.sourceWorldId = '',
    this.sourceLessonId = '',
  });

  final int schemaVersion;
  final String recordId;
  final int createdOrder;
  final String worldId;
  final String lessonId;
  final String taskId;
  final String choiceId;
  final String expectedChoiceId;
  final bool isCorrect;
  final String errorType;
  final String repairFocusId;
  final String skillAtomId;
  final String decisionTimeBucket;
  final String resultKind;
  final String runId;
  final String runKind;
  final int? runOrdinal;
  final String sourceWorldId;
  final String sourceLessonId;

  Map<String, Object?> toPayload() {
    final payload = <String, Object?>{
      'schemaVersion': schemaVersion,
      'recordId': recordId,
      'createdOrder': createdOrder,
      'worldId': worldId,
      'lessonId': lessonId,
      'taskId': taskId,
      'choiceId': choiceId,
      'expectedChoiceId': expectedChoiceId,
      'isCorrect': isCorrect,
      'errorType': errorType,
      'repairFocusId': repairFocusId,
      'skillAtomId': skillAtomId,
      'decisionTimeBucket': decisionTimeBucket,
      'resultKind': resultKind,
    };
    if (runId.isNotEmpty) {
      payload['runId'] = runId;
    }
    if (runKind.isNotEmpty) {
      payload['runKind'] = runKind;
    }
    if (runOrdinal != null) {
      payload['runOrdinal'] = runOrdinal;
    }
    if (sourceWorldId.isNotEmpty) {
      payload['sourceWorldId'] = sourceWorldId;
    }
    if (sourceLessonId.isNotEmpty) {
      payload['sourceLessonId'] = sourceLessonId;
    }
    return payload;
  }

  static Act0LearningEvidenceRecordV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']);
    final createdOrder = _nonNegativeInt(map['createdOrder']);
    final recordId = _requiredString(map['recordId']);
    final worldId = _requiredString(map['worldId']);
    final lessonId = _requiredString(map['lessonId']);
    final taskId = _requiredString(map['taskId']);
    final choiceId = _requiredString(map['choiceId']);
    final expectedChoiceId = _requiredString(map['expectedChoiceId']);
    final errorType = _requiredString(map['errorType']);
    final skillAtomId = _requiredString(map['skillAtomId']);
    final decisionTimeBucket = _requiredString(map['decisionTimeBucket']);
    final resultKind = _requiredString(map['resultKind']);
    final isCorrect = map['isCorrect'];
    final repairFocusId = _optionalString(map['repairFocusId']);
    final runOrdinal = map.containsKey('runOrdinal')
        ? _nonNegativeInt(map['runOrdinal'])
        : null;
    final runId = _optionalString(map['runId']);
    final runKind = _optionalString(map['runKind']);
    final sourceWorldId = _optionalString(map['sourceWorldId']);
    final sourceLessonId = _optionalString(map['sourceLessonId']);
    if (schemaVersion != 1 ||
        createdOrder == null ||
        recordId == null ||
        worldId == null ||
        lessonId == null ||
        taskId == null ||
        choiceId == null ||
        expectedChoiceId == null ||
        errorType == null ||
        skillAtomId == null ||
        decisionTimeBucket == null ||
        resultKind == null ||
        isCorrect is! bool ||
        !_decisionTimeBuckets.contains(decisionTimeBucket) ||
        !_resultKinds.contains(resultKind) ||
        (isCorrect && resultKind != 'correct') ||
        (!isCorrect && resultKind == 'correct') ||
        (isCorrect && errorType != 'none')) {
      return null;
    }
    return Act0LearningEvidenceRecordV1(
      recordId: recordId,
      createdOrder: createdOrder,
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      choiceId: choiceId,
      expectedChoiceId: expectedChoiceId,
      isCorrect: isCorrect,
      errorType: errorType,
      repairFocusId: repairFocusId,
      skillAtomId: skillAtomId,
      decisionTimeBucket: decisionTimeBucket,
      resultKind: resultKind,
      runId: runId,
      runKind: runKind,
      runOrdinal: runOrdinal,
      sourceWorldId: sourceWorldId,
      sourceLessonId: sourceLessonId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0LearningEvidenceRecordV1 &&
      other.schemaVersion == schemaVersion &&
      other.recordId == recordId &&
      other.createdOrder == createdOrder &&
      other.worldId == worldId &&
      other.lessonId == lessonId &&
      other.taskId == taskId &&
      other.choiceId == choiceId &&
      other.expectedChoiceId == expectedChoiceId &&
      other.isCorrect == isCorrect &&
      other.errorType == errorType &&
      other.repairFocusId == repairFocusId &&
      other.skillAtomId == skillAtomId &&
      other.decisionTimeBucket == decisionTimeBucket &&
      other.resultKind == resultKind &&
      other.runId == runId &&
      other.runKind == runKind &&
      other.runOrdinal == runOrdinal &&
      other.sourceWorldId == sourceWorldId &&
      other.sourceLessonId == sourceLessonId;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    schemaVersion,
    recordId,
    createdOrder,
    worldId,
    lessonId,
    taskId,
    choiceId,
    expectedChoiceId,
    isCorrect,
    errorType,
    repairFocusId,
    skillAtomId,
    decisionTimeBucket,
    resultKind,
    runId,
    runKind,
    runOrdinal,
    sourceWorldId,
    sourceLessonId,
  ]);
}

class Act0LearningEvidenceRunSummaryV1 {
  const Act0LearningEvidenceRunSummaryV1({
    required this.runId,
    required this.runKind,
    required this.runOrdinal,
    required this.spotsPlayed,
    required this.correctCount,
    required this.incorrectCount,
    required this.distinctErrorTypes,
    required this.topRepairFocusId,
    required this.currentSessionOnly,
  });

  final String runId;
  final String runKind;
  final int? runOrdinal;
  final int spotsPlayed;
  final int correctCount;
  final int incorrectCount;
  final List<String> distinctErrorTypes;
  final String topRepairFocusId;
  final bool currentSessionOnly;
}

/// Learner-safe, current-run-only view model for future summary consumers.
///
/// This adapter deliberately consumes only [latestRunSummary]. It does not
/// inspect old ungrouped records, infer trends, or create Profile/Review claims.
class Act0SessionSummaryEvidenceViewModelV1 {
  const Act0SessionSummaryEvidenceViewModelV1({
    required this.hasEvidence,
    required this.title,
    required this.runId,
    required this.runKind,
    required this.spotsLine,
    required this.resultLine,
    required this.repairFocusLine,
    required this.currentSessionOnly,
  });

  final bool hasEvidence;
  final String title;
  final String runId;
  final String runKind;
  final String spotsLine;
  final String resultLine;
  final String? repairFocusLine;
  final bool currentSessionOnly;

  List<String> get claimLines {
    if (!hasEvidence) {
      return const <String>[];
    }
    return List<String>.unmodifiable(<String>[
      title,
      if (spotsLine.isNotEmpty) spotsLine,
      if (resultLine.isNotEmpty) resultLine,
      if (repairFocusLine != null && repairFocusLine!.isNotEmpty)
        repairFocusLine!,
    ]);
  }

  static Act0SessionSummaryEvidenceViewModelV1 fromHistory(
    Act0LearningEvidenceHistoryV1 history, {
    Map<String, String> repairFocusLabelsById = const <String, String>{},
  }) {
    final summary = history.latestRunSummary();
    if (summary == null || !summary.currentSessionOnly) {
      return const Act0SessionSummaryEvidenceViewModelV1(
        hasEvidence: false,
        title: 'This run',
        runId: '',
        runKind: '',
        spotsLine: '',
        resultLine: '',
        repairFocusLine: null,
        currentSessionOnly: false,
      );
    }
    final repairFocusLabel =
        repairFocusLabelsById[summary.topRepairFocusId]?.trim() ?? '';
    final safeRepairFocusLine =
        repairFocusLabel.isEmpty ||
            _containsForbiddenSummaryClaim(repairFocusLabel)
        ? null
        : 'Main repair focus: $repairFocusLabel.';
    return Act0SessionSummaryEvidenceViewModelV1(
      hasEvidence: true,
      title: 'This run',
      runId: summary.runId,
      runKind: summary.runKind,
      spotsLine:
          'You played ${summary.spotsPlayed} ${summary.spotsPlayed == 1 ? 'spot' : 'spots'}.',
      resultLine:
          '${summary.correctCount} correct / ${summary.incorrectCount} to review.',
      repairFocusLine: safeRepairFocusLine,
      currentSessionOnly: true,
    );
  }
}

class Act0LearningEvidenceHistoryV1 {
  const Act0LearningEvidenceHistoryV1({
    this.records = const <Act0LearningEvidenceRecordV1>[],
  });

  static const int maxRecords = 200;

  final List<Act0LearningEvidenceRecordV1> records;

  Act0LearningEvidenceHistoryV1 append(Act0LearningEvidenceRecordV1 record) {
    final next = <Act0LearningEvidenceRecordV1>[...records, record]
      ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
    return Act0LearningEvidenceHistoryV1(
      records: next.length <= maxRecords
          ? List<Act0LearningEvidenceRecordV1>.unmodifiable(next)
          : List<Act0LearningEvidenceRecordV1>.unmodifiable(
              next.sublist(next.length - maxRecords),
            ),
    );
  }

  /// Appends a normalized completion exactly once by its stable attempt key.
  ///
  /// Incomplete completions remain skipped; callers must not supplement them
  /// from presentation state.
  Act0LearningEvidenceHistoryV1 appendCompletedDecision(
    Act0CompletedDecisionV1 decision, {
    Act0EvidenceRunKeyV1? runKey,
  }) {
    if (records.any((record) => record.recordId == decision.attemptKey)) {
      return this;
    }
    final createdOrder =
        records.fold<int>(
          0,
          (maxOrder, record) =>
              record.createdOrder > maxOrder ? record.createdOrder : maxOrder,
        ) +
        1;
    final record = act0LearningEvidenceRecordFromCompletedDecisionV1(
      decision,
      createdOrder: createdOrder,
      runKey: runKey,
    );
    return record == null ? this : append(record);
  }

  List<Act0LearningEvidenceRecordV1> lastN(int count) {
    if (count <= 0) {
      return const <Act0LearningEvidenceRecordV1>[];
    }
    final start = records.length > count ? records.length - count : 0;
    return List<Act0LearningEvidenceRecordV1>.unmodifiable(
      records.sublist(start),
    );
  }

  List<Act0LearningEvidenceRecordV1> bySkillAtom(String skillAtomId) =>
      _whereField((record) => record.skillAtomId, skillAtomId);

  List<Act0LearningEvidenceRecordV1> byRepairFocus(String repairFocusId) =>
      _whereField((record) => record.repairFocusId, repairFocusId);

  List<Act0LearningEvidenceRecordV1> byRunId(String runId) =>
      _whereField((record) => record.runId, runId);

  List<Act0LearningEvidenceRecordV1> latestRunRecords() {
    final latestGrouped = records
        .cast<Act0LearningEvidenceRecordV1?>()
        .lastWhere(
          (record) => record?.runId.trim().isNotEmpty == true,
          orElse: () => null,
        );
    if (latestGrouped == null) {
      return const <Act0LearningEvidenceRecordV1>[];
    }
    return byRunId(latestGrouped.runId);
  }

  Act0LearningEvidenceRunSummaryV1? latestRunSummary() {
    final latest = latestRunRecords();
    if (latest.isEmpty) {
      return null;
    }
    return _runSummary(latest);
  }

  List<Act0LearningEvidenceRecordV1> mistakes() =>
      List<Act0LearningEvidenceRecordV1>.unmodifiable(
        records.where((record) => !record.isCorrect),
      );

  List<Map<String, Object?>> toPayload() =>
      records.map((record) => record.toPayload()).toList(growable: false);

  String toStorageString() => jsonEncode(toPayload());

  static Act0LearningEvidenceHistoryV1? tryParse(Object? raw) {
    if (raw is! List) {
      return null;
    }
    final records =
        raw
            .map(Act0LearningEvidenceRecordV1.tryParse)
            .whereType<Act0LearningEvidenceRecordV1>()
            .toList(growable: false)
          ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
    return Act0LearningEvidenceHistoryV1(
      records: List<Act0LearningEvidenceRecordV1>.unmodifiable(
        records.length <= maxRecords
            ? records
            : records.sublist(records.length - maxRecords),
      ),
    );
  }

  static Act0LearningEvidenceHistoryV1? tryParseStorageString(String raw) {
    try {
      return tryParse(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  List<Act0LearningEvidenceRecordV1> _whereField(
    String Function(Act0LearningEvidenceRecordV1 record) value,
    String query,
  ) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return const <Act0LearningEvidenceRecordV1>[];
    }
    return List<Act0LearningEvidenceRecordV1>.unmodifiable(
      records.where((record) => value(record) == normalized),
    );
  }

  Act0LearningEvidenceRunSummaryV1 _runSummary(
    List<Act0LearningEvidenceRecordV1> runRecords,
  ) {
    final correctCount = runRecords.where((record) => record.isCorrect).length;
    final errorTypes = <String>{};
    final repairFocusCounts = <String, int>{};
    for (final record in runRecords) {
      if (!record.isCorrect && record.errorType.trim().isNotEmpty) {
        errorTypes.add(record.errorType);
      }
      if (!record.isCorrect && record.repairFocusId.trim().isNotEmpty) {
        repairFocusCounts[record.repairFocusId] =
            (repairFocusCounts[record.repairFocusId] ?? 0) + 1;
      }
    }
    final rankedRepairFocus = repairFocusCounts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        return countCompare != 0 ? countCompare : a.key.compareTo(b.key);
      });
    final latest = runRecords.last;
    return Act0LearningEvidenceRunSummaryV1(
      runId: latest.runId,
      runKind: latest.runKind,
      runOrdinal: latest.runOrdinal,
      spotsPlayed: runRecords.length,
      correctCount: correctCount,
      incorrectCount: runRecords.length - correctCount,
      distinctErrorTypes: List<String>.unmodifiable(errorTypes),
      topRepairFocusId: rankedRepairFocus.isEmpty
          ? ''
          : rankedRepairFocus.first.key,
      currentSessionOnly: latest.runId.trim().isNotEmpty,
    );
  }
}

const Set<String> _decisionTimeBuckets = <String>{
  'under_3s',
  '3_to_10s',
  'over_10s',
  'unknown',
};

const Set<String> _resultKinds = <String>{'correct', 'incorrect', 'suboptimal'};

String? _requiredString(Object? raw) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

String _optionalString(Object? raw) => raw?.toString().trim() ?? '';

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}

bool _containsForbiddenSummaryClaim(String raw) {
  final lower = raw.toLowerCase();
  const forbiddenPhrases = <String>[
    'based on your last',
    'biggest leak',
    'weakest area',
  ];
  if (forbiddenPhrases.any(lower.contains)) {
    return true;
  }
  const forbiddenTokens = <String>{
    'ai',
    'gto',
    'leak',
    'mastered',
    'solver',
    'trend',
  };
  final tokens = RegExp(
    r'[a-z0-9]+',
  ).allMatches(lower).map((match) => match.group(0) ?? '').toSet();
  return forbiddenTokens.any(tokens.contains);
}
