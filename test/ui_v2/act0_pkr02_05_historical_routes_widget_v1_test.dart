import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_multi_repair_queue_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import '../support/act0_shell_presentation_finders_v1.dart';

// SYNTHETIC fixtures built using source-owned serializers. No real earned
// historical action-hand save is claimed. Reuses the existing repair test shape.
const _key = 'act0_shell_progress_v1';
const _ids = <String>[
  'actions_theory',
  'actions_fold_drill',
  'actions_call_drill',
  'actions_raise_drill',
  'actions_review',
];
const _protected = <String>[
  'earnedXp',
  'completedTaskIds',
  'reviewMistakeHistory',
  'reviewResolutionReceipts',
  'openRepairIntents',
  'multiRepairQueue',
  'learningEvidenceHistory',
];

Map<String, dynamic> _fixture(String task, {String? phase, bool done = false}) {
  const lesson = 'fold_check_call_raise';
  final id = 'synthetic-old-hand-$task';
  final intent = Act0RepairIntentV1(
    repairOccurrenceId: id,
    sourceWorldId: 'world_1',
    sourceLessonId: lesson,
    sourceTaskId: task,
    choiceId: 'call',
    result: 'incorrect',
    errorType: 'historical_hand_error',
    missedSignalId: 'facing_bet',
    missedSignalLabel: 'Facing a bet',
    skillAtomId: 'action_read',
    skillLabel: 'Action read',
    targetWorldId: 'world_1',
    targetLessonId: lesson,
    targetTaskId: task,
    mappingType: 'repair',
    reasonCode: 'same_signal_action_read_facing_bet',
  );
  final queue = const Act0MultiRepairQueueV1().upsertIntent(intent, order: 1);
  final evidence = Act0LearningEvidenceRecordV1(
    recordId: id,
    createdOrder: 1,
    worldId: 'world_1',
    lessonId: lesson,
    taskId: task,
    sourceTaskId: task,
    choiceId: 'call',
    expectedChoiceId: 'raise',
    isCorrect: false,
    errorType: 'historical_hand_error',
    conceptFamilyId: 'facing_bet',
    repairFocusId: 'facing_bet',
    skillAtomId: 'action_read',
    decisionTimeBucket: 'under_3s',
    resultKind: 'incorrect',
    assistanceKind: Act0DecisionAssistanceV1.none,
    authoredSourceFingerprint: 'synthetic-noncurrent-source',
  );
  final mistake = Act0ReviewMistakeRecordV1(
    recordId: 'synthetic-review-$task',
    sourceDecisionId: id,
    createdOrder: 1,
    updatedOrder: 1,
    worldId: 'world_1',
    lessonId: lesson,
    decisionTaskId: task,
    sourceTaskId: task,
    decisionKind: 'actionList',
    selectedId: 'call',
    expectedId: 'raise',
    resultKind: 'incorrect',
    errorType: 'historical_hand_error',
    skillAtomId: 'action_read',
    repairFocusId: 'facing_bet',
    runId: '',
    runKind: '',
    runOrdinal: null,
    attemptRecordIds: [id],
    dedupUsesFallback: false,
  );
  expect(
    Act0RepairIntentV1.tryParse(intent.toPayload())!.toPayload(),
    intent.toPayload(),
  );
  expect(
    Act0ReviewMistakeRecordV1.tryParse(mistake.toPayload())!.toPayload(),
    mistake.toPayload(),
  );
  final completed = Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .takeWhile((l) => l.lessonId != lesson)
      .expand((l) => l.taskList)
      .map((t) => t.taskId)
      .toList();
  if (done) completed.add(task);
  // Snapshot stores completedTaskIds as a Set and serializes it sorted.
  // Match that canonical encoding; evidence/queue/history order stays exact.
  completed.sort();
  return <String, dynamic>{
    'schemaVersion': 18,
    'completedTaskIds': completed,
    'skippedTaskIds': <String>[],
    'completedLessonIds': <String>[],
    'selectedWorldId': 'world_1',
    'selectedLessonId': lesson,
    'selectedTaskId': task,
    'earnedXp': 30,
    'dailyCompletedRepCount': 0,
    'retentionMemory': <Object>[],
    'openRepairIntents': queue
        .activeRepairIntents()
        .map((i) => i.toPayload())
        .toList(),
    'multiRepairQueue': queue.toPayload(),
    'multiRepairQueueOrder': 1,
    'repairOutcomeProjection': <Object>[],
    'reviewResolutionReceipts': <Object>[],
    'reviewMistakeHistory': [mistake.toPayload()],
    'learningEvidenceHistory': [evidence.toPayload()],
    'resumeInRunner': phase != null,
    'resumePhase': phase ?? 'review',
    'resumeTeachingStepIndex': 0,
    if (phase == 'review') 'resumeSelectedOptionId': 'call',
  };
}

Future<void> _seed(Map<String, dynamic> p) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    _key: jsonEncode(p),
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
  });
}

Future<void> _mount(WidgetTester t) async {
  await t.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: false,
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  (t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
      .debugPersistProgressV1();
  await t.pump(const Duration(milliseconds: 250));
  return jsonDecode((await SharedPreferences.getInstance()).getString(_key)!)
      as Map<String, dynamic>;
}

Future<void> _tap(WidgetTester t, Finder f) async {
  expect(f, findsOneWidget);
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}

void _unchanged(Map<String, dynamic> before, Map<String, dynamic> after) {
  for (final key in _protected) {
    expect(after[key], before[key], reason: 'Historical $key changed');
  }
}

void main() {
  for (final task in _ids) {
    testWidgets(
      'synthetic historical Practice CTA $task is unavailable twice',
      (t) async {
        await t.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => t.binding.setSurfaceSize(null));
        final original = _fixture(task);
        await _seed(original);
        await _mount(t);
        _unchanged(original, await _saved(t));
        await _tap(t, find.text('Practice').last);
        final before = await _saved(t);
        final launch = act0ShellPresentationFinderV1(
          'act0_shell_play_repair_queue_item_cta',
        );
        for (var attempt = 0; attempt < 2; attempt++) {
          await _tap(t, launch);
          expect(
            find.byKey(const Key('act0_w1_historical_repair_unavailable')),
            findsOneWidget,
          );
          expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
          expect(t.takeException(), isNull);
          _unchanged(before, await _saved(t));
          await t.pump(const Duration(seconds: 5));
          await t.pumpAndSettle();
        }
      },
    );
  }
  testWidgets(
    'synthetic historical Review CTA preserves debt and stays in Review',
    (t) async {
      await t.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final original = _fixture('actions_raise_drill');
      await _seed(original);
      await _mount(t);
      _unchanged(original, await _saved(t));
      await _tap(t, find.text('Review').last);
      final before = await _saved(t);
      // Follow the active production presentation to the real repair callback.
      await _tap(
        t,
        act0ShellPresentationFinderV1('act0_shell_review_practice_cta'),
      );
      expect(
        find.byKey(const Key('act0_w1_historical_repair_unavailable')),
        findsOneWidget,
      );
      expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
      _unchanged(before, await _saved(t));
      expect(t.takeException(), isNull);
    },
  );
  for (final phase in ['drill', 'review']) {
    testWidgets(
      'synthetic cold-restored historical $phase cannot become vocabulary repair',
      (t) async {
        await t.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => t.binding.setSurfaceSize(null));
        final original = _fixture('actions_raise_drill', phase: phase);
        await _seed(original);
        for (var restart = 0; restart < 2; restart++) {
          await _mount(t);
          final before = await _saved(t);
          _unchanged(original, before);
          final runner = find.byType(Act0LessonRunnerShellV1);
          // Hold if a pre-migration active hand is silently resumed as vocabulary.
          expect(
            runner,
            findsNothing,
            reason:
                'Old active hand needs an explicit unavailable/deferred route',
          );
          _unchanged(before, await _saved(t));
          await t.pumpWidget(const SizedBox());
          await t.pumpAndSettle();
        }
      },
    );
  }
  testWidgets(
    'direct synthetic missed feedback does not fall through unavailable',
    (t) async {
      await t.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => t.binding.setSurfaceSize(null));
      // Separate direct feedback harness. This is NOT a persistence-restored
      // active repair, and does not claim saved-debt or XP coverage.
      await t.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            showPlacementOnStart: false,
            debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerFeedback,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_raise_drill',
              feedbackCorrect: false,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final state = t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final task = state.debugSelectedTaskIdV1();
      final phase = state.debugPhaseV1();
      final option = state.debugSelectedOptionIdV1();
      final runner = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.runner.selectedOption?.isCorrect, false);
      await _tap(t, find.byKey(const Key('act0_shell_feedback_continue_cta')));
      expect(
        find.byKey(const Key('act0_w1_historical_repair_unavailable')),
        findsOneWidget,
      );
      expect(state.debugSelectedTaskIdV1(), task);
      expect(state.debugPhaseV1(), phase);
      expect(state.debugSelectedOptionIdV1(), option);
      expect(t.takeException(), isNull);
    },
  );
}
