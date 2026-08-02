import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

const _progressKey = 'act0_shell_progress_v1';
const _fixturePath =
    'tools/contracts/e2e_product_integrity_checkpoint_progressed_replay_v1.json';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('fresh entry reaches the canonical first learning decision', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sink = Act0InMemoryTelemetrySinkV1();
    await tester.pumpWidget(
      MaterialApp(home: Act0ShellPreviewScreenV1(telemetrySink: sink)),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_placement_intro_cta')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('act0_shell_placement_intro_cta')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_option_new')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
    await tester.pumpAndSettle();
    final welcome = find.byKey(const Key('act0_shell_welcome_primary_cta'));
    await tester.ensureVisible(welcome);
    await tester.tap(welcome);
    await tester.pumpAndSettle();
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final wrong = runner.runner.options.firstWhere(
      (option) => !option.isCorrect,
    );
    await tester.tap(find.byKey(Key('act0_shell_option_${wrong.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(welcome);
    await tester.tap(welcome);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    final lesson = find.byKey(const Key('act0_shell_lesson_First Table Guide'));
    expect(lesson, findsOneWidget);
    await tester.tap(lesson);
    await tester.pumpAndSettle();
    final start = find.byKey(const Key('act0_shell_selected_lesson_cta'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    for (var step = 0; step < 30; step++) {
      final active = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      if (active.selectedTaskId == 'what_poker_is_table_read_transfer') break;
      final continueCta = find.byKey(const Key('act0_shell_continue_cta'));
      if (continueCta.evaluate().isNotEmpty) {
        await tester.pump(const Duration(milliseconds: 900));
        await tester.tap(continueCta);
      } else {
        await _answerVisiblePrompt(tester, correct: true);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const Key('act0_shell_feedback_continue_cta')),
        );
      }
      await tester.pumpAndSettle();
    }
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'what_poker_is_table_read_transfer',
    );
    await _advanceToPrompt(tester);
    await _answerVisiblePrompt(tester, correct: false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .repairReasonLine,
      isNotEmpty,
    );
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'what_poker_is_table_read_recheck',
    );
    await _advanceToPrompt(tester);
    await _answerVisiblePrompt(tester, correct: true);
    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
    final recheckReceipt = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(recheckReceipt.repairResultReceiptLine, isNotEmpty);
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta_label')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_learning_run_payoff')), findsNothing);
    expect(
      sink.events.where((event) => event.name == 'feedback_viewed'),
      hasLength(3),
    );
    expect(
      sink.events.where((event) => event.name == 'repair_started'),
      hasLength(1),
    );
    expect(
      sink.events.where((event) => event.name == 'repair_attempted'),
      hasLength(1),
    );
    expect(
      sink.events.where((event) => event.name == 'repair_item_started'),
      hasLength(1),
    );
    expect(
      sink.events.where((event) => event.name == 'task_result'),
      hasLength(2),
    );
    expect(
      _eventIndex(sink, 'repair_started'),
      lessThan(_eventIndex(sink, 'repair_attempted')),
    );
    expect(
      _eventIndex(sink, 'repair_attempted'),
      lessThan(_lastEventIndex(sink, 'task_result')),
    );
  });

  test(
    'progressed fixture uses the production persistence shape without run injection',
    () {
      final fixture =
          jsonDecode(File(_fixturePath).readAsStringSync())
              as Map<String, dynamic>;
      final completed =
          fixture['completed_lesson_ids_by_world'] as Map<String, dynamic>;
      expect(completed.keys, containsAll(<String>['world_1', 'world_2']));
      expect(fixture['constraints']['no_active_learning_run'], isTrue);
      expect(
        fixture['constraints']['no_feedback_repair_recheck_or_payoff_state'],
        isTrue,
      );
      expect(
        Act0ShellStateV1.sample
            .worldById('world_2')
            .lessons
            .any((lesson) => lesson.lessonId == 'hand_discipline_apply'),
        isTrue,
      );
    },
  );

  testWidgets(
    'restored progression records two source outcomes then opens payoff focus',
    (tester) async {
      final fixture =
          jsonDecode(File(_fixturePath).readAsStringSync())
              as Map<String, dynamic>;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        _progressKey: jsonEncode(_persistedProgressForFixture(fixture)),
      });
      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            telemetrySink: sink,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();
      final worldThree = find.byKey(const Key('act0_shell_world_3'));
      await tester.scrollUntilVisible(
        worldThree,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(worldThree);
      await tester.pumpAndSettle();
      final position = find.byKey(
        const Key('act0_shell_lesson_The 6 positions'),
      );
      await tester.ensureVisible(position);
      await tester.tap(position);
      await tester.pumpAndSettle();
      final positionStep = find.byKey(
        const Key('act0_shell_lesson_step_position_six_seats_positions_button'),
      );
      await tester.scrollUntilVisible(
        positionStep,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(positionStep);
      await tester.tap(positionStep);
      await tester.pumpAndSettle();
      final start = find.byKey(const Key('act0_shell_selected_lesson_cta'));
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pumpAndSettle();
      await _advanceToTask(tester, 'position_six_seats_positions_button');
      await _advanceToPrompt(tester);
      await _answerVisiblePrompt(tester, correct: true);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();

      // Replaying the same completed source must not create another run outcome.
      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();
      final replayWorldThree = find.byKey(const Key('act0_shell_world_3'));
      await tester.scrollUntilVisible(
        replayWorldThree,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(replayWorldThree);
      await tester.pumpAndSettle();
      final replayPosition = find.byKey(
        const Key('act0_shell_lesson_The 6 positions'),
      );
      await tester.ensureVisible(replayPosition);
      await tester.tap(replayPosition);
      await tester.pumpAndSettle();
      final replayPositionStep = find.byKey(
        const Key('act0_shell_lesson_step_position_six_seats_positions_button'),
      );
      await tester.scrollUntilVisible(
        replayPositionStep,
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(replayPositionStep);
      await tester.tap(replayPositionStep);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_selected_lesson_cta')));
      await tester.pumpAndSettle();
      await _advanceToTask(tester, 'position_six_seats_positions_button');
      await _advanceToPrompt(tester);
      await _answerVisiblePrompt(tester, correct: true);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();

      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        hasLength(1),
      );

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();
      final worldFour = find.byKey(const Key('act0_shell_world_4'));
      await tester.scrollUntilVisible(
        worldFour,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(worldFour);
      await tester.pumpAndSettle();
      final price = find.byKey(const Key('act0_shell_lesson_Call price'));
      await tester.ensureVisible(price);
      await tester.tap(price);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_selected_lesson_cta')));
      await tester.pumpAndSettle();
      await _advanceToTask(tester, 'w4_bad_price_fold');
      await _advanceToPrompt(tester);
      await _answerVisiblePrompt(tester, correct: true);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Learn').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_learning_run_payoff')), findsOneWidget);
      expect(
        sink.events.where((event) => event.name == 'learning_run_started'),
        hasLength(1),
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        hasLength(2),
      );
      expect(
        _eventIndex(sink, 'learning_run_started'),
        lessThan(_eventIndex(sink, 'learning_run_outcome_recorded')),
      );
      expect(
        _lastEventIndex(sink, 'learning_run_outcome_recorded'),
        lessThan(_eventIndex(sink, 'learning_run_payoff_eligible')),
      );
      expect(
        _eventIndex(sink, 'learning_run_payoff_eligible'),
        lessThan(_eventIndex(sink, 'learning_run_closed')),
      );
      expect(
        _eventIndex(sink, 'learning_run_closed'),
        lessThan(_eventIndex(sink, 'session_payoff_generated')),
      );
      await tester.tap(
        find.byKey(const Key('act0_learning_run_payoff_complete_cta')),
      );
      await tester.pumpAndSettle();
      final focusedRunner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(focusedRunner.runner.phase, Act0LessonPhaseV1.drill);
      expect(focusedRunner.selectedTaskId, 'w4_bad_price_fold');
    },
  );
}

Map<String, Object> _persistedProgressForFixture(Map<String, dynamic> fixture) {
  final completedByWorld =
      fixture['completed_lesson_ids_by_world'] as Map<String, dynamic>;
  final completedLessonIds = <String>[];
  final completedTaskIds = <String>[];
  for (final entry in completedByWorld.entries) {
    final world = Act0ShellStateV1.sample.worldById(entry.key);
    for (final lessonId in (entry.value as List<dynamic>).cast<String>()) {
      final lesson = world.lessons.firstWhere(
        (candidate) => candidate.lessonId == lessonId,
      );
      completedLessonIds.add(lessonId);
      completedTaskIds.addAll(lesson.taskList.map((task) => task.taskId));
    }
  }
  final current =
      (fixture['target'] as Map<String, dynamic>)['current']
          as Map<String, dynamic>;
  return <String, Object>{
    'schemaVersion': 16,
    'completedTaskIds': completedTaskIds,
    'skippedTaskIds': <String>[],
    'completedLessonIds': completedLessonIds,
    'selectedWorldId': current['world_id'] as String,
    'selectedLessonId': current['lesson_id'] as String,
    'selectedTaskId': current['task_id'] as String,
    'earnedXp': 0,
  };
}

Future<void> _answerVisiblePrompt(
  WidgetTester tester, {
  required bool correct,
}) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere(
    (candidate) => candidate.isCorrect == correct,
  );
  if (runner.runner.sizingConfig.isEnabled) {
    await tester.tap(find.byKey(Key('act0_shell_sizing_preset_${option.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
    await tester.pumpAndSettle();
    return;
  }
  final key = option.seatId == null
      ? Key('act0_shell_option_${option.id}')
      : Key('act0_shell_seat_tap_${option.seatId}');
  await tester.ensureVisible(find.byKey(key));
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> _advanceToPrompt(WidgetTester tester) async {
  for (var index = 0; index < 16; index++) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    final option = runner.runner.options.first;
    final key = option.seatId == null
        ? Key('act0_shell_option_${option.id}')
        : Key('act0_shell_seat_tap_${option.seatId}');
    if (runner.runner.sizingConfig.isEnabled ||
        find.byKey(key).evaluate().isNotEmpty) {
      return;
    }
    final cta = find.byKey(const Key('act0_shell_continue_cta'));
    expect(cta, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
  fail('Runner did not reach its decision prompt.');
}

Future<void> _advanceToTask(WidgetTester tester, String taskId) async {
  for (var index = 0; index < 48; index++) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    if (runner.selectedTaskId == taskId) return;
    final option = runner.runner.options.isEmpty
        ? null
        : runner.runner.options.first;
    final optionKey = option == null
        ? null
        : option.seatId == null
        ? Key('act0_shell_option_${option.id}')
        : Key('act0_shell_seat_tap_${option.seatId}');
    if (runner.runner.sizingConfig.isEnabled ||
        (optionKey != null && find.byKey(optionKey).evaluate().isNotEmpty)) {
      await _answerVisiblePrompt(tester, correct: true);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
    } else {
      final cta = find.byKey(const Key('act0_shell_continue_cta'));
      expect(cta, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(cta);
    }
    await tester.pumpAndSettle();
  }
  fail('Runner did not reach $taskId.');
}

int _eventIndex(Act0InMemoryTelemetrySinkV1 sink, String name) {
  final index = sink.events.indexWhere((event) => event.name == name);
  expect(
    index,
    greaterThanOrEqualTo(0),
    reason: 'Missing telemetry event: $name',
  );
  return index;
}

int _lastEventIndex(Act0InMemoryTelemetrySinkV1 sink, String name) {
  final index = sink.events.lastIndexWhere((event) => event.name == name);
  expect(
    index,
    greaterThanOrEqualTo(0),
    reason: 'Missing telemetry event: $name',
  );
  return index;
}
