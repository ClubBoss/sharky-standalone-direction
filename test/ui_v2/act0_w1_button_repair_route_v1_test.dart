import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  testWidgets(
    'W1 hero miss uses BTN repair then independently rechecks W1 source',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: Act0ShellStateV1.sample,
            telemetrySink: sink,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'what_poker_is',
              taskId: 'what_poker_is_find_hero',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      await _answer(tester, correct: false);
      await _continueFeedback(tester);

      final debt =
          state.debugOpenRepairIntentPayloadForSourceTaskV1(
                'what_poker_is_find_hero',
              )
              as Map<String, Object?>?;
      expect(debt?['sourceTaskId'], 'what_poker_is_find_hero');
      expect(debt?['missedSignalId'], 'hero_button');
      expect(
        debt?['targetTaskId'],
        'position_six_seats_position_repair_seat_id_btn',
      );
      expect(
        state.debugSelectedTaskIdV1(),
        'position_six_seats_position_repair_seat_id_btn',
      );

      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(state.debugSelectedTaskIdV1(), 'what_poker_is_find_hero');
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          'what_poker_is_find_hero',
        ),
        isNull,
      );

      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          'what_poker_is_find_hero',
        ),
        isNull,
      );
      expect(state.debugOpenRepairIntentCountV1(), 0);
      final rechecks = sink.events
          .where((event) => event.name == 'recheck_result')
          .toList(growable: false);
      expect(rechecks, hasLength(1));
      expect(
        rechecks.single.fields['source_task_id'],
        'what_poker_is_find_hero',
      );
      expect(
        rechecks.single.fields['recheck_task_id'],
        'what_poker_is_find_hero',
      );
      expect(rechecks.single.fields['result'], 'correct');
      expect(rechecks.single.fields['proof_status'], 'unassisted');
    },
  );
}

Future<void> _answer(WidgetTester tester, {required bool correct}) async {
  var runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere(
    (candidate) => candidate.isCorrect == correct,
  );
  final control = () {
    final seatId = option.seatId;
    return seatId == null || seatId.isEmpty
        ? find.byKey(Key('act0_shell_option_${option.id}'))
        : find.byKey(Key('act0_shell_seat_tap_$seatId'));
  }();
  for (var step = 0; step < 12 && control.evaluate().isEmpty; step++) {
    final next = find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.tap(next);
    await tester.pumpAndSettle();
    runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
  }
  expect(control, findsOneWidget);
  await tester.tap(control);
  await tester.pumpAndSettle();
}

Future<void> _continueFeedback(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (cta.evaluate().isEmpty) return;
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}
