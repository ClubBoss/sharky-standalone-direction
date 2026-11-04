import 'dart:ui' show SemanticsFlag;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _previousKey = Key('act0_shell_previous_cta');
const _nextKey = Key('act0_shell_continue_cta');

Act0RunnerStateV1 _theory({int step = 0}) => Act0ShellStateV1.sample
    .lessonById('what_poker_is')
    .taskList
    .firstWhere((task) => task.taskId == 'what_poker_is_theory')
    .runner
    .copyWith(phase: Act0LessonPhaseV1.theory, teachingStepIndex: step);

Future<void> _pumpRunner(
  WidgetTester tester, {
  required Act0RunnerStateV1 runner,
  required VoidCallback onBack,
  required VoidCallback onContinue,
  VoidCallback? onPrevious,
}) async {
  // The admitted development profile is EN iPhone 14 Pro only.
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          key: const ValueKey('learning-rail-accessibility'),
          runner: runner,
          selectedWorldId: 'world_1',
          selectedLessonId: 'what_poker_is',
          selectedTaskId: 'what_poker_is_theory',
          onBack: onBack,
          onPreviousTheory: onPrevious,
          onContinueTheory: onContinue,
          onContinueReview: () {},
          onChooseOption: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('48pt targets receive edge taps outside the compact paint', (
    tester,
  ) async {
    var backCalls = 0;
    var continueCalls = 0;
    await _pumpRunner(
      tester,
      runner: _theory(),
      onBack: () => backCalls++,
      onContinue: () => continueCalls++,
    );
    await tester.pump(const Duration(seconds: 1));

    final previous = find.byKey(_previousKey);
    final next = find.byKey(_nextKey);
    final previousRect = tester.getRect(previous);
    final nextRect = tester.getRect(next);
    for (final rect in [previousRect, nextRect]) {
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      final rail = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );
      expect(rail.contains(rect.topLeft), isTrue);
      expect(rect.bottom, lessThanOrEqualTo(rail.bottom));
      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      expect(rect.overlaps(table), isFalse);
    }
    expect(previousRect.overlaps(nextRect), isFalse);

    for (final button in [previous, next]) {
      final painted = find.descendant(
        of: button,
        matching: find.byType(Container),
      );
      expect(painted, findsOneWidget);
      final paintedRect = tester.getRect(painted);
      expect(paintedRect.height, 32);
      final targetRect = tester.getRect(button);
      final edge = Offset(targetRect.center.dx, targetRect.top + 2);
      expect(paintedRect.contains(edge), isFalse);
      await tester.tapAt(edge);
      await tester.pump();
    }
    expect(backCalls, 1);
    expect(continueCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('named button semantics preserve the dwell lock across rebuild', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    var continueCalls = 0;
    final runner = _theory();
    Future<void> pump() => _pumpRunner(
      tester,
      runner: runner,
      onBack: () {},
      onContinue: () => continueCalls++,
    );
    await pump();
    final previous = find.byKey(_previousKey);
    final next = find.byKey(_nextKey);
    final previousData = tester.getSemantics(previous).getSemanticsData();
    expect(previousData.label, 'Back');
    expect(previousData.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(previousData.hasAction(SemanticsAction.tap), isTrue);
    final locked = tester.getSemantics(next).getSemanticsData();
    expect(locked.label, 'Continue');
    expect(locked.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(locked.hasFlag(SemanticsFlag.isEnabled), isFalse);
    expect(locked.hasAction(SemanticsAction.tap), isFalse);
    final rect = tester.getRect(next);
    await tester.tapAt(Offset(rect.center.dx, rect.top + 2));
    expect(continueCalls, 0);

    await tester.pump(const Duration(milliseconds: 100));
    await pump();
    await tester.pump(const Duration(seconds: 1));
    final unlocked = tester.getSemantics(next).getSemanticsData();
    expect(unlocked.label, 'Continue');
    expect(unlocked.hasFlag(SemanticsFlag.isEnabled), isTrue);
    expect(unlocked.hasAction(SemanticsAction.tap), isTrue);
    expect(tester.getRect(next), rect);
    await tester.tapAt(Offset(rect.center.dx, rect.top + 2));
    expect(continueCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Previous callback availability preserves its route and name', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    var backCalls = 0;
    var previousCalls = 0;
    final runner = _theory(step: 1);
    await _pumpRunner(
      tester,
      runner: runner,
      onBack: () => backCalls++,
      onContinue: () {},
    );
    final previous = find.byKey(_previousKey);
    expect(tester.widget<TextButton>(previous).onPressed, isNull);
    final data = tester.getSemantics(previous).getSemanticsData();
    expect(data.label, 'Back');
    expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
    expect(data.hasFlag(SemanticsFlag.isEnabled), isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    expect(tester.getSize(previous).height, greaterThanOrEqualTo(48));
    await tester.tapAt(tester.getTopLeft(previous) + const Offset(2, 2));
    expect(backCalls, 0);
    await _pumpRunner(
      tester,
      runner: runner,
      onBack: () => backCalls++,
      onPrevious: () => previousCalls++,
      onContinue: () {},
    );
    await tester.tap(previous);
    expect(previousCalls, 1);
    expect(backCalls, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
