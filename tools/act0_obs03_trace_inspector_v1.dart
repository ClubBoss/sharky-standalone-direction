import 'dart:convert';
import 'dart:io';

/// Accepts the JSON snapshot and the collector's actual physical JSONL codec.
/// Console prefixes and truncated/foreign rows are not repaired or guessed.
Object? decodeAct0Obs03TraceV1(String content) {
  Object? value;
  try {
    value = jsonDecode(content);
  } on FormatException {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty);
    value = lines.map(jsonDecode).toList();
  }
  if (value is Map && value.containsKey('schema')) return value;
  final rows = value is Map ? [value] : value;
  if (rows is! List || rows.isEmpty || rows.any((r) => r is! Map)) return null;
  final capture = (rows.last as Map)['capture'];
  if (capture is! Map) return null;
  final healthOnly =
      rows.length == 1 &&
      (rows.single as Map).keys.length == 1 &&
      (rows.single as Map).containsKey('capture');
  if (!healthOnly &&
      rows.any(
        (r) =>
            (r as Map)['name'] is! String ||
            r['fields'] is! Map ||
            r['capture'] is! Map,
      ))
    return null;
  return {
    'schema': 'act0_hnp_local_trace_v1',
    'capture': capture,
    'events': healthOnly ? [] : rows,
  };
}

/// Checks exported trace consistency only. It does not authenticate a binary,
/// manufacture missing observations, grade answers or grant learner progress.
Map<String, Object?> inspectAct0Obs03TraceV1(
  Object? decoded, {
  required String attemptId,
  required String expectedSourceFingerprint,
}) {
  Map<String, Object?> insufficient(String reason) => {
    'schemaVersion': 1,
    'status': 'INSUFFICIENT',
    'reason': reason,
  };
  if (decoded is! Map || decoded['schema'] != 'act0_hnp_local_trace_v1')
    return insufficient('unknown_trace_schema');
  final capture = decoded['capture'];
  final raw = decoded['events'];
  // A contiguous prefix may contain all incident joins while losing its tail.
  // Match the declared capture size before trusting the sequence below.
  if (capture is! Map ||
      capture['schemaVersion'] is! int ||
      capture['schemaVersion'] != 1 ||
      capture['complete'] != true ||
      capture['rejectedEventCount'] != 0 ||
      capture['evictedEventCount'] != 0 ||
      raw is! List ||
      capture['recordedEventCount'] is! int ||
      capture['recordedEventCount'] != raw.length)
    return insufficient('incomplete_capture');
  final events = <Map>[];
  for (var i = 0; i < raw.length; i++) {
    final row = raw[i];
    if (row is! Map ||
        row['sequence'] is! int ||
        row['sequence'] != i + 1 ||
        row['fields'] is! Map)
      return insufficient('invalid_sequence');
    events.add(row);
  }
  Map? one(String name, String id) {
    final rows = events
        .where(
          (e) => e['name'] == name && (e['fields'] as Map)['attempt_id'] == id,
        )
        .toList();
    return rows.length == 1 ? rows.single['fields'] as Map : null;
  }

  final decision = one('decision_made', attemptId);
  final evidence = one('decision_evidence_recorded', attemptId);
  final transfer = one('transfer_evaluated', attemptId);
  final elapsed = one('elapsed_learning_observed', attemptId);
  if (decision == null ||
      evidence == null ||
      transfer == null ||
      elapsed == null)
    return insufficient('missing_decision_or_evaluation');
  if (decision['schemaVersion'] != 2 ||
      decision['schemaVersion'] is! int ||
      decision.containsKey('review_kind') ||
      evidence['schemaVersion'] != 1 ||
      transfer['schemaVersion'] != 1 ||
      elapsed['schemaVersion'] != 1)
    return insufficient('unknown_event_semantics');
  for (final row in [evidence, transfer, elapsed]) {
    if (row['schemaVersion'] is! int)
      return insufficient('unknown_event_semantics');
  }
  if (!const {
        'insufficient_evidence_v1',
        'same_task_repeat_v1',
        'same_family_transfer_v1',
      }.contains(transfer['relationship']) ||
      !const {
        'insufficient_evidence_v1',
        'confirmation_needed_v1',
        'recent_verified_v1',
      }.contains(transfer['transfer_verdict']) ||
      elapsed['elapsed_basis'] != 'recent_source_epoch' ||
      !const {
        'unknown',
        'under_24h',
        '24h_to_72h',
        '72h_to_7d',
        '7d_or_more',
      }.contains(elapsed['elapsed_bucket'])) {
    return insufficient('missing_evaluation_result');
  }
  if (expectedSourceFingerprint.isEmpty ||
      evidence['source_fingerprint'] != expectedSourceFingerprint ||
      evidence['source_current'] != true ||
      evidence['evidence_status'] != 'source_linked')
    return insufficient('source_not_established');
  for (final key in [
    'run_id',
    'session_id',
    'review_kind',
    'assistance_kind',
    'chosen_action',
    'expected_action',
    'world_id',
    'lesson_id',
    'task_id',
    'error_type',
  ]) {
    if (evidence[key] is! String || (evidence[key] as String).isEmpty)
      return insufficient('missing_evidence_identity');
  }
  if (!const {
    'unknown',
    'under_3s',
    '3_to_10s',
    'over_10s',
  }.contains(evidence['decisionTimeBucket'])) {
    return insufficient('missing_or_unknown_decision_time');
  }
  if (evidence['correct'] is! bool ||
      decision['correct'] != evidence['correct'] ||
      decision['chosen_action'] != evidence['chosen_action'] ||
      decision['session_id'] != evidence['session_id'])
    return insufficient('decision_evidence_mismatch');
  for (final row in [transfer, elapsed]) {
    for (final key in [
      'run_id',
      'session_id',
      'source_fingerprint',
      'world_id',
      'lesson_id',
      'task_id',
    ]) {
      if (row[key] != evidence[key])
        return insufficient('evaluation_identity_mismatch');
    }
  }
  if (transfer['transfer_verdict'] == 'recent_verified_v1' &&
      (transfer['eligible_evidence_count'] is! int ||
          (transfer['eligible_evidence_count'] as int) < 5 ||
          transfer['baseline_attempt_id'] is! String ||
          transfer['comparison_attempt_id'] is! String)) {
    return insufficient('missing_verified_transfer_references');
  }
  // A reference must name another source-current, source-linked record of the
  // same concept epoch that was created before this attempt. Only the
  // comparison may be this attempt: the producer compares against the newest
  // epoch record, which is usually the attempt being observed.
  final baselineId = transfer['baseline_attempt_id'];
  final comparisonId = transfer['comparison_attempt_id'];
  final previousId = elapsed['previous_attempt_id'];
  final family = evidence['concept_family_id'];
  final currentOrder = evidence['created_order'];
  String? referenceProblem(Object? id, {required bool mayBeCurrent}) {
    if (id == null) return null;
    if (id is! String || id.isEmpty) return 'missing_source_reference';
    if (id == attemptId)
      return mayBeCurrent ? null : 'invalid_source_reference';
    final source = one('decision_evidence_recorded', id);
    if (source == null) return 'missing_source_reference';
    final sourceOrder = source['created_order'];
    if (source['source_current'] != true ||
        source['evidence_status'] != 'source_linked' ||
        family is! String ||
        family.isEmpty ||
        source['concept_family_id'] != family ||
        currentOrder is! int ||
        sourceOrder is! int ||
        sourceOrder >= currentOrder)
      return 'invalid_source_reference';
    return null;
  }

  final referenceFailure =
      referenceProblem(baselineId, mayBeCurrent: false) ??
      referenceProblem(comparisonId, mayBeCurrent: true) ??
      referenceProblem(previousId, mayBeCurrent: false) ??
      (baselineId != null && baselineId == comparisonId
          ? 'invalid_source_reference'
          : null);
  if (referenceFailure != null) return insufficient(referenceFailure);
  final occurrence = evidence['repair_occurrence_id'];
  Map? repair;
  if (const {'repair', 'recheck'}.contains(evidence['sequence_stage'])) {
    final sourceId = evidence['sequence_source_attempt_id'];
    final sequence = one('sequence_repair_observed', attemptId);
    if (sourceId is! String ||
        one('decision_evidence_recorded', sourceId) == null ||
        sequence == null ||
        sequence['schemaVersion'] is! int ||
        sequence['schemaVersion'] != 1 ||
        sequence['sequence_source_attempt_id'] != sourceId ||
        sequence['sequence_stage'] != evidence['sequence_stage'] ||
        sequence['session_id'] != evidence['session_id'] ||
        sequence['evidence_status'] != 'source_linked') {
      return insufficient('missing_or_mismatched_sequence_repair');
    }
  }
  if (occurrence != null && evidence['assistance_kind'] == 'none') {
    if (occurrence is! String ||
        one('decision_evidence_recorded', occurrence) == null)
      return insufficient('missing_repair_source');
    repair = one('repair_outcome_recorded', attemptId);
    if (repair == null ||
        repair['schemaVersion'] is! int ||
        repair['schemaVersion'] != 1 ||
        repair['repair_occurrence_id'] != occurrence ||
        repair['session_id'] != evidence['session_id'] ||
        repair['evidence_status'] != 'source_linked')
      return insufficient('missing_or_mismatched_repair_outcome');
  }
  return {
    'schemaVersion': 1,
    'status': 'TRACE_RECONSTRUCTED',
    'attempt_id': attemptId,
    'run_id': evidence['run_id'],
    'session_id': evidence['session_id'],
    'source_fingerprint': expectedSourceFingerprint,
    'world_id': evidence['world_id'],
    'lesson_id': evidence['lesson_id'],
    'task_id': evidence['task_id'],
    'chosen_action': evidence['chosen_action'],
    'expected_action': evidence['expected_action'],
    'correct': evidence['correct'],
    'error_type': evidence['error_type'],
    'decisionTimeBucket': evidence['decisionTimeBucket'],
    'review_kind': evidence['review_kind'],
    'assistance_kind': evidence['assistance_kind'],
    'transfer_verdict': transfer['transfer_verdict'],
    'elapsed_bucket': elapsed['elapsed_bucket'],
    if (repair != null) 'repair_occurrence_id': occurrence,
    if (repair != null) 'repair_state': repair['repair_state'],
  };
}

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
      'Usage: dart run tools/act0_obs03_trace_inspector_v1.dart TRACE_JSON ATTEMPT_ID SOURCE_FINGERPRINT',
    );
    exitCode = 64;
    return;
  }
  try {
    final result = inspectAct0Obs03TraceV1(
      decodeAct0Obs03TraceV1(File(args[0]).readAsStringSync()),
      attemptId: args[1],
      expectedSourceFingerprint: args[2],
    );
    stdout.writeln(jsonEncode(result));
    if (result['status'] != 'TRACE_RECONSTRUCTED') exitCode = 2;
  } catch (_) {
    stdout.writeln(
      jsonEncode({
        'schemaVersion': 1,
        'status': 'INSUFFICIENT',
        'reason': 'unreadable_trace',
      }),
    );
    exitCode = 2;
  }
}
