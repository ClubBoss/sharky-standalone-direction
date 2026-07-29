import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('task-scoped runner drill parsing retains only complete selectors', () {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=what_poker_is&task=what_poker_is_table_read_transfer',
      ),
    );

    expect(entry, isNotNull);
    expect(entry!.surface, Act0ControlledDemoCaptureSurfaceV1.runnerDrill);
    expect(entry.worldId, 'world_1');
    expect(entry.lessonId, 'what_poker_is');
    expect(entry.taskId, 'what_poker_is_table_read_transfer');
    expect(
      parseAct0ControlledDemoHarnessEntryV1(
        Uri.parse(
          'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1',
        ),
      ),
      isNull,
    );
    expect(
      parseAct0ControlledDemoHarnessEntryV1(
        Uri.parse(
          'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=what_poker_is',
        ),
      ),
      isNull,
    );
    expect(parseAct0ControlledDemoHarnessEntryV1(Uri()), isNull);
  });

  testWidgets('task-scoped runner drill opens the selected table task', (
    tester,
  ) async {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=what_poker_is&task=what_poker_is_table_read_transfer',
      ),
    );
    await _pump(tester, entry!);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'what_poker_is_table_read_transfer',
    );
    expect(
      find.byKey(const Key('act0_shell_option_five_board_now')),
      findsOneWidget,
    );
    expect(find.textContaining('Theory page'), findsNothing);
    expect(find.text('Which marker identifies you?'), findsNothing);
  });

  testWidgets('published World 3 selector resolves to a live table runner', (
    tester,
  ) async {
    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_3&lesson=button_advantage&task=button_advantage_button_vs_cutoff',
      ),
    );
    await _pump(tester, entry!);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_seat_tap_prompt')), findsOneWidget);
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .selectedTaskId,
      'button_advantage_button_vs_cutoff',
    );
    expect(find.byKey(const Key('act0_shell_home_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_bottom_nav')), findsNothing);
    expect(find.textContaining('Today'), findsNothing);
  });

  testWidgets('short seat task distributes meaning through the canonical dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final entry = parseAct0ControlledDemoHarnessEntryV1(
      Uri.parse(
        'http://127.0.0.1:7357/?act0_capture=runner_drill&world=world_1&lesson=positions&task=positions_early_late',
      ),
    );
    await _pump(tester, entry!);

    final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
    final prompt = tester.getRect(
      find.byKey(const Key('act0_shell_seat_tap_prompt')),
    );
    final question = tester.getRect(
      find.byKey(const Key('act0_shell_action_question')),
    );
    final action = tester.getRect(
      find.byKey(const Key('act0_shell_seat_tap_prompt_text')),
    );

    expect(prompt.top, greaterThanOrEqualTo(table.bottom - 1));
    expect(prompt.height, greaterThan(180));
    expect(action.top - question.bottom, greaterThan(36));
    expect(action.bottom, lessThanOrEqualTo(874));
    expect(find.byKey(const Key('act0_shell_runner_scroll')), findsOneWidget);
  });

  testWidgets('invalid task-scoped drill selector fails closed to Home', (
    tester,
  ) async {
    await _pump(
      tester,
      const Act0ShellDebugHarnessEntryV1(
        mode: Act0ControlledDemoCaptureModeV1.directState,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_missing',
        lessonId: 'what_poker_is',
        taskId: 'what_poker_is_table_read_transfer',
      ),
    );

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);

    await _pump(
      tester,
      const Act0ShellDebugHarnessEntryV1(
        mode: Act0ControlledDemoCaptureModeV1.directState,
        surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
        worldId: 'world_1',
        lessonId: 'what_poker_is',
        taskId: 'missing_task',
      ),
    );

    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_runner_screen')), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Act0ShellDebugHarnessEntryV1 entry,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        state: Act0ShellStateV1.sample,
        debugHarnessEntry: entry,
      ),
    ),
  );
  await tester.pumpAndSettle();
}
