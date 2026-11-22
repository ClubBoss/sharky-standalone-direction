import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_source_choreography_test_wait_v1.dart';

final act0RoutePracticeFinder = find.byKey(
  const Key('act0_shell_route_practice_runner'),
);

Future<void> answerAct0RoutePracticeV1(
  WidgetTester tester, {
  required bool correct,
}) async {
  final shell = tester.widget<Act0LessonRunnerShellV1>(
    find.descendant(
      of: act0RoutePracticeFinder,
      matching: find.byType(Act0LessonRunnerShellV1),
    ),
  );
  final runner = shell.runner;
  expect(runner.phase, Act0LessonPhaseV1.drill);
  expect(runner.activeTeachingStep, isNull);
  await pumpSourceChoreographyToDecisionV1(tester, runner.table);
  final choice = runner.options.firstWhere(
    (choice) => choice.isCorrect == correct,
  );
  if (runner.sizingConfig.isEnabled) {
    await tapAct0RoutePracticeKeyV1(
      tester,
      'act0_shell_sizing_preset_${choice.id}',
    );
    await tapAct0RoutePracticeKeyV1(tester, 'act0_shell_sizing_confirm_cta');
  } else {
    await tapAct0RoutePracticeKeyV1(
      tester,
      choice.seatId == null
          ? 'act0_shell_option_${choice.id}'
          : 'act0_shell_seat_tap_${choice.seatId}',
    );
  }
}

Future<void> tapAct0RoutePracticeKeyV1(WidgetTester tester, String id) async {
  final target = find.byKey(Key(id));
  expect(target, findsOneWidget, reason: id);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  final reachable = target.hitTestable();
  expect(reachable, findsOneWidget, reason: id);
  await tester.tap(reachable);
  await tester.pumpAndSettle();
}

Future<void> finishAct0RoutePracticeV1(
  WidgetTester tester, {
  required bool correct,
}) async {
  expect(act0RoutePracticeFinder, findsOneWidget);
  for (
    var rep = 0;
    rep < 6 && act0RoutePracticeFinder.evaluate().isNotEmpty;
    rep++
  ) {
    final shell = tester.widget<Act0LessonRunnerShellV1>(
      find.descendant(
        of: act0RoutePracticeFinder,
        matching: find.byType(Act0LessonRunnerShellV1),
      ),
    );
    if (shell.runner.phase == Act0LessonPhaseV1.drill) {
      await answerAct0RoutePracticeV1(tester, correct: correct);
    }
    await tapAct0RoutePracticeKeyV1(tester, 'act0_shell_feedback_continue_cta');
  }
  expect(act0RoutePracticeFinder, findsNothing);
}
