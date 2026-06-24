import 'dart:convert';

/// Evidence-only record for a completed Act0 decision.
///
/// This contract deliberately has no learner-facing interpretation fields.
/// Persistence and UI consumption are separate, future decisions.
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

  Map<String, Object?> toPayload() => <String, Object?>{
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
      other.resultKind == resultKind;

  @override
  int get hashCode => Object.hash(
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
  );
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
