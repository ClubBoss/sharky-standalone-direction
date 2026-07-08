import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  test('W7-W12 same-signal mapper chooses launchable non-source targets', () {
    for (final route in const <_SameSignalRouteCaseV1>[
      _SameSignalRouteCaseV1(
        worldId: 'world_7',
        nextRepId: 'repeat_board_read',
        skillAtomId: 'board_read',
        sourceSignalId: 'board_cards',
        sourceTaskId: 'visible_king_combo_reduction_intro',
        targetLessonId: 'range_thinking_lite_combo_density',
        targetTaskId: 'paired_board_texture_lite_intro',
      ),
      _SameSignalRouteCaseV1(
        worldId: 'world_8',
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'stack_depth',
        sourceTaskId: 'short_stack_all_in_pressure_intro',
        targetLessonId: 'spr_and_commitment',
        targetTaskId: 'w7_low_spr_commit',
      ),
      _SameSignalRouteCaseV1(
        worldId: 'world_9',
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'tournament_pressure',
        sourceTaskId: 'bubble_survival_pressure_intro',
        targetLessonId: 'survival_pressure_basics',
        targetTaskId: 'w9_short_stack_survival',
      ),
      _SameSignalRouteCaseV1(
        worldId: 'world_10',
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'player_tendency',
        sourceTaskId: 'w10_nit_tag',
        targetLessonId: 'player_type_basics',
        targetTaskId: 'w10_loose_passive_tag',
      ),
      _SameSignalRouteCaseV1(
        worldId: 'world_11',
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'session_plan',
        sourceTaskId: 'w11_plan_focus_choice',
        targetLessonId: 'session_plan_basics',
        targetTaskId: 'w11_plan_avoid_overload',
      ),
      _SameSignalRouteCaseV1(
        worldId: 'world_12',
        nextRepId: 'repeat_table_read',
        skillAtomId: 'table_read',
        sourceSignalId: 'tilt_reset',
        sourceTaskId: 'w12_after_bad_beat_reset',
        targetLessonId: 'tilt_reset_protocol',
        targetTaskId: 'w12_after_mistake_reset',
      ),
    ]) {
      final mapped = act0FirstValueSameSignalRepMappingV1(
        nextRepId: route.nextRepId,
        skillAtomId: route.skillAtomId,
        sourceSignalId: route.sourceSignalId,
        sourceTaskId: route.sourceTaskId,
        receiptOutcome: 'repair_started',
      );

      expect(mapped?.worldId, route.worldId, reason: route.sourceTaskId);
      expect(
        mapped?.lessonId,
        route.targetLessonId,
        reason: route.sourceTaskId,
      );
      expect(mapped?.taskId, route.targetTaskId, reason: route.sourceTaskId);
      expect(mapped?.taskId, isNot(route.sourceTaskId));
      expect(mapped?.mappingType, 'repair', reason: route.sourceTaskId);
    }
  });

  testWidgets(
    'W9 Practice repair queue clears correct same-signal repair and retains failed repair',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      final state = _stateWithCanonicalSourceAndRouteTarget(
        worldId: 'world_9',
        sourceLessonId: 'tournament_pressure_lite',
        sourceTaskId: 'bubble_survival_pressure_intro',
        sourceRunner: _sourceRunner(
          lessonId: 'bubble_survival_pressure_intro',
          signalLabel: 'Tournament pressure',
        ),
        targetLessonId: 'survival_pressure_basics',
        targetTaskId: 'w9_short_stack_survival',
      );

      await _pumpHost(
        tester,
        state: state,
        sink: sink,
        worldId: 'world_9',
        lessonId: 'tournament_pressure_lite',
        taskId: 'bubble_survival_pressure_intro',
      );
      await _answerOption(tester, 'ignore_signal');

      final intent = _openRepairIntentPayload(
        tester,
        'bubble_survival_pressure_intro',
      );
      expect(intent, isNotNull);
      expect(intent?['sourceWorldId'], 'world_9');
      expect(intent?['sourceLessonId'], 'tournament_pressure_lite');
      expect(intent?['sourceTaskId'], 'bubble_survival_pressure_intro');
      expect(intent?['choiceId'], 'ignore_signal');
      expect(intent?['result'], 'incorrect');
      expect(intent?['missedSignalId'], 'tournament_pressure');
      expect(intent?['missedSignalLabel'], 'Tournament pressure');
      expect(intent?['errorType'], 'missed_table_read');
      expect(intent?['targetWorldId'], 'world_9');
      expect(intent?['targetLessonId'], 'survival_pressure_basics');
      expect(intent?['targetTaskId'], 'w9_short_stack_survival');
      expect(intent?['targetTaskId'], isNot(intent?['sourceTaskId']));
      expect(intent?['mappingType'], 'repair');
      expect(
        intent?['reasonCode'],
        'same_signal_table_read_tournament_pressure',
      );

      await _launchPracticeQueueRepair(tester);
      expect(_activeTaskId(tester), 'w9_short_stack_survival');
      await _advanceToAnswer(tester);
      await _answerWrongly(tester);
      await _continueFeedback(tester);
      expect(
        _openRepairIntentPayload(tester, 'bubble_survival_pressure_intro'),
        isNotNull,
      );

      await _launchPracticeQueueRepair(tester);
      expect(_activeTaskId(tester), 'w9_short_stack_survival');
      await _advanceToAnswer(tester);
      await _answerCorrectly(tester);
      await _continueFeedback(tester);
      expect(
        _openRepairIntentPayload(tester, 'bubble_survival_pressure_intro'),
        isNull,
      );

      final repairStarts = sink.events
          .where((event) => event.name == 'repair_started')
          .toList(growable: false);
      final repairCompletions = sink.events
          .where((event) => event.name == 'repair_completed')
          .toList(growable: false);
      expect(repairStarts.map((event) => event.fields['repairTaskId']), [
        'w9_short_stack_survival',
      ]);
      expect(repairCompletions, isNotEmpty);
      expect(
        sink.events.where((event) => event.name == 'world_complete'),
        isEmpty,
      );
      expect(
        sink.events.where((event) => event.name == 'lesson_complete'),
        isEmpty,
      );
    },
  );
}

class _SameSignalRouteCaseV1 {
  const _SameSignalRouteCaseV1({
    required this.worldId,
    required this.nextRepId,
    required this.skillAtomId,
    required this.sourceSignalId,
    required this.sourceTaskId,
    required this.targetLessonId,
    required this.targetTaskId,
  });

  final String worldId;
  final String nextRepId;
  final String skillAtomId;
  final String sourceSignalId;
  final String sourceTaskId;
  final String targetLessonId;
  final String targetTaskId;
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required Act0ShellStateV1 state,
  required Act0InMemoryTelemetrySinkV1 sink,
  required String worldId,
  required String lessonId,
  required String taskId,
  bool debugHarness = true,
}) async {
  tester.view.physicalSize = const Size(1200, 1600);
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
        state: state,
        telemetrySink: sink,
        debugHarnessEntry: debugHarness
            ? Act0ShellDebugHarnessEntryV1(
                mode: Act0ControlledDemoCaptureModeV1.directState,
                surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
                worldId: worldId,
                lessonId: lessonId,
                taskId: taskId,
              )
            : null,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0ShellStateV1 _stateWithCanonicalSourceAndRouteTarget({
  required String worldId,
  required String sourceLessonId,
  required String sourceTaskId,
  required Act0RunnerStateV1 sourceRunner,
  required String targetLessonId,
  required String targetTaskId,
}) {
  final sample = Act0ShellStateV1.sample;
  final baseWorld = sample.worldById(worldId);
  final targetBaseLesson = baseWorld.lessons.firstWhere(
    (lesson) => lesson.lessonId == targetLessonId,
  );
  final targetTask = targetBaseLesson.taskList.firstWhere(
    (task) => task.taskId == targetTaskId,
  );
  final sourceLesson = Act0LessonCardV1(
    lessonId: sourceLessonId,
    title: sourceLessonId,
    subtitle: 'Same-signal source',
    state: Act0LessonStateV1.current,
    phaseLabel: 'Source',
    primaryCtaLabel: 'Open lesson',
    isSelectable: true,
    isLocked: false,
    rewardXp: 1,
    runner: sourceRunner,
    tasks: <Act0LessonTaskV1>[
      Act0LessonTaskV1(
        taskId: sourceTaskId,
        title: sourceTaskId,
        phase: Act0LessonPhaseV1.drill,
        runner: sourceRunner,
        rewardXp: 1,
        stepKind: Act0LessonStepKindV1.practice,
      ),
    ],
  );
  final targetLesson = targetBaseLesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    tasks: <Act0LessonTaskV1>[targetTask],
  );
  final world = baseWorld.copyWith(
    status: Act0WorldStateV1.current,
    isSelectable: true,
    isLocked: false,
    lessons: <Act0LessonCardV1>[sourceLesson, targetLesson],
  );
  return _stateForWorld(world, selectedLessonId: sourceLessonId);
}

Act0ShellStateV1 _stateForWorld(
  Act0WorldCardV1 world, {
  required String selectedLessonId,
}) {
  final sample = Act0ShellStateV1.sample;
  final selectedLesson = world.lessons.firstWhere(
    (lesson) => lesson.lessonId == selectedLessonId,
  );
  return Act0ShellStateV1(
    courseTitle: sample.courseTitle,
    courseSubtitle: sample.courseSubtitle,
    levelLabel: sample.levelLabel,
    xp: sample.xp,
    xpTarget: sample.xpTarget,
    streakDays: sample.streakDays,
    dailyGoalLabel: sample.dailyGoalLabel,
    dailyGoalValue: sample.dailyGoalValue,
    pathProgressLabel: sample.pathProgressLabel,
    selectedWorldId: world.worldId,
    worlds: <Act0WorldCardV1>[world],
    lessons: <Act0LessonCardV1>[selectedLesson],
    review: sample.review,
    profile: sample.profile,
  );
}

Act0RunnerStateV1 _sourceRunner({
  required String lessonId,
  required String signalLabel,
}) {
  return Act0RunnerStateV1(
    lessonId: lessonId,
    lessonTitle: lessonId,
    lessonSubtitle: 'Same-signal source',
    beatIndex: 1,
    beatCount: 1,
    phase: Act0LessonPhaseV1.drill,
    caption: signalLabel,
    hint: signalLabel,
    question: 'Which signal matters?',
    options: <Act0RunnerOptionV1>[
      Act0RunnerOptionV1(
        id: 'use_signal',
        label: 'Use $signalLabel',
        isCorrect: true,
        preferredLabel: 'Use $signalLabel',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Correct.',
        feedbackReason: signalLabel,
        repairFocusLabels: <String>[signalLabel],
      ),
      Act0RunnerOptionV1(
        id: 'ignore_signal',
        label: 'Ignore it',
        isCorrect: false,
        preferredLabel: 'Use $signalLabel',
        betterAnswerLabel: 'Use $signalLabel',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Not yet.',
        feedbackReason: signalLabel,
        repairFocusLabels: <String>[signalLabel],
      ),
    ],
    feedbackTitle: signalLabel,
    feedbackReason: signalLabel,
    primaryCtaLabel: 'Continue',
    nextLessonId: null,
    returnTarget: 'learn',
    table: const Act0TableStateV1(
      tableFormat: Act0TableFormatV1.sixMax,
      playerCount: 6,
      seats: <Act0SeatStateV1>[],
      heroCards: <Act0CardStateV1>[],
      boardCards: <Act0CardStateV1>[],
      streetLabel: 'Preflop',
      potLabel: '',
      toCallLabel: '',
      centerLabel: '',
      highlightedSeatIds: <String>[],
      highlightedCardIds: <String>[],
    ),
  );
}

Future<void> _answerOption(WidgetTester tester, String optionId) async {
  final option = find.byKey(Key('act0_shell_option_$optionId'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> _continueFeedback(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (cta.evaluate().isEmpty) {
      return;
    }
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

Future<void> _advanceToAnswer(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    if (_hasVisibleAnswer()) {
      return;
    }
    final cta = find.byKey(const Key('act0_shell_continue_cta'));
    if (cta.evaluate().isNotEmpty) {
      await tester.tap(cta);
      await tester.pumpAndSettle();
      continue;
    }
    final runnerCta = find.byKey(const Key('act0_shell_runner_primary_cta'));
    if (runnerCta.evaluate().isNotEmpty) {
      await tester.tap(runnerCta);
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pumpAndSettle();
  }
  if (!_hasVisibleAnswer()) {
    fail('Runner did not reach a visible answer surface.');
  }
}

bool _hasVisibleAnswer() {
  return find
          .byKey(const Key('act0_shell_action_panel'))
          .evaluate()
          .isNotEmpty ||
      find
          .byWidgetPredicate((widget) {
            final key = widget.key;
            return key is ValueKey<String> &&
                key.value.startsWith('act0_shell_option_');
          })
          .evaluate()
          .isNotEmpty;
}

Future<void> _answerCorrectly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere((option) => option.isCorrect);
  await _answerOption(tester, option.id);
}

Future<void> _answerWrongly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere(
    (option) => !option.isCorrect,
  );
  await _answerOption(tester, option.id);
}

Future<void> _launchPracticeQueueRepair(WidgetTester tester) async {
  await _openPractice(tester);
  final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
  expect(queue, findsOneWidget);
  expect(
    find.descendant(of: queue, matching: find.text('Practice this')),
    findsOneWidget,
  );
  await tester.tap(find.text('Practice this'));
  await tester.pumpAndSettle();
}

Future<void> _openPractice(WidgetTester tester) async {
  final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
  if (runnerBack.evaluate().isNotEmpty) {
    await tester.tap(runnerBack);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Practice'));
  await tester.pumpAndSettle();
}

Map<String, Object?>? _openRepairIntentPayload(
  WidgetTester tester,
  String sourceTaskId,
) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugOpenRepairIntentPayloadForSourceTaskV1(sourceTaskId)
      as Map<String, Object?>?;
}

String _activeTaskId(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugSelectedTaskIdV1() as String;
}
