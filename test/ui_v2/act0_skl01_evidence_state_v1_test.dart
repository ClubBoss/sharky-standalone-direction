import 'dart:convert';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
// Deterministic/widget evidence only. Simulated clocks are not Human retention.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_record_card_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_evidence_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../support/act0_shell_presentation_finders_v1.dart';

final _start = DateTime.utc(2026, 1, 1);
final _now = _start.add(const Duration(days: 20));
Act0LessonTaskV1 get _theory => Act0ShellStateV1.sample
    .lessonById('blinds_action_order')
    .taskList
    .singleWhere((t) => t.taskId == 'positions_theory');

Act0StudyObservationV1 _study({String? revision, DateTime? time}) =>
    Act0StudyObservationV1(
      worldId: 'world_1',
      lessonId: 'blinds_action_order',
      taskId: _theory.taskId,
      sourceRevision:
          revision ??
          act0AuthoredStudyRevisionV1(
            worldId: 'world_1',
            lessonId: 'blinds_action_order',
            task: _theory,
          )!,
      sessionId: 'study-session',
      recordedAtUtc: time ?? _start,
    );

Act0ProfileEvidenceProjectionV1 _project({
  List<Act0StudyObservationV1> study = const [],
  Act0LearningEvidenceHistoryV1 history = const Act0LearningEvidenceHistoryV1(),
}) => Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(
  history,
  studyObservations: study,
  nowUtc: _now,
);

Act0LearningEvidenceRecordV1 _response(
  int order, {
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  String? fingerprint,
  String? session,
  int? hours,
  bool correct = true,
  String runKind = '',
  bool timestamped = true,
}) {
  final task = Act0ShellStateV1.sample
      .lessonById('blinds_action_order')
      .taskList
      .singleWhere(
        (t) =>
            t.taskId == (order.isEven ? 'blinds_first_actor' : 'blinds_review'),
      );
  final option = task.runner.options.firstWhere((o) => o.isCorrect == correct);
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: task.runner,
    option: option,
    taskFamily: task.resolvedTaskFamily,
  )!;
  return Act0LearningEvidenceRecordV1(
    recordId: 'skl-response-$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'blinds_action_order',
    taskId: task.taskId,
    sourceTaskId: task.taskId,
    choiceId: option.id,
    expectedChoiceId: task.runner.options.firstWhere((o) => o.isCorrect).id,
    isCorrect: correct,
    errorType: correct ? 'none' : 'missed_action_read',
    conceptFamilyId: receipt.sourceSignalId,
    repairFocusId: receipt.sourceSignalId,
    skillAtomId: receipt.skillAtomId,
    decisionTimeBucket: '3_to_10s',
    resultKind: correct ? 'correct' : 'incorrect',
    assistanceKind: assistance,
    authoredSourceFingerprint:
        fingerprint ??
        act0AuthoredSourceFingerprintV1(
          worldId: 'world_1',
          lessonId: 'blinds_action_order',
          task: task,
        )!,
    sessionId: session ?? 'session-$order',
    runKind: runKind,
    recordedAtUtc: timestamped
        ? _start.add(Duration(hours: hours ?? order * 24))
        : null,
    reviewKind: Act0ReviewKindV1.spacedReview,
  );
}

void main() {
  test(
    'the weekly recap counts dated graded responses at the exact clock boundaries',
    () {
      final startHour = _now.difference(_start).inHours - 7 * 24;
      final onBoundary = _response(1, hours: startHour);
      final history = Act0LearningEvidenceHistoryV1(
        records: [
          onBoundary,
          onBoundary,
          _response(2, hours: startHour - 1),
          _response(
            3,
            hours: startHour + 3,
            assistance: Act0DecisionAssistanceV1.quickHint,
          ),
          _response(
            4,
            hours: startHour + 4,
            assistance: Act0DecisionAssistanceV1.legacyUnknown,
          ),
          _response(5, hours: startHour + 5, correct: false),
          _response(
            6,
            hours: startHour + 6,
            runKind: act0PlacementAssessmentRunKindV1,
          ),
          _response(
            7,
            hours: startHour + 7,
            runKind: act0DiagnosticLearningEntryRunKindV1,
          ),
          _response(8, hours: startHour + 7 * 24 + 1),
          _response(9, timestamped: false),
        ],
      );
      final summary = _project(
        study: [_study(time: _now)],
        history: history,
      ).weeklyAnswers!;
      expect(summary.answers, 4);
      expect(summary.correctWithoutHelp, 1);
      expect(summary.withHelp, 1);

      final later = Act0WeeklyAnswersV1.fromHistory(
        history,
        _now.add(const Duration(days: 8)),
      );
      expect(later.answers, 0);
      expect(_project(study: [_study(time: _now)]).weeklyAnswers!.answers, 0);
    },
  );

  testWidgets('You shows saved weekly responses and opens the Practice hub', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final answer = _response(1, hours: _now.difference(_start).inHours - 1);
    SharedPreferences.setMockInitialValues({
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 17,
        'earnedXp': 0,
        'completedTaskIds': [],
        'skippedTaskIds': [],
        'completedLessonIds': [],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is_content',
        'selectedTaskId': 'what_poker_is_pot_stack',
        'learningEvidenceHistory': [answer.toPayload()],
      }),
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.profile,
          showPlacementOnStart: false,
          clock: Act0FixedUtcClockV1(_now),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final action = find.byKey(const Key('act0_weekly_open_practice'));
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      action.hitTestable(),
      280,
      scrollable: scrollable,
    );
    expect(find.text('Past 7 days'), findsOneWidget);
    expect(find.text('1 saved answer'), findsOneWidget);
    expect(find.text('1 correct without help'), findsOneWidget);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(
      act0ShellPresentationFinderV1('act0_shell_play_screen'),
      findsOneWidget,
    );
  });

  test(
    'study is an exact topic observation, never practice or independent proof',
    () {
      final study = _study();
      final restored = Act0StudyObservationV1.restore([study.toPayload()])!;
      final projection = _project(study: restored);
      expect(projection.studiedTopics.single.title, _theory.title);
      expect(
        projection.studiedTopics.single.observation.toPayload(),
        study.toPayload(),
      );
      expect(projection.practiceStates, isEmpty);
      expect(projection.signals, isEmpty);
      expect(_project().studiedTopics, isEmpty);
    },
  );

  test(
    'duplicate delivery is once-only and conflicting study fails closed',
    () {
      final payload = _study().toPayload();
      expect(Act0StudyObservationV1.restore([payload, payload]), hasLength(1));
      expect(_project(study: [_study(), _study()]).studiedTopics, hasLength(1));
      final conflict = _study(time: _start.add(const Duration(hours: 1)));
      expect(
        Act0StudyObservationV1.restore([payload, conflict.toPayload()]),
        isNull,
      );
      expect(_project(study: [_study(), conflict]).studiedTopics, isEmpty);
    },
  );

  test('unknown schema, wrong role and partial observation are rejected', () {
    final payload = _study().toPayload();
    for (final bad in [
      {...payload, 'schemaVersion': 99},
      {...payload, 'role': 'unseen'},
      {...payload}..remove('sessionId'),
      {...payload}..remove('sourceRevision'),
      {...payload, 'sourceRevision': 'unversioned'},
      {...payload, 'observationId': 'another event'},
      {...payload, 'recordedAtUtc': '2026-01-01T00:00:00'},
    ]) {
      expect(Act0StudyObservationV1.restore([bad]), isNull);
    }
    expect(Act0StudyObservationV1.restore('partial'), isNull);
  });

  test('stale or future study is retained but not promoted', () {
    final stale = _study(revision: '0' * 64);
    final future = _study(time: _now.add(const Duration(seconds: 1)));
    final history = Act0StudyObservationV1.restore([
      stale.toPayload(),
      future.toPayload(),
    ])!;
    final projection = _project(study: history);
    expect(projection.studiedTopics, isEmpty);
    expect(projection.unverifiedStudyCount, 2);
    expect(history.map((r) => r.toPayload()), [
      stale.toPayload(),
      future.toPayload(),
    ]);
  });

  test(
    'teaching-only content and table revisions invalidate study independently of assessment',
    () {
      final task = _theory;
      Act0LessonTaskV1 changed({bool role = false, bool table = false}) =>
          Act0LessonTaskV1(
            taskId: task.taskId,
            title: task.title,
            phase: role ? Act0LessonPhaseV1.drill : task.phase,
            rewardXp: task.rewardXp,
            stepKind: task.stepKind,
            taskFamily: task.taskFamily,
            tablePresentation: task.tablePresentation,
            runner: task.runner.copyWith(
              teachingSteps: [
                for (final step in task.runner.teachingSteps)
                  Act0TeachingStepV1(
                    title: step.title,
                    body: table
                        ? step.body
                        : '${step.body} Revised explanation.',
                    table: table
                        ? (step.table ?? task.runner.table).copyWith(
                            potLabel: 'Pot 9 BB',
                          )
                        : step.table,
                    focusSeatIds: step.focusSeatIds,
                    focusCardIds: step.focusCardIds,
                    focusLabels: step.focusLabels,
                    ctaLabel: step.ctaLabel,
                    identityTeachingSemantics: step.identityTeachingSemantics,
                  ),
              ],
            ),
          );
      final original = act0AuthoredStudyRevisionV1(
        worldId: 'world_1',
        lessonId: 'blinds_action_order',
        task: task,
      );
      for (final revised in [changed(), changed(table: true)]) {
        expect(
          act0AuthoredStudyRevisionV1(
            worldId: 'world_1',
            lessonId: 'blinds_action_order',
            task: revised,
          ),
          isNot(original),
        );
        expect(
          act0AuthoredSourceFingerprintV1(
            worldId: 'world_1',
            lessonId: 'blinds_action_order',
            task: revised,
          ),
          act0AuthoredSourceFingerprintV1(
            worldId: 'world_1',
            lessonId: 'blinds_action_order',
            task: task,
          ),
        );
      }
      expect(
        act0AuthoredStudyRevisionV1(
          worldId: 'world_1',
          lessonId: 'blinds_action_order',
          task: changed(role: true),
        ),
        isNull,
      );
      expect(
        act0AuthoredStudyRevisionV1(
          worldId: 'world_1',
          lessonId: 'blinds_action_order',
          task: task,
        ),
        original,
      );
    },
  );

  test(
    'assisted practice and an independent response remain different from confirmation',
    () {
      for (final assistance in [
        Act0DecisionAssistanceV1.none,
        Act0DecisionAssistanceV1.quickHint,
        Act0DecisionAssistanceV1.theoryRecall,
      ]) {
        final projection = _project(
          history: Act0LearningEvidenceHistoryV1(
            records: [_response(1, assistance: assistance)],
          ),
        );
        final state = projection.practiceStates.single;
        expect(state.stateLabel, 'Practiced');
        expect(state.hasRecentIndependentConfirmation, isFalse);
        expect(
          state.assistedCount,
          assistance == Act0DecisionAssistanceV1.none ? 0 : 1,
        );
        expect(
          state.signal.eligibleEvidenceCount,
          assistance == Act0DecisionAssistanceV1.none ? 1 : 0,
        );
      }
    },
  );

  test(
    'existing response diversity and elapsed contract alone grants recent confirmation',
    () {
      final records = [for (var i = 1; i <= 5; i++) _response(i)];
      final projection = _project(
        history: Act0LearningEvidenceHistoryV1(records: records),
      );
      expect(
        projection.practiceStates.single.stateLabel,
        'Recent verified responses',
      );
      expect(
        projection.practiceStates.single.records.map((r) => r.recordId),
        records.map((r) => r.recordId),
      );
      for (final ineligible in [
        [for (var i = 1; i <= 5; i++) _response(i, session: 'one-session')],
        [for (var i = 1; i <= 5; i++) _response(i, hours: i)],
        [
          for (var i = 1; i <= 5; i++)
            _response(i, assistance: Act0DecisionAssistanceV1.quickHint),
        ],
      ]) {
        expect(
          _project(
            history: Act0LearningEvidenceHistoryV1(records: ineligible),
          ).practiceStates.single.hasRecentIndependentConfirmation,
          isFalse,
        );
      }
    },
  );

  test(
    'duplicate, stale, unknown and incomplete grade provenance cannot promote',
    () {
      final records = [for (var i = 1; i <= 5; i++) _response(i)];
      final duplicated = _project(
        history: Act0LearningEvidenceHistoryV1(
          records: [records.first, records.first],
        ),
      );
      expect(duplicated.practiceStates.single.records, hasLength(1));
      for (final last in [
        _response(5, fingerprint: '0' * 64),
        _response(5, assistance: Act0DecisionAssistanceV1.legacyUnknown),
        Act0LearningEvidenceRecordV1.tryParse({
          ..._response(5).toPayload(),
          'taskId': 'unknown-task',
        })!,
      ]) {
        final projection = _project(
          history: Act0LearningEvidenceHistoryV1(
            records: [...records.take(4), last],
          ),
        );
        expect(
          projection.practiceStates.where(
            (s) => s.hasRecentIndependentConfirmation,
          ),
          isEmpty,
        );
        expect(projection.hasUnverifiedPractice, isTrue);
      }
      final conflict = Act0LearningEvidenceRecordV1.tryParse({
        ...records.last.toPayload(),
        'sessionId': 'conflicting-session',
      })!;
      expect(
        _project(
          history: Act0LearningEvidenceHistoryV1(
            records: [...records, conflict],
          ),
        ).practiceStates.where((s) => s.hasRecentIndependentConfirmation),
        isEmpty,
      );
    },
  );

  testWidgets(
    'You card explains studied and assisted practice at the reference size',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final projection = _project(
        study: [_study()],
        history: Act0LearningEvidenceHistoryV1(
          records: [
            _response(1, assistance: Act0DecisionAssistanceV1.quickHint),
          ],
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [Act0LearningRecordCardV1(projection: projection)],
            ),
          ),
        ),
      );
      expect(find.text('Studied topics · 1'), findsOneWidget);
      expect(find.text('Practiced'), findsOneWidget);
      expect(find.text('Recent verified responses'), findsNothing);
      await tester.tap(find.text('Practiced'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 with help'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
