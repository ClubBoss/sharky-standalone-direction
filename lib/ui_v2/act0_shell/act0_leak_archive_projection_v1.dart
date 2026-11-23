import '../../models/poker_street.dart';
import 'act0_attempt_archive_v1.dart';
import 'act0_authored_source_proof_v1.dart';
import 'act0_completed_decision_contract_v1.dart';
import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_leak_dashboard_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_shell_state_v1.dart';
import 'act0_w14_skill_state_v1.dart';

typedef _TaskKey = (String, String, String);

_TaskKey _key(Act0LearningEvidenceRecordV1 record) =>
    (record.worldId, record.lessonId, record.taskId);

bool _isLearningAnswer(Act0LearningEvidenceRecordV1 record) =>
    !record.isPlacementAssessment && !record.isDiagnosticLearningEntry;

Act0LeakDashboardV1 act0LeakDashboardFromArchiveV1({
  required Act0AttemptArchiveV1 archive,
  required Act0LearningEvidenceHistoryV1 history,
  required List<Act0WorldCardV1> worlds,
  required DateTime nowUtc,
  required Iterable<Act0LeakPracticeTargetV1> Function(
    Act0LearningEvidenceRecordV1 miss,
  )
  reviewRepairsForMiss,
  required Iterable<Act0LeakPracticeTargetV1> Function() dailyPracticeTargets,
  int minimumAttempts = 8,
}) {
  final archived = {
    for (final attempt in archive.attempts) attempt.id: attempt,
  };
  // Earlier facts can disqualify a repeat even when the first answer was
  // deleted from the archive or aged out. They never add to its counts.
  final earlierByTask = <_TaskKey, Act0LearningEvidenceRecordV1>{};
  for (final record in [
    ...history.provenanceRecords,
    ...archive.attempts.map((attempt) => attempt.evidence),
  ]) {
    if (!_isLearningAnswer(record)) continue;
    final key = _key(record);
    final previous = earlierByTask[key];
    if (previous == null || record.createdOrder < previous.createdOrder) {
      earlierByTask[key] = record;
    }
  }
  final tasks = {
    for (final world in worlds)
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          (world.worldId, lesson.lessonId, task.taskId): task,
  };
  final fingerprints = <_TaskKey, String?>{};
  bool matchesCurrentTask(Act0LearningEvidenceRecordV1 record) {
    final key = _key(record);
    final task = tasks[key];
    return task != null &&
        fingerprints.putIfAbsent(
              key,
              () => act0AuthoredSourceFingerprintV1(
                worldId: record.worldId,
                lessonId: record.lessonId,
                task: task,
              ),
            ) ==
            record.authoredSourceFingerprint;
  }

  late final dailyTargets = dailyPracticeTargets().toList();
  Iterable<Act0LeakPracticeTargetV1> targetsForMiss(String id) sync* {
    final miss = archived[id]!.evidence;
    if (!matchesCurrentTask(miss)) return;
    yield* reviewRepairsForMiss(miss);
    yield* dailyTargets.where(
      (target) =>
          (target.worldId, target.lessonId, target.sourceTaskId) == _key(miss),
    );
  }

  return Act0LeakDashboardV1.aggregate(
    nowUtc: nowUtc,
    minimumAttempts: minimumAttempts,
    observations: [
      for (final attempt in archive.attempts)
        if (_isLearningAnswer(attempt.evidence))
          _observation(
            attempt,
            earlierByTask[_key(attempt.evidence)]!.recordId ==
                attempt.evidence.recordId,
            matchesCurrentTask(attempt.evidence)
                ? tasks[_key(attempt.evidence)]
                : null,
          ),
    ],
    practiceForMiss: targetsForMiss,
  );
}

Act0LeakObservationV1 _observation(
  Act0ArchivedAttemptV1 attempt,
  bool earliest,
  Act0LessonTaskV1? task,
) {
  final record = attempt.evidence;
  final kind = switch (record.reviewKind) {
    Act0ReviewKindV1.initialAssessment || Act0ReviewKindV1.unseenTransfer
        when earliest =>
      record.assistanceKind == Act0DecisionAssistanceV1.none &&
              task?.guidedDecision != true
          ? Act0LeakAttemptKindV1.firstIndependent
          : Act0LeakAttemptKindV1.unclassified,
    Act0ReviewKindV1.legacyUnspaced when earliest =>
      Act0LeakAttemptKindV1.unclassified,
    _ => Act0LeakAttemptKindV1.repeat,
  };

  final table = task?.runner.table;
  final hasSpot =
      table != null &&
      table.scope != Act0TableScopeV1.orientation &&
      table.scope != Act0TableScopeV1.explanation &&
      (attempt.tableFingerprint == null ||
          attempt.tableFingerprint == act0ReplayTableFingerprintV1(table));
  final street = hasSpot ? table.streetLabel.trim().toLowerCase() : null;
  final position = hasSpot
      ? table.seats
            .where(
              (seat) => table.heroSeatId == null
                  ? seat.isHero
                  : seat.seatId == table.heroSeatId,
            )
            .singleOrNull
            ?.seatLabel
            .trim()
            .toUpperCase()
      : null;
  final concept = [
    record.conceptFamilyId,
    record.repairFocusId,
    record.skillAtomId,
  ].where((id) => id.isNotEmpty && id != 'none' && id != 'unknown').firstOrNull;
  return (
    id: record.recordId,
    recordedAt: record.recordedAtUtc!,
    kind: kind,
    correct: record.isCorrect,
    buckets: {
      (Act0LeakDimensionV1.world, record.worldId),
      if (concept != null) (Act0LeakDimensionV1.concept, concept),
      if (task != null)
        for (final skill in act0SkillsForTaskV1(record.lessonId, task.taskId))
          (Act0LeakDimensionV1.skill, skill),
      if (hasSpot && table.canonicalSeatOrder.contains(position))
        (Act0LeakDimensionV1.position, position!),
      if (PokerStreet.values.any((value) => value.name == street))
        (Act0LeakDimensionV1.street, street!),
    },
  );
}
