import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
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
