import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'Review recovery replays the authoritative table task through repair and recheck',
    (tester) async {
      final telemetrySink = Act0InMemoryTelemetrySinkV1();
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);

      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: Act0ShellStateV1.sample,
            telemetrySink: telemetrySink,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'what_poker_is',
              taskId: 'what_poker_is_table_read_transfer',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_selectedTaskId(tester), 'what_poker_is_table_read_transfer');
      await _tap(tester, 'act0_shell_option_five_board_now');
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      await _tap(tester, 'act0_shell_runner_back');

      await _openBottomTab(tester, 'Review');
      expect(
        find.byKey(const Key('act0_shell_review_repair_coach_card')),
        findsOneWidget,
      );
      await _tap(tester, 'act0_shell_review_practice_cta');
      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
      expect(_selectedTaskId(tester), 'what_poker_is_table_read_recheck');

      await _advanceTeachingToDrill(tester);
      await _tap(tester, 'act0_shell_option_two_three_four');
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_feedback_reason')),
        findsOneWidget,
      );
      await _tap(tester, 'act0_shell_feedback_continue_cta');

      expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
      expect(
        find.byKey(
          const Key(
            'act0_shell_fixed_mistake_what_poker_is_table_read_transfer',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_review_practice_cta')),
        findsNothing,
        reason:
            'The repaired item must not remain actionable as a pending loop.',
      );

      final repairShown = _events(telemetrySink, 'repair_item_shown');
      final repairStarted = _events(telemetrySink, 'repair_item_started');
      final repairCompleted = _events(telemetrySink, 'repair_item_completed');
      expect(repairShown, hasLength(1));
      expect(repairStarted, hasLength(1));
      expect(repairCompleted, hasLength(1));

      final started = repairStarted.single;
      final completed = repairCompleted.single;
      expect(
        repairShown.single.fields['repairItemId'],
        'repair:what_poker_is_table_read_transfer',
      );
      expect(
        started.fields['repairItemId'],
        'repair:what_poker_is_table_read_transfer',
      );
      expect(
        started.fields['sourceTaskId'],
        'what_poker_is_table_read_transfer',
      );
      expect(
        started.fields['targetTaskId'],
        'what_poker_is_table_read_recheck',
      );
      expect(started.fields['createdFrom'], 'mistake');
      expect(started.fields['mappingType'], 'mapped');
      expect(started.fields['status'], 'in_progress');
      expect(started.fields['sessionId'], 'session_v1|1');
      expect(started.fields['session_id'], started.fields['sessionId']);
      expect(
        completed.fields['sourceTaskId'],
        'what_poker_is_table_read_transfer',
      );
      expect(
        completed.fields['repairItemId'],
        'repair:what_poker_is_table_read_transfer',
      );
      expect(
        completed.fields['targetTaskId'],
        'what_poker_is_table_read_recheck',
      );
      expect(completed.fields['outcome'], 'repaired');

      final choices = _events(telemetrySink, 'user_choice');
      expect(choices, hasLength(2));
      expect(
        choices.first.fields['taskId'],
        'what_poker_is_table_read_transfer',
      );
      expect(choices.first.fields['choiceId'], 'five_board_now');
      expect(choices.last.fields['taskId'], 'what_poker_is_table_read_recheck');
      expect(choices.last.fields['choiceId'], 'two_three_four');
      expect(_events(telemetrySink, 'feedback_viewed'), hasLength(2));
    },
  );
}

String _selectedTaskId(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
    .selectedTaskId!;

List<Act0TelemetryEventV1> _events(
  Act0InMemoryTelemetrySinkV1 sink,
  String name,
) => sink.events.where((event) => event.name == name).toList(growable: false);

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _openBottomTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  expect(tab, findsOneWidget);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> _advanceTeachingToDrill(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    if (find
        .byKey(const Key('act0_shell_option_two_three_four'))
        .evaluate()
        .isNotEmpty) {
      return;
    }
    for (final key in const <String>[
      'act0_shell_runner_primary_cta',
      'act0_shell_continue_cta',
      'act0_shell_theory_continue_cta',
    ]) {
      final cta = find.byKey(Key(key));
      if (cta.evaluate().isNotEmpty) {
        await tester.ensureVisible(cta);
        await tester.tap(cta);
        await tester.pumpAndSettle();
        break;
      }
    }
  }
  expect(
    find.byKey(const Key('act0_shell_option_two_three_four')),
    findsOneWidget,
    reason: 'Review recheck did not reach its mapped direct-table decision.',
  );
}
