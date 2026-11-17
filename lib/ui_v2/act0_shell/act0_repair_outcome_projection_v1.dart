import 'act0_authored_source_proof_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

const String act0RepairOutcomeStateAttemptedV1 = 'repair_attempted_v1';
const String act0RepairOutcomeStateCorrectV1 = 'repair_correct_v1';
const String act0RepairOutcomeStateStillNeedsRepV1 =
    'repair_still_needs_rep_v1';

class Act0RepairOutcomeProjectionV1 {
  const Act0RepairOutcomeProjectionV1({
    this.outcomes = const <Act0RepairOutcomeV1>[],
  });

  final List<Act0RepairOutcomeV1> outcomes;

  bool get hasOutcomes => outcomes.isNotEmpty;

  Act0RepairOutcomeProjectionV1 appendAnsweredTask({
    required Act0PracticeRepairQueueLaunchRequestV1? launchRequest,
    required String selectedChoiceId,
    required String correctChoiceId,
    required bool? isCorrect,
    required int sequence,
    String sessionId = '',
    String repairAttemptId = '',
    Act0RepairIntentV1? repairIntent,
  }) {
    final request = launchRequest;
    if (request == null || !request.isLaunchable) {
      return this;
    }
    if (repairAttemptId.isNotEmpty &&
        outcomes.any((outcome) => outcome.repairAttemptId == repairAttemptId)) {
      return this;
    }
    if (request.sourceType != act0PracticeRepairQueueSourceActiveRepairV1 ||
        request.targetType != act0PracticeRepairQueueTargetTypeActiveRepairV1) {
      return this;
    }
    final sourceTaskId = request.sourceTaskId.trim();
    final repairTaskId = request.repairTaskId.trim();
    final targetWorldId = request.targetWorldId.trim();
    final targetLessonId = request.targetLessonId.trim();
    final targetTaskId = request.targetTaskId.trim();
    final queueItemId = request.queueItemId.trim();
    if (sourceTaskId.isEmpty ||
        repairTaskId.isEmpty ||
        targetWorldId.isEmpty ||
        targetLessonId.isEmpty ||
        targetTaskId.isEmpty ||
        queueItemId.isEmpty) {
      return this;
    }
    final outcome = Act0RepairOutcomeV1(
      repairOccurrenceId: request.repairOccurrenceId,
      repairIntent: repairIntent,
      repairAttemptId: repairAttemptId,
      sourceTaskId: sourceTaskId,
      repairTaskId: repairTaskId,
      repairFocusKey: request.repairFocusKey.trim(),
      queueItemId: queueItemId,
      targetWorldId: targetWorldId,
      targetLessonId: targetLessonId,
      targetTaskId: targetTaskId,
      selectedChoiceId: selectedChoiceId.trim(),
      correctChoiceId: correctChoiceId.trim(),
      isCorrect: isCorrect,
      outcomeState: _outcomeStateForCorrectnessV1(isCorrect),
      sequence: sequence < 0 ? 0 : sequence,
      sourceType: request.sourceType,
      sessionId: sessionId.trim(),
    );
    final next = <Act0RepairOutcomeV1>[...outcomes, outcome]
      ..sort((a, b) {
        final sequenceCompare = a.sequence.compareTo(b.sequence);
        if (sequenceCompare != 0) {
          return sequenceCompare;
        }
        return a.queueItemId.compareTo(b.queueItemId);
      });
    return Act0RepairOutcomeProjectionV1(
      outcomes: List<Act0RepairOutcomeV1>.unmodifiable(next),
    );
  }

  List<Map<String, Object?>> toPayload() =>
      outcomes.map((outcome) => outcome.toPayload()).toList(growable: false);

  static Act0RepairOutcomeProjectionV1 tryParse(Object? raw) {
    if (raw is! List) {
      return const Act0RepairOutcomeProjectionV1();
    }
    final byIdentity = <String, Act0RepairOutcomeV1>{};
    for (final value in raw) {
      final outcome = Act0RepairOutcomeV1.tryParse(value);
      if (outcome == null) {
        continue;
      }
      final identity = outcome.repairAttemptId.isNotEmpty
          ? 'attempt|${outcome.repairAttemptId}'
          : '${outcome.sequence}|${outcome.queueItemId}';
      byIdentity[identity] = outcome;
    }
    final outcomes = byIdentity.values.toList(growable: false)
      ..sort((a, b) {
        final sequence = a.sequence.compareTo(b.sequence);
        return sequence != 0
            ? sequence
            : a.queueItemId.compareTo(b.queueItemId);
      });
    return Act0RepairOutcomeProjectionV1(
      outcomes: List<Act0RepairOutcomeV1>.unmodifiable(outcomes),
    );
  }
}

class Act0RepairOutcomeV1 {
  const Act0RepairOutcomeV1({
    this.schemaVersion = 1,
    this.repairOccurrenceId = '',
    this.repairAttemptId = '',
    this.repairIntent,
    this.repairIntentIsUnconfirmed = false,
    this.hasStoredRepairIntentPayload = false,
    this.storedRepairIntentPayload,
    required this.sourceTaskId,
    required this.repairTaskId,
    required this.repairFocusKey,
    required this.queueItemId,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.selectedChoiceId,
    required this.correctChoiceId,
    required this.isCorrect,
    required this.outcomeState,
    required this.sequence,
    required this.sourceType,
    this.sessionId = '',
  });

  final int schemaVersion;
  final String repairOccurrenceId;
  final String repairAttemptId;
  // Immutable launched-link witness; never derived from the later grade.
  final Act0RepairIntentV1? repairIntent;
  // A declared corrupt witness stays on its original event. Dropping that
  // latest event could otherwise revive an older successful repair card.
  final bool repairIntentIsUnconfirmed;
  final bool hasStoredRepairIntentPayload;
  final Object? storedRepairIntentPayload;
  final String sourceTaskId;
  final String repairTaskId;
  final String repairFocusKey;
  final String queueItemId;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String selectedChoiceId;
  final String correctChoiceId;
  final bool? isCorrect;
  final String outcomeState;
  final int sequence;
  final String sourceType;
  final String sessionId;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    if (repairOccurrenceId.isNotEmpty) 'repairOccurrenceId': repairOccurrenceId,
    if (repairAttemptId.isNotEmpty) 'repairAttemptId': repairAttemptId,
    if (hasStoredRepairIntentPayload || repairIntentIsUnconfirmed)
      'repairIntent': storedRepairIntentPayload
    else if (repairIntent != null)
      'repairIntent': repairIntent!.toPayload(),
    'sourceTaskId': sourceTaskId,
    'repairTaskId': repairTaskId,
    'repairFocusKey': repairFocusKey,
    'queueItemId': queueItemId,
    'targetWorldId': targetWorldId,
    'targetLessonId': targetLessonId,
    'targetTaskId': targetTaskId,
    'selectedChoiceId': selectedChoiceId,
    'correctChoiceId': correctChoiceId,
    'isCorrect': isCorrect,
    'outcomeState': outcomeState,
    'sequence': sequence,
    'sourceType': sourceType,
    if (sessionId.isNotEmpty) 'sessionId': sessionId,
  };

  static Act0RepairOutcomeV1? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final map = raw.cast<String, Object?>();
    final schemaVersion = _nonNegativeInt(map['schemaVersion']) ?? 1;
    final sourceTaskId = _requiredString(map, 'sourceTaskId');
    final repairTaskId = _requiredString(map, 'repairTaskId');
    final queueItemId = _requiredString(map, 'queueItemId');
    final targetWorldId = _requiredString(map, 'targetWorldId');
    final targetLessonId = _requiredString(map, 'targetLessonId');
    final targetTaskId = _requiredString(map, 'targetTaskId');
    final outcomeState = _requiredString(map, 'outcomeState');
    final sequence = _nonNegativeInt(map['sequence']);
    final sourceType = _requiredString(map, 'sourceType');
    final correctness = map['isCorrect'];
    final rawRepairIntent = map['repairIntent'];
    final repairIntent = rawRepairIntent == null
        ? null
        : Act0RepairIntentV1.tryParse(rawRepairIntent);
    if (schemaVersion != 1 ||
        sourceTaskId == null ||
        repairTaskId == null ||
        queueItemId == null ||
        targetWorldId == null ||
        targetLessonId == null ||
        targetTaskId == null ||
        outcomeState == null ||
        sequence == null ||
        sourceType != act0PracticeRepairQueueSourceActiveRepairV1 ||
        (correctness != null && correctness is! bool) ||
        outcomeState != _outcomeStateForCorrectnessV1(correctness as bool?)) {
      return null;
    }
    return Act0RepairOutcomeV1(
      repairOccurrenceId: map['repairOccurrenceId']?.toString().trim() ?? '',
      repairAttemptId: map['repairAttemptId']?.toString().trim() ?? '',
      repairIntent: repairIntent,
      repairIntentIsUnconfirmed:
          map.containsKey('repairIntent') &&
          (repairIntent == null || repairIntent.relationRevision < 0),
      hasStoredRepairIntentPayload: map.containsKey('repairIntent'),
      storedRepairIntentPayload: rawRepairIntent,
      sourceTaskId: sourceTaskId,
      repairTaskId: repairTaskId,
      repairFocusKey: map['repairFocusKey']?.toString().trim() ?? '',
      queueItemId: queueItemId,
      targetWorldId: targetWorldId,
      targetLessonId: targetLessonId,
      targetTaskId: targetTaskId,
      selectedChoiceId: map['selectedChoiceId']?.toString().trim() ?? '',
      correctChoiceId: map['correctChoiceId']?.toString().trim() ?? '',
      isCorrect: correctness,
      outcomeState: outcomeState,
      sequence: sequence,
      sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
      sessionId: map['sessionId']?.toString().trim() ?? '',
    );
  }
}

/// Current-card boundary only. It never removes historical banked repair proof.
/// Only the source or a declared target's actual repair run can cap this view;
/// ordinary practice on the target remains its own activity.
bool act0RepairCurrentViewHasUnconfirmedLaterSourceAttemptV1({
  required Act0RepairIntentV1 intent,
  required Act0RepairOutcomeV1 outcome,
  required Act0LearningEvidenceHistoryV1 learningEvidence,
  required Act0RepairFingerprintResolverV1 currentFingerprintForIdentity,
}) {
  if (!act0RepairGoalOutcomeIsEligibleV1(
    intent: intent,
    outcome: outcome,
    learningEvidence: learningEvidence,
    currentFingerprintForIdentity: currentFingerprintForIdentity,
  ))
    return true;
  final provenance = [
    ...learningEvidence.sourceAnchors,
    ...learningEvidence.records,
  ];
  final repairs = act0RepairEvidenceRecordsForIdV1(
    learningEvidence,
    outcome.repairAttemptId,
  );
  if (repairs.length != 1) return true;
  final sourceFingerprint = currentFingerprintForIdentity(
    worldId: intent.sourceWorldId,
    lessonId: intent.sourceLessonId,
    taskId: intent.sourceTaskId,
  );
  if (sourceFingerprint == null || sourceFingerprint.isEmpty) return true;
  final targetFingerprint = currentFingerprintForIdentity(
    worldId: intent.targetWorldId,
    lessonId: intent.targetLessonId,
    taskId: intent.targetTaskId,
  );
  for (final record in provenance) {
    if (record.createdOrder <= repairs.single.createdOrder ||
        record.isPlacementAssessment ||
        record.isDiagnosticLearningEntry)
      continue;
    final isSource =
        record.worldId == intent.sourceWorldId &&
        record.lessonId == intent.sourceLessonId &&
        record.taskId == intent.sourceTaskId &&
        record.authoredSourceFingerprint == sourceFingerprint;
    final isTargetRepair =
        record.runKind == 'repair' &&
        record.worldId == intent.targetWorldId &&
        record.lessonId == intent.targetLessonId &&
        record.taskId == intent.targetTaskId &&
        record.authoredSourceFingerprint == targetFingerprint;
    if (!isSource && !isTargetRepair) continue;
    if (act0RepairEvidenceRecordsForIdV1(
          learningEvidence,
          record.recordId,
        ).length !=
        1) {
      return true;
    }
    final proof = act0CurrentAuthoredSourceProofV1(record);
    if (record.sourceTaskId != record.taskId ||
        record.runId.isEmpty ||
        record.sessionId.isEmpty ||
        (record.runOrdinal ?? 0) <= 0 ||
        proof == null ||
        proof.fingerprint !=
            (isSource ? sourceFingerprint : targetFingerprint) ||
        record.assistanceKind.name != 'none' ||
        record.isCorrect != proof.isCurrentlyCorrect ||
        !proof.isCurrentlyCorrect)
      return true;
  }
  return false;
}

String _outcomeStateForCorrectnessV1(bool? isCorrect) {
  if (isCorrect == true) {
    return act0RepairOutcomeStateCorrectV1;
  }
  if (isCorrect == false) {
    return act0RepairOutcomeStateStillNeedsRepV1;
  }
  return act0RepairOutcomeStateAttemptedV1;
}

String? _requiredString(Map<String, Object?> map, String key) {
  final value = map[key]?.toString().trim() ?? '';
  return value.isEmpty ? null : value;
}

int? _nonNegativeInt(Object? raw) {
  final value = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  return value == null || value < 0 ? null : value;
}
