// Guards source-owned teaching versus assessment through save/reload and You.
// Widget/test-platform persistence proof; not native or historical user data.
// Target actions use the real route; predecessor navigation is fixture-seeded.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_session_identity_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
const _worldId = 'world_1';
const _lessonId = 'positions';
const _theoryTaskId = 'positions_theory';
const _drillTaskId = 'positions_utg';

// Reuses the OBS04/LDR01 durable-map versus preferences-cache separation.
// This object survives the cache reset. It is never re-seeded for a restart.
class _Disk extends SharedPreferencesStorePlatform {
  _Disk(Map<String, Object> initial)
    : values = {
        for (final entry in initial.entries)
          'flutter.${entry.key}': entry.value,
      };

  final Map<String, Object> values;
  int readCount = 0;

  @override
  Future<Map<String, Object>> getAll() async {
    readCount++;
    return Map<String, Object>.of(values);
  }

  @override
  Future<bool> setValue(String type, String key, Object value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    throw StateError('This test must not clear the durable fixture.');
  }
}

class _Fixture {
  _Fixture(this.taskId, this.disk, this.sink);

  final String taskId;
  final _Disk disk;
  final Act0InMemoryTelemetrySinkV1 sink;
  String sessionId = '';
  String runId = '';
  bool? assessmentSeatAffordance;

  // Only flush/load are used here. Production writes and payload validation
  // remain owned by the actual shell's private progress-store instance.
  Act0ProgressStoreV1 get reader => Act0ProgressStoreV1(
    key: _progressKey,
    isValidPayload: (raw) => jsonDecode(raw) is Map,
  );
}

class _Snapshot {
  const _Snapshot(this.payload, this.history);

  final Map<String, dynamic> payload;
  final Act0LearningEvidenceHistoryV1 history;

  List<Act0LearningEvidenceRecordV1> recordsFor(String taskId) => history
      .records
      .where((record) => record.taskId == taskId)
      .toList(growable: false);

  bool get firstCorrectEarned => Act0AchievementSeedProjectionV1.fromSources(
    learningEvidenceHistory: history,
  ).seedForId(act0AchievementSeedFirstCorrectReadV1).earned;

  int get independentEligibleCount =>
      Act0LearningTransferMeasurementV1.fromLearningEvidence(history).signals
          .fold(0, (count, signal) => count + signal.eligibleEvidenceCount);
}

Act0LessonTaskV1 _task(String taskId) => Act0ShellStateV1.sample
    .worldById(_worldId)
    .lessons
    .singleWhere((lesson) => lesson.lessonId == _lessonId)
    .taskList
    .singleWhere((task) => task.taskId == taskId);

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Widget _host(Act0InMemoryTelemetrySinkV1 sink, Act0ShellTabV1 tab) =>
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: false,
        initialTab: tab,
        telemetrySink: sink,
      ),
    );

Future<void> _flush(WidgetTester tester, _Fixture fixture) async {
  await tester.pump();
  await fixture.reader.flush();
  await tester.pump();
}

Future<_Snapshot> _read(_Fixture fixture) async {
  final readsBefore = fixture.disk.readCount;
  final raw = await fixture.reader.load();
  expect(fixture.disk.readCount, greaterThan(readsBefore));
  expect(
    raw,
    isNotNull,
    reason: 'The real progress store must return saved bytes.',
  );
  final payload = Map<String, dynamic>.from(jsonDecode(raw!) as Map);
  final history = Act0LearningEvidenceHistoryV1.restore(
    payload['learningEvidenceHistory'],
    payload['learningEvidenceLineage'],
  );
  expect(
    history,
    isNotNull,
    reason: 'Saved evidence and lineage must parse together.',
  );
  return _Snapshot(payload, history!);
}

Future<_Fixture> _mount(WidgetTester tester, String taskId) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final priorPlatform = SharedPreferencesStorePlatform.instance;
  final world = Act0ShellStateV1.sample.worldById(_worldId);
  final lesson = world.lessons.singleWhere(
    (item) => item.lessonId == _lessonId,
  );
  final priorLessons = world.lessons
      .takeWhile((item) => item.lessonId != _lessonId)
      .toList();
  final completed = <String>[
    for (final item in priorLessons)
      for (final task in item.taskList) task.taskId,
    for (final task in lesson.taskList.takeWhile(
      (item) => item.taskId != taskId,
    ))
      task.taskId,
  ];
  expect(completed, isNot(contains(taskId)));
  const emptyHistory = Act0LearningEvidenceHistoryV1();
  SharedPreferences.setMockInitialValues({});
  final disk = _Disk({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _progressKey: jsonEncode({
      'schemaVersion': 19,
      'completedTaskIds': completed,
      'completedLessonIds': [for (final item in priorLessons) item.lessonId],
      'skippedTaskIds': <String>[],
      'selectedWorldId': _worldId,
      'selectedLessonId': _lessonId,
      'selectedTaskId': taskId,
      'earnedXp': 0,
      'learningEvidenceHistory': emptyHistory.toPayload(),
      'learningEvidenceLineage': emptyHistory.lineagePayload(),
      'sessionIdentityState': const Act0SessionIdentityStateV1().toPayload(),
    }),
  });
  SharedPreferencesStorePlatform.instance = disk;
  final fixture = _Fixture(taskId, disk, Act0InMemoryTelemetrySinkV1());
  addTearDown(() async {
    try {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await fixture.reader.flush();
    } finally {
      SharedPreferences.setMockInitialValues({});
      SharedPreferencesStorePlatform.instance = priorPlatform;
    }
  });
  await tester.pumpWidget(_host(fixture.sink, Act0ShellTabV1.learn));
  await tester.pumpAndSettle();
  await _flush(tester, fixture);
  // The real Learn launch creates the run/session identity. Merely booting
  // initialTab:play would skip that source-owned lifecycle operation.
  final launch = find.byKey(const Key('act0_shell_current_mission_cta'));
  expect(launch, findsOneWidget);
  await tester.ensureVisible(launch);
  await tester.pumpAndSettle();
  expect(launch.hitTestable(), findsOneWidget);
  expect(tester.widget<FilledButton>(launch).onPressed, isNotNull);
  await tester.tap(launch);
  await tester.pumpAndSettle();
  await _flush(tester, fixture);
  expect(_runner(tester).selectedTaskId, taskId);
  expect(_runner(tester).runner.phase, _task(taskId).entryPhase);
  fixture.runId = _runner(tester).evidenceRunId;
  expect(fixture.runId, isNotEmpty);
  final starts = fixture.sink.events
      .where(
        (event) =>
            event.name == 'session_start' && event.fields['task_id'] == taskId,
      )
      .toList();
  expect(starts, hasLength(1));
  expect(starts.single.fields['session_id'], isA<String>());
  fixture.sessionId = starts.single.fields['session_id'] as String;
  expect(fixture.sessionId, isNotEmpty);
  final before = await _read(fixture);
  expect(before.history.records, isEmpty);
  expect(before.history.hasCompleteLineage, isTrue);
  fixture.sink.events.clear();
  return fixture;
}

Future<void> _advanceToDrill(WidgetTester tester, _Fixture fixture) async {
  for (var step = 0; step < 12; step++) {
    final runner = _runner(tester);
    expect(runner.selectedTaskId, fixture.taskId);
    if (runner.runner.phase == Act0LessonPhaseV1.drill &&
        runner.runner.teachingStepIndex >= runner.runner.teachingSteps.length) {
      await tester.pumpAndSettle();
      return;
    }
    await tester.pump(const Duration(milliseconds: 900));
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    final next = theory.evaluate().isNotEmpty
        ? theory
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  fail(
    'The genuine source drill did not become ready through its teaching controls.',
  );
}

Future<void> _help(
  WidgetTester tester,
  Act0DecisionAssistanceV1 assistance,
) async {
  if (assistance == Act0DecisionAssistanceV1.none) return;
  expect(assistance, Act0DecisionAssistanceV1.theoryRecall);
  expect(_runner(tester).selectedTaskId, _drillTaskId);
  final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
  expect(hint, findsOneWidget);
  await tester.ensureVisible(hint);
  expect(hint.hitTestable(), findsOneWidget);
  await tester.tap(hint);
  await tester.pumpAndSettle();
  // The source seat branch calls _openTheoryRecallSheet directly. The inline
  // quick-hint peek/full-idea controls belong to other production routes.
  expect(find.byType(BottomSheet), findsOneWidget);
  expect(
    find.byKey(const Key('act0_shell_theory_recall_sheet')),
    findsOneWidget,
  );
  expect(find.byKey(const Key('act0_shell_hint_title')), findsNothing);
  expect(
    find.byKey(const Key('act0_shell_review_full_idea_cta')),
    findsNothing,
  );
  debugPrint(
    'ASM02_HELP_ROUTE ${jsonEncode({'task': _drillTaskId, 'route': 'seat_theory_recall_modal', 'expectedAssistance': assistance.name, 'quickHintAvailability': 'not_exposed_on_this_source_route'})}',
  );
  final close = find.byKey(const Key('act0_shell_theory_recall_close_cta'));
  expect(close, findsOneWidget);
  await tester.ensureVisible(close);
  expect(close.hitTestable(), findsOneWidget);
  await tester.tap(close);
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('act0_shell_theory_recall_sheet')), findsNothing);
}

Future<bool> _tapSourceSeat(
  WidgetTester tester,
  Act0RunnerOptionV1 option, {
  required bool allowTeachingDisabled,
}) async {
  expect(option.seatId, isNotNull);
  final tap = find.byKey(Key('act0_shell_seat_tap_${option.seatId}'));
  final node = find.byKey(Key('act0_shell_seat_node_${option.seatId}'));
  // A legitimate correction may remove a teaching seat's assessment affordance.
  // In that case physically tap the same visible seat; do not invoke callbacks.
  final active =
      tap.evaluate().isNotEmpty &&
      tester.widget<GestureDetector>(tap).onTap != null;
  if (!allowTeachingDisabled) expect(active, isTrue);
  final target = active ? tap : node;
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  if (active) {
    expect(target.hitTestable(), findsOneWidget);
    await tester.tap(target);
  } else {
    // An intentionally noninteractive teaching scene can IgnorePointer. Tap
    // the actual rendered seat center, while rejecting offscreen/empty nodes.
    final rect = tester.getRect(target);
    expect(rect.isEmpty, isFalse);
    expect((Offset.zero & const Size(393, 852)).contains(rect.center), isTrue);
    await tester.tapAt(rect.center);
  }
  await tester.pumpAndSettle();
  return active;
}

List<Act0TelemetryEventV1> _decisions(_Fixture fixture) => fixture.sink.events
    .where(
      (event) =>
          event.name == 'decision_made' &&
          event.fields['task_id'] == fixture.taskId,
    )
    .toList(growable: false);

void _validateCompletion(
  _Fixture fixture,
  _Snapshot saved, {
  required String choiceId,
  required String expectedId,
  required bool correct,
  required bool requireCompletion,
}) {
  final events = _decisions(fixture);
  final records = saved.recordsFor(fixture.taskId);
  expect(events.length, requireCompletion ? 1 : inInclusiveRange(0, 1));
  expect(
    records.length,
    events.length,
    reason:
        'A real completion must reach the canonical evidence append exactly once.',
  );
  if (events.isEmpty) return;
  final event = events.single.fields;
  final record = records.single;
  expect(event['chosen_action'], choiceId);
  expect(event['expected_action'], expectedId);
  expect(event['correct'], correct);
  expect(event['session_id'], fixture.sessionId);
  expect(record.recordId, event['attempt_id']);
  expect(record.worldId, _worldId);
  expect(record.lessonId, _lessonId);
  expect(record.sourceTaskId, fixture.taskId);
  expect(record.choiceId, choiceId);
  expect(record.expectedChoiceId, expectedId);
  expect(record.isCorrect, correct);
  expect(record.resultKind, correct ? 'correct' : 'incorrect');
  expect(record.errorType, correct ? 'none' : isNot('none'));
  expect(record.resultKind, event['result_classification']);
  expect(record.errorType, event['error_type']);
  expect(record.assistanceKind.name, event['assistance_kind']);
  expect(record.decisionTimeBucket, event['decisionTimeBucket']);
  expect(record.sessionId, fixture.sessionId);
  expect(record.runId, fixture.runId);
  expect(record.runId, isNotEmpty);
  expect(record.runKind, 'lesson');
  expect(record.startedBy, 'learn_route');
  expect(record.recordedAtUtc, isNotNull);
  expect(
    record.authoredSourceFingerprint,
    act0CurrentAuthoredSourceFingerprintForIdentityV1(
      worldId: _worldId,
      lessonId: _lessonId,
      taskId: fixture.taskId,
    ),
  );
  final saves = fixture.sink.events
      .where(
        (item) =>
            item.name == 'progress_persist_result' &&
            item.fields['task_id'] == fixture.taskId &&
            item.fields['session_id'] == record.sessionId,
      )
      .toList();
  expect(
    saves,
    isNotEmpty,
    reason: 'flush alone is not a storage acknowledgement.',
  );
  expect(
    saves.map((item) => item.fields['outcome']),
    everyElement('acknowledged'),
  );
  expect(
    fixture.disk.values['flutter.${_progressKey}_head'],
    fixture.disk.values['flutter.${_progressKey}_recovery'],
  );
  expect(fixture.disk.values['flutter.${_progressKey}_head'], isA<String>());
}

void _trace(String stage, _Fixture fixture, _Snapshot snapshot) {
  final records = snapshot.recordsFor(fixture.taskId);
  debugPrint(
    'ASM02_POSITIONS_TRACE ${jsonEncode({
      'stage': stage,
      'task': fixture.taskId,
      'sourceRunId': fixture.runId,
      'sourceSessionId': fixture.sessionId,
      'activeAssessmentSeatAffordance': fixture.assessmentSeatAffordance,
      'records': [for (final record in records) record.toPayload()],
      'sourceProofs': [
        for (final record in records) {'recordId': record.recordId, 'resolved': act0CurrentAuthoredSourceProofV1(record) != null, 'currentlyCorrect': act0CurrentAuthoredSourceProofV1(record)?.isCurrentlyCorrect},
      ],
      'completeSourceReaderCount': act0CompleteCurrentAuthoredEvidenceV1(snapshot.history).records.length,
      'independentEligibleCount': snapshot.independentEligibleCount,
      'firstCorrectEarned': snapshot.firstCorrectEarned,
      'targetCompleted': (snapshot.payload['completedTaskIds'] as List).contains(fixture.taskId),
      'earnedXp': snapshot.payload['earnedXp'],
      'decisions': [for (final event in _decisions(fixture)) event.fields],
      'saves': [for (final event in fixture.sink.events.where((event) => event.name == 'progress_persist_result')) event.fields],
      // Fixed observation boundaries only. These are actual emitted bytes and
      // decoded payload, including lineage, for later compatibility replay.
      'durableSnapshot': {'payload': snapshot.payload, 'headEnvelope': fixture.disk.values['flutter.${_progressKey}_head'], 'recoveryEnvelope': fixture.disk.values['flutter.${_progressKey}_recovery']},
    })}',
  );
}

Future<_Snapshot> _continueAfterDecision(
  WidgetTester tester,
  _Fixture fixture,
  _Snapshot before, {
  required bool correct,
}) async {
  expect(_runner(tester).runner.phase, Act0LessonPhaseV1.review);
  expect(before.payload['completedTaskIds'], isNot(contains(fixture.taskId)));
  expect(before.payload['earnedXp'], 0);
  final next = find.byKey(const Key('act0_shell_feedback_continue_cta'));
  expect(next, findsOneWidget);
  await tester.ensureVisible(next);
  await tester.pumpAndSettle();
  expect(next.hitTestable(), findsOneWidget);
  expect(tester.widget<FilledButton>(next).onPressed, isNotNull);
  final eventStart = fixture.sink.events.length;
  await tester.tap(next);
  await tester.pumpAndSettle();
  await _flush(tester, fixture);
  final after = await _read(fixture);
  _trace(
    'after_real_feedback_continue_${correct ? "correct" : "wrong"}',
    fixture,
    after,
  );
  final currentRunner = _runner(tester);
  final newSaves = fixture.sink.events
      .skip(eventStart)
      .where((event) => event.name == 'progress_persist_result')
      .toList();
  final declaredRepairTarget = _decisions(
    fixture,
  ).single.fields['repair_target_task_id'];
  debugPrint(
    'ASM02_TASK_BOUNDARY ${jsonEncode({
      'targetTask': fixture.taskId,
      'answerCorrect': correct,
      'currentSourceTask': currentRunner.selectedTaskId,
      'currentSourcePhase': currentRunner.runner.phase.name,
      'sourceDeclaredRepairTask': declaredRepairTarget,
      'newSaveOutcomes': [for (final event in newSaves) event.fields['outcome']],
      'taskCompleted': (after.payload['completedTaskIds'] as List).contains(fixture.taskId),
      'earnedXp': after.payload['earnedXp'],
    })}',
  );
  // Continue may navigate into a source-owned retry/repair. It must not append
  // another decision or rewrite the actual target answer and its lineage.
  expect(after.history.toPayload(), before.history.toPayload());
  expect(after.history.lineagePayload(), before.history.lineagePayload());
  expect(_decisions(fixture), hasLength(1));
  expect(currentRunner.runner.selectedOptionId, isNull);
  if (correct) {
    expect(after.payload['completedTaskIds'], contains(fixture.taskId));
    expect(
      (after.payload['completedTaskIds'] as List).where(
        (id) => id == fixture.taskId,
      ),
      hasLength(1),
    );
    expect(after.payload['earnedXp'], _task(fixture.taskId).rewardXp);
    expect(after.payload['selectedTaskId'], currentRunner.selectedTaskId);
    // Completion and successor navigation queue snapshots in one callback;
    // production may coalesce them. Join the acknowledged final route while
    // checking the original target's completion/reward separately above.
    final completionSaves = newSaves.where(
      (event) =>
          event.fields['task_id'] == after.payload['selectedTaskId'] &&
          event.fields['world_id'] == after.payload['selectedWorldId'] &&
          event.fields['lesson_id'] == after.payload['selectedLessonId'] &&
          event.fields['session_id'] == fixture.sessionId &&
          event.fields['operation'] == 'save',
    );
    expect(completionSaves, isNotEmpty);
    expect(
      completionSaves.map((event) => event.fields['outcome']),
      everyElement('acknowledged'),
    );
  } else {
    // The source CTA starts repair or an inside-lesson retry after a miss. No
    // correct follow-up is supplied merely to manufacture task completion.
    expect(currentRunner.runner.phase, Act0LessonPhaseV1.drill);
    if (currentRunner.selectedTaskId != fixture.taskId) {
      expect(declaredRepairTarget, isA<String>());
      expect((declaredRepairTarget as String).trim(), isNotEmpty);
      // decision_made carries a receipt nextRepId, not a concrete route ID.
      // Production maps it before the CTA and binds the stored intent to the
      // canonical miss. Read that actual intent; do not reconstruct a target.
      final originalRecord = before.recordsFor(fixture.taskId).single;
      final intents = (before.payload['openRepairIntents'] as List)
          .map(Act0RepairIntentV1.tryParse)
          .whereType<Act0RepairIntentV1>()
          .where(
            (intent) =>
                intent.sourceTaskId == fixture.taskId &&
                intent.repairOccurrenceId == originalRecord.recordId,
          )
          .toList();
      expect(intents, hasLength(1));
      final intent = intents.single;
      expect(intent.sourceWorldId, originalRecord.worldId);
      expect(intent.sourceLessonId, originalRecord.lessonId);
      expect(intent.choiceId, originalRecord.choiceId);
      expect(intent.result, originalRecord.resultKind);
      expect(intent.errorType, originalRecord.errorType);
      expect(intent.missedSignalId, originalRecord.repairFocusId);
      expect(intent.skillAtomId, originalRecord.skillAtomId);
      expect(currentRunner.selectedTaskId, intent.targetTaskId);
      expect(after.payload['selectedTaskId'], intent.targetTaskId);
      expect(after.payload['selectedLessonId'], intent.targetLessonId);
      expect(after.payload['selectedWorldId'], intent.targetWorldId);
      final launches = fixture.sink.events
          .skip(eventStart)
          .where(
            (event) =>
                event.name == 'repair_entered' &&
                event.fields['source_task_id'] == intent.sourceTaskId &&
                event.fields['repair_task_id'] == intent.targetTaskId,
          )
          .toList();
      expect(launches, hasLength(1));
      debugPrint(
        'ASM02_REPAIR_ROUTE_JOIN ${jsonEncode({'receiptRepId': declaredRepairTarget, 'persistedIntentBeforeContinue': intent.toPayload(), 'actualRepairEntered': launches.single.fields})}',
      );
    }
    expect(after.payload['completedTaskIds'], isNot(contains(fixture.taskId)));
    expect(after.payload['earnedXp'], 0);
    // The source may not issue a save for navigation alone. The original wrong
    // answer's joined acknowledgement was already required before this CTA.
    expect(
      newSaves.map((event) => event.fields['outcome']),
      everyElement('acknowledged'),
    );
  }
  return after;
}

Future<_Snapshot> _restart(
  WidgetTester tester,
  _Fixture fixture,
  _Snapshot before,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await fixture.reader.flush();
  final durableBefore = Map<String, Object>.of(fixture.disk.values);
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesStorePlatform.instance = fixture.disk;
  expect(
    fixture.disk.values,
    durableBefore,
    reason: 'Restart must never re-seed saved progress.',
  );
  final readsBefore = fixture.disk.readCount;
  await tester.pumpWidget(_host(fixture.sink, Act0ShellTabV1.profile));
  await tester.pumpAndSettle();
  expect(fixture.disk.readCount, greaterThan(readsBefore));
  await _flush(tester, fixture);
  // Reading unchanged disk bytes alone cannot show that the new shell restored
  // a wrong/assisted record. Ask the existing observer to serialize its actual
  // restored in-memory state; no record, completion or payload is supplied.
  final restoredSaveStart = fixture.sink.events.length;
  final dynamic restoredShell = tester.state(
    find.byType(Act0ShellPreviewScreenV1),
  );
  restoredShell.debugPersistProgressV1();
  await _flush(tester, fixture);
  final restoredSaves = fixture.sink.events
      .skip(restoredSaveStart)
      .where((event) => event.name == 'progress_persist_result')
      .toList();
  expect(
    restoredSaves,
    hasLength(1),
    reason: 'Require a new save of the fresh shell state.',
  );
  expect(restoredSaves.single.fields['operation'], 'save');
  expect(restoredSaves.single.fields['outcome'], 'acknowledged');
  final after = await _read(fixture);
  _trace(
    'after_cache_reset_fresh_shell_and_acknowledged_reserialization',
    fixture,
    after,
  );
  expect(after.history.toPayload(), before.history.toPayload());
  expect(after.history.lineagePayload(), before.history.lineagePayload());
  expect(
    after.payload['completedTaskIds'],
    unorderedEquals(before.payload['completedTaskIds'] as List),
  );
  expect(after.payload['earnedXp'], before.payload['earnedXp']);
  final legacy = find.byType(Act0ProfileShellV1);
  final academy = find.byType(Act0AcademyYouLeafV1);
  expect(legacy.evaluate().length + academy.evaluate().length, 1);
  final moments = legacy.evaluate().isNotEmpty
      ? tester
            .widget<Act0ProfileShellV1>(legacy)
            .achievementSeedConsumer
            .moments
      : tester.widget<Act0AcademyYouLeafV1>(academy).input.earnedMoments;
  expect(
    moments.any(
      (moment) => moment.seedId == act0AchievementSeedFirstCorrectReadV1,
    ),
    after.firstCorrectEarned,
    reason:
        'The fresh production You consumer must agree with the saved evidence.',
  );
  return after;
}

Future<_Snapshot> _continueTeachingAfterDisabledTap(
  WidgetTester tester,
  _Fixture fixture,
) async {
  for (
    var step = 0;
    step < 12 && _runner(tester).selectedTaskId == _theoryTaskId;
    step++
  ) {
    await tester.pump(const Duration(milliseconds: 900));
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    final next = theory.evaluate().isNotEmpty
        ? theory
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.ensureVisible(next);
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  expect(_runner(tester).selectedTaskId, isNot(_theoryTaskId));
  await _flush(tester, fixture);
  final saved = await _read(fixture);
  _trace('after_disabled_teaching_tap_and_real_continue', fixture, saved);
  expect(saved.recordsFor(_theoryTaskId), isEmpty);
  expect(saved.payload['completedTaskIds'], contains(_theoryTaskId));
  expect(saved.payload['earnedXp'], _task(_theoryTaskId).rewardXp);
  expect(_decisions(fixture), isEmpty);
  return saved;
}

void main() {
  for (final correct in [true, false]) {
    testWidgets(
      'ASM02 theory ${correct ? "BTN" : "UTG"} tap cannot become independent proof after save and reload',
      (tester) async {
        final task = _task(_theoryTaskId);
        expect(task.phase, Act0LessonPhaseV1.theory);
        expect(
          task.runner.table.seats
              .singleWhere((seat) => seat.isDealerButton)
              .seatId,
          'btn',
        );
        final choiceId = correct ? 'bottom' : 'top';
        final option = task.runner.options.singleWhere(
          (item) => item.id == choiceId,
        );
        expect(option.seatId, correct ? 'btn' : 'utg');
        final fixture = await _mount(tester, task.taskId);
        fixture.assessmentSeatAffordance = await _tapSourceSeat(
          tester,
          option,
          allowTeachingDisabled: true,
        );
        await _flush(tester, fixture);
        final saved = await _read(fixture);
        _trace('after_real_theory_tap', fixture, saved);
        _validateCompletion(
          fixture,
          saved,
          choiceId: choiceId,
          expectedId: 'bottom',
          correct: correct,
          requireCompletion: fixture.assessmentSeatAffordance!,
        );
        if (!fixture.assessmentSeatAffordance!) {
          expect(_decisions(fixture), isEmpty);
          expect(saved.recordsFor(task.taskId), isEmpty);
        }
        final afterContinue = fixture.assessmentSeatAffordance!
            ? await _continueAfterDecision(
                tester,
                fixture,
                saved,
                correct: correct,
              )
            : await _continueTeachingAfterDisabledTap(tester, fixture);
        final restored = await _restart(tester, fixture, afterContinue);
        // These are the contract assertions. They deliberately run after the
        // actual completion/save/reload/consumer observations have been logged.
        expect(
          restored
              .recordsFor(task.taskId)
              .where((record) => record.isIndependentCorrect),
          isEmpty,
          reason: 'Authored teaching is not an independent correct assessment.',
        );
        expect(
          restored.independentEligibleCount,
          0,
          reason:
              'Neither a correct nor a wrong teaching tap is an independent assessment sample.',
        );
        expect(restored.firstCorrectEarned, isFalse);
      },
    );
  }

  testWidgets(
    'ASM02 ordinary positions theory Continue saves completion without an assessment',
    (tester) async {
      final fixture = await _mount(tester, _theoryTaskId);
      for (
        var step = 0;
        step < 12 && _runner(tester).selectedTaskId == _theoryTaskId;
        step++
      ) {
        await tester.pump(const Duration(milliseconds: 900));
        final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
        final next = theory.evaluate().isNotEmpty
            ? theory
            : find.byKey(const Key('act0_shell_continue_cta'));
        expect(next, findsOneWidget);
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(_runner(tester).selectedTaskId, isNot(_theoryTaskId));
      await _flush(tester, fixture);
      final saved = await _read(fixture);
      _trace('after_ordinary_continue', fixture, saved);
      expect(_decisions(fixture), isEmpty);
      expect(saved.history.records, isEmpty);
      expect(saved.payload['completedTaskIds'], contains(_theoryTaskId));
      expect(saved.payload['earnedXp'], _task(_theoryTaskId).rewardXp);
      final saves = fixture.sink.events
          .where((event) => event.name == 'progress_persist_result')
          .toList();
      expect(saves, isNotEmpty);
      expect(
        saves.map((event) => event.fields['outcome']),
        everyElement('acknowledged'),
      );
      final restored = await _restart(tester, fixture, saved);
      expect(restored.payload['completedTaskIds'], contains(_theoryTaskId));
      expect(restored.history.records, isEmpty);
      expect(restored.independentEligibleCount, 0);
      expect(restored.firstCorrectEarned, isFalse);
    },
  );

  for (final assistance in [
    Act0DecisionAssistanceV1.none,
    Act0DecisionAssistanceV1.theoryRecall,
  ]) {
    for (final correct in [true, false]) {
      testWidgets(
        'ASM02 genuine UTG drill ${assistance.name} ${correct ? "correct" : "wrong"} survives save and reload honestly',
        (tester) async {
          final task = _task(_drillTaskId);
          expect(task.phase, Act0LessonPhaseV1.drill);
          expect(task.runner.table.highlightedSeatIds, isEmpty);
          expect(task.runner.table.activeSeatId, isEmpty);
          final choiceId = correct ? 'utg' : 'hj';
          final option = task.runner.options.singleWhere(
            (item) => item.id == choiceId,
          );
          expect(option.seatId, choiceId);
          final fixture = await _mount(tester, task.taskId);
          await _advanceToDrill(tester, fixture);
          await _help(tester, assistance);
          await _flush(tester, fixture);
          expect((await _read(fixture)).history.records, isEmpty);
          // Only a save issued after the physical answer may acknowledge it.
          // Clearing telemetry does not change runtime assistance or evidence.
          fixture.sink.events.clear();
          fixture.assessmentSeatAffordance = await _tapSourceSeat(
            tester,
            option,
            allowTeachingDisabled: false,
          );
          await _flush(tester, fixture);
          final saved = await _read(fixture);
          _trace('after_real_drill_choice_${assistance.name}', fixture, saved);
          _validateCompletion(
            fixture,
            saved,
            choiceId: choiceId,
            expectedId: 'utg',
            correct: correct,
            requireCompletion: true,
          );
          final afterContinue = await _continueAfterDecision(
            tester,
            fixture,
            saved,
            correct: correct,
          );
          final restored = await _restart(tester, fixture, afterContinue);
          final record = restored.recordsFor(task.taskId).single;
          final proof = act0CurrentAuthoredSourceProofV1(record);
          expect(
            proof,
            isNotNull,
            reason:
                'Re-run the real authored-source reader on reloaded evidence.',
          );
          expect(proof!.isCurrentlyCorrect, correct);
          expect(
            act0CompleteCurrentAuthoredEvidenceV1(restored.history).records,
            hasLength(1),
          );
          expect(record.assistanceKind, assistance);
          final independent = assistance == Act0DecisionAssistanceV1.none;
          expect(record.isIndependentCorrect, correct && independent);
          expect(restored.independentEligibleCount, independent ? 1 : 0);
          expect(restored.firstCorrectEarned, correct && independent);
        },
      );
    }
  }
}
