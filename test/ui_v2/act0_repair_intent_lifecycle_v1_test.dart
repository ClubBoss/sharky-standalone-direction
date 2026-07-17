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

  testWidgets('wrong answer stores one deterministic open repair intent', (
    tester,
  ) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_legal_context',
        'actions_check_drill',
      ]),
      taskId: 'actions_legal_context',
    );
    await _advanceTeachingToDrill(tester);

    await _answerOption(tester, 'fold');

    final intent = _openRepairIntentPayload(tester, 'actions_legal_context');
    expect(intent, isNotNull);
    expect(intent?['sourceTaskId'], 'actions_legal_context');
    expect(intent?['choiceId'], 'fold');
    expect(intent?['result'], 'incorrect');
    expect(intent?['missedSignalId'], 'no_bet_yet');
    expect(intent?['skillAtomId'], 'action_read');
    expect(intent?['targetTaskId'], 'actions_check_drill');
    expect(intent?['mappingType'], 'repair');
    expect(intent?['reasonCode'], 'same_signal_action_read_no_bet_yet');
    expect(_openRepairIntentCount(tester), 1);
    expect(
      find.byKey(const Key('act0_shell_visible_repair_reason')),
      findsOneWidget,
    );
    expect(find.text('Repair focus'), findsOneWidget);
    expect(
      find.text(
        'This rep repeats the same clue. Before choosing, ask whether a bet faces you.',
      ),
      findsOneWidget,
    );
    expect(find.text('You missed the no-bet-yet clue.'), findsNothing);

    final repeat = _openRepairIntentPayload(tester, 'actions_legal_context');
    expect(repeat, intent);
  });

  testWidgets('suboptimal answer stores open repair intent', (tester) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_raise_drill',
      ]),
      taskId: 'actions_raise_drill',
    );
    await _advanceTeachingToDrill(tester);

    await _answerOption(tester, 'call');

    final intent = _openRepairIntentPayload(tester, 'actions_raise_drill');
    expect(intent, isNotNull);
    expect(intent?['sourceTaskId'], 'actions_raise_drill');
    expect(intent?['choiceId'], 'call');
    expect(intent?['result'], 'suboptimal');
    expect(intent?['mappingType'], 'repair');
    expect(_openRepairIntentCount(tester), 1);
  });

  testWidgets('correct answer does not store open repair intent', (
    tester,
  ) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_legal_context',
        'actions_check_drill',
      ]),
      taskId: 'actions_legal_context',
    );
    await _advanceTeachingToDrill(tester);

    await _answerOption(tester, 'check');

    await _openPractice(tester);
    expect(find.byKey(const Key('act0_shell_play_repair_queue')), findsNothing);
  });

  testWidgets('showing Review does not clear open repair intent prematurely', (
    tester,
  ) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_legal_context',
        'actions_check_drill',
      ]),
      taskId: 'actions_legal_context',
    );
    await _advanceTeachingToDrill(tester);
    await _answerOption(tester, 'fold');
    final beforeReview = _openRepairIntentPayload(
      tester,
      'actions_legal_context',
    );

    await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_review_fix_next_cta')),
      findsNothing,
    );
    expect(
      _openRepairIntentPayload(tester, 'actions_legal_context'),
      beforeReview,
    );
  });

  testWidgets('successful Practice queue repair clears matching intent', (
    tester,
  ) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_legal_context',
        'actions_check_drill',
      ]),
      taskId: 'actions_legal_context',
    );
    await _advanceTeachingToDrill(tester);
    await _answerOption(tester, 'fold');

    await _launchPracticeQueueRepair(tester);
    expect(_activeTaskId(tester), 'actions_check_drill');

    await _advanceTeachingToDrill(tester);
    await _answerCorrectly(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await _openPractice(tester);
    final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
    expect(
      find.descendant(of: queue, matching: find.text('Practice this')),
      findsNothing,
    );
  });

  testWidgets('failed Practice queue repair keeps matching intent active', (
    tester,
  ) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_legal_context',
        'actions_check_drill',
      ]),
      taskId: 'actions_legal_context',
    );
    await _advanceTeachingToDrill(tester);
    await _answerOption(tester, 'fold');

    await _launchPracticeQueueRepair(tester);
    await _advanceTeachingToDrill(tester);
    await _answerWrongly(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    final intent = _openRepairIntentPayload(tester, 'actions_legal_context');
    expect(intent, isNotNull);
    expect(intent?['targetTaskId'], 'actions_check_drill');
    expect(intent?['reasonCode'], 'same_signal_action_read_no_bet_yet');
  });

  testWidgets('exact replay fallback clears after correct replay completion', (
    tester,
  ) async {
    await _pumpLifecycleHost(
      tester,
      state: _stateForFoldCheckCallRaiseTasks(const <String>[
        'actions_check_drill',
      ]),
      taskId: 'actions_check_drill',
    );
    await _advanceTeachingToDrill(tester);
    await _answerWrongly(tester);

    final intent = _openRepairIntentPayload(tester, 'actions_check_drill');
    expect(intent?['mappingType'], 'exact');
    expect(intent?['targetTaskId'], 'actions_check_drill');

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    await _answerCorrectly(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    expect(_openRepairIntentPayload(tester, 'actions_check_drill'), isNull);
  });

  testWidgets(
    'feedback CTA runs the mapped repair before its source-task recheck',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpLifecycleHost(
        tester,
        state: _stateForFoldCheckCallRaiseTasks(const <String>[
          'actions_legal_context',
          'actions_check_drill',
        ]),
        taskId: 'actions_legal_context',
        telemetrySink: sink,
      );
      await _advanceTeachingToDrill(tester);

      await _answerOption(tester, 'fold');
      expect(find.text('Try same clue'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(_activeTaskId(tester), 'actions_check_drill');
      await _advanceTeachingToDrill(tester);
      final repairShown = sink.events
          .where(
            (event) =>
                event.name == 'task_shown' &&
                event.fields['taskId'] == 'actions_check_drill',
          )
          .toList(growable: false);
      expect(repairShown, hasLength(1));
      expect(
        sink.events.where((event) => event.name == 'repair_entered'),
        hasLength(1),
      );
      expect(
        sink.events.where((event) => event.name == 'repair_item_started'),
        hasLength(1),
      );

      await _answerCorrectly(tester);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(_activeTaskId(tester), 'actions_legal_context');
      expect(
        sink.events.where((event) => event.name == 'recheck_started'),
        hasLength(1),
      );

      await _advanceTeachingToDrill(tester);
      await _answerCorrectly(tester);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(
        sink.events.where((event) => event.name == 'repair_completed'),
        hasLength(1),
      );
      expect(
        sink.events.where((event) => event.name == 'recheck_completed'),
        hasLength(1),
      );
      expect(
        sink.events
            .where(
              (event) =>
                  event.name == 'user_choice' &&
                  event.fields['taskId'] == 'actions_legal_context',
            )
            .length,
        2,
      );
      expect(
        sink.events
            .where(
              (event) =>
                  event.name == 'user_choice' &&
                  event.fields['taskId'] == 'actions_check_drill',
            )
            .length,
        1,
      );
    },
  );

  testWidgets(
    'placement board-card miss preserves the repair intent and finishes the quick check',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPlacementDiagnosticHost(tester, telemetrySink: sink);

      await _answerPlacementQuestion(tester, 'friends');
      await _answerPlacementQuestion(tester, 'rules');
      await tester.tap(
        find.byKey(const Key('act0_shell_placement_start_diagnostic')),
      );
      await tester.pumpAndSettle();

      await _answerPlacementCorrectly(tester);
      expect(find.text('Correct read'), findsOneWidget);
      expect(find.text('Next check'), findsOneWidget);
      expect(find.text('Try same clue'), findsNothing);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Which cards can everyone use?'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('act0_shell_option_hero_private_cards')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Missed clue'), findsOneWidget);
      expect(find.text('Repair focus'), findsNothing);
      expect(find.text('Try same clue'), findsNothing);
      expect(find.text('Next check'), findsOneWidget);
      expect(
        _openRepairIntentPayload(tester, 'what_poker_is_table_read_transfer'),
        isNotNull,
      );
      expect(
        _openRepairIntentPayload(
          tester,
          'what_poker_is_table_read_transfer',
        )?['targetTaskId'],
        'cards_ranks_suits_board_count',
      );

      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No bet faces Hero. Which action is free?'),
        findsOneWidget,
      );
      expect(
        sink.events.where((event) => event.name == 'repair_entered'),
        isEmpty,
      );
      expect(
        sink.events.where((event) => event.name == 'repair_item_started'),
        isEmpty,
      );
      expect(
        sink.events.where((event) => event.name == 'recheck_started'),
        isEmpty,
      );
      expect(
        find.text('Count private cards, board cards, and pot once.'),
        findsNothing,
      );

      await _answerPlacementCorrectly(tester);
      expect(find.text('Correct read'), findsOneWidget);
      expect(find.text('See my start'), findsOneWidget);
      expect(find.text('Try same clue'), findsNothing);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_placement_result')),
        findsOneWidget,
      );
      expect(find.text('Rusty beginner'), findsOneWidget);
      expect(
        sink.events
            .where(
              (event) =>
                  event.name == 'user_choice' &&
                  event.fields['taskId'] == 'what_poker_is_table_read_transfer',
            )
            .length,
        3,
      );
    },
  );

  testWidgets('placement uncertainty uses the same forward receipt contract', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pumpPlacementDiagnosticHost(tester, telemetrySink: sink);

    await _answerPlacementQuestion(tester, 'friends');
    await _answerPlacementQuestion(tester, 'rules');
    await tester.tap(
      find.byKey(const Key('act0_shell_placement_start_diagnostic')),
    );
    await tester.pumpAndSettle();

    await _answerPlacementCorrectly(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('act0_shell_option_not_sure_yet')));
    await tester.pumpAndSettle();

    expect(find.text('Repair focus'), findsNothing);
    expect(find.text('Try same clue'), findsNothing);
    expect(find.text('Next check'), findsOneWidget);
    final choice = sink.events.lastWhere(
      (event) => event.name == 'user_choice',
    );
    expect(choice.fields['choiceId'], 'not_sure_yet');
    expect(choice.fields['result_classification'], 'suboptimal');

    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    expect(
      find.text('No bet faces Hero. Which action is free?'),
      findsOneWidget,
    );
    expect(
      sink.events.where((event) => event.name == 'repair_entered'),
      isEmpty,
    );
  });
}

Future<void> _pumpPlacementDiagnosticHost(
  WidgetTester tester, {
  required Act0InMemoryTelemetrySinkV1 telemetrySink,
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
        showPlacementOnStart: true,
        telemetrySink: telemetrySink,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _answerPlacementQuestion(
  WidgetTester tester,
  String optionId,
) async {
  final intro = find.byKey(const Key('act0_shell_placement_intro_cta'));
  if (intro.evaluate().isNotEmpty) {
    await tester.tap(intro);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(Key('act0_shell_placement_option_$optionId')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('act0_shell_placement_next_cta')));
  await tester.pumpAndSettle();
}

Future<void> _answerPlacementCorrectly(WidgetTester tester) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final option = runner.runner.options.firstWhere((option) => option.isCorrect);
  if (runner.runner.sizingConfig.isEnabled) {
    await tester.tap(find.byKey(Key('act0_shell_sizing_preset_${option.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
    await tester.pumpAndSettle();
    return;
  }
  final answerKey = option.seatId == null
      ? Key('act0_shell_option_${option.id}')
      : Key('act0_shell_seat_tap_${option.seatId}');
  final answer = find.byKey(answerKey);
  if (answer.evaluate().isEmpty) {
    await _advanceTeachingToDrill(tester);
    await _answerCorrectly(tester);
    return;
  }
  await tester.tap(answer);
  await tester.pumpAndSettle();
}

Future<void> _pumpLifecycleHost(
  WidgetTester tester, {
  required Act0ShellStateV1 state,
  required String taskId,
  Act0InMemoryTelemetrySinkV1? telemetrySink,
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
        telemetrySink: telemetrySink,
        debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: taskId,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0ShellStateV1 _stateForFoldCheckCallRaiseTasks(List<String> taskIds) {
  final sample = Act0ShellStateV1.sample;
  final baseWorld = sample.worldById('world_1');
  final baseLesson = baseWorld.lessons.firstWhere(
    (lesson) => lesson.lessonId == 'fold_check_call_raise',
  );
  final tasks = <Act0LessonTaskV1>[
    for (final taskId in taskIds)
      baseLesson.taskList.firstWhere((task) => task.taskId == taskId),
  ];
  final lesson = baseLesson.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    primaryCtaLabel: 'Open lesson',
    tasks: tasks,
  );
  final world = baseWorld.copyWith(
    status: Act0WorldStateV1.current,
    isSelectable: true,
    isLocked: false,
    lessons: <Act0LessonCardV1>[lesson],
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
    selectedWorldId: 'world_1',
    worlds: <Act0WorldCardV1>[world],
    lessons: <Act0LessonCardV1>[lesson],
    review: sample.review,
    profile: sample.profile,
  );
}

Future<void> _advanceTeachingToDrill(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    if (_hasVisibleAnswer()) {
      return;
    }
    final selectedLessonCta = find.byKey(
      const Key('act0_shell_selected_lesson_cta'),
    );
    if (selectedLessonCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(selectedLessonCta);
      await tester.tap(selectedLessonCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final currentMissionCta = find.byKey(
      const Key('act0_shell_current_mission_cta'),
    );
    if (currentMissionCta.evaluate().isNotEmpty) {
      await tester.ensureVisible(currentMissionCta);
      await tester.tap(currentMissionCta, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }
    final featuredCta = find.byKey(const Key('act0_shell_play_featured_cta'));
    if (featuredCta.evaluate().isNotEmpty) {
      await tester.tap(featuredCta);
      await tester.pumpAndSettle();
      continue;
    }
    final dailyGroup = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyGroup.evaluate().isNotEmpty) {
      await tester.tap(dailyGroup);
      await tester.pumpAndSettle();
      continue;
    }
    final cta = find.byKey(const Key('act0_shell_runner_primary_cta'));
    if (cta.evaluate().isNotEmpty) {
      await tester.tap(cta);
      await tester.pumpAndSettle();
      continue;
    }
    final continueButton = find.byKey(const Key('act0_shell_continue_cta'));
    if (continueButton.evaluate().isNotEmpty) {
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      continue;
    }
    final continueCta = find.byKey(const Key('act0_shell_theory_continue_cta'));
    if (continueCta.evaluate().isNotEmpty) {
      await tester.tap(continueCta);
      await tester.pumpAndSettle();
      continue;
    }
    await tester.pumpAndSettle();
  }
  if (_hasVisibleAnswer()) {
    return;
  }
  fail('Runner did not reach a visible answer surface.');
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

Future<void> _answerOption(WidgetTester tester, String optionId) async {
  final option = find.byKey(Key('act0_shell_option_$optionId'));
  expect(option, findsOneWidget);
  await tester.tap(option);
  await tester.pumpAndSettle();
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

int _openRepairIntentCount(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugOpenRepairIntentCountV1() as int;
}

String _activeTaskId(WidgetTester tester) {
  final state = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  return state.debugSelectedTaskIdV1() as String;
}
