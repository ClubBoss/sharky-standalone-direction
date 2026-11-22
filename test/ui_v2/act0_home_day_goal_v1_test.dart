import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

final _dayOne = DateTime.utc(2026, 11, 20, 12);
const _reminders = MethodChannel('com.clubboss.sharky/practice_reminder_v1');

Future<void> _mount(WidgetTester tester, DateTime now) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        clock: Act0FixedUtcClockV1(now),
        showPlacementOnStart: true,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _snapshot() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString('act0_shell_progress_v1')!)
      as Map<String, dynamic>;
}

Future<void> _advanceTheory(WidgetTester tester) async {
  final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
  await tester.pump(const Duration(milliseconds: 900));
  await _tap(
    tester,
    theory.evaluate().isNotEmpty
        ? 'act0_shell_theory_continue_cta'
        : 'act0_shell_continue_cta',
  );
}

Future<void> _finishFirstLesson(WidgetTester tester) async {
  await _tap(tester, 'act0_shell_w1_start_basics');
  final runnerFinder = find.byType(Act0LessonRunnerShellV1);
  for (var step = 0; step < 28 && runnerFinder.evaluate().isNotEmpty; step++) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(runnerFinder).runner;
    final feedback = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (feedback.evaluate().isNotEmpty) {
      await _tap(tester, 'act0_shell_feedback_continue_cta');
    } else if (runner.activeTeachingStep != null ||
        !runner.options.any((option) => option.isCorrect)) {
      await _advanceTheory(tester);
    } else {
      await pumpSourceChoreographyToDecisionV1(tester, runner.table);
      final answer = runner.options.singleWhere((option) => option.isCorrect);
      final option = 'act0_shell_option_${answer.id}';
      await _tap(
        tester,
        find.byKey(Key(option)).evaluate().isNotEmpty
            ? option
            : 'act0_shell_seat_tap_${answer.seatId}',
      );
    }
  }
  expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
}

void main() {
  testWidgets(
    'due review is primary beside an unfinished lesson and counts today',
    (tester) async {
      final now = _dayOne.add(const Duration(days: 1));
      const reviewTask = 'what_poker_is_find_hero';
      const interruptedTask = 'what_poker_is_table_read_transfer';
      const lessonId = 'what_poker_is';
      final lesson = Act0ShellStateV1.sample.lessonById('first_table_guide');
      final interrupted = lesson.courseTaskList.singleWhere(
        (task) => task.taskId == interruptedTask,
      );
      final scheduled = Act0DurableRetentionFamilyV1(
        conceptFamilyId: 'hero_button',
        worldId: 'world_1',
        sourceLessonId: lessonId,
        sourceTaskId: reviewTask,
        retentionState: Act0RetentionStateV1.recoveredPendingSpacedReview,
        nextDueAtUtc: now,
        lastSpacedReviewAtUtc: null,
        spacedSuccessStage: 0,
        lapseCount: 0,
        incorrectCount: 1,
        correctCount: 1,
        lastRecordedAtUtc: _dayOne,
        lastCreatedOrder: 2,
        lastSessionId: 'fixture-day-one',
        lastReviewKind: Act0ReviewKindV1.immediateRepair,
        hasLegacyUnspacedEvidence: false,
      );
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        'act0_shell_progress_v1': jsonEncode({
          'schemaVersion': 20,
          'learningEvidenceHistory': [],
          'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
              .lineagePayload(),
          'durableRetentionHistory': [scheduled.toPayload()],
          'completedTaskIds': [
            'what_poker_is_theory',
            reviewTask,
            'first_table_guide_first_decision',
          ],
          'completedLessonIds': [],
          'skippedTaskIds': [],
          'earnedXp': 10,
          'selectedWorldId': 'world_1',
          'selectedLessonId': lessonId,
          'selectedTaskId': interruptedTask,
          'resumeInRunner': true,
          'resumePhase': 'drill',
          'resumeTeachingStepIndex': interrupted.runner.teachingSteps.length,
          'pendingDecisionAssistance': [],
        }),
      });
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _mount(tester, now);
      final primary = find.byKey(const Key('act0_academy_home_leaf_cta'));
      expect(
        find.descendant(of: primary, matching: find.text('Quick review')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_home_resume_lesson')), findsOneWidget);
      await _tap(tester, 'act0_academy_home_leaf_cta');
      final runnerFinder = find.byType(Act0LessonRunnerShellV1);
      expect(
        tester.widget<Act0LessonRunnerShellV1>(runnerFinder).selectedTaskId,
        reviewTask,
      );
      final answer = tester
          .widget<Act0LessonRunnerShellV1>(runnerFinder)
          .runner
          .options
          .singleWhere((option) => option.isCorrect);
      await _tap(tester, 'act0_shell_option_${answer.id}');
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      expect(find.text('Today’s goal complete'), findsOneWidget);
      final savedAfter = await _snapshot();
      expect(savedAfter['earnedXp'], 10);
      expect(find.text('Continue lesson'), findsOneWidget);
      await _tap(tester, 'act0_academy_home_leaf_cta');
      final resumed = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
      expect(resumed.selectedTaskId, interruptedTask);
      expect(resumed.runner.activeTeachingStep, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  for (final enableReminder in [true, false]) {
    testWidgets(
      'lesson counts today and reminder choice is explicit ($enableReminder)',
      (tester) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final calls = <MethodCall>[];
        final messenger = tester.binding.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(_reminders, (call) async {
          calls.add(call);
          return call.method == 'setEnabled';
        });
        addTearDown(() => messenger.setMockMethodCallHandler(_reminders, null));
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await _mount(tester, _dayOne);
        await _finishFirstLesson(tester);
        expect(calls.where((call) => call.method == 'setEnabled'), isEmpty);
        await _tap(
          tester,
          enableReminder
              ? 'act0_first_lesson_reminder_yes'
              : 'act0_first_lesson_reminder_no',
        );
        expect(
          calls.where((call) => call.method == 'setEnabled'),
          hasLength(enableReminder ? 1 : 0),
        );
        expect((await _snapshot())['firstLessonReminderAnswered'], isTrue);
        await _tap(tester, 'act0_shell_block_summary_home_cta');
        expect(find.text('Today’s goal complete'), findsOneWidget);
        expect(find.byKey(const Key('act0_home_daily_practice')), findsNothing);

        await _tap(tester, 'act0_academy_home_leaf_cta');
        final lesson = tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedLessonId;
        await _tap(tester, 'act0_shell_runner_back');
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();

        await _mount(tester, _dayOne.add(const Duration(days: 2)));
        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Today’s goal: one lesson or review'), findsOneWidget);
        final resume = find.byKey(const Key('act0_home_resume_lesson'));
        await _tap(
          tester,
          resume.evaluate().isNotEmpty
              ? 'act0_home_resume_lesson'
              : 'act0_academy_home_leaf_cta',
        );
        expect(
          tester
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .selectedLessonId,
          lesson,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
      variant: const TargetPlatformVariant({TargetPlatform.iOS}),
    );
  }
}
