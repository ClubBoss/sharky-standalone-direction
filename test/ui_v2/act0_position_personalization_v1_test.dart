import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('position family accepts only the canonical BTN same-signal repair', () {
    final family = Act0PositionPersonalizationV1.fromRepairIntent(_intent());

    expect(family, isNotNull);
    expect(family!.feedbackFocus, 'The Button anchors late position.');
    expect(family.repairStrategyId, 'find_dealer_button_then_tap_btn_v1');
    expect(family.recheckMappingId, 'same_hero_button_signal_v1');
    expect(
      Act0PositionPersonalizationV1.fromRepairIntent(
        _intent(targetTaskId: 'position_six_seats_positions_button'),
      ),
      isNull,
    );
  });

  testWidgets(
    'W3 BTN miss repairs and rechecks the hero-button signal with ordered telemetry',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPositionTask(tester, sink);

      await _answer(tester, correct: false);
      await _continueFeedback(tester);

      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final intent =
          state.debugOpenRepairIntentPayloadForSourceTaskV1(
                Act0PositionPersonalizationV1.sourceTaskId,
              )
              as Map<String, Object?>?;
      expect(intent?['errorType'], 'misread_table_position');
      expect(intent?['missedSignalId'], 'hero_button');
      expect(intent?['skillAtomId'], 'table_position_read');
      expect(
        intent?['targetTaskId'],
        Act0PositionPersonalizationV1.repairTaskId,
      );

      expect(
        state.debugSelectedTaskIdV1(),
        Act0PositionPersonalizationV1.repairTaskId,
      );
      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugSelectedTaskIdV1(),
        Act0PositionPersonalizationV1.sourceTaskId,
      );
      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          Act0PositionPersonalizationV1.sourceTaskId,
        ),
        isNull,
      );

      final familyEvents = sink.events
          .where((event) => event.name.startsWith('position_personalization_'))
          .toList(growable: false);
      expect(familyEvents.map((event) => event.name), <String>[
        'position_personalization_classified',
        'position_personalization_recheck',
        'position_personalization_payoff',
      ]);
      expect(
        familyEvents.map((event) => event.fields['final_learning_outcome']),
        <String>[
          'repair_required',
          'position_signal_recovered',
          'position_signal_recovered',
        ],
      );
      for (final event in familyEvents) {
        expect(event.fields['lesson_id'], 'position_six_seats');
        expect(event.fields['skill_id'], 'table_position_read');
        expect(
          event.fields['repair_strategy'],
          'find_dealer_button_then_tap_btn_v1',
        );
      }

      final sourceChoices = sink.events
          .where((event) => event.name == 'user_choice')
          .toList(growable: false);
      expect(sourceChoices, hasLength(3));
      expect(
        sourceChoices.first.fields['taskId'],
        Act0PositionPersonalizationV1.sourceTaskId,
      );
      expect(
        sourceChoices.first.fields['error_type'],
        'misread_table_position',
      );
      expect(
        familyEvents.first.fields['error_type'],
        Act0PositionPersonalizationV1.errorType,
      );
      expect(familyEvents.first.fields['user_choice'], isNotEmpty);
      expect(sourceChoices.first.fields['decisionTimeBucket'], isNotEmpty);
    },
  );

  testWidgets(
    'W3 BTN correct-first outcome stays truthful and needs no repair',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPositionTask(tester, sink);

      await _answer(tester, correct: true);
      await _continueFeedback(tester);

      final payoffs = sink.events
          .where((event) => event.name == 'position_personalization_payoff')
          .toList(growable: false);
      expect(payoffs, hasLength(1));
      expect(
        payoffs.single.fields['final_learning_outcome'],
        'position_signal_read_cleanly',
      );
      expect(
        sink.events.where((event) => event.name == 'repair_started'),
        isEmpty,
      );
    },
  );
}

Act0RepairIntentV1 _intent({
  String targetTaskId = Act0PositionPersonalizationV1.repairTaskId,
}) => Act0RepairIntentV1(
  sourceWorldId: Act0PositionPersonalizationV1.worldId,
  sourceLessonId: Act0PositionPersonalizationV1.lessonId,
  sourceTaskId: Act0PositionPersonalizationV1.sourceTaskId,
  choiceId: 'co',
  result: 'incorrect',
  errorType: Act0PositionPersonalizationV1.errorType,
  missedSignalId: Act0PositionPersonalizationV1.missedSignalId,
  missedSignalLabel: 'Button',
  skillAtomId: Act0PositionPersonalizationV1.skillId,
  skillLabel: 'Table position read',
  targetWorldId: Act0PositionPersonalizationV1.worldId,
  targetLessonId: Act0PositionPersonalizationV1.lessonId,
  targetTaskId: targetTaskId,
  mappingType: 'repair',
  reasonCode: 'same_signal_table_position_read_hero_button',
);

Future<void> _pumpPositionTask(
  WidgetTester tester,
  Act0InMemoryTelemetrySinkV1 sink,
) async {
  tester.view.physicalSize = const Size(375, 812);
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
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        state: Act0ShellStateV1.sample,
        telemetrySink: sink,
        debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
          worldId: Act0PositionPersonalizationV1.worldId,
          lessonId: Act0PositionPersonalizationV1.lessonId,
          taskId: Act0PositionPersonalizationV1.sourceTaskId,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _answer(WidgetTester tester, {required bool correct}) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere(
    (candidate) => candidate.isCorrect == correct,
  );
  final seatId = option.seatId;
  final finder = seatId == null || seatId.isEmpty
      ? find.byKey(Key('act0_shell_option_${option.id}'))
      : find.byKey(Key('act0_shell_seat_tap_$seatId'));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _continueFeedback(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (cta.evaluate().isEmpty) return;
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    expect(tester.getRect(cta).bottom, lessThanOrEqualTo(812));
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

Future<void> _openRepair(WidgetTester tester) async {
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Practice'));
  await tester.pumpAndSettle();
  final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
  expect(queue, findsOneWidget);
  await tester.tap(
    find.descendant(of: queue, matching: find.text('Practice this')),
  );
  await tester.pumpAndSettle();
}
