import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

Act0RunnerStateV1 _demo() => Act0ShellStateV1.sample
    .lessonById('fold_check_call_raise')
    .taskList
    .firstWhere((task) => task.taskId == 'actions_check_drill')
    .runner;

Future<String> _handoffAfter(
  WidgetTester t,
  String optionId, {
  bool direct = false,
}) async {
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    MaterialApp(
      key: ValueKey('$optionId$direct'),
      home: Act0WelcomeShellV1(
        replayMode: false,
        handoffStartsRecommendedTask: direct,
        onCompleted: () {},
      ),
    ),
  );
  await t.pumpAndSettle();
  await t.tap(find.byKey(const Key('act0_shell_welcome_primary_cta')));
  await t.pumpAndSettle();
  final demo = t.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  demo.onChooseOption(
    demo.runner.options.firstWhere((option) => option.id == optionId),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
  return find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data ?? '')
      .join('\n');
}

void main() {
  final answer = _demo().options.firstWhere((option) => option.isCorrect);

  for (final option in _demo().options) {
    testWidgets('${option.id} handoff teaches from source without grading', (
      t,
    ) async {
      final text = await _handoffAfter(t, option.id);
      expect(text, contains('You chose ${option.label}.'));
      expect(text, contains(option.feedbackReason));
      if (!option.isCorrect) expect(text, contains(answer.feedbackReason));
      expect(text, contains('This preview is ungraded.'));
      expect(text, isNot(contains('You tried')));
      expect(text, isNot(matches(RegExp(r'\b(Correct|Wrong|XP|earned)\b'))));
      expect(find.text('See my next step'), findsOneWidget);
    });
  }

  testWidgets('recommended-task handoff keeps its existing route label', (
    t,
  ) async {
    await _handoffAfter(t, answer.id, direct: true);
    expect(find.text('Start recommended lesson'), findsOneWidget);
  });

  test('learner copy drops internal route and live-check jargon', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
    ).readAsStringSync();
    for (final phrase in [
      'route rep',
      'on the route first',
      'The live check',
      'Sharky loop',
      'Locked inventory',
    ]) {
      expect(source, isNot(contains(phrase)), reason: phrase);
    }
  });
}
