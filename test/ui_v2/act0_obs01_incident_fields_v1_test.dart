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

/// Positive transfer shaped like the producer: the comparison is the newest
/// epoch record (the current attempt) and the baseline/previous are earlier
/// source-linked records of the same concept family.
Map _verifiedTrace({
  Object? baseline = 'attempt_0',
  Object? comparison = 'attempt_1',
  Object? previous = 'attempt_0',
  Map<String, Object?> earlier = const {},
}) {
  final trace = _trace();
  final events = (trace['events'] as List).cast<Map>();
  final current = _fields(trace, 'decision_evidence_recorded');
  current
    ..['concept_family_id'] = 'family_1'
    ..['created_order'] = 2;
  final earlierEvidence = {
    ...current,
    'attempt_id': 'attempt_0',
    'run_id': 'run_0',
    'session_id': 'session_0',
    'task_id': 'task_0',
    'source_fingerprint': 'earlier_fingerprint',
    'created_order': 1,
    'correct': true,
    'chosen_action': 'call',
    ...earlier,
  };
  _fields(trace, 'transfer_evaluated')
    ..['relationship'] = 'same_family_transfer_v1'
    ..['transfer_verdict'] = 'recent_verified_v1'
    ..['eligible_evidence_count'] = 5
    ..['baseline_attempt_id'] = baseline
    ..['comparison_attempt_id'] = comparison;
  _fields(trace, 'elapsed_learning_observed')['previous_attempt_id'] = previous;
  final all = [
    {'name': 'decision_evidence_recorded', 'fields': earlierEvidence},
    for (final e in events) {'name': e['name'], 'fields': e['fields']},
  ];
  trace['events'] = [
    for (var i = 0; i < all.length; i++) {...all[i], 'sequence': i + 1},
  ];
  (trace['capture'] as Map)['recordedEventCount'] = all.length;
  return jsonDecode(jsonEncode(trace)) as Map;
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

  test('OBS01 producer-shaped verified transfer still reconstructs', () {
    final result = _inspect(_verifiedTrace());
    expect(result['status'], 'TRACE_RECONSTRUCTED');
    expect(result['transfer_verdict'], 'recent_verified_v1');
  });

  // Independent review 5811045902: these three synthetic traces were reported
  // as TRACE_RECONSTRUCTED with a positive recent_verified_v1 verdict.
  test('OBS01 foreign or invalid referenced source is never reconstructed', () {
    for (final earlier in <Map<String, Object?>>[
      {'source_current': false},
      {'evidence_status': 'missing'},
      {'evidence_status': 'insufficient_evidence'},
      {'concept_family_id': 'other_family'},
      {'concept_family_id': null},
      {'created_order': 3},
      {'created_order': null},
    ]) {
      final result = _inspect(_verifiedTrace(earlier: earlier));
      expect(result['status'], 'INSUFFICIENT', reason: '$earlier');
      expect(result['reason'], 'invalid_source_reference', reason: '$earlier');
    }
  });

  test('OBS01 identical baseline and comparison are never reconstructed', () {
    for (final id in ['attempt_0', 'attempt_1']) {
      final result = _inspect(_verifiedTrace(baseline: id, comparison: id));
      expect(result['status'], 'INSUFFICIENT', reason: id);
    }
  });

  test('OBS01 baseline or previous naming the current attempt is rejected', () {
    for (final trace in [
      _verifiedTrace(baseline: 'attempt_1'),
      _verifiedTrace(previous: 'attempt_1'),
      _verifiedTrace(baseline: 'attempt_1', comparison: 'attempt_1'),
    ]) {
      final result = _inspect(trace);
      expect(result['status'], 'INSUFFICIENT');
      expect(result['reason'], 'invalid_source_reference');
    }
  });

  Map evidenceOf(Map trace, String attemptId) =>
      (trace['events'] as List).singleWhere(
            (e) =>
                e['name'] == 'decision_evidence_recorded' &&
                e['fields']['attempt_id'] == attemptId,
          )['fields']
          as Map;

  // Independent review 5811442259: the producer never selects assisted or
  // replay/immediate-repair/legacy records as a transfer baseline/comparison.
  test('OBS01 ineligible transfer baseline is never reconstructed', () {
    for (final earlier in <Map<String, Object?>>[
      {'assistance_kind': 'quickHint'},
      {'assistance_kind': 'theoryRecall'},
      {'review_kind': 'exactReplay'},
      {'review_kind': 'immediateRepair'},
      {'review_kind': 'legacyUnspaced'},
      {'review_kind': null},
    ]) {
      final result = _inspect(_verifiedTrace(earlier: earlier));
      expect(result['status'], 'INSUFFICIENT', reason: '$earlier');
      expect(
        result['reason'],
        'ineligible_transfer_reference',
        reason: '$earlier',
      );
    }
  });

  test('OBS01 ineligible current attempt cannot be the comparison', () {
    for (final delta in <Map<String, Object?>>[
      {'assistance_kind': 'quickHint'},
      {'review_kind': 'exactReplay'},
    ]) {
      final trace = _verifiedTrace();
      evidenceOf(trace, 'attempt_1').addAll(delta);
      final result = _inspect(trace);
      expect(result['status'], 'INSUFFICIENT', reason: '$delta');
      expect(result['reason'], 'ineligible_transfer_reference');
    }
  });

  test('OBS01 elapsed previous keeps its own epoch rule', () {
    // An assisted earlier record may still be the previous epoch attempt; the
    // transfer reference rule must not be copied onto elapsed lineage.
    final trace = _verifiedTrace(
      baseline: null,
      earlier: {'assistance_kind': 'quickHint'},
    );
    (trace['events'] as List).singleWhere(
        (e) => e['name'] == 'transfer_evaluated',
      )['fields']
      ..['relationship'] = 'insufficient_evidence_v1'
      ..['transfer_verdict'] = 'confirmation_needed_v1'
      ..['eligible_evidence_count'] = 1;
    final result = _inspect(trace);
    expect(result['status'], 'TRACE_RECONSTRUCTED');
    expect(result['transfer_verdict'], 'confirmation_needed_v1');
  });
}
