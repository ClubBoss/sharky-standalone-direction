import 'act0_authored_source_proof_v1.dart';
import 'act0_completed_decision_contract_v1.dart';
import 'act0_durable_learning_time_contract_v1.dart';
import 'act0_durable_retention_contract_v1.dart';
import 'act0_learning_evidence_contract_v1.dart';
import 'act0_learning_transfer_measurement_v1.dart';
import 'act0_repair_outcome_projection_v1.dart';
import 'act0_telemetry_sink_v1.dart';

/// Read-only diagnostics AFTER the source owner accepts a completed record.
/// No input comes from a telemetry log; no projection is written back to grade,
/// progress, evidence, repair or retention state. Exact UTC values stay local.
List<Act0TelemetryEventV1> act0EvidenceTelemetryEventsV1({
  required Act0LearningEvidenceRecordV1 record,
  required Act0LearningEvidenceHistoryV1 history,
  required DateTime nowUtc,
  String repairOccurrenceId = '',
}) {
  final matches = [
    ...history.sourceAnchors,
    ...history.records,
  ].where((r) => r.recordId == record.recordId).toList();
  if (matches.isEmpty || matches.any((r) => r != record)) {
    return [
      _event('evidence_lineage_unavailable', {
        'evidence_status': 'insufficient_evidence',
        'reason': 'missing_or_conflicting_record',
      }),
    ];
  }
  final proof = act0CurrentAuthoredSourceProofV1(record);
  final recent = act0RecentAuthoredEvidenceV1(history, nowUtc: nowUtc);
  final familyId = proof?.conceptFamilyId ?? '';
  final epoch = recent.families[familyId] ?? const [];
  final index = epoch.indexWhere((r) => r.recordId == record.recordId);
  final inEpoch = index >= 0;
  final previous = index > 0 ? epoch[index - 1] : null;
  final linked =
      inEpoch && record.runId.isNotEmpty && record.sessionId.isNotEmpty;
  final common = <String, Object?>{
    'attempt_id': record.recordId,
    'created_order': record.createdOrder,
    if (record.runId.isNotEmpty) 'run_id': record.runId,
    if (record.runKind.isNotEmpty) 'run_kind': record.runKind,
    if (record.runOrdinal != null) 'run_ordinal': record.runOrdinal,
    if (record.sessionId.isNotEmpty) 'session_id': record.sessionId,
    'world_id': record.worldId,
    'lesson_id': record.lessonId,
    'task_id': record.taskId,
    if (record.sourceTaskId.isNotEmpty) 'source_task_id': record.sourceTaskId,
    if (record.authoredSourceFingerprint.isNotEmpty)
      'source_fingerprint': record.authoredSourceFingerprint,
    if (familyId.isNotEmpty) 'concept_family_id': familyId,
    'source_current': proof != null,
    'history_lineage_complete': history.hasCompleteLineage,
    'evidence_status': linked ? 'source_linked' : 'insufficient_evidence',
    'source_surface': 'act0_completed_evidence',
  };
  final signal = Act0LearningTransferMeasurementV1.fromLearningEvidence(
    history,
    nowUtc: nowUtc,
  ).signalForConcept(familyId);
  Act0LearningEvidenceRecordV1? reference(
    int? order,
    String task,
    String session,
  ) {
    final rows = epoch
        .where(
          (r) =>
              r.createdOrder == order &&
              r.taskId == task &&
              r.sessionId == session,
        )
        .toList();
    return rows.length == 1 ? rows.single : null;
  }

  final baseline = reference(
    signal.baselineOrder,
    signal.baselineTaskId,
    signal.baselineSessionId,
  );
  final comparison = reference(
    signal.comparisonOrder,
    signal.comparisonTaskId,
    signal.comparisonSessionId,
  );
  final retention = Act0DurableRetentionHistoryV1.fromCurrentAuthoredEvidence(
    history,
    nowUtc: nowUtc,
  ).familyById(familyId);
  return List.unmodifiable([
    _event('decision_evidence_recorded', {
      ...common,
      'chosen_action': record.choiceId,
      'expected_action': record.expectedChoiceId,
      'correct': record.isCorrect,
      'error_type': record.errorType,
      'assistance_kind': record.assistanceKind.name,
      'review_kind': record.reviewKind.name,
      'decisionTimeBucket': record.decisionTimeBucket,
      if (repairOccurrenceId.isNotEmpty)
        'repair_occurrence_id': repairOccurrenceId,
    }),
    _event('transfer_evaluated', {
      ...common,
      'relationship': signal.relationship,
      'transfer_verdict': signal.verdict,
      'eligible_evidence_count': signal.eligibleEvidenceCount,
      if (baseline != null) 'baseline_attempt_id': baseline.recordId,
      if (baseline != null) 'baseline_session_id': baseline.sessionId,
      if (comparison != null) 'comparison_attempt_id': comparison.recordId,
      if (comparison != null) 'comparison_session_id': comparison.sessionId,
    }),
    _event('elapsed_learning_observed', {
      ...common,
      'elapsed_basis': 'recent_source_epoch',
      'elapsed_bucket': _elapsedBucket(
        previous?.recordedAtUtc,
        inEpoch ? record.recordedAtUtc : null,
      ),
      if (previous != null) 'previous_attempt_id': previous.recordId,
      if (previous != null) 'previous_session_id': previous.sessionId,
      'retention_state': retention?.retentionState.name ?? 'unseen',
    }),
  ]);
}

/// Projects an already accepted occurrence-bound repair outcome. A correct
/// answer alone is not a resolution receipt or independent repair proof.
Act0TelemetryEventV1 act0RepairOutcomeTelemetryEventV1({
  required Act0RepairOutcomeV1 outcome,
  required Act0LearningEvidenceHistoryV1 history,
}) {
  Act0LearningEvidenceRecordV1? find(String id) {
    final rows = [
      ...history.sourceAnchors,
      ...history.records,
    ].where((r) => r.recordId == id).toList();
    return id.isNotEmpty &&
            rows.isNotEmpty &&
            rows.every((r) => r == rows.first)
        ? rows.first
        : null;
  }

  final source = find(outcome.repairOccurrenceId);
  final attempt = find(outcome.repairAttemptId);
  final linked =
      source != null &&
      attempt != null &&
      source.taskId == outcome.sourceTaskId &&
      attempt.taskId == outcome.repairTaskId &&
      source.sessionId.isNotEmpty &&
      attempt.runId.isNotEmpty &&
      !source.isCorrect &&
      act0CurrentAuthoredSourceProofV1(source) != null &&
      act0CurrentAuthoredSourceProofV1(attempt) != null &&
      attempt.sessionId == outcome.sessionId &&
      attempt.isCorrect == outcome.isCorrect &&
      source.createdOrder < attempt.createdOrder;
  return _event('repair_outcome_recorded', {
    'evidence_status': linked ? 'source_linked' : 'insufficient_evidence',
    if (outcome.repairOccurrenceId.isNotEmpty)
      'repair_occurrence_id': outcome.repairOccurrenceId,
    if (outcome.repairAttemptId.isNotEmpty)
      'attempt_id': outcome.repairAttemptId,
    if (attempt?.runId.isNotEmpty == true) 'run_id': attempt!.runId,
    if (outcome.sessionId.isNotEmpty) 'session_id': outcome.sessionId,
    if (source?.sessionId.isNotEmpty == true)
      'source_session_id': source!.sessionId,
    'source_task_id': outcome.sourceTaskId,
    'task_id': outcome.repairTaskId,
    'repair_state': outcome.outcomeState,
    'event_order': outcome.sequence,
    if (outcome.isCorrect != null) 'correct': outcome.isCorrect,
    if (attempt != null) 'assistance_kind': attempt.assistanceKind.name,
    'independent_repair':
        linked &&
        act0IndependentRepairProofV1(
          isCorrect: attempt.isCorrect,
          assistanceKind: attempt.assistanceKind,
        ),
    'source_surface': 'act0_repair_outcome',
  });
}

Act0TelemetryEventV1 _event(String name, Map<String, Object?> fields) =>
    Act0TelemetryEventV1(
      name: name,
      fields: Map.unmodifiable({'schemaVersion': 1, ...fields}),
    );

String _elapsedBucket(DateTime? previous, DateTime? current) {
  if (previous == null || current == null || current.isBefore(previous))
    return 'unknown';
  final elapsed = current.difference(previous);
  if (elapsed < Act0DurableLearningTimingV1.recoveryToFirstReview)
    return 'under_24h';
  if (elapsed < Act0DurableLearningTimingV1.firstToSecondReview)
    return '24h_to_72h';
  if (elapsed < Act0DurableLearningTimingV1.durableMaintenance)
    return '72h_to_7d';
  return '7d_or_more';
}
