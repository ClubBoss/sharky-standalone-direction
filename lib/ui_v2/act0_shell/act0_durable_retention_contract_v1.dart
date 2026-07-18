import 'dart:convert';

import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';

class Act0DurableRetentionHistoryV1 {
  const Act0DurableRetentionHistoryV1({
    this.families = const <Act0DurableRetentionFamilyV1>[],
  });

  final List<Act0DurableRetentionFamilyV1> families;

  Act0DurableRetentionFamilyV1? familyById(String conceptFamilyId) {
    final id = conceptFamilyId.trim();
    for (final family in families) {
      if (family.conceptFamilyId == id) {
        return family;
      }
    }
    return null;
  }

  factory Act0DurableRetentionHistoryV1.fromLearningEvidence(
    Act0LearningEvidenceHistoryV1 history,
  ) {
    var result = const Act0DurableRetentionHistoryV1();
    for (final record in history.records) {
      result = result.applyEvidence(record);
    }
    return result;
  }

  Act0DurableRetentionHistoryV1 applyEvidence(
    Act0LearningEvidenceRecordV1 record,
  ) {
    final conceptFamilyId = act0ConceptFamilyIdForDurableEvidenceV1(record);
    if (conceptFamilyId.isEmpty || conceptFamilyId == 'none') {
      return this;
    }
    final current = familyById(conceptFamilyId);
    final next = record.recordedAtUtc == null
        ? (current ?? Act0DurableRetentionFamilyV1.empty(conceptFamilyId))
              .applyLegacy(record)
        : (current ?? Act0DurableRetentionFamilyV1.empty(conceptFamilyId))
              .applyTimestamped(record);
    final updated = <Act0DurableRetentionFamilyV1>[
      for (final family in families)
        if (family.conceptFamilyId != conceptFamilyId) family,
      next,
    ]..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0DurableRetentionHistoryV1(
      families: List<Act0DurableRetentionFamilyV1>.unmodifiable(updated),
    );
  }

  Act0DurableRetentionHistoryV1 refreshedAt(DateTime nowUtc) {
    final now = nowUtc.toUtc();
    return Act0DurableRetentionHistoryV1(
      families: List<Act0DurableRetentionFamilyV1>.unmodifiable(
        families.map((family) => family.refreshedAt(now)).toList()
          ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId)),
      ),
    );
  }

  List<Act0DueReviewItemV1> dueItemsAt(DateTime nowUtc) {
    final due = <Act0DueReviewItemV1>[];
    for (final family in families) {
      final refreshed = family.refreshedAt(nowUtc);
      if (refreshed.retentionState != Act0RetentionStateV1.due ||
          refreshed.nextDueAtUtc == null ||
          refreshed.sourceTaskId.isEmpty) {
        continue;
      }
      due.add(
        Act0DueReviewItemV1(
          conceptFamilyId: refreshed.conceptFamilyId,
          worldId: refreshed.worldId,
          lessonId: refreshed.sourceLessonId,
          taskId: refreshed.sourceTaskId,
          nextDueAtUtc: refreshed.nextDueAtUtc!,
          repeatedMissCount: refreshed.incorrectCount,
          lapseCount: refreshed.lapseCount,
        ),
      );
    }
    due.sort(_compareDueItems);
    return List<Act0DueReviewItemV1>.unmodifiable(due);
  }

  List<Map<String, Object?>> toPayload() =>
      families.map((family) => family.toPayload()).toList(growable: false);

  String toStorageString() => jsonEncode(toPayload());

  static Act0DurableRetentionHistoryV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0DurableRetentionHistoryV1();
    }
    final byConcept = <String, Act0DurableRetentionFamilyV1>{};
    for (final value in raw) {
      final family = Act0DurableRetentionFamilyV1.tryParse(value);
      if (family == null) {
        continue;
      }
      final existing = byConcept[family.conceptFamilyId];
      if (existing == null ||
          family.lastCreatedOrder >= existing.lastCreatedOrder) {
        byConcept[family.conceptFamilyId] = family;
      }
    }
    final families = byConcept.values.toList()
      ..sort((a, b) => a.conceptFamilyId.compareTo(b.conceptFamilyId));
    return Act0DurableRetentionHistoryV1(
      families: List<Act0DurableRetentionFamilyV1>.unmodifiable(families),
    );
  }
}

class Act0DurableRetentionFamilyV1 {
  const Act0DurableRetentionFamilyV1({
    this.schemaVersion = 1,
    required this.conceptFamilyId,
    required this.worldId,
    required this.sourceLessonId,
    required this.sourceTaskId,
    required this.retentionState,
    required this.nextDueAtUtc,
    required this.lastSpacedReviewAtUtc,
    required this.spacedSuccessStage,
    required this.lapseCount,
    required this.incorrectCount,
    required this.correctCount,
    required this.lastRecordedAtUtc,
    required this.lastCreatedOrder,
    required this.lastSessionId,
    required this.lastReviewKind,
    required this.hasLegacyUnspacedEvidence,
  });

  factory Act0DurableRetentionFamilyV1.empty(String conceptFamilyId) =>
      Act0DurableRetentionFamilyV1(
        conceptFamilyId: conceptFamilyId.trim(),
        worldId: '',
        sourceLessonId: '',
        sourceTaskId: '',
        retentionState: Act0RetentionStateV1.unseen,
        nextDueAtUtc: null,
        lastSpacedReviewAtUtc: null,
        spacedSuccessStage: 0,
        lapseCount: 0,
        incorrectCount: 0,
        correctCount: 0,
        lastRecordedAtUtc: null,
        lastCreatedOrder: -1,
        lastSessionId: '',
        lastReviewKind: Act0ReviewKindV1.legacyUnspaced,
        hasLegacyUnspacedEvidence: false,
      );

  final int schemaVersion;
  final String conceptFamilyId;
  final String worldId;
  final String sourceLessonId;
  final String sourceTaskId;
  final Act0RetentionStateV1 retentionState;
  final DateTime? nextDueAtUtc;
  final DateTime? lastSpacedReviewAtUtc;
  final int spacedSuccessStage;
  final int lapseCount;
  final int incorrectCount;
  final int correctCount;
  final DateTime? lastRecordedAtUtc;
  final int lastCreatedOrder;
  final String lastSessionId;
  final Act0ReviewKindV1 lastReviewKind;
  final bool hasLegacyUnspacedEvidence;

  bool get hasRetentionDebt =>
      incorrectCount > 0 && retentionState != Act0RetentionStateV1.unseen;

  Act0DurableRetentionFamilyV1 refreshedAt(DateTime nowUtc) {
    final due = nextDueAtUtc;
    if (due == null || nowUtc.toUtc().isBefore(due)) {
      return this;
    }
    if (retentionState == Act0RetentionStateV1.recoveredPendingSpacedReview ||
        retentionState == Act0RetentionStateV1.durable ||
        retentionState == Act0RetentionStateV1.lapsed) {
      return _copyWith(retentionState: Act0RetentionStateV1.due);
    }
    return this;
  }

  Act0DurableRetentionFamilyV1 applyLegacy(
    Act0LearningEvidenceRecordV1 record,
  ) {
    final latest = record.createdOrder >= lastCreatedOrder;
    return _copyWith(
      worldId: _prefer(record.worldId, worldId),
      sourceLessonId: latest
          ? _prefer(record.lessonId, sourceLessonId)
          : sourceLessonId,
      sourceTaskId: latest
          ? _prefer(
              record.sourceTaskId.isEmpty ? record.taskId : record.sourceTaskId,
              sourceTaskId,
            )
          : sourceTaskId,
      retentionState: !record.isCorrect && latest
          ? Act0RetentionStateV1.needsRepair
          : retentionState,
      incorrectCount: incorrectCount + (record.isCorrect ? 0 : 1),
      correctCount: correctCount + (record.isCorrect ? 1 : 0),
      lastCreatedOrder: latest ? record.createdOrder : lastCreatedOrder,
      lastSessionId: latest ? record.sessionId : lastSessionId,
      lastReviewKind: latest ? record.reviewKind : lastReviewKind,
      hasLegacyUnspacedEvidence: true,
    );
  }

  Act0DurableRetentionFamilyV1 applyTimestamped(
    Act0LearningEvidenceRecordV1 record,
  ) {
    final recordedAt = record.recordedAtUtc!.toUtc();
    final currentAtAttempt = refreshedAt(recordedAt);
    final dueEligible =
        currentAtAttempt.nextDueAtUtc != null &&
        !recordedAt.isBefore(currentAtAttempt.nextDueAtUtc!) &&
        record.reviewKind != Act0ReviewKindV1.immediateRepair &&
        record.reviewKind != Act0ReviewKindV1.exactReplay;
    final priorDebt = currentAtAttempt.incorrectCount > 0;
    var state = currentAtAttempt.retentionState;
    var nextDue = currentAtAttempt.nextDueAtUtc;
    var lastSpaced = currentAtAttempt.lastSpacedReviewAtUtc;
    var stage = currentAtAttempt.spacedSuccessStage;
    var lapses = currentAtAttempt.lapseCount;

    if (!record.isCorrect) {
      if (dueEligible ||
          state == Act0RetentionStateV1.durable ||
          state == Act0RetentionStateV1.due ||
          stage > 0) {
        state = Act0RetentionStateV1.lapsed;
        nextDue = recordedAt.add(Act0DurableLearningTimingV1.lapseToReview);
        stage = 0;
        lapses += 1;
      } else {
        state = Act0RetentionStateV1.needsRepair;
        nextDue = null;
        stage = 0;
      }
    } else if (dueEligible) {
      stage = (stage + 1).clamp(
        0,
        Act0DurableLearningTimingV1.durableSpacedSuccesses,
      );
      lastSpaced = recordedAt;
      if (stage >= Act0DurableLearningTimingV1.durableSpacedSuccesses) {
        state = Act0RetentionStateV1.durable;
        nextDue = recordedAt.add(
          Act0DurableLearningTimingV1.durableMaintenance,
        );
      } else {
        state = Act0RetentionStateV1.recoveredPendingSpacedReview;
        nextDue = recordedAt.add(
          Act0DurableLearningTimingV1.firstToSecondReview,
        );
      }
    } else if (priorDebt) {
      state = Act0RetentionStateV1.recoveredPendingSpacedReview;
      nextDue = recordedAt.add(
        Act0DurableLearningTimingV1.recoveryToFirstReview,
      );
      stage = 0;
    }

    return Act0DurableRetentionFamilyV1(
      conceptFamilyId: conceptFamilyId,
      worldId: _prefer(record.worldId, worldId),
      sourceLessonId: _prefer(record.lessonId, sourceLessonId),
      sourceTaskId: _prefer(
        record.sourceTaskId.isEmpty ? record.taskId : record.sourceTaskId,
        sourceTaskId,
      ),
      retentionState: state,
      nextDueAtUtc: nextDue,
      lastSpacedReviewAtUtc: lastSpaced,
      spacedSuccessStage: stage,
      lapseCount: lapses,
      incorrectCount:
          currentAtAttempt.incorrectCount + (record.isCorrect ? 0 : 1),
      correctCount: currentAtAttempt.correctCount + (record.isCorrect ? 1 : 0),
      lastRecordedAtUtc: recordedAt,
      lastCreatedOrder: record.createdOrder,
      lastSessionId: record.sessionId,
      lastReviewKind: record.reviewKind,
      hasLegacyUnspacedEvidence: hasLegacyUnspacedEvidence,
    );
  }

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'conceptFamilyId': conceptFamilyId,
    'worldId': worldId,
    'sourceLessonId': sourceLessonId,
    'sourceTaskId': sourceTaskId,
    'retentionState': retentionState.name,
    if (nextDueAtUtc != null)
      'nextDueAtUtc': act0UtcStorageStringV1(nextDueAtUtc!),
    if (lastSpacedReviewAtUtc != null)
      'lastSpacedReviewAtUtc': act0UtcStorageStringV1(lastSpacedReviewAtUtc!),
    'spacedSuccessStage': spacedSuccessStage,
    'lapseCount': lapseCount,
    'incorrectCount': incorrectCount,
    'correctCount': correctCount,
    if (lastRecordedAtUtc != null)
      'lastRecordedAtUtc': act0UtcStorageStringV1(lastRecordedAtUtc!),
    'lastCreatedOrder': lastCreatedOrder,
    'lastSessionId': lastSessionId,
    'lastReviewKind': lastReviewKind.name,
    'hasLegacyUnspacedEvidence': hasLegacyUnspacedEvidence,
  };

  static Act0DurableRetentionFamilyV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<Object?, Object?>();
    final schemaVersion = _int(map['schemaVersion']);
    final conceptFamilyId = _string(map['conceptFamilyId']);
    final retentionState = act0EnumByNameV1(
      Act0RetentionStateV1.values,
      map['retentionState'],
    );
    final lastReviewKind = act0EnumByNameV1(
      Act0ReviewKindV1.values,
      map['lastReviewKind'],
    );
    final spacedSuccessStage = _int(map['spacedSuccessStage']);
    final lapseCount = _int(map['lapseCount']);
    final incorrectCount = _int(map['incorrectCount']);
    final correctCount = _int(map['correctCount']);
    final lastCreatedOrder = _int(
      map['lastCreatedOrder'],
      allowNegativeOne: true,
    );
    if (schemaVersion != 1 ||
        conceptFamilyId.isEmpty ||
        retentionState == null ||
        lastReviewKind == null ||
        spacedSuccessStage == null ||
        lapseCount == null ||
        incorrectCount == null ||
        correctCount == null ||
        lastCreatedOrder == null ||
        spacedSuccessStage >
            Act0DurableLearningTimingV1.durableSpacedSuccesses) {
      return null;
    }
    return Act0DurableRetentionFamilyV1(
      conceptFamilyId: conceptFamilyId,
      worldId: _string(map['worldId']),
      sourceLessonId: _string(map['sourceLessonId']),
      sourceTaskId: _string(map['sourceTaskId']),
      retentionState: retentionState,
      nextDueAtUtc: act0TryParseUtcV1(map['nextDueAtUtc']),
      lastSpacedReviewAtUtc: act0TryParseUtcV1(map['lastSpacedReviewAtUtc']),
      spacedSuccessStage: spacedSuccessStage,
      lapseCount: lapseCount,
      incorrectCount: incorrectCount,
      correctCount: correctCount,
      lastRecordedAtUtc: act0TryParseUtcV1(map['lastRecordedAtUtc']),
      lastCreatedOrder: lastCreatedOrder,
      lastSessionId: _string(map['lastSessionId']),
      lastReviewKind: lastReviewKind,
      hasLegacyUnspacedEvidence: map['hasLegacyUnspacedEvidence'] == true,
    );
  }

  Act0DurableRetentionFamilyV1 _copyWith({
    String? worldId,
    String? sourceLessonId,
    String? sourceTaskId,
    Act0RetentionStateV1? retentionState,
    DateTime? nextDueAtUtc,
    bool clearNextDueAtUtc = false,
    DateTime? lastSpacedReviewAtUtc,
    int? spacedSuccessStage,
    int? lapseCount,
    int? incorrectCount,
    int? correctCount,
    DateTime? lastRecordedAtUtc,
    int? lastCreatedOrder,
    String? lastSessionId,
    Act0ReviewKindV1? lastReviewKind,
    bool? hasLegacyUnspacedEvidence,
  }) {
    return Act0DurableRetentionFamilyV1(
      conceptFamilyId: conceptFamilyId,
      worldId: worldId ?? this.worldId,
      sourceLessonId: sourceLessonId ?? this.sourceLessonId,
      sourceTaskId: sourceTaskId ?? this.sourceTaskId,
      retentionState: retentionState ?? this.retentionState,
      nextDueAtUtc: clearNextDueAtUtc
          ? null
          : nextDueAtUtc ?? this.nextDueAtUtc,
      lastSpacedReviewAtUtc:
          lastSpacedReviewAtUtc ?? this.lastSpacedReviewAtUtc,
      spacedSuccessStage: spacedSuccessStage ?? this.spacedSuccessStage,
      lapseCount: lapseCount ?? this.lapseCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      correctCount: correctCount ?? this.correctCount,
      lastRecordedAtUtc: lastRecordedAtUtc ?? this.lastRecordedAtUtc,
      lastCreatedOrder: lastCreatedOrder ?? this.lastCreatedOrder,
      lastSessionId: lastSessionId ?? this.lastSessionId,
      lastReviewKind: lastReviewKind ?? this.lastReviewKind,
      hasLegacyUnspacedEvidence:
          hasLegacyUnspacedEvidence ?? this.hasLegacyUnspacedEvidence,
    );
  }
}

class Act0DueReviewItemV1 {
  const Act0DueReviewItemV1({
    required this.conceptFamilyId,
    required this.worldId,
    required this.lessonId,
    required this.taskId,
    required this.nextDueAtUtc,
    required this.repeatedMissCount,
    required this.lapseCount,
  });

  final String conceptFamilyId;
  final String worldId;
  final String lessonId;
  final String taskId;
  final DateTime nextDueAtUtc;
  final int repeatedMissCount;
  final int lapseCount;
}

int _compareDueItems(Act0DueReviewItemV1 a, Act0DueReviewItemV1 b) {
  final due = a.nextDueAtUtc.compareTo(b.nextDueAtUtc);
  if (due != 0) {
    return due;
  }
  final severity = (b.repeatedMissCount + b.lapseCount).compareTo(
    a.repeatedMissCount + a.lapseCount,
  );
  if (severity != 0) {
    return severity;
  }
  final concept = a.conceptFamilyId.compareTo(b.conceptFamilyId);
  return concept != 0 ? concept : a.taskId.compareTo(b.taskId);
}

String act0ConceptFamilyIdForDurableEvidenceV1(
  Act0LearningEvidenceRecordV1 record,
) {
  for (final value in <String>[
    record.conceptFamilyId,
    record.repairFocusId,
    record.skillAtomId,
    record.errorType,
  ]) {
    final normalized = value.trim();
    if (normalized.isNotEmpty && normalized != 'none') {
      return normalized;
    }
  }
  return '';
}

String _prefer(String candidate, String fallback) {
  final value = candidate.trim();
  return value.isEmpty ? fallback : value;
}

String _string(Object? raw) => raw?.toString().trim() ?? '';

int? _int(Object? raw, {bool allowNegativeOne = false}) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  final minimum = allowNegativeOne ? -1 : 0;
  return value == null || value < minimum ? null : value;
}
