import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_board_texture_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `board_texture_basics` composes its tasks through the lesson-prefixing
/// builder, so these are the runtime task identities the runner, the repair
/// intent, and the personalization contract all agree on.
const String _sourceTaskId = 'board_texture_basics_w5_dry_board';
const String _repairTaskId = 'board_texture_basics_w5_wet_board';
const String _drawOutsTaskId = 'flush_draws_w5_flush_draw_find';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('W5 contract names the runtime task identity', () {
    expect(Act0BoardTexturePersonalizationV1.sourceTaskId, _sourceTaskId);
    expect(Act0BoardTexturePersonalizationV1.repairTaskId, _repairTaskId);
    expect(
      Act0BoardTexturePersonalizationV1.isCanonicalSourceTask(_sourceTaskId),
      isTrue,
    );
    expect(
      Act0BoardTexturePersonalizationV1.isCanonicalSourceTask('w5_dry_board'),
      isFalse,
    );
  });

  test('W5 adapter admits only every exact tuple dimension', () {
    final family = Act0BoardTexturePersonalizationV1.fromRepairIntent(
      _intent(),
    );
    expect(family, isNotNull);
    expect(family!.feedbackMappingId, 'w5_board_texture_feedback_v1');
    expect(family.repairStrategyId, 'compare_board_connection_v1');
    expect(family.recheckMappingId, 'same_board_texture_signal_v1');
    expect(family.cleanPayoffOutcome, 'board_texture_read_cleanly');
    expect(family.successfulPayoffOutcome, 'board_texture_recovered');
    expect(family.failedRecheckOutcome, 'board_texture_still_needs_rep');

    // Every tuple dimension is independently rejected.
    for (final altered in <Act0RepairIntentV1>[
      _intent(sourceWorldId: 'world_4'),
      _intent(sourceLessonId: 'connected_boards'),
      _intent(sourceTaskId: _repairTaskId),
      _intent(targetWorldId: 'world_4'),
      _intent(targetLessonId: 'connected_boards'),
      _intent(targetTaskId: _sourceTaskId),
      _intent(errorType: 'misread_draw_outs'),
      _intent(skillAtomId: 'draw_read'),
      _intent(missedSignalId: 'hero_cards'),
      _intent(mappingType: 'mapped'),
      _intent(reasonCode: 'same_signal_draw_read_board_cards'),
    ])
      expect(
        Act0BoardTexturePersonalizationV1.fromRepairIntent(altered),
        isNull,
      );
  });

  test('W5 authored source and repair content is unchanged', () {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_5')
        .lessons
        .firstWhere((value) => value.lessonId == 'board_texture_basics');
    final source = lesson.tasks.firstWhere(
      (value) => value.taskId == _sourceTaskId,
    );
    final repair = lesson.tasks.firstWhere(
      (value) => value.taskId == _repairTaskId,
    );

    expect(source.title, 'Dry board');
    expect(repair.title, 'Wet board');
    for (final task in <Act0LessonTaskV1>[source, repair]) {
      expect(task.phase, Act0LessonPhaseV1.drill);
      expect(task.runner.question, 'What texture is this?');
      expect(task.runner.table.boardCards, hasLength(3));
      expect(task.runner.options.map((option) => option.id).toSet(), <String>{
        'dry',
        'wet',
      });
      expect(
        task.runner.options.where((option) => option.isCorrect),
        hasLength(1),
      );
      // The authored signal declaration is what makes the miss classify as a
      // board read rather than falling through to the generic table read.
      for (final option in task.runner.options)
        expect(option.repairFocusCardIds, <String>[
          'board_0',
          'board_1',
          'board_2',
        ]);
    }
    expect(
      source.runner.options.firstWhere((option) => option.isCorrect).id,
      'dry',
    );
    expect(
      repair.runner.options.firstWhere((option) => option.isCorrect).id,
      'wet',
    );
  });

  testWidgets('W5 source recheck mounts decision controls and recovers once', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pump(tester, sink, textScale: 1.4);

    // Source miss -> classification.
    await _answer(tester, correct: false);
    final intent = _openIntent(tester);
    expect(intent, isNotNull);
    expect(intent, containsPair('sourceWorldId', 'world_5'));
    expect(intent, containsPair('sourceLessonId', 'board_texture_basics'));
    expect(intent, containsPair('sourceTaskId', _sourceTaskId));
    expect(intent, containsPair('targetWorldId', 'world_5'));
    expect(intent, containsPair('targetLessonId', 'board_texture_basics'));
    expect(intent, containsPair('targetTaskId', _repairTaskId));
    expect(intent, containsPair('errorType', 'misread_board_texture'));
    expect(intent, containsPair('skillAtomId', 'board_read'));
    expect(intent, containsPair('missedSignalId', 'board_cards'));
    expect(intent, containsPair('mappingType', 'repair'));
    expect(
      intent,
      containsPair('reasonCode', 'same_signal_board_read_board_cards'),
    );

    // Exact repair target launches.
    await _continue(tester);
    expect(_selectedTask(tester), _repairTaskId);
    await _answer(tester, correct: true);

    // The source recheck relaunches the original task as an unanswered drill,
    // keeping its recheck identity visible.
    await _continue(tester);
    expect(_selectedTask(tester), _sourceTaskId);
    final atRecheck = _runner(tester);
    expect(atRecheck.isSourceRecheckAttempt, isTrue);
    expect(atRecheck.runner.selectedOptionId, isNull);
    expect(atRecheck.runner.phase, Act0LessonPhaseV1.drill);
    expect(find.text('Original read recheck'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsNothing,
    );

    // Through the authored teaching step, the decision controls mount exactly
    // once each with nothing preselected.
    await _advanceTeaching(tester);
    final atDecision = _runner(tester);
    expect(atDecision.isSourceRecheckAttempt, isTrue);
    expect(atDecision.runner.selectedOptionId, isNull);
    expect(find.byKey(const Key('act0_shell_option_dry')), findsOneWidget);
    expect(find.byKey(const Key('act0_shell_option_wet')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    // Correct recheck -> exactly one recovery, then the delta.
    await _answer(tester, correct: true);
    await _continue(tester);

    expect(_familyNames(sink), <String>[
      'board_texture_personalization_classified',
      'board_texture_personalization_recheck',
      'board_texture_personalization_payoff',
    ]);
    expect(_familyOutcomes(sink), <String>[
      'repair_required',
      'board_texture_recovered',
      'board_texture_recovered',
    ]);
    _expectFamilyFields(sink);

    expect(_named(sink, 'user_choice'), hasLength(3));
    expect(_named(sink, 'repair_started'), hasLength(1));
    expect(_named(sink, 'repair_item_started'), hasLength(1));
    expect(_named(sink, 'learning_run_outcome_recorded'), hasLength(1));
    expect(
      _named(sink, 'learning_run_outcome_recorded').single.fields,
      containsPair('outcome_type', 'recoveredAfterRepair'),
    );
    expect(_named(sink, 'learning_effect_delta_viewed'), hasLength(1));
    expect(_named(sink, 'learning_effect_delta_completed'), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('W5 failed source recheck still needs practice', (tester) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pump(tester, sink);
    await _answer(tester, correct: false);
    await _continue(tester);
    await _answer(tester, correct: true);
    await _continue(tester);

    expect(_selectedTask(tester), _sourceTaskId);
    expect(_runner(tester).isSourceRecheckAttempt, isTrue);
    await _answer(tester, correct: false);

    final outcomes = _named(sink, 'learning_run_outcome_recorded');
    expect(outcomes, hasLength(1));
    expect(
      outcomes.single.fields,
      containsPair('outcome_type', 'stillNeedsPractice'),
    );
    expect(outcomes.single.fields, containsPair('recheck_result', false));
    expect(_familyOutcomes(sink), contains('board_texture_still_needs_rep'));
    expect(_named(sink, 'board_texture_personalization_payoff'), isEmpty);
    expect(_named(sink, 'learning_effect_delta_viewed'), isEmpty);
    expect(_named(sink, 'learning_effect_delta_completed'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('W5 failed repair never finalizes the source recheck', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pump(tester, sink);
    await _answer(tester, correct: false);
    await _continue(tester);
    expect(_selectedTask(tester), _repairTaskId);
    await _answer(tester, correct: false);
    await _continue(tester);

    // The repair intent stays open and no recheck ever runs.
    expect(_openIntent(tester), isNotNull);
    expect(_named(sink, 'recheck_started'), isEmpty);
    expect(_named(sink, 'board_texture_personalization_recheck'), isEmpty);
    expect(_named(sink, 'board_texture_personalization_payoff'), isEmpty);
    expect(_named(sink, 'learning_run_outcome_recorded'), isEmpty);
    expect(_named(sink, 'learning_effect_delta_viewed'), isEmpty);
    expect(_named(sink, 'learning_effect_delta_completed'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('W5 correct-first pays off cleanly with no repair', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pump(tester, sink);
    await _answer(tester, correct: true);
    await _continue(tester);

    expect(
      _named(sink, 'board_texture_personalization_payoff').single.fields,
      containsPair('final_learning_outcome', 'board_texture_read_cleanly'),
    );
    expect(_named(sink, 'board_texture_personalization_classified'), isEmpty);
    expect(_named(sink, 'board_texture_personalization_recheck'), isEmpty);
    expect(_named(sink, 'repair_started'), isEmpty);
    expect(_named(sink, 'recheck_started'), isEmpty);
    expect(_named(sink, 'learning_effect_delta_viewed'), isEmpty);
    expect(_named(sink, 'learning_effect_delta_completed'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('W5 draw-outs task emits no board-texture family events', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pump(tester, sink, lessonId: 'flush_draws', taskId: _drawOutsTaskId);
    expect(_selectedTask(tester), _drawOutsTaskId);
    await _answer(tester, correct: false);

    expect(_familyNames(sink), isEmpty);
    expect(tester.takeException(), isNull);
  });
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

Act0RepairIntentV1 _intent({
  String? sourceWorldId,
  String? sourceLessonId,
  String? sourceTaskId,
  String? targetWorldId,
  String? targetLessonId,
  String? targetTaskId,
  String? errorType,
  String? skillAtomId,
  String? missedSignalId,
  String? mappingType,
  String? reasonCode,
}) => Act0RepairIntentV1(
  sourceWorldId: sourceWorldId ?? 'world_5',
  sourceLessonId: sourceLessonId ?? 'board_texture_basics',
  sourceTaskId: sourceTaskId ?? _sourceTaskId,
  choiceId: 'wet',
  result: 'incorrect',
  errorType: errorType ?? 'misread_board_texture',
  missedSignalId: missedSignalId ?? 'board_cards',
  missedSignalLabel: 'Board cards',
  skillAtomId: skillAtomId ?? 'board_read',
  skillLabel: 'Board read',
  targetWorldId: targetWorldId ?? 'world_5',
  targetLessonId: targetLessonId ?? 'board_texture_basics',
  targetTaskId: targetTaskId ?? _repairTaskId,
  mappingType: mappingType ?? 'repair',
  reasonCode: reasonCode ?? 'same_signal_board_read_board_cards',
);

Future<void> _pump(
  WidgetTester tester,
  Act0InMemoryTelemetrySinkV1 sink, {
  double textScale = 1,
  String lessonId = 'board_texture_basics',
  String taskId = _sourceTaskId,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: Act0ShellStateV1.sample,
            telemetrySink: sink,
            debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_5',
              lessonId: lessonId,
              taskId: taskId,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

String _selectedTask(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugSelectedTaskIdV1() as String;
}

Map<String, Object?>? _openIntent(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugOpenRepairIntentPayloadForSourceTaskV1(_sourceTaskId)
      as Map<String, Object?>?;
}

/// Advances any authored teaching steps that precede the decision.
///
/// The learning rail gates its Continue control behind a read-lock `Timer`.
/// `pumpAndSettle` does not fire plain timers, so the elapsed pumps here are
/// what let the control enable — without them the button renders disabled and
/// a tap is silently dropped.
Future<void> _advanceTeaching(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_continue_cta'));
    if (cta.evaluate().isEmpty) return;
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.ensureVisible(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

Future<void> _answer(WidgetTester tester, {required bool correct}) async {
  await _advanceTeaching(tester);
  final runner = _runner(tester);
  final option = runner.runner.options.firstWhere(
    (value) => value.isCorrect == correct,
  );
  final finder = find.byKey(Key('act0_shell_option_${option.id}'));
  expect(
    finder,
    findsOneWidget,
    reason:
        'no decision control for ${option.id} on ${_selectedTask(tester)} '
        '(recheck=${runner.isSourceRecheckAttempt} '
        'phase=${runner.runner.phase} '
        'teachingStep=${runner.runner.teachingStepIndex}/'
        '${runner.runner.teachingSteps.length} '
        'selected=${runner.runner.selectedOptionId})',
  );
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _continue(WidgetTester tester) async {
  final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
  expect(cta, findsOneWidget);
  await tester.ensureVisible(cta);
  await tester.tap(cta);
  await tester.pumpAndSettle();
}

Iterable<Act0TelemetryEventV1> _named(
  Act0InMemoryTelemetrySinkV1 sink,
  String name,
) => sink.events.where((event) => event.name == name);

Iterable<Act0TelemetryEventV1> _family(Act0InMemoryTelemetrySinkV1 sink) => sink
    .events
    .where((event) => event.name.startsWith('board_texture_personalization_'));

List<String> _familyNames(Act0InMemoryTelemetrySinkV1 sink) =>
    _family(sink).map((event) => event.name).toList(growable: false);

List<Object?> _familyOutcomes(Act0InMemoryTelemetrySinkV1 sink) => _family(sink)
    .map((event) => event.fields['final_learning_outcome'])
    .toList(growable: false);

void _expectFamilyFields(Act0InMemoryTelemetrySinkV1 sink) {
  for (final event in _family(sink)) {
    expect(event.fields['lesson_id'], 'board_texture_basics');
    expect(event.fields['task_id'], _sourceTaskId);
    expect(event.fields['skill_id'], 'board_read');
    expect(event.fields['error_type'], 'misread_board_texture');
    expect(event.fields['missed_signal_id'], 'board_cards');
    expect(event.fields['mapping_type'], 'repair');
    expect(event.fields['reason_code'], 'same_signal_board_read_board_cards');
    expect(event.fields['feedback_mapping_id'], 'w5_board_texture_feedback_v1');
    expect(event.fields['repair_strategy'], 'compare_board_connection_v1');
    expect(event.fields['recheck_mapping_id'], 'same_board_texture_signal_v1');

    // Physical-board telemetry leakage guard: no card, suit, or texture copy
    // in personalization telemetry.
    final serialized = event.fields.toString().toLowerCase();
    for (final forbidden in <String>[
      'k-7-2',
      't-9-8',
      'kc',
      '7d',
      '2s',
      'th',
      '9h',
      '8c',
      'rainbow',
      'two hearts',
      'connected ranks',
    ])
      expect(serialized, isNot(contains(forbidden)));
  }
}
