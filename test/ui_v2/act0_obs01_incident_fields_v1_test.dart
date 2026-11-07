// Synthetic codec controls only; actual source/consumer evidence is exercised
// by act0_obs03_source_lineage and act0_obs03_privacy_lineage.
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../tools/act0_obs03_trace_inspector_v1.dart';

Map _trace() {
  final common = <String, Object?>{
    'schemaVersion': 1,
    'attempt_id': 'attempt_1',
    'run_id': 'run_1',
    'session_id': 'session_1',
    'world_id': 'world_1',
    'lesson_id': 'lesson_1',
    'task_id': 'task_1',
    'source_fingerprint': 'synthetic_fingerprint',
  };
  final events = [
    {
      'name': 'decision_made',
      'fields': {
        'schemaVersion': 2,
        'attempt_id': 'attempt_1',
        'session_id': 'session_1',
        'correct': false,
        'chosen_action': 'fold',
      },
    },
    {
      'name': 'decision_evidence_recorded',
      'fields': {
        ...common,
        'source_current': true,
        'evidence_status': 'source_linked',
        'review_kind': 'initialAssessment',
        'assistance_kind': 'none',
        'chosen_action': 'fold',
        'expected_action': 'call',
        'correct': false,
        'error_type': 'missed_price',
        'decisionTimeBucket': '3_to_10s',
      },
    },
    {
      'name': 'transfer_evaluated',
      'fields': {
        ...common,
        'relationship': 'insufficient_evidence_v1',
        'transfer_verdict': 'confirmation_needed_v1',
        'eligible_evidence_count': 1,
      },
    },
    {
      'name': 'elapsed_learning_observed',
      'fields': {
        ...common,
        'elapsed_basis': 'recent_source_epoch',
        'elapsed_bucket': 'unknown',
      },
    },
  ];
  return {
    'schema': 'act0_hnp_local_trace_v1',
    'capture': {
      'schemaVersion': 1,
      'complete': true,
      'rejectedEventCount': 0,
      'evictedEventCount': 0,
      'recordedEventCount': events.length,
    },
    'events': [
      for (var i = 0; i < events.length; i++) {...events[i], 'sequence': i + 1},
    ],
  };
}

Map _inspect(Map trace) => inspectAct0Obs03TraceV1(
  trace,
  attemptId: 'attempt_1',
  expectedSourceFingerprint: 'synthetic_fingerprint',
);

Map _fields(Map trace, String name) =>
    (trace['events'] as List).singleWhere((e) => e['name'] == name)['fields']
        as Map;

void main() {
  test('OBS01 incident includes every observed decision fact', () {
    final result = _inspect(_trace());
    expect(result['status'], 'TRACE_RECONSTRUCTED');
    expect(result['task_id'], 'task_1');
    expect(result['chosen_action'], 'fold');
    expect(result['correct'], false);
    expect(result['decisionTimeBucket'], '3_to_10s');
    expect(result['assistance_kind'], 'none');
    expect(result['session_id'], 'session_1');
    expect(result['error_type'], 'missed_price');
  });

  test(
    'OBS01 incomplete decision facts cannot reconstruct a full incident',
    () {
      for (final key in [
        'world_id',
        'lesson_id',
        'task_id',
        'expected_action',
        'error_type',
        'decisionTimeBucket',
      ]) {
        final trace = _trace();
        _fields(trace, 'decision_evidence_recorded').remove(key);
        expect(_inspect(trace)['status'], 'INSUFFICIENT', reason: key);
      }
      for (final bucket in ['invented_time', 3, null]) {
        final trace = _trace();
        _fields(trace, 'decision_evidence_recorded')['decisionTimeBucket'] =
            bucket;
        expect(_inspect(trace)['status'], 'INSUFFICIENT');
      }
    },
  );

  test(
    'OBS01 unlinked positive or unknown transfer is never reconstructed',
    () {
      for (final delta in [
        {
          'transfer_verdict': 'recent_verified_v1',
          'eligible_evidence_count': 5,
        },
        {'relationship': 'unseen_transfer'},
        {'transfer_verdict': 'invented_verified'},
      ]) {
        final trace = jsonDecode(jsonEncode(_trace())) as Map;
        _fields(trace, 'transfer_evaluated').addAll(delta);
        expect(_inspect(trace)['status'], 'INSUFFICIENT', reason: '$delta');
      }
    },
  );
}
