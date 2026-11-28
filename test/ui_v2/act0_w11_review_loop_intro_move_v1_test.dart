import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w14_skill_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_shell_presentation_finders_v1.dart';

const _world = 'world_11';
const _old = 'table_trigger_multiway_and_spr';
const _new = 'post_session_review_loop';
const _intro = 'w11_review_loop_intro';
const _correct = 'bb_called_8_into_18_versus_a_tight_turn_range';
const _wrong = 'lost_a_big_pot_and_felt_bad';
const _key = 'act0_shell_progress_v1';
final _catalog = Act0ShellStateV1.sample;
final _lessons = _catalog.worldById(_world).lessons;
final _multiway = _lessons.singleWhere((l) => l.lessonId == _old);
final _review = _lessons.singleWhere((l) => l.lessonId == _new);
final _task = _review.courseTaskList.firstWhere((t) => t.taskId == _intro);

// Reconstruct the pre-B151 assessment from the historical title, empty
// teaching rail and still-identical assessment fields. No current-identity
// resolver is used to manufacture the legacy fingerprint.
String get _legacyFingerprint => act0AuthoredSourceFingerprintV1(
  worldId: _world,
  lessonId: _old,
  task: Act0LessonTaskV1(
    taskId: _intro,
    title: _task.title,
    phase: _task.phase,
    stepKind: _task.stepKind,
    rewardXp: 7,
    taskFamily: _task.taskFamily,
    tablePresentation: _task.tablePresentation,
    runner: _task.runner.copyWith(
      lessonTitle: 'Multiway pots and stack depth',
      teachingSteps: const [],
    ),
  ),
)!;

Act0LearningEvidenceRecordV1 _record({
  bool correct = false,
  String lesson = _old,
  int order = 1,
  String? fingerprint,
}) => Act0LearningEvidenceRecordV1(
  recordId: 'w11-answer-$order',
  createdOrder: order,
  worldId: _world,
  lessonId: lesson,
  taskId: _intro,
  sourceTaskId: _intro,
  choiceId: correct ? _correct : _wrong,
  expectedChoiceId: _correct,
  isCorrect: correct,
  errorType: correct ? 'none' : 'misread_real_play_process',
  repairFocusId: 'misread_real_play_process',
  skillAtomId: 'table_read',
  decisionTimeBucket: 'under_3s',
  resultKind: correct ? 'correct' : 'incorrect',
  runKind: 'lesson',
  runId: 'lesson-run-1',
  sessionId: 'session_v1|1',
  runOrdinal: 1,
  assistanceKind: Act0DecisionAssistanceV1.none,
  authoredSourceFingerprint: fingerprint ?? _legacyFingerprint,
);

Map<String, Object?> _save({
  required bool introDone,
  required bool reviewDone,
  required String selectedLesson,
  required String selectedTask,
  bool resume = false,
}) {
  final earlier = [
    for (final w in _catalog.worlds.where((w) => w.worldNumber < 11))
      ...w.lessons,
    ..._lessons.takeWhile((l) => l.lessonId != _old),
  ];
  final finished = [
    for (final lesson in earlier) ...lesson.courseTaskList,
    ..._multiway.courseTaskList,
    if (introDone) _task,
    if (reviewDone) ..._review.courseTaskList.where((t) => t.taskId != _intro),
  ];
  return {
    'schemaVersion': 20,
    'pendingDecisionAssistance': <Object>[],
    'learningEvidenceHistory': <Object>[],
    'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
        .lineagePayload(),
    'completedTaskIds': finished.map((t) => t.taskId).toList(),
    'completedLessonIds': [
      ...earlier.map((l) => l.lessonId),
      if (introDone) _old,
      if (reviewDone) _new,
    ],
    'selectedWorldId': _world,
    'selectedLessonId': selectedLesson,
    'selectedTaskId': selectedTask,
    'earnedXp': finished.fold<int>(0, (sum, t) => sum + t.rewardXp),
    'w1StartChosen': true,
    'w1RulesBestScore': act0W1RulesQuestionsV1.length,
    if (resume)
      'lessonResume': {
        'worldId': _world,
        'lessonId': _old,
        'taskId': _intro,
        'phase': 'theory',
        'teachingStepIndex': 0,
        'selectedOptionId': null,
      },
  };
}

Future<dynamic> _mount(
  WidgetTester t,
  Map<String, Object?> saved, {
  Act0ShellTabV1 tab = Act0ShellTabV1.home,
}) async {
  SharedPreferences.setMockInitialValues({
    _key: jsonEncode(saved),
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
  });
  await t.binding.setSurfaceSize(const Size(393, 852));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        showPlacementOnStart: false,
        initialTab: tab,
      ),
    ),
  );
  await t.pumpAndSettle();
  return t.state(find.byType(Act0ShellPreviewScreenV1));
}

Future<Map<String, dynamic>> _persist(WidgetTester t, dynamic state) async {
  state.debugPersistProgressV1();
  await t.pump(const Duration(milliseconds: 250));
  return (await t.runAsync(() async {
    await Act0ProgressStoreV1(key: _key, isValidPayload: (_) => true).flush();
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final head = jsonDecode(prefs.getString('${_key}_head')!) as Map;
    return jsonDecode(head['payload'] as String) as Map<String, dynamic>;
  }))!;
}

Future<void> _tap(WidgetTester t, Finder finder) async {
  await t.ensureVisible(finder);
  await t.tap(finder);
  await t.pumpAndSettle();
}

void main() {
  test(
    'fresh curriculum ends multiway on recap and starts review with concept',
    () {
      expect(_multiway.courseTaskList.last.taskId, 'w11_trigger_recap');
      expect(_review.courseTaskList.first.taskId, _intro);
      expect(_task.rewardXp, 7);
      expect(_task.runner.options.map((o) => o.id), [
        _correct,
        _wrong,
        'need_more_wins_next_time',
      ]);
      expect(_task.runner.options.map((o) => o.quality.name), [
        'correct',
        'wrong',
        'wrong',
      ]);
      final teaching = _task.runner.teachingSteps.single;
      expect(teaching.title, 'Close the cycle daily.');
      expect(
        teaching.body,
        'Session plan starts the day, trigger reads guide live play, and review sets tomorrow’s focus. That cycle compounds skill.',
      );
      expect(teaching.focusLabels, [
        'Plan',
        'Trigger',
        'Review',
        'Daily cycle',
      ]);
    },
  );

  testWidgets('a: completed legacy intro stays paid and never reopens', (
    t,
  ) async {
    final saved = _save(
      introDone: true,
      reviewDone: true,
      selectedLesson: _new,
      selectedTask: _review.courseTaskList.last.taskId,
    );
    final state = await _mount(t, saved);
    final restored = await _persist(t, state);
    expect(restored['completedLessonIds'], containsAll([_old, _new]));
    expect(
      restored['completedTaskIds'],
      unorderedEquals(saved['completedTaskIds'] as List),
    );
    expect(restored['earnedXp'], saved['earnedXp']);
    expect(state.debugSelectedTaskIdV1(), isNot(_intro));
  });

  testWidgets(
    'completed old multiway does not require the already paid intro again',
    (t) async {
      final next = _review.courseTaskList[1];
      final saved = _save(
        introDone: true,
        reviewDone: false,
        selectedLesson: _new,
        selectedTask: next.taskId,
      );
      final state = await _mount(t, saved);
      expect(state.debugSelectedTaskIdV1(), next.taskId);
      final restored = await _persist(t, state);
      expect(restored['completedLessonIds'], contains(_old));
      expect(restored['completedLessonIds'], isNot(contains(_new)));
      expect(restored['completedTaskIds'], contains(_intro));
      expect(restored['earnedXp'], saved['earnedXp']);
    },
  );

  testWidgets('b: old intro resume moves without reopening multiway', (
    t,
  ) async {
    final saved = _save(
      introDone: false,
      reviewDone: false,
      selectedLesson: _old,
      selectedTask: _intro,
      resume: true,
    );
    final state = await _mount(t, saved);
    expect(state.debugSelectedLessonIdV1(), _new);
    expect(state.debugSelectedTaskIdV1(), _intro);
    final restored = await _persist(t, state);
    expect(restored['completedLessonIds'], contains(_old));
    expect(restored['completedTaskIds'], isNot(contains(_intro)));
    expect(restored['earnedXp'], saved['earnedXp']);
    expect(restored['lessonResume'], containsPair('lessonId', _new));
    expect(restored['lessonResume'], containsPair('taskId', _intro));
    await _tap(t, act0ShellPresentationFinderV1('act0_shell_main_cta'));
    expect(
      t
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      _intro,
    );
  });

  testWidgets('c: previously completed review stays completed', (t) async {
    final next = _lessons[_lessons.indexOf(_review) + 1];
    final saved = _save(
      introDone: true,
      reviewDone: true,
      selectedLesson: next.lessonId,
      selectedTask: next.courseTaskList.first.taskId,
    );
    final state = await _mount(t, saved);
    expect(state.debugSelectedLessonIdV1(), next.lessonId);
    final restored = await _persist(t, state);
    expect(restored['completedLessonIds'], contains(_new));
    expect(restored['earnedXp'], saved['earnedXp']);
  });

  test('d: old assessment fingerprint and skill accounting remain valid', () {
    for (final lesson in [_old, _new]) {
      expect(
        act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: _world,
          lessonId: lesson,
          taskId: _intro,
        ),
        _legacyFingerprint,
      );
      expect(
        act0ConceptErrorDefinitionForTaskV1(
          worldId: _world,
          lessonId: lesson,
          taskId: _intro,
        )?.id,
        'misread_real_play_process',
      );
      expect(
        act0Day7FamilyForSourceV1(
          worldId: _world,
          lessonId: lesson,
          taskId: _intro,
          family: 'misread_real_play_process',
        ),
        'misread_real_play_process',
      );
    }
    expect(
      act0CurrentAuthoredSourceFingerprintForIdentityV1(
        worldId: 'world_10',
        lessonId: _old,
        taskId: _intro,
      ),
      isNull,
    );
    expect(
      act0CurrentAuthoredSourceFingerprintForIdentityV1(
        worldId: _world,
        lessonId: _new,
        taskId: 'w11_trigger_recap',
      ),
      isNull,
    );
    Act0W14SkillStateV1 skill(List<Act0LearningEvidenceRecordV1> records) {
      final history = Act0LearningEvidenceHistoryV1(records: records);
      final restored = Act0LearningEvidenceHistoryV1.restore(
        history.toPayload(),
        history.lineagePayload(),
      )!;
      return act0W14SkillStatesV1(
        worlds: _catalog.worlds,
        history: restored,
      ).singleWhere((s) => s.label == 'Session routine');
    }

    expect(skill([_record()]).tasksToRevisit, 1);
    final correct = skill([_record(correct: true)]);
    expect(correct.independentTasks, 1);
    expect(correct.helpedOrUnverifiedTasks, 0);
    final retry = skill([
      _record(),
      _record(correct: true, lesson: _new, order: 2),
    ]);
    expect(retry.answeredTasks, 1);
    expect(retry.independentTasks, 0);
    expect(retry.helpedOrUnverifiedTasks, 1);
    expect(retry.tasksToRevisit, 1);
    expect(
      skill([
        _record(correct: true, fingerprint: 'stale'),
      ]).helpedOrUnverifiedTasks,
      1,
    );
  });

  test(
    'Day 7 lookup keeps the old due-item family and changes only its task location',
    () {
      final now = DateTime.utc(2026, 11, 27);
      final saved = Act0DurableRetentionFamilyV1(
        conceptFamilyId: 'misread_real_play_process',
        worldId: _world,
        sourceLessonId: _old,
        sourceTaskId: _intro,
        retentionState: Act0RetentionStateV1.due,
        nextDueAtUtc: now.subtract(const Duration(days: 1)),
        lastSpacedReviewAtUtc: now.subtract(const Duration(days: 8)),
        spacedSuccessStage: 1,
        lapseCount: 0,
        incorrectCount: 1,
        correctCount: 2,
        lastRecordedAtUtc: now.subtract(const Duration(days: 8)),
        lastCreatedOrder: 2,
        lastSessionId: 'session_v1|1',
        lastReviewKind: Act0ReviewKindV1.spacedReview,
        hasLegacyUnspacedEvidence: false,
      );
      final history = Act0DurableRetentionHistoryV1.tryParseStrict([
        saved.toPayload(),
      ])!;
      final item = history.dueItemsAt(now).single;
      expect(item.lessonId, _new);
      expect(item.taskId, _intro);
      expect(item.conceptFamilyId, saved.conceptFamilyId);
      expect(item.nextDueAtUtc, saved.nextDueAtUtc);
      // Keep the actual historical evidence and schedule unchanged.
      expect(history.families.single.toPayload(), saved.toPayload());
    },
  );

  testWidgets('e: legacy Review mistake opens the moved task and closes', (
    t,
  ) async {
    final miss = _record();
    final goal = act0RepairGoalContractForSourceV1(
      worldId: _world,
      lessonId: _new,
      taskId: _intro,
      choiceId: _wrong,
    )!;
    expect(goal.targetTaskId, _intro);
    expect(goal.sourceFingerprint, _legacyFingerprint);
    expect(goal.targetFingerprint, _legacyFingerprint);
    final intent = Act0RepairIntentV1(
      repairOccurrenceId: miss.recordId,
      goalId: goal.goalId,
      relationId: goal.relationId,
      relationRevision: goal.relationRevision,
      sourceFingerprint: _legacyFingerprint,
      targetFingerprint: _legacyFingerprint,
      sourceWorldId: _world,
      sourceLessonId: _old,
      sourceTaskId: _intro,
      choiceId: _wrong,
      result: miss.resultKind,
      errorType: miss.errorType,
      missedSignalId: miss.repairFocusId,
      missedSignalLabel: goal.goalId,
      skillAtomId: miss.skillAtomId,
      skillLabel: goal.goalId,
      targetWorldId: _world,
      targetLessonId: _old,
      targetTaskId: _intro,
      mappingType: goal.mappingType,
      reasonCode: 'intentional_exact_replay',
    );
    final queue = const Act0MultiRepairQueueV1().upsertIntent(intent, order: 1);
    final history = Act0LearningEvidenceHistoryV1(records: [miss]);
    final migratedQueue = Act0MultiRepairQueueV1.tryParse(queue.toPayload());
    expect(
      migratedQueue.entries.single.queueItemId,
      queue.entries.single.queueItemId,
    );
    final migratedIntent = migratedQueue.activeRepairIntents().single;
    expect(migratedIntent.sourceLessonId, _new);
    expect(migratedIntent.targetLessonId, _new);
    expect(
      act0RepairGoalResolutionForIntentV1(
        migratedIntent,
        learningEvidence: history,
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      ).canLaunch,
      isTrue,
    );
    final saved =
        _save(
          introDone: true,
          reviewDone: false,
          selectedLesson: _new,
          selectedTask: _review.courseTaskList[1].taskId,
        )..addAll({
          'learningEvidenceHistory': history.toPayload(),
          'learningEvidenceLineage': history.lineagePayload(),
          'openRepairIntents': [intent.toPayload()],
          'multiRepairQueue': queue.toPayload(),
          'multiRepairQueueOrder': 1,
          'retentionMemory': [
            {
              'taskId': _intro,
              'lessonId': _old,
              'worldId': _world,
              'status': 'openRepair',
              'attempts': 1,
              'fixedAtSequence': 0,
              'lastRecheckSequence': 0,
              'successfulRecheckCount': 0,
            },
          ],
        });
    final state = await _mount(t, saved, tab: Act0ShellTabV1.review);
    expect(state.debugOpenRepairIntentCountV1(), 1);
    expect(
      state.debugOpenRepairIntentPayloadForSourceTaskV1(_intro),
      containsPair('sourceLessonId', _new),
    );
    await _tap(
      t,
      act0ShellPresentationFinderV1('act0_shell_review_practice_cta'),
    );
    expect(state.debugSelectedLessonIdV1(), _new);
    expect(state.debugSelectedTaskIdV1(), _intro);
    final choice = find.byKey(const Key('act0_shell_option_$_correct'));
    for (var step = 0; step < 3 && choice.evaluate().isEmpty; step++) {
      await t.pump(const Duration(seconds: 1));
      final cta = find.byKey(const Key('act0_shell_theory_continue_cta'));
      await _tap(
        t,
        cta.evaluate().isNotEmpty
            ? cta
            : find.byKey(const Key('act0_shell_continue_cta')),
      );
    }
    await _tap(t, choice);
    await _tap(t, find.byKey(const Key('act0_shell_feedback_continue_cta')));
    expect(state.debugOpenRepairIntentCountV1(), 0);
    final restored = await _persist(t, state);
    expect(restored['earnedXp'], saved['earnedXp']);
  });
}
