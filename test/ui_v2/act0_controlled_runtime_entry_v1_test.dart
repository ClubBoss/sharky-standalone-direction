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
