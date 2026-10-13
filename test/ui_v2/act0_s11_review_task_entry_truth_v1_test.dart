import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget, reason: key);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _mount(
  WidgetTester tester, {
  bool fresh = false,
  bool resumeRunner = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        initialTab: resumeRunner ? Act0ShellTabV1.play : Act0ShellTabV1.home,
        showPlacementOnStart: fresh,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _question(WidgetTester tester, String optionId) async {
  for (var i = 0; i < 12; i++) {
    if (find.byKey(Key('act0_shell_option_$optionId')).evaluate().isNotEmpty)
      return;
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsNothing,
      reason: 'Unanswered task must not enter feedback',
    );
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    await _tap(
      tester,
      theory.evaluate().isNotEmpty
          ? 'act0_shell_theory_continue_cta'
          : 'act0_shell_continue_cta',
    );
  }
  fail('Question never became selectable: $optionId');
}

void main() {
  testWidgets(
    'representative Poker recap restore enters assessment before feedback',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final lesson = Act0ShellStateV1.sample.lessonById(
        'what_poker_is_content',
      );
      final task = lesson.taskList.last;
      expect(task.taskId, 'what_poker_is_review');
      expect(task.phase, Act0LessonPhaseV1.review);
      expect(task.entryPhase, Act0LessonPhaseV1.drill);
      // A deterministic restore fixture, not native acceptance or earned proof.
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        _progressKey: jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': [
            for (final t in lesson.taskList.take(lesson.taskList.length - 1))
              t.taskId,
          ],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': lesson.lessonId,
          'selectedTaskId': task.taskId,
          'earnedXp': 0,
          'resumePhase': 'review',
          'resumeSelectedOptionId': 'stale_previous_answer',
        }),
      });
      await _mount(tester, resumeRunner: true);
      expect(_runner(tester).selectedTaskId, task.taskId);
      expect(_runner(tester).runner.phase, Act0LessonPhaseV1.drill);
      expect(_runner(tester).runner.selectedOptionId, isNull);
      final correct = task.runner.options.firstWhere((o) => o.isCorrect);
      await _question(tester, correct.id);
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsNothing,
      );
      await _tap(tester, 'act0_shell_option_${correct.id}');
      expect(_runner(tester).runner.phase, Act0LessonPhaseV1.review);
      final saved = await _saved();
      final records = saved['learningEvidenceHistory'] as List;
      expect(records.single['taskId'], task.taskId);
      expect(records.single['isCorrect'], true);
    },
  );
  for (final wrongFirst in [false, true]) {
    testWidgets(
      'W1 final review requires actual ${wrongFirst ? "wrong then correct" : "correct"} answer; restart and XP',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        await _mount(tester, fresh: true);
        for (final key in [
          'act0_shell_placement_intro_cta',
          'act0_shell_placement_option_new',
          'act0_shell_placement_next_cta',
          'act0_shell_welcome_primary_cta',
        ]) {
          await _tap(tester, key);
        }
        final welcomeAnswer = _runner(
          tester,
        ).runner.options.firstWhere((o) => o.isCorrect);
        await _tap(tester, 'act0_shell_option_${welcomeAnswer.id}');
        await _tap(tester, 'act0_shell_welcome_primary_cta');
        await _tap(tester, 'act0_shell_main_cta');
        final lesson = Act0ShellStateV1.sample
            .worldById('world_1')
            .lessons
            .firstWhere((l) => l.lessonId == 'what_poker_is');
        for (final task in lesson.taskList.take(5)) {
          expect(_runner(tester).selectedTaskId, task.taskId);
          if (task.phase == Act0LessonPhaseV1.theory) {
            for (
              var i = 0;
              i < 12 && _runner(tester).selectedTaskId == task.taskId;
              i++
            ) {
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
          } else {
            final answer = task.runner.options.firstWhere((o) => o.isCorrect);
            // Table-reading tasks may own native seat controls rather than cards.
            for (var i = 0; i < 12; i++) {
              final option = find.byKey(Key('act0_shell_option_${answer.id}'));
              final seat = find.byKey(
                Key('act0_shell_seat_tap_${answer.seatId}'),
              );
              if (option.evaluate().isNotEmpty || seat.evaluate().isNotEmpty) {
                await _tap(
                  tester,
                  seat.evaluate().isNotEmpty
                      ? 'act0_shell_seat_tap_${answer.seatId}'
                      : 'act0_shell_option_${answer.id}',
                );
                break;
              }
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
            await _tap(tester, 'act0_shell_feedback_continue_cta');
          }
        }
        expect(_runner(tester).selectedTaskId, 'first_table_guide_route_roles');
        expect(_runner(tester).runner.phase, Act0LessonPhaseV1.drill);
        expect(_runner(tester).runner.selectedOptionId, isNull);
        await _question(tester, 'review');
        expect(
          find.text('Where do you go to fix mistakes after a miss?'),
          findsOneWidget,
        );
        expect(find.text('CORRECT READ'), findsNothing);
        var saved = await _saved();
        expect(saved['earnedXp'], 25);
        expect(saved['completedLessonIds'], isEmpty);
        expect((saved['learningEvidenceHistory'] as List).length, 4);
        expect(saved['resumeSelectedOptionId'], isNull);
        // Cold remount uses the genuine snapshot produced by the five prior steps.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await _mount(tester, resumeRunner: true);
        expect(_runner(tester).selectedTaskId, 'first_table_guide_route_roles');
        await _question(tester, 'review');
        expect(find.text('CORRECT READ'), findsNothing);
        if (wrongFirst) {
          final wrong = _runner(
            tester,
          ).runner.options.firstWhere((o) => !o.isCorrect);
          await _tap(tester, 'act0_shell_option_${wrong.id}');
          expect(find.text('CORRECT READ'), findsNothing);
          final wrongSaved = await _saved();
          final wrongRecords = (wrongSaved['learningEvidenceHistory'] as List)
              .where((r) => r['taskId'] == 'first_table_guide_route_roles')
              .toList();
          expect(wrongRecords.single['isCorrect'], false);
          expect(wrongSaved['earnedXp'], 25);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          await _mount(tester, resumeRunner: true);
          await _question(tester, 'review');
        }
        await _tap(tester, 'act0_shell_option_review');
        expect(_runner(tester).runner.phase, Act0LessonPhaseV1.review);
        expect(_runner(tester).runner.selectedOptionId, 'review');
        expect(find.text('CORRECT READ'), findsOneWidget);
        saved = await _saved();
        final records = (saved['learningEvidenceHistory'] as List)
            .where((r) => r['taskId'] == 'first_table_guide_route_roles')
            .toList();
        expect(records.length, wrongFirst ? 2 : 1);
        expect(records.last['choiceId'], 'review');
        expect(records.last['expectedChoiceId'], 'review');
        expect(records.last['isCorrect'], true);
        expect(records.last['assistanceKind'], 'none');
        if (wrongFirst) expect(records.first['isCorrect'], false);
        expect(saved['earnedXp'], 25);
        await _tap(tester, 'act0_shell_feedback_continue_cta');
        // Wrong-first runs include the existing end-of-lesson independent recheck.
        if (find.byType(Act0BlockCompletionShellV1).evaluate().isEmpty) {
          await _question(tester, 'review');
          await _tap(tester, 'act0_shell_option_review');
          await _tap(tester, 'act0_shell_feedback_continue_cta');
        }
        expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
        saved = await _saved();
        expect(saved['earnedXp'], 30);
        expect(saved['completedLessonIds'], contains('what_poker_is'));
        expect(
          saved['completedTaskIds'],
          contains('first_table_guide_route_roles'),
        );
        final count = (saved['learningEvidenceHistory'] as List).length;
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await _mount(tester);
        saved = await _saved();
        expect(saved['earnedXp'], 30);
        expect((saved['learningEvidenceHistory'] as List).length, count);
        expect(find.text('CORRECT READ'), findsNothing);
      },
    );
  }
}
