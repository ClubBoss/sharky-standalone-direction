import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'act0_shell_progress_v1';
const _pot = 'pot_committed_chips';

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget, reason: key);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Act0LessonRunnerShellV1 _shell(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<Map<String, dynamic>> _saved() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_key)!) as Map<String, dynamic>;
}

void main() {
  test(
    'W1 pot recap owns pot options, causal feedback and correct C position',
    () {
      final lesson = Act0ShellStateV1.sample.lessonById(
        'what_poker_is_content',
      );
      final task = lesson.taskList.last;
      expect(task.taskId, 'what_poker_is_review');
      expect(task.rewardXp, 3);
      expect(task.runner.question, 'What is the pot?');
      expect(
        task.runner.options.where((o) => o.isCorrect).single.id,
        _pot,
        reason: 'Everyone folds answers a win condition, not a pot definition',
      );
      expect(task.runner.options[2].id, _pot);
      final correct = task.runner.options[2];
      expect(correct.label, 'Chips already committed to the middle');
      expect(correct.quality, Act0FeedbackQualityV1.correct);
      expect(correct.feedbackReason, contains('prize'));
      for (final id in ['everyone_folds', 'largest_stack']) {
        final wrong = task.runner.options.firstWhere((o) => o.id == id);
        expect(wrong.isCorrect, false);
        expect(wrong.quality, Act0FeedbackQualityV1.wrong);
        expect(wrong.betterAnswerLabel, correct.label);
        expect(wrong.feedbackReason, contains('pot'));
      }
      final transfer = Act0ShellStateV1.sample
          .lessonById('what_poker_is')
          .taskList
          .firstWhere((t) => t.taskId == 'what_poker_is_table_read_transfer');
      expect(
        transfer.runner.options.where((o) => o.isCorrect).single.id,
        'two_three_six',
      );
    },
  );

  for (final wrong in [false, true]) {
    testWidgets(
      'representative Learn recap ${wrong ? "wrong" : "correct"} choice owns feedback, evidence and earned XP',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final first = Act0ShellStateV1.sample.lessonById('what_poker_is');
        final lesson = Act0ShellStateV1.sample.lessonById(
          'what_poker_is_content',
        );
        final task = lesson.taskList.last;
        // Representative deterministic entry fixture, not native/earned history.
        // No run IDs or graded records are injected. Learn Start owns those.
        SharedPreferences.setMockInitialValues({
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          _key: jsonEncode({
            'schemaVersion': 18,
            'completedTaskIds': [
              ...first.taskList.map((t) => t.taskId),
              ...lesson.taskList
                  .take(lesson.taskList.length - 1)
                  .map((t) => t.taskId),
            ],
            'completedLessonIds': [first.lessonId],
            'selectedWorldId': 'world_1',
            'selectedLessonId': lesson.lessonId,
            'selectedTaskId': task.taskId,
            'earnedXp': 30,
          }),
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              initialTab: Act0ShellTabV1.learn,
              showPlacementOnStart: false,
            ),
          ),
        );
        await tester.pumpAndSettle();
        await _tap(tester, 'act0_shell_current_mission_cta');
        expect(_shell(tester).selectedTaskId, task.taskId);
        for (var i = 0; i < 12; i++) {
          expect(
            find.byKey(const Key('act0_shell_feedback_continue_cta')),
            findsNothing,
          );
          if (find
              .byKey(
                Key('act0_shell_option_${wrong ? "everyone_folds" : _pot}'),
              )
              .evaluate()
              .isNotEmpty)
            break;
          await tester.pump(const Duration(seconds: 3));
          final theory = find.byKey(
            const Key('act0_shell_theory_continue_cta'),
          );
          await _tap(
            tester,
            theory.evaluate().isNotEmpty
                ? 'act0_shell_theory_continue_cta'
                : 'act0_shell_continue_cta',
          );
        }
        expect(_shell(tester).runner.selectedOptionId, isNull);
        expect((await _saved())['learningEvidenceHistory'] ?? [], isEmpty);
        final choice = wrong ? 'everyone_folds' : _pot;
        await _tap(tester, 'act0_shell_option_$choice');
        expect(_shell(tester).runner.phase, Act0LessonPhaseV1.review);
        final option = task.runner.options.firstWhere((o) => o.id == choice);
        expect(find.textContaining(option.feedbackReason), findsWidgets);
        final saved = await _saved();
        final record = (saved['learningEvidenceHistory'] as List).single;
        expect(record['choiceId'], choice);
        expect(record['expectedChoiceId'], _pot);
        expect(record['isCorrect'], !wrong);
        expect(record['errorType'], wrong ? isNot('none') : 'none');
        expect(record['taskId'], task.taskId);
        expect(record['lessonId'], lesson.lessonId);
        expect(record['worldId'], 'world_1');
        expect(record['runId'], isNotEmpty);
        expect(record['startedBy'], 'learn_route');
        expect(record['sessionId'], isNotEmpty);
        expect(record['assistanceKind'], 'none');
        expect(saved['earnedXp'], 30);
        expect(saved['completedLessonIds'], isNot(contains(lesson.lessonId)));
        if (wrong) {
          expect(saved['completedTaskIds'], isNot(contains(task.taskId)));
        } else {
          await _tap(tester, 'act0_shell_feedback_continue_cta');
          expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
          final completed = await _saved();
          expect(completed['earnedXp'], 33);
          expect(completed['completedTaskIds'], contains(task.taskId));
          expect(completed['completedLessonIds'], contains(lesson.lessonId));
          expect(
            completed['learningEvidenceHistory'],
            saved['learningEvidenceHistory'],
          );
        }
      },
    );
  }
}
