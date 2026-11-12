import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';

// Synthetic prerequisite completion only. The target has no prior completion
// or evidence; its first answer is an actual current UI action.
// This is not a fresh-install test or genuine historical-hand migration proof.
const _task = 'actions_raise_drill';
const _lesson = 'fold_check_call_raise';
const _key = 'act0_shell_progress_v1';
Future<void> _tap(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  if (f.evaluate().isEmpty) {
    debugPrint(
      'PKR_ALL_KEYS: ${t.allWidgets.map((w) => w.key).whereType<ValueKey<String>>().map((k) => k.value).toList()}',
    );
    final state = t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
    debugPrint(
      'PKR_ROUTE_STATE: ${state.debugSelectedWorldIdV1()} / ${state.debugSelectedLessonIdV1()} / ${state.debugSelectedTaskIdV1()} / ${state.debugPhaseV1()} / ${state.debugSelectedOptionIdV1()}',
    );
  }
  expect(
    f,
    findsOneWidget,
    reason: 'Actual current UI route must be reachable',
  );
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved(WidgetTester t) async {
  (t.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic)
      .debugPersistProgressV1();
  await t.pump(const Duration(milliseconds: 250));
  return jsonDecode((await SharedPreferences.getInstance()).getString(_key)!)
      as Map<String, dynamic>;
}

void main() {
  testWidgets(
    'current Learn Raise first completion gives 5 XP and actual replay gives zero',
    (t) async {
      await t.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final prerequisites =
          Act0ShellStateV1.sample
              .worldById('world_1')
              .lessons
              .takeWhile((l) => l.lessonId != _lesson)
              .expand((l) => l.taskList)
              .map((task) => task.taskId)
              .toList()
            ..sort();
      prerequisites.addAll(
        Act0ShellStateV1.sample
            .lessonById(_lesson)
            .taskList
            .takeWhile((task) => task.taskId != _task)
            .map((task) => task.taskId),
      );
      prerequisites.sort();
      expect(prerequisites, isNot(contains(_task)));
      SharedPreferences.setMockInitialValues(<String, Object>{
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _key: jsonEncode(<String, Object?>{
          'schemaVersion': 18,
          'completedTaskIds': prerequisites,
          'skippedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': _lesson,
          'selectedTaskId': _task,
          'earnedXp': 0,
          'learningEvidenceHistory': <Object>[],
          'reviewMistakeHistory': <Object>[],
          'openRepairIntents': <Object>[],
          'reviewResolutionReceipts': <Object>[],
        }),
      });
      await t.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            showPlacementOnStart: false,
          ),
        ),
      );
      await t.pumpAndSettle();
      final before = await _saved(t);
      expect(before['earnedXp'], 0);
      expect(before['completedTaskIds'], isNot(contains(_task)));
      List<Map<String, dynamic>> targetEvidence(Map<String, dynamic> saved) =>
          (saved['learningEvidenceHistory'] as List)
              .cast<Map<String, dynamic>>()
              .where((record) => record['taskId'] == _task)
              .toList();
      expect(targetEvidence(before), isEmpty);
      for (var attempt = 0; attempt < 1; attempt++) {
        await _tap(t, 'act0_shell_current_mission_cta');
        var runner = t.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(runner.selectedTaskId, _task);
        final option = runner.runner.options.singleWhere((o) => o.isCorrect);
        final key = 'act0_shell_option_${option.id}';
        for (
          var step = 0;
          step < 12 && find.byKey(Key(key)).evaluate().isEmpty;
          step++
        ) {
          await _tap(t, 'act0_shell_continue_cta');
        }
        expect(
          t
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .selectedTaskId,
          _task,
        );
        await _tap(t, key);
        await _tap(t, 'act0_shell_feedback_continue_cta');
        final saved = await _saved(t);
        expect(saved['earnedXp'], 5, reason: 'Actual first completion +5');
        expect(
          (saved['completedTaskIds'] as List).where((id) => id == _task),
          hasLength(1),
        );
        expect(saved['openRepairIntents'], isEmpty);
        final evidence = targetEvidence(saved);
        expect(evidence, hasLength(attempt + 1));
        expect(evidence.last['isCorrect'], true);
        expect(evidence.last['resultKind'], 'correct');
      }
      final first = await _saved(t);
      final firstRecord = Map<String, dynamic>.from(
        targetEvidence(first).single,
      );
      // Earn the remaining recap through its current runner, so the completed
      // lesson becomes a genuinely reachable replay route in Learn.
      var recap = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(recap.selectedTaskId, 'actions_review');
      final recapAnswer = recap.runner.options.singleWhere((o) => o.isCorrect);
      final recapKey = 'act0_shell_option_${recapAnswer.id}';
      for (
        var step = 0;
        step < 12 && find.byKey(Key(recapKey)).evaluate().isEmpty;
        step++
      ) {
        await _tap(t, 'act0_shell_continue_cta');
      }
      expect(
        t
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        'actions_review',
      );
      await _tap(t, recapKey);
      await _tap(t, 'act0_shell_feedback_continue_cta');
      final earnedLesson = await _saved(t);
      expect(earnedLesson['completedTaskIds'], contains('actions_review'));
      expect(earnedLesson['completedLessonIds'], contains(_lesson));
      expect(targetEvidence(earnedLesson).single, firstRecord);
      if (find
          .byKey(const Key('act0_shell_block_summary_continue_cta'))
          .evaluate()
          .isNotEmpty) {
        await _tap(t, 'act0_shell_block_summary_continue_cta');
      }
      await _tap(t, 'act0_shell_runner_back');
      await t.tap(find.text('Learn').last);
      await t.pumpAndSettle();
      final lesson = Act0ShellStateV1.sample.lessonById(_lesson);
      if (find
          .byKey(Key('act0_shell_lesson_${lesson.title}'))
          .evaluate()
          .isEmpty) {
        await _tap(t, 'act0_shell_learn_v5_view_full_path');
      }
      await _tap(t, 'act0_shell_lesson_${lesson.title}');
      await _tap(t, 'act0_shell_lesson_step_$_task');
      await _tap(t, 'act0_shell_selected_lesson_cta');
      final replay = t.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(replay.selectedTaskId, _task);
      final replayAnswer = replay.runner.options.singleWhere(
        (o) => o.isCorrect,
      );
      final beforeReplay = await _saved(t);
      final replayKey = 'act0_shell_option_${replayAnswer.id}';
      for (
        var step = 0;
        step < 12 && find.byKey(Key(replayKey)).evaluate().isEmpty;
        step++
      ) {
        await _tap(t, 'act0_shell_continue_cta');
      }
      expect(
        t
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        _task,
      );
      await _tap(t, replayKey);
      await _tap(t, 'act0_shell_feedback_continue_cta');
      final afterReplay = await _saved(t);
      expect(afterReplay['earnedXp'], beforeReplay['earnedXp']);
      expect(
        (afterReplay['completedTaskIds'] as List).where((id) => id == _task),
        hasLength(1),
      );
      final replayRecords = targetEvidence(afterReplay);
      expect(replayRecords, hasLength(2));
      expect(replayRecords.first, firstRecord);
      expect(replayRecords.last['recordId'], isNot(firstRecord['recordId']));
      expect(replayRecords.last['isCorrect'], true);
      expect(replayRecords.last['resultKind'], 'correct');
      expect(afterReplay['openRepairIntents'], isEmpty);
      expect(t.takeException(), isNull);
    },
  );
}
