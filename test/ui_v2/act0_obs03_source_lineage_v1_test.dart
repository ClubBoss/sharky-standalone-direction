// MACHINE projections with explicit synthetic clocks; no Human/elapsed proof.
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hnp_trace_file_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_observability_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import '../../tools/act0_obs03_trace_inspector_v1.dart';

final _t0 = DateTime.utc(2026, 1, 1);
final _world = Act0ShellStateV1.sample.worldById('world_1');
final _lesson = _world.lessons.firstWhere(
  (l) => l.lessonId == 'blinds_action_order',
);

Act0LearningEvidenceRecordV1 _record(
  int order,
  int hour, {
  String taskId = 'blinds_review',
  bool correct = true,
  Act0ReviewKindV1 kind = Act0ReviewKindV1.spacedReview,
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
}) {
  final task = _lesson.taskList.firstWhere((t) => t.taskId == taskId);
  final option = task.runner.options.firstWhere((o) => o.isCorrect == correct);
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: task.runner,
    option: option,
    taskFamily: task.resolvedTaskFamily,
  )!;
  return Act0LearningEvidenceRecordV1(
    recordId: 'obs03_attempt_v1|$order',
    createdOrder: order,
    worldId: _world.worldId,
    lessonId: _lesson.lessonId,
    taskId: taskId,
    sourceTaskId: taskId,
    choiceId: option.id,
    expectedChoiceId: task.runner.options.firstWhere((o) => o.isCorrect).id,
    isCorrect: option.isCorrect,
    errorType: correct ? 'none' : 'missed_action_read',
    conceptFamilyId: receipt.sourceSignalId,
    repairFocusId: receipt.sourceSignalId,
    skillAtomId: receipt.skillAtomId,
    decisionTimeBucket: '3_to_10s',
    resultKind: correct ? 'correct' : 'incorrect',
    runId: 'run_v1|world_1|blinds_action_order|lesson|$order',
    runKind: 'lesson',
    runOrdinal: order,
    sessionId: 'session_v1|$order',
    recordedAtUtc: _t0.add(Duration(hours: hour)),
    reviewKind: kind,
    assistanceKind: assistance,
    authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
      worldId: _world.worldId,
      lessonId: _lesson.lessonId,
      task: task,
    )!,
  );
}

Act0LearningEvidenceRecordV1 _with(
  Act0LearningEvidenceRecordV1 record,
  Map<String, Object?> delta,
) {
  final payload = {...record.toPayload(), ...delta};
  if (delta.containsKey('recordedAtUtc') && delta['recordedAtUtc'] == null) {
    payload.remove('recordedAtUtc');
    payload.remove('reviewKind');
  }
  return Act0LearningEvidenceRecordV1.tryParse(payload)!;
}

List<Act0TelemetryEventV1> _project(
  List<Act0LearningEvidenceRecordV1> rows, {
  DateTime? now,
}) => act0EvidenceTelemetryEventsV1(
  record: rows.last,
  history: Act0LearningEvidenceHistoryV1(records: rows),
  nowUtc: now ?? rows.last.recordedAtUtc!,
);

Map<String, Object?> _fields(List<Act0TelemetryEventV1> events, String name) =>
    events.singleWhere((e) => e.name == name).fields;

class _Store implements Act0HnpTraceFileStoreV1 {
  String contents = '';
  @override
  Future<String?> getPath() async => null;
  @override
  Future<void> replace(String jsonl) async {
    contents = jsonl;
  }
}

void main() {
  test(
    'OBS03 incident reconstruction fails closed for missing rows, wrong source and mismatched sessions',
    () async {
      final source = _record(
        1,
        0,
        correct: false,
        kind: Act0ReviewKindV1.initialAssessment,
      );
      final repair = _record(2, 0, kind: Act0ReviewKindV1.exactReplay);
      final store = _Store();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      for (final record in [source, repair]) {
        sink.record(
          Act0TelemetryEventV1(
            name: 'decision_made',
            fields: {
              'schemaVersion': 2,
              'attempt_id': record.recordId,
              'session_id': record.sessionId,
              'correct': record.isCorrect,
              'chosen_action': record.choiceId,
              'route_review_kind': 'initialAssessment',
            },
          ),
        );
        final history = Act0LearningEvidenceHistoryV1(
          records: record == source ? [source] : [source, repair],
        );
        for (final event in act0EvidenceTelemetryEventsV1(
          record: record,
          history: history,
          nowUtc: record.recordedAtUtc!,
        ))
          sink.record(event);
      }
      await sink.flushExport();
      final snapshot = jsonDecode(sink.exportJson()) as Map;
      Map inspect(Map trace, {String? fingerprint}) => inspectAct0Obs03TraceV1(
        trace,
        attemptId: repair.recordId,
        expectedSourceFingerprint:
            fingerprint ?? repair.authoredSourceFingerprint,
      );
      expect(inspect(snapshot)['status'], 'TRACE_RECONSTRUCTED');
      expect(
        inspect(snapshot, fingerprint: 'wrong_source')['status'],
        'INSUFFICIENT',
      );
      for (final removed in [
        'decision_made',
        'decision_evidence_recorded',
        'transfer_evaluated',
        'elapsed_learning_observed',
      ]) {
        final damaged = jsonDecode(jsonEncode(snapshot)) as Map;
        (damaged['events'] as List).removeWhere(
          (e) =>
              e['name'] == removed &&
              e['fields']['attempt_id'] == repair.recordId,
        );
        expect(inspect(damaged)['status'], 'INSUFFICIENT');
      }
      final mismatched = jsonDecode(jsonEncode(snapshot)) as Map;
      (mismatched['events'] as List).firstWhere(
        (e) =>
            e['name'] == 'decision_made' &&
            e['fields']['attempt_id'] == repair.recordId,
      )['fields']['session_id'] = 'different_session';
      expect(inspect(mismatched)['status'], 'INSUFFICIENT');
      final noVerdict = jsonDecode(jsonEncode(snapshot)) as Map;
      (noVerdict['events'] as List)
          .firstWhere(
            (e) =>
                e['name'] == 'transfer_evaluated' &&
                e['fields']['attempt_id'] == repair.recordId,
          )['fields']
          .remove('transfer_verdict');
      expect(inspect(noVerdict)['status'], 'INSUFFICIENT');
    },
  );
  test(
    'OBS03 canonical record owns review kind and explicit run/session/attempt joins',
    () {
      final rows = [
        _record(1, 0, correct: false, kind: Act0ReviewKindV1.initialAssessment),
        _record(2, 0, kind: Act0ReviewKindV1.exactReplay),
      ];
      final before = jsonEncode(
        Act0LearningEvidenceHistoryV1(records: rows).toStorageString(),
      );
      final projected = _project(rows);
      final canonical = _fields(projected, 'decision_evidence_recorded');
      expect(canonical['review_kind'], 'exactReplay');
      expect(canonical['run_id'], rows.last.runId);
      expect(canonical['session_id'], rows.last.sessionId);
      expect(canonical['attempt_id'], rows.last.recordId);
      expect(
        canonical['source_fingerprint'],
        rows.last.authoredSourceFingerprint,
      );
      expect(canonical['correct'], rows.last.isCorrect);
      expect(canonical['evidence_status'], 'source_linked');
      expect(
        jsonEncode(
          Act0LearningEvidenceHistoryV1(records: rows).toStorageString(),
        ),
        before,
      );
      expect(() => canonical.clear(), throwsUnsupportedError);
    },
  );

  test('OBS03 coarse elapsed buckets bind exact accepted source records', () {
    for (final testCase in [
      (0, 'under_24h'),
      (23, 'under_24h'),
      (24, '24h_to_72h'),
      (72, '72h_to_7d'),
      (168, '7d_or_more'),
    ]) {
      final rows = [_record(1, 0), _record(2, testCase.$1)];
      final fields = _fields(_project(rows), 'elapsed_learning_observed');
      expect(fields['elapsed_bucket'], testCase.$2);
      expect(fields['previous_attempt_id'], rows.first.recordId);
      expect(fields['attempt_id'], rows.last.recordId);
      expect(fields, isNot(contains('recordedAtUtc')));
      expect(fields, isNot(contains('elapsed_run_ms')));
    }
  });

  test(
    'OBS03 missing, future and backward time remain insufficient without guessed spacing',
    () {
      final initial = _record(1, 0);
      for (final rows in [
        [initial],
        [
          initial,
          _with(_record(2, 24), {'recordedAtUtc': null}),
        ],
        [_record(1, 24), _record(2, 0)],
        [initial, _record(2, 48)],
      ]) {
        final fields = _fields(
          _project(rows, now: _t0.add(const Duration(hours: 24))),
          'elapsed_learning_observed',
        );
        expect(fields['elapsed_bucket'], 'unknown');
      }
    },
  );

  test(
    'OBS03 canonical transfer projection matches its owner and keeps exact replay unverified',
    () {
      final rows = [_record(1, 0), _record(2, 24), _record(3, 72)];
      final history = Act0LearningEvidenceHistoryV1(records: rows);
      final signal = Act0LearningTransferMeasurementV1.fromLearningEvidence(
        history,
        nowUtc: rows.last.recordedAtUtc!,
      ).signalForConcept(rows.last.conceptFamilyId);
      final fields = _fields(_project(rows), 'transfer_evaluated');
      expect(fields['transfer_verdict'], signal.verdict);
      expect(fields['relationship'], signal.relationship);
      expect(fields['eligible_evidence_count'], signal.eligibleEvidenceCount);
      expect(fields['transfer_verdict'], isNot(act0RecentEvidenceVerifiedV1));
    },
  );

  test(
    'OBS03 current positive transfer retains owner-linked comparison IDs',
    () {
      final rows = [
        for (var i = 1; i <= 5; i++)
          _record(
            i,
            (i - 1) * 24,
            taskId: i.isEven ? 'blinds_first_actor' : 'blinds_review',
          ),
      ];
      final history = Act0LearningEvidenceHistoryV1(records: rows);
      final signal = Act0LearningTransferMeasurementV1.fromLearningEvidence(
        history,
        nowUtc: rows.last.recordedAtUtc!,
      ).signalForConcept(rows.last.conceptFamilyId);
      expect(signal.verdict, act0RecentEvidenceVerifiedV1);
      final fields = _fields(_project(rows), 'transfer_evaluated');
      expect(fields['transfer_verdict'], signal.verdict);
      expect(
        fields['baseline_attempt_id'],
        rows
            .singleWhere((r) => r.createdOrder == signal.baselineOrder)
            .recordId,
      );
      expect(fields['comparison_attempt_id'], rows.last.recordId);
    },
  );

  test(
    'OBS03 assistance, changed source and missing source chronology do not create transfer',
    () {
      final good = [
        for (var i = 1; i <= 5; i++)
          _record(
            i,
            (i - 1) * 24,
            taskId: i.isEven ? 'blinds_first_actor' : 'blinds_review',
          ),
      ];
      for (final rows in [
        [
          for (final r in good) _with(r, {'assistanceKind': 'quickHint'}),
        ],
        [
          ...good.take(4),
          _with(good.last, {'authoredSourceFingerprint': 'changed_source'}),
        ],
        [good.first, ...good.skip(2)],
      ]) {
        expect(
          _fields(_project(rows), 'transfer_evaluated')['transfer_verdict'],
          isNot(act0RecentEvidenceVerifiedV1),
        );
      }
    },
  );

  test(
    'OBS03 unknown record or conflicting occurrence is explicit insufficient evidence',
    () {
      final r = _record(1, 0);
      for (final history in [
        const Act0LearningEvidenceHistoryV1(),
        Act0LearningEvidenceHistoryV1(
          records: [
            r,
            _with(r, {'runId': 'conflicting_run'}),
          ],
        ),
      ]) {
        final event = act0EvidenceTelemetryEventsV1(
          record: r,
          history: history,
          nowUtc: _t0,
        ).single;
        expect(event.name, 'evidence_lineage_unavailable');
        expect(event.fields['evidence_status'], 'insufficient_evidence');
      }
    },
  );

  test(
    'OBS03 repair lineage separates repeated task occurrences and excludes assisted credit',
    () {
      final rows = [
        _record(1, 0, correct: false),
        _record(2, 0),
        _record(3, 0, correct: false),
        _record(4, 0),
      ];
      Act0RepairOutcomeV1 outcome(String occurrence) => Act0RepairOutcomeV1(
        repairOccurrenceId: occurrence,
        repairAttemptId: rows.last.recordId,
        sourceTaskId: rows.first.taskId,
        repairTaskId: rows.last.taskId,
        repairFocusKey: rows.first.conceptFamilyId,
        queueItemId: 'queue_v1',
        targetWorldId: _world.worldId,
        targetLessonId: _lesson.lessonId,
        targetTaskId: rows.last.taskId,
        selectedChoiceId: rows.last.choiceId,
        correctChoiceId: rows.last.expectedChoiceId,
        isCorrect: true,
        outcomeState: act0RepairOutcomeStateCorrectV1,
        sequence: 4,
        sourceType: 'active_repair',
        sessionId: rows.last.sessionId,
      );
      final history = Act0LearningEvidenceHistoryV1(records: rows);
      final a = act0RepairOutcomeTelemetryEventV1(
        outcome: outcome(rows.first.recordId),
        history: history,
      );
      final b = act0RepairOutcomeTelemetryEventV1(
        outcome: outcome(rows[2].recordId),
        history: history,
      );
      expect(
        a.fields['repair_occurrence_id'],
        isNot(b.fields['repair_occurrence_id']),
      );
      expect(b.fields['independent_repair'], true);
      final absent = act0RepairOutcomeTelemetryEventV1(
        outcome: outcome('missing'),
        history: history,
      );
      expect(absent.fields['evidence_status'], 'insufficient_evidence');
      expect(absent.fields['independent_repair'], false);
      final assisted = act0RepairOutcomeTelemetryEventV1(
        outcome: outcome(rows[2].recordId),
        history: Act0LearningEvidenceHistoryV1(
          records: [
            ...rows.take(3),
            _with(rows.last, {'assistanceKind': 'quickHint'}),
          ],
        ),
      );
      expect(assisted.fields['independent_repair'], false);
      final stale = act0RepairOutcomeTelemetryEventV1(
        outcome: outcome(rows[2].recordId),
        history: Act0LearningEvidenceHistoryV1(
          records: [
            ...rows.take(2),
            _with(rows[2], {'authoredSourceFingerprint': 'changed_source'}),
            rows.last,
          ],
        ),
      );
      expect(stale.fields['evidence_status'], 'insufficient_evidence');
      expect(stale.fields['independent_repair'], false);
    },
  );

  test(
    'OBS03 new source events survive private export without timestamps or raw state',
    () async {
      final store = _Store();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      final events = _project([_record(1, 0), _record(2, 24)]);
      for (final e in events) sink.record(e);
      await sink.flushExport();
      expect(sink.events.map((e) => e.name), events.map((e) => e.name));
      for (var i = 0; i < events.length; i++)
        expect(sink.events[i].fields, events[i].fields);
      expect(jsonDecode(sink.exportJson())['capture']['redactedFieldCount'], 0);
      expect(store.contents, isNot(contains('2026-01-')));
      expect(store.contents, isNot(contains('recordedAtUtc')));
    },
  );
}
