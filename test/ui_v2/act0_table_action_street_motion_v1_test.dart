import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  testWidgets(
    'canonical W6 turn choreography gates interaction until Hero is ready',
    (tester) async {
      var choices = 0;
      final sink = Act0InMemoryTelemetrySinkV1();
      final task = _task();

      await tester.pumpWidget(
        _host(
          task: task,
          sink: sink,
          onChoose: (_) => choices += 1,
        ),
      );

      expect(find.byKey(const Key('act0_shell_card_board_3')), findsNothing);
      expect(
        sink.events.where((event) => event.name == 'task_shown'),
        hasLength(1),
      );

      final option = find.byKey(const Key('act0_shell_option_check_more'));
      expect(option, findsOneWidget);
      await tester.tap(option);
      await tester.pump();
      expect(choices, 0);
      expect(
        sink.events.where((event) => event.name == 'user_choice'),
        isEmpty,
      );

      await tester.pump(const Duration(seconds: 4));

      expect(find.byKey(const Key('act0_shell_card_board_3')), findsOneWidget);
      expect(find.text('Pot 11 BB'), findsWidgets);

      await tester.tap(option);
      await tester.pump();
      expect(choices, 1);
      expect(
        sink.events.where((event) => event.name == 'user_choice'),
        hasLength(1),
      );
      expect(
        sink.events
            .firstWhere((event) => event.name == 'user_choice')
            .fields['decisionTimeBucket'],
        isNot('unknown'),
      );
    },
  );

  testWidgets('reduced motion settles the hand without queued choreography', (
    tester,
  ) async {
    var choices = 0;
    final task = _task();

    await tester.pumpWidget(
      _host(
        task: task,
        disableAnimations: true,
        onChoose: (_) => choices += 1,
      ),
    );

    expect(find.byKey(const Key('act0_shell_card_board_3')), findsOneWidget);
    expect(find.text('Pot 11 BB'), findsWidgets);
    await tester.tap(find.byKey(const Key('act0_shell_option_check_more')));
    await tester.pump();
    expect(choices, 1);

    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const Key('act0_shell_card_board_3')), findsOneWidget);
    expect(choices, 1);
  });

  testWidgets('settled capture mode renders the exact terminal snapshot', (
    tester,
  ) async {
    final task = _task();

    await tester.pumpWidget(
      _host(
        task: task,
        mode: Act0TableChoreographyModeV1.settled,
      ),
    );

    expect(find.byKey(const Key('act0_shell_card_board_0')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_card_board_1')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_card_board_2')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_card_board_3')), findsOneWidget);
    expect(find.text('Pot 11 BB'), findsWidgets);
  });

  testWidgets('ordinary rebuild does not restart an in-flight attempt', (
    tester,
  ) async {
    final task = _task();

    await tester.pumpWidget(_host(task: task));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.byKey(const Key('act0_shell_card_board_3')), findsNothing);

    await tester.pumpWidget(_host(task: task));
    await tester.pump(const Duration(milliseconds: 1900));

    expect(
      find.byKey(const Key('act0_shell_card_board_3')),
      findsOneWidget,
      reason: 'the second build must continue the original one-shot timeline',
    );
  });

  testWidgets('task replacement makes stale choreography callbacks harmless', (
    tester,
  ) async {
    var replacementChoices = 0;
    final source = _task();
    final replacement = Act0ShellStateV1.sample
        .worldById('world_6')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'range_pressure_lines')
        .taskList
        .firstWhere((task) => task.taskId == 'w6_bluff_candidate');

    await tester.pumpWidget(_host(task: source));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(
      _host(
        task: replacement,
        onChoose: (_) => replacementChoices += 1,
      ),
    );
    await tester.pump(const Duration(seconds: 4));

    final replacementOption = find.byKey(
      Key('act0_shell_option_' + replacement.runner.options.first.id),
    );
    expect(replacementOption, findsOneWidget);
    await tester.tap(replacementOption);
    await tester.pump();
    expect(replacementChoices, 1);
  });
}

Act0LessonTaskV1 _task() => Act0ShellStateV1.sample
    .worldById('world_6')
    .lessons
    .firstWhere((lesson) => lesson.lessonId == 'range_pressure_lines')
    .taskList
    .firstWhere(
      (task) => task.taskId == 'w6_turn_pressure_shift_transfer',
    );

Widget _host({
  required Act0LessonTaskV1 task,
  Act0TelemetrySinkV1? sink,
  ValueChanged<Act0RunnerOptionV1>? onChoose,
  bool disableAnimations = false,
  Act0TableChoreographyModeV1 mode = Act0TableChoreographyModeV1.runtime,
}) {
  final runner = task.runner.copyWith(
    phase: Act0LessonPhaseV1.drill,
    teachingSteps: const <Act0TeachingStepV1>[],
  );
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(402, 874),
        disableAnimations: disableAnimations,
      ),
      child: Scaffold(
        body: Act0LessonRunnerShellV1(
          runner: runner,
          worldNumber: 6,
          selectedWorldId: 'world_6',
          selectedLessonId: 'range_pressure_lines',
          selectedTaskId: task.taskId,
          selectedTaskFamily: task.resolvedTaskFamily,
          tableChoreographyMode: mode,
          telemetrySink: sink,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: onChoose ?? (_) {},
          onContinueReview: () {},
        ),
      ),
    ),
  );
}
