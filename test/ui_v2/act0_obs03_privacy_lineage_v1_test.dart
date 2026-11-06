import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hnp_trace_file_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

class _Store implements Act0HnpTraceFileStoreV1 {
  _Store({this.fail = false});
  final bool fail;
  String contents = '';
  @override
  Future<String> getPath() async => '/private/Alice/trace.jsonl';
  @override
  Future<void> replace(String jsonl) async {
    if (fail) throw StateError('private incident detail');
    contents = jsonl;
  }
}

class _BlockedStore extends _Store {
  final entered = Completer<void>();
  final release = Completer<void>();
  int writes = 0;
  @override
  Future<void> replace(String jsonl) async {
    if (++writes == 1) {
      entered.complete();
      await release.future;
    }
    contents = jsonl;
  }
}

class _ObservedSink implements Act0TelemetrySinkV1 {
  _ObservedSink(this.delegate);
  final Act0TelemetrySinkV1 delegate;
  final List<Act0TelemetryEventV1> source = [];
  @override
  void record(Act0TelemetryEventV1 event) {
    source.add(event);
    delegate.record(event);
  }
}

Act0TelemetryEventV1 _event(
  String name, [
  Map<String, Object?> extra = const {},
]) => Act0TelemetryEventV1(name: name, fields: {'schemaVersion': 1, ...extra});

Map<String, dynamic> _export(Act0HnpTelemetrySinkV1 sink) =>
    jsonDecode(sink.exportJson()) as Map<String, dynamic>;

const _evidenceDirectory = String.fromEnvironment('OBS03_EVIDENCE_DIR');

void _writeEvidence(String name, Object data) {
  if (_evidenceDirectory.isEmpty) return;
  final file = File('$_evidenceDirectory/$name.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(data)}\n',
  );
}

class _PartialSink implements Act0TelemetrySinkV1 {
  _PartialSink(this.delegate);
  final Act0TelemetrySinkV1 delegate;
  int count = 0;
  @override
  void record(Act0TelemetryEventV1 event) {
    // Deliberately lose decisions while delivering later payoff/repair rows.
    if (event.name == 'decision_made' || (++count).isEven) return;
    delegate.record(event);
  }
}

void main() {
  test('OBS03 snapshots the accepted event and nested allowed lists', () async {
    final sink = Act0HnpTelemetrySinkV1(fileStore: _Store());
    final options = <String>['check', 'fold'];
    final fields = <String, Object?>{
      'schemaVersion': 1,
      'taskId': 'actions_check_drill',
      'acceptable_action_ids': options,
    };
    sink.record(Act0TelemetryEventV1(name: 'decision_made', fields: fields));
    fields['taskId'] = 'rewritten_after_capture';
    options.add('rewritten');
    expect(sink.events.single.fields['taskId'], 'actions_check_drill');
    expect(sink.events.single.fields['acceptable_action_ids'], [
      'check',
      'fold',
    ]);
    expect(() => sink.events.clear(), throwsUnsupportedError);
    expect(() => sink.events.single.fields.clear(), throwsUnsupportedError);
    await sink.flushExport();
  });

  test(
    'OBS03 filters PII, free text, raw state and unsupported values before every output',
    () async {
      final store = _Store();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      final messages = <String>[];
      final original = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) messages.add(message);
      };
      try {
        sink.record(
          _event('decision_made', {
            'taskId': 'actions_check_drill',
            'email': 'alice@example.com',
            'playerName': 'Alice',
            'deviceId': 'private-device',
            'recordedAtUtc': '2026-11-06T13:00:00Z',
            'handHistory': 'As Ks private history',
            'feedbackReason': 'Private answer prose',
            'detail': {'email': 'alice@example.com'},
            'choiceId': 'alice@example.com',
            'source_surface': 'raw localized sentence',
            'correct': Object(),
          }),
        );
        await sink.flushExport();
        expect(sink.events.single.fields, {
          'schemaVersion': 1,
          'taskId': 'actions_check_drill',
        });
        final physical =
            '${sink.exportJson()} ${sink.exportJsonl()} ${store.contents} ${messages.join()}';
        for (final forbidden in [
          'alice@example.com',
          'Alice',
          'private-device',
          'Private answer',
          'As Ks',
          '/private/',
        ]) {
          expect(physical, isNot(contains(forbidden)));
        }
      } finally {
        debugPrint = original;
      }
    },
  );

  test('OBS03 a malformed event cannot poison later JSONL export', () async {
    final store = _Store();
    final sink = Act0HnpTelemetrySinkV1(fileStore: store);
    final cyclic = <String, Object?>{};
    cyclic['detail'] = cyclic;
    expect(() => sink.record(_event('task_result', cyclic)), returnsNormally);
    sink.record(_event('task_result', {'result': 'incorrect'}));
    await sink.flushExport();
    expect(store.contents.trim().split('\n').map(jsonDecode), hasLength(2));
    expect(_export(sink)['capture']['redactedFieldCount'], 1);
  });

  test(
    'OBS03 loss and unsupported schemas remain explicit and no lineage is invented',
    () async {
      final store = _Store();
      final sink = Act0HnpTelemetrySinkV1(maxEvents: 2, fileStore: store);
      sink.record(_event('session_start', {'session_id': 'session_v1|1'}));
      sink.record(
        _event('decision_made', {
          'session_id': 'session_v1|1',
          'attempt_id': 'attempt_v1|1',
          'result': 'incorrect',
        }),
      );
      sink.record(
        _event('unreviewed_private_event', {'email': 'private@example.com'}),
      );
      sink.record(
        _event('task_result', {'schemaVersion': 999, 'result': 'correct'}),
      );
      sink.record(
        _event('repair_completed', {
          'sourceTaskId': 'actions_check_drill',
          'repairTaskId': 'actions_raise_drill',
          'result': 'correct',
        }),
      );
      await sink.flushExport();
      final trace = _export(sink);
      expect(trace['capture']['recordedEventCount'], 5);
      expect(trace['capture']['rejectedEventCount'], 2);
      expect(trace['capture']['evictedEventCount'], 1);
      expect(trace['capture']['complete'], false);
      final rows = (trace['events'] as List).cast<Map>();
      expect(rows.map((e) => e['sequence']), [2, 5]);
      expect(rows.first['fields']['attempt_id'], 'attempt_v1|1');
      expect(rows.last['fields'], isNot(contains('session_id')));
      expect(rows.last['fields'], isNot(contains('run_id')));
      expect(rows.last['fields'], isNot(contains('transfer_verdict')));
      expect(
        jsonDecode(
          store.contents.trim().split('\n').last,
        )['capture']['complete'],
        false,
      );
    },
  );

  test(
    'OBS03 retained trace reconstructs only supplied versioned links',
    () async {
      final sink = Act0HnpTelemetrySinkV1(fileStore: _Store());
      for (final row in [
        _event('session_start', {'session_id': 'session_v1|7'}),
        _event('learning_run_started', {
          'session_id': 'session_v1|7',
          'run_id': 'learning_run_v1|3',
        }),
        _event('decision_made', {
          'session_id': 'session_v1|7',
          'run_id': 'learning_run_v1|3',
          'attempt_id': 'attempt_v1|9',
          'result': 'incorrect',
        }),
        _event('repair_started', {
          'session_id': 'session_v1|7',
          'sourceTaskId': 'source_task',
          'repairTaskId': 'repair_task',
        }),
        _event('repair_completed', {
          'session_id': 'session_v1|7',
          'sourceTaskId': 'source_task',
          'repairTaskId': 'repair_task',
          'result': 'correct',
        }),
        _event('learning_run_closed', {
          'run_id': 'learning_run_v1|3',
          'elapsed_run_ms': 38000,
        }),
      ]) {
        sink.record(row);
      }
      final trace = _export(sink);
      expect(trace['capture']['complete'], true);
      expect(trace['capture']['redactedFieldCount'], 0);
      final rows = (trace['events'] as List).cast<Map>();
      expect(rows.map((e) => e['sequence']), [1, 2, 3, 4, 5, 6]);
      expect(rows[2]['fields']['run_id'], rows[1]['fields']['run_id']);
      expect(
        rows[4]['fields']['sourceTaskId'],
        rows[3]['fields']['sourceTaskId'],
      );
      expect(rows[5]['fields']['elapsed_run_ms'], 38000);
      await sink.flushExport();
      // Transport fixture only: it does not establish the canonical producer's
      // missing decision/run/transfer/elapsed joins or a real transfer outcome.
    },
  );

  test('OBS03 invalid retention cannot disable the bound', () {
    for (final limit in [0, -1]) {
      expect(
        () => Act0HnpTelemetrySinkV1(maxEvents: limit, fileStore: _Store()),
        throwsArgumentError,
      );
    }
  });

  test(
    'OBS03 slow export coalesces writes and flush includes later events',
    () async {
      final store = _BlockedStore();
      final sink = Act0HnpTelemetrySinkV1(maxEvents: 2, fileStore: store);
      await store.entered.future;
      for (var i = 0; i < 30; i++) {
        sink.record(_event('task_result', {'attemptOrdinal': i + 1}));
      }
      store.release.complete();
      await sink.flushExport();
      expect(store.writes, 2);
      expect(sink.events, hasLength(2));
      expect(
        jsonDecode(store.contents.trim().split('\n').last)['sequence'],
        30,
      );
      expect(_export(sink)['capture']['evictedEventCount'], 28);
    },
  );

  test(
    'OBS03 an entirely rejected file retains explicit loss evidence',
    () async {
      final store = _Store();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      sink.record(_event('private@example.com'));
      sink.record(_event('task_result', {'schemaVersion': 1.0}));
      await sink.flushExport();
      expect(sink.events, isEmpty);
      final captured = jsonDecode(store.contents)['capture'];
      expect(captured['rejectedEventCount'], 2);
      expect(captured['complete'], false);
      expect(store.contents, isNot(contains('private@example.com')));
    },
  );

  test('OBS03 source enum values remain serializable categories', () async {
    final store = _Store();
    final sink = Act0HnpTelemetrySinkV1(fileStore: store);
    sink.record(
      _event('recheck_completed', {
        'result': 'correct',
        'retentionStatus': Act0LessonPhaseV1.review,
      }),
    );
    await sink.flushExport();
    expect(
      jsonDecode(store.contents.trim())['fields']['retentionStatus'],
      'review',
    );
  });

  testWidgets(
    'OBS03 partial or failed telemetry cannot change actual grades, progress or transfer',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = _Store();
      final full = Act0HnpTelemetrySinkV1(fileStore: store);
      final observed = _ObservedSink(full);
      final partial = Act0HnpTelemetrySinkV1(fileStore: _Store());
      final failed = Act0HnpTelemetrySinkV1(fileStore: _Store(fail: true));
      final without = await _journey(tester, null);
      for (final sink in [observed, _PartialSink(partial), failed]) {
        expect(await _journey(tester, sink), without);
      }
      await Future.wait([
        full.flushExport(),
        partial.flushExport(),
        failed.flushExport(),
      ]);
      expect(full.events.where((e) => e.name == 'decision_made'), hasLength(3));
      expect(partial.events.where((e) => e.name == 'decision_made'), isEmpty);
      expect(full.events.any((e) => e.name == 'repair_completed'), true);
      final decision = full.events.firstWhere((e) => e.name == 'decision_made');
      expect(decision.fields['session_id'], isNotEmpty);
      final records = (without['decisions'] as List).cast<Map>();
      final joins = <Map<String, Object?>>[];
      for (final event in full.events.where((e) => e.name == 'decision_made')) {
        final record = records.singleWhere(
          (r) => r['recordId'] == event.fields['attempt_id'],
        );
        expect(event.fields['session_id'], record['sessionId']);
        expect(
          event.fields['attempt_id'] as String,
          contains('|${record['runId']}|'),
        );
        joins.add({
          'attemptId': event.fields['attempt_id'],
          'durableRunId': record['runId'],
          'sessionId': record['sessionId'],
          'sourceReviewKind': record['reviewKind'],
          'telemetryReviewKind': event.fields['review_kind'],
        });
      }
      final redactedKeys = <String, int>{};
      for (var i = 0; i < observed.source.length; i++) {
        for (final key in observed.source[i].fields.keys) {
          if (!full.events[i].fields.containsKey(key)) {
            redactedKeys.update(key, (n) => n + 1, ifAbsent: () => 1);
          }
        }
      }
      // This source field contains prose. All actual technical IDs, choices,
      // counters and outcome categories on this journey must survive capture.
      expect(redactedKeys.keys, unorderedEquals(['source_evidence_summary']));
      expect(tester.takeException(), isNull);
      _writeEvidence('canonical-journey', _export(full));
      _writeEvidence('partial-journey', _export(partial));
      _writeEvidence('telemetry-parity', {
        'schemaVersion': 1,
        'execution': 'deterministic_widget_393x852_en',
        'comparedModes': [
          'disabled',
          'full',
          'partial_without_decisions',
          'file_write_failure',
        ],
        'identicalLearnerOutcome': without,
        'producerDecisionRunJoin': 'encoded_in_versioned_attempt_id',
        'incidentDecisionJoins': joins,
        'filteredSourceFieldCounts': redactedKeys,
        'fullOriginalObs03': 'not_attested_by_this_test',
      });
    },
  );
}

Future<Map<String, Object?>> _journey(
  WidgetTester tester,
  Act0TelemetrySinkV1? sink,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  final world = Act0ShellStateV1.sample.worldById('world_1');
  // Existing prerequisite-only fixture; the observed decisions below are made
  // through real learner controls, not injected result/repair/transfer rows.
  final fixture =
      jsonDecode(
            File(
              'tools/contracts/alpha_action_capability_prerequisite_progression_v1.json',
            ).readAsStringSync(),
          )
          as Map;
  final lessons = (fixture['completed_lesson_ids'] as List).cast<String>();
  SharedPreferences.setMockInitialValues({
    'intake_completed_v1': true,
    'act0_welcome_completed_v1': true,
    'act0_shell_progress_v1': jsonEncode({
      'schemaVersion': 16,
      'completedTaskIds': [
        for (final id in lessons)
          ...world.lessons
              .firstWhere((l) => l.lessonId == id)
              .taskList
              .map((t) => t.taskId),
      ],
      'skippedTaskIds': <String>[],
      'completedLessonIds': lessons,
      'selectedWorldId': world.worldId,
      'selectedLessonId': fixture['target']['lesson_id'],
      'selectedTaskId': fixture['target']['task_id'],
      'earnedXp': 0,
    }),
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: false,
        telemetrySink: sink,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await _tap(tester, find.text('Learn').last);
  await _tap(tester, find.byKey(const Key('act0_shell_current_mission_cta')));
  for (var step = 0; step < 24; step++) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    if (runner.selectedTaskId == 'actions_check_drill' &&
        find.byKey(const Key('act0_shell_option_check')).evaluate().isNotEmpty)
      break;
    expect(step, lessThan(23), reason: 'theory must reach canonical decision');
    await tester.pump(const Duration(milliseconds: 900));
    await _tap(tester, find.byKey(const Key('act0_shell_continue_cta')));
  }
  for (final correct in [false, true, true]) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final option = runner.runner.options.firstWhere(
      (o) => o.isCorrect == correct,
    );
    await _tap(tester, find.byKey(Key('act0_shell_option_${option.id}')));
    await _tap(
      tester,
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
    );
  }
  final prefs = await SharedPreferences.getInstance();
  final saved = jsonDecode(prefs.getString('act0_shell_progress_v1')!) as Map;
  final history = saved['learningEvidenceHistory'];
  final records = (history is Map ? history['records'] : history) as List;
  final evidence = Act0LearningEvidenceHistoryV1.tryParse(history)!;
  final transfer = Act0LearningTransferMeasurementV1.fromLearningEvidence(
    evidence,
  );
  expect(
    transfer.signals.any(
      (s) => s.relationship == act0LearningTransferSameFamilyTransferV1,
    ),
    false,
  );
  return {
    for (final key in [
      'earnedXp',
      'completedTaskIds',
      'skippedTaskIds',
      'completedLessonIds',
      'openRepairIntents',
      'repairOutcomeProjection',
    ])
      key: saved[key],
    'decisions': [
      for (final raw in records)
        {
          for (final key in [
            'schemaVersion',
            'recordId',
            'createdOrder',
            'worldId',
            'lessonId',
            'taskId',
            'sourceTaskId',
            'choiceId',
            'expectedChoiceId',
            'isCorrect',
            'errorType',
            'resultKind',
            'assistanceKind',
            'runId',
            'runKind',
            'runOrdinal',
            'sessionId',
            'reviewKind',
            'authoredSourceFingerprint',
          ])
            if ((raw as Map).containsKey(key)) key: raw[key],
        },
    ],
    'transfer': [
      for (final signal in transfer.signals)
        {
          'family': signal.conceptFamilyId,
          'relationship': signal.relationship,
          'verdict': signal.verdict,
          'eligibleEvidenceCount': signal.eligibleEvidenceCount,
          'baselineSessionId': signal.baselineSessionId,
          'comparisonSessionId': signal.comparisonSessionId,
        },
    ],
  };
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
