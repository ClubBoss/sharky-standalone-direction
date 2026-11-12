import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Private67 composition, not unchanged public PR #444. Only prerequisites are
// synthetic: the target starts with no completion or evidence, is completed by
// UI, and becomes replayable by actually finishing the rest of this lesson.
// No reseed, callbacks, presentation overrides or forced persistence after boot.
// This is widget mechanism evidence, not fresh-install, old-save or native proof.
const _worldId = 'world_1';
const _lessonId = 'fold_check_call_raise';
const _progressKey = 'act0_shell_progress_v1';
const _theoryId = 'actions_theory';
const _maxTeachingTaps = 12;

Act0LessonCardV1 get _lesson => Act0ShellStateV1.sample.lessonById(_lessonId);

Act0LessonTaskV1 _sourceTask(String taskId) =>
    _lesson.taskList.singleWhere((task) => task.taskId == taskId);

List<Map<String, dynamic>> _evidence(
  Map<String, dynamic> saved,
  String taskId,
) => (saved['learningEvidenceHistory'] as List)
    .cast<Map<String, dynamic>>()
    .where((record) => record['taskId'] == taskId)
    .toList();

void _diagnose(
  WidgetTester tester,
  String stage, {
  Map<String, dynamic>? saved,
}) {
  final runners = tester
      .widgetList<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
      .map(
        (widget) => <String, Object?>{
          'world': widget.selectedWorldId,
          'lesson': widget.selectedLessonId,
          'task': widget.selectedTaskId,
          'phase': widget.runner.phase.name,
          'selectedOption': widget.runner.selectedOptionId,
          'teachingIndex': widget.runner.teachingStepIndex,
          'question': widget.runner.question,
        },
      )
      .toList();
  debugPrint(
    'PKR_ACTION_MATRIX ${jsonEncode(<String, Object?>{'stage': stage, 'route': runners, 'keys': tester.allWidgets.map((widget) => widget.key).whereType<ValueKey<String>>().map((key) => key.value).toList(), if (saved != null) 'saved': saved})}',
  );
}

Act0LessonRunnerShellV1 _expectTask(
  WidgetTester tester,
  String taskId, {
  Act0LessonPhaseV1? runtimePhase,
}) {
  _diagnose(tester, 'identity:$taskId');
  final finder = find.byType(Act0LessonRunnerShellV1);
  expect(finder, findsOneWidget);
  final runner = tester.widget<Act0LessonRunnerShellV1>(finder);
  expect(runner.selectedWorldId, _worldId);
  expect(runner.selectedLessonId, _lessonId);
  expect(runner.selectedTaskId, taskId);
  if (runtimePhase != null) expect(runner.runner.phase, runtimePhase);
  return runner;
}

Future<void> _tap(
  WidgetTester tester,
  String key, {
  String? expectedTaskId,
}) async {
  _diagnose(tester, 'before-tap:$key');
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget, reason: 'Required normal UI route: $key');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  _diagnose(tester, 'after-scroll:$key');
  expect(finder.hitTestable(), findsOneWidget);
  if (expectedTaskId != null) _expectTask(tester, expectedTaskId);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester tester, String stage) async {
  // Observe ordinary asynchronous product writes; do not call a debug save.
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
  final raw = (await SharedPreferences.getInstance()).getString(_progressKey);
  _diagnose(tester, 'read-save:$stage');
  expect(raw, isNotNull);
  final saved = jsonDecode(raw!) as Map<String, dynamic>;
  _diagnose(tester, stage, saved: saved);
  return saved;
}

void _expectOneCompletion(Map<String, dynamic> saved, String taskId) {
  expect(
    (saved['completedTaskIds'] as List).where((id) => id == taskId),
    hasLength(1),
  );
}

Future<void> _mountAt(WidgetTester tester, String targetId) async {
  await tester.binding.setSurfaceSize(const Size(393, 852));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final prerequisites = <String>{
    ...Act0ShellStateV1.sample
        .worldById(_worldId)
        .lessons
        .takeWhile((lesson) => lesson.lessonId != _lessonId)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId),
    ..._lesson.taskList
        .takeWhile((task) => task.taskId != targetId)
        .map((task) => task.taskId),
  }.toList()..sort();
  expect(prerequisites, isNot(contains(targetId)));
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _progressKey: jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': prerequisites,
      'skippedTaskIds': <String>[],
      'completedLessonIds': <String>[],
      'selectedWorldId': _worldId,
      'selectedLessonId': _lessonId,
      'selectedTaskId': targetId,
      'earnedXp': 0,
      'learningEvidenceHistory': <Object>[],
      'reviewMistakeHistory': <Object>[],
      'openRepairIntents': <Object>[],
      'reviewResolutionReceipts': <Object>[],
    }),
  });
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.learn,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  final before = await _saved(tester, '$targetId:before-mission');
  expect(before['earnedXp'], 0);
  expect(before['completedTaskIds'], isNot(contains(targetId)));
  expect(before['completedLessonIds'], isNot(contains(_lessonId)));
  expect(_evidence(before, targetId), isEmpty);
  // A current lesson is intentionally absent from All lessons. Use its mission.
  await _tap(tester, 'act0_shell_current_mission_cta');
  _expectTask(tester, targetId);
}

Future<void> _answer(
  WidgetTester tester,
  String taskId,
  String choiceId,
) async {
  final source = _sourceTask(taskId);
  expect(source.phase, isNot(Act0LessonPhaseV1.theory));
  expect(
    source.runner.options.singleWhere((o) => o.id == choiceId).isCorrect,
    isTrue,
  );
  final optionKey = 'act0_shell_option_$choiceId';
  for (
    var step = 0;
    step < _maxTeachingTaps && find.byKey(Key(optionKey)).evaluate().isEmpty;
    step++
  ) {
    _expectTask(tester, taskId);
    await _tap(tester, 'act0_shell_continue_cta', expectedTaskId: taskId);
  }
  final ready = _expectTask(
    tester,
    taskId,
    runtimePhase: Act0LessonPhaseV1.drill,
  );
  expect(ready.runner.selectedOptionId, isNull);
  expect(
    ready.runner.options.singleWhere((o) => o.id == choiceId).isCorrect,
    isTrue,
  );
  await _tap(tester, optionKey, expectedTaskId: taskId);
  final feedback = _expectTask(
    tester,
    taskId,
    runtimePhase: Act0LessonPhaseV1.review,
  );
  expect(feedback.runner.selectedOptionId, choiceId);
  expect(feedback.runner.selectedOption?.isCorrect, isTrue);
  await _tap(
    tester,
    'act0_shell_feedback_continue_cta',
    expectedTaskId: taskId,
  );
}

Future<void> _completeTheory(WidgetTester tester) async {
  for (var step = 0; step < _maxTeachingTaps; step++) {
    final runners = tester.widgetList<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    if (runners.length != 1 || runners.single.selectedTaskId != _theoryId) {
      return;
    }
    _expectTask(tester, _theoryId, runtimePhase: Act0LessonPhaseV1.theory);
    await _tap(tester, 'act0_shell_continue_cta', expectedTaskId: _theoryId);
  }
  _diagnose(tester, 'theory:did-not-advance');
  fail('Theory did not complete via its authored Continue route');
}

Future<void> _finishLesson(WidgetTester tester, String targetId) async {
  final tasks = _lesson.taskList;
  final start = tasks.indexWhere((task) => task.taskId == targetId);
  for (final task in tasks.skip(start + 1)) {
    // The source-owned Action sequence intentionally jumps from theory to
    // actions_check_drill, not the adjacent legal-context node. Earn that
    // missing node later via the normal current-mission route, never a reseed.
    if (targetId == _theoryId && task.taskId == 'actions_legal_context') {
      continue;
    }
    _expectTask(tester, task.taskId);
    final correct = task.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    await _answer(tester, task.taskId, correct.id);
    final saved = await _saved(tester, 'earned-remaining:${task.taskId}');
    _expectOneCompletion(saved, task.taskId);
  }
  if (targetId == _theoryId) {
    final beforeLegal = await _saved(
      tester,
      'theory:legal-context-still-needed',
    );
    expect(
      beforeLegal['completedTaskIds'],
      isNot(contains('actions_legal_context')),
    );
    expect(beforeLegal['completedLessonIds'], isNot(contains(_lessonId)));
    await _returnToLearn(tester, 'theory:resume-missing-context');
    await _tap(tester, 'act0_shell_current_mission_cta');
    _expectTask(tester, 'actions_legal_context');
    final legal = _sourceTask('actions_legal_context');
    final choice = legal.runner.options.singleWhere(
      (option) => option.isCorrect,
    );
    await _answer(tester, legal.taskId, choice.id);
  }
  final saved = await _saved(tester, '$targetId:lesson-completed-through-UI');
  expect(saved['completedLessonIds'], contains(_lessonId));
  for (final task in tasks) _expectOneCompletion(saved, task.taskId);
}

Future<void> _returnToLearn(WidgetTester tester, String stage) async {
  if (find
      .byKey(const Key('act0_shell_block_summary_continue_cta'))
      .evaluate()
      .isNotEmpty) {
    await _tap(tester, 'act0_shell_block_summary_continue_cta');
  }
  await _tap(tester, 'act0_shell_runner_back');
  _diagnose(tester, '$stage:before-learn-tab');
  final learn = find.text('Learn').last;
  expect(learn.hitTestable(), findsOneWidget);
  await tester.tap(learn);
  await tester.pumpAndSettle();
}

Future<void> _openCompletedLessonReplay(
  WidgetTester tester,
  String taskId,
) async {
  await _returnToLearn(tester, taskId);
  final lessonKey = 'act0_shell_lesson_${_lesson.title}';
  if (find.byKey(Key(lessonKey)).evaluate().isEmpty) {
    await _tap(tester, 'act0_shell_learn_v5_view_full_path');
  }
  await _tap(tester, lessonKey);
  await _tap(tester, 'act0_shell_lesson_step_$taskId');
  await _tap(tester, 'act0_shell_selected_lesson_cta');
  _expectTask(tester, taskId);
}

void main() {
  for (final target
      in <
        ({
          String taskId,
          String choiceId,
          Act0LessonPhaseV1 phase,
          Act0LessonStepKindV1 stepKind,
        })
      >[
        (
          taskId: 'actions_fold_drill',
          choiceId: 'fold',
          phase: Act0LessonPhaseV1.drill,
          stepKind: Act0LessonStepKindV1.fixMistakes,
        ),
        (
          taskId: 'actions_call_drill',
          choiceId: 'call',
          phase: Act0LessonPhaseV1.drill,
          stepKind: Act0LessonStepKindV1.practice,
        ),
        (
          taskId: 'actions_review',
          choiceId: 'raise',
          phase: Act0LessonPhaseV1.review,
          stepKind: Act0LessonStepKindV1.proveIt,
        ),
      ]) {
    testWidgets(
      '${target.taskId}: actual first +5 and completed-Learn replay +0',
      (tester) async {
        final source = _sourceTask(target.taskId);
        expect(source.rewardXp, 5);
        expect(source.phase, target.phase);
        expect(source.stepKind, target.stepKind);
        expect(source.entryPhase, Act0LessonPhaseV1.drill);
        await _mountAt(tester, target.taskId);
        await _answer(tester, target.taskId, target.choiceId);
        final first = await _saved(tester, '${target.taskId}:first');
        expect(first['earnedXp'], source.rewardXp);
        _expectOneCompletion(first, target.taskId);
        expect(first['openRepairIntents'], isEmpty);
        final firstEvidence = _evidence(first, target.taskId);
        expect(firstEvidence, hasLength(1));
        final firstRecord = Map<String, dynamic>.from(firstEvidence.single);
        expect(firstRecord['worldId'], _worldId);
        expect(firstRecord['lessonId'], _lessonId);
        expect(firstRecord['choiceId'], target.choiceId);
        expect(firstRecord['isCorrect'], isTrue);
        expect(firstRecord['resultKind'], 'correct');
        expect(firstRecord['assistanceKind'], 'none');
        expect(firstRecord['recordId'], isNotEmpty);
        await _finishLesson(tester, target.taskId);
        final completed = await _saved(
          tester,
          '${target.taskId}:before-replay',
        );
        expect(_evidence(completed, target.taskId).single, firstRecord);
        await _openCompletedLessonReplay(tester, target.taskId);
        final beforeReplay = await _saved(
          tester,
          '${target.taskId}:replay-entry',
        );
        expect(_evidence(beforeReplay, target.taskId), <Object>[firstRecord]);
        await _answer(tester, target.taskId, target.choiceId);
        final replayed = await _saved(tester, '${target.taskId}:replayed');
        expect(replayed['earnedXp'], beforeReplay['earnedXp']);
        _expectOneCompletion(replayed, target.taskId);
        expect(replayed['completedTaskIds'], beforeReplay['completedTaskIds']);
        expect(
          replayed['completedLessonIds'],
          beforeReplay['completedLessonIds'],
        );
        final records = _evidence(replayed, target.taskId);
        expect(records, hasLength(2));
        expect(records.first, firstRecord);
        expect(records.last['recordId'], isNot(firstRecord['recordId']));
        expect(records.last['worldId'], _worldId);
        expect(records.last['lessonId'], _lessonId);
        expect(records.last['choiceId'], target.choiceId);
        expect(records.last['isCorrect'], isTrue);
        expect(records.last['resultKind'], 'correct');
        expect(records.last['assistanceKind'], 'none');
        expect(replayed['openRepairIntents'], isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('actions_theory: Continue first +5, completed-Learn repeat +0, '
      'no graded answer evidence', (tester) async {
    final source = _sourceTask(_theoryId);
    expect(source.phase, Act0LessonPhaseV1.theory);
    expect(source.stepKind, Act0LessonStepKindV1.learn);
    expect(source.rewardXp, 5);
    await _mountAt(tester, _theoryId);
    await _completeTheory(tester);
    final first = await _saved(tester, 'theory:first-completion');
    expect(first['earnedXp'], source.rewardXp);
    _expectOneCompletion(first, _theoryId);
    expect(_evidence(first, _theoryId), isEmpty);
    await _finishLesson(tester, _theoryId);
    final completed = await _saved(tester, 'theory:lesson-completed');
    expect(_evidence(completed, _theoryId), isEmpty);
    await _openCompletedLessonReplay(tester, _theoryId);
    final beforeReplay = await _saved(tester, 'theory:replay-entry');
    await _completeTheory(tester);
    final replayed = await _saved(tester, 'theory:replayed');
    expect(replayed['earnedXp'], beforeReplay['earnedXp']);
    _expectOneCompletion(replayed, _theoryId);
    expect(replayed['completedTaskIds'], beforeReplay['completedTaskIds']);
    expect(replayed['completedLessonIds'], beforeReplay['completedLessonIds']);
    expect(_evidence(replayed, _theoryId), isEmpty);
    expect(replayed['openRepairIntents'], isEmpty);
    expect(tester.takeException(), isNull);
  });
}
