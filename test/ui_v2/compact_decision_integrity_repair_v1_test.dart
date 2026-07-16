import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';

Act0RunnerOptionV1 _expandedOptionV1(Act0RunnerOptionV1 option) {
  return Act0RunnerOptionV1(
    id: option.id,
    label:
        '${option.label} · table context must remain visible before you choose this answer, because the learner needs the private cards, board cards, and pot in one readable sentence.',
    amountLabel: option.amountLabel,
    seatId: option.seatId,
    isCorrect: option.isCorrect,
    preferredLabel: option.preferredLabel,
    betterAnswerLabel: option.betterAnswerLabel,
    quality: option.quality,
    feedbackTitle: option.feedbackTitle,
    feedbackReason: option.feedbackReason,
    repairFocusSeatIds: option.repairFocusSeatIds,
    repairFocusCardIds: option.repairFocusCardIds,
    repairFocusLabels: option.repairFocusLabels,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'active runner owners forward measured accessibility mode without replacing the canonical route',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> pumpPreviewOwner() async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(375, 812),
                textScaler: TextScaler.linear(1),
              ),
              child: Act0ShellPreviewScreenV1(
                initialTab: Act0ShellTabV1.play,
                initialPhase: Act0LessonPhaseV1.drill,
                state: Act0ShellStateV1.sample,
                showPlacementOnStart: false,
                debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
                  mode: Act0ControlledDemoCaptureModeV1.directState,
                  surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
                  worldId: 'world_1',
                  lessonId: 'fold_check_call_raise',
                  taskId: 'actions_call_drill',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpPreviewOwner();
      expect(
        find.byKey(const Key('act0_shell_accessibility_evidence_surface')),
        findsNothing,
      );
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .onAccessibilityPrototypeStepChanged,
        isNotNull,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              textScaler: TextScaler.linear(1),
            ),
            child: Act0WelcomeShellV1(replayMode: false, onCompleted: () {}),
          ),
        ),
      );
      await tester.tap(find.text('Try one table read'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_accessibility_evidence_surface')),
        findsNothing,
      );
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .onAccessibilityPrototypeStepChanged,
        isNotNull,
      );
    },
  );

  testWidgets(
    'W1 table-read quick check keeps every compact choice tied to the visible table',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final runner = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );

      expect(
        runner.options.map((option) => option.id),
        containsAllInOrder(<String>[
          'two_three_six',
          'two_five_six',
          'two_three_four',
          'not_sure_yet',
        ]),
      );
      expect(
        runner.options.where((option) => option.isCorrect).single.id,
        'two_three_six',
      );
      expect(runner.table.potLabel, 'Pot 6 BB');
      expect(runner.table.toCallLabel, isEmpty);
      expect(
        runner.options.where((option) => option.isCorrect).single.label,
        '2 private · 3 board · Pot 6 BB',
      );
      expect(
        runner.options.map((option) => option.label),
        everyElement(hasLength(lessThanOrEqualTo(36))),
      );

      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('What does this table show?'), findsOneWidget);
      expect(find.text('2 private · 3 board · Pot 6 BB'), findsOneWidget);
      expect(find.text('2 private · 5 board · Pot 6 BB'), findsOneWidget);
      expect(find.text('2 private · 3 board · Pot 4 BB'), findsOneWidget);
      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      expect(table.width / table.height, closeTo(0.576, 0.01));
      // The normal table uses the measured decision remainder, not the old
      // 405 px worst-case lower reservation.
      expect(table.height, greaterThanOrEqualTo(480));
      final answerRows = <Rect>[
        tester.getRect(
          find.byKey(const Key('act0_shell_option_two_three_six')),
        ),
        tester.getRect(find.byKey(const Key('act0_shell_option_two_five_six'))),
        tester.getRect(
          find.byKey(const Key('act0_shell_option_two_three_four')),
        ),
        tester.getRect(find.byKey(const Key('act0_shell_option_not_sure_yet'))),
      ];
      for (final row in answerRows) {
        expect(row.height, greaterThanOrEqualTo(44));
      }
      expect(answerRows[0].height, closeTo(answerRows[1].height, 0.5));
      expect(answerRows[1].height, closeTo(answerRows[2].height, 0.5));
      expect(answerRows[2].height, closeTo(answerRows[3].height, 0.5));
      final dock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      final question = tester.getRect(
        find.byKey(const Key('act0_shell_action_question')),
      );
      final answerGroupHeight = answerRows.last.bottom - answerRows.first.top;
      final usablePostQuestionHeight = dock.bottom - question.bottom;
      expect(answerGroupHeight, greaterThan(usablePostQuestionHeight * 0.6));
      expect(dock.bottom - answerRows.last.bottom, inInclusiveRange(24, 80));
      final guidance = tester.getRect(
        find.byKey(const Key('act0_shell_wave1b_table_signal_chip')),
      );
      final bbSeat = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_bb')),
      );
      final hjSeat = tester.getRect(
        find.byKey(const Key('act0_shell_seat_node_hj')),
      );
      expect(guidance.overlaps(bbSeat), isFalse, reason: '$guidance $bbSeat');
      expect(guidance.overlaps(hjSeat), isFalse, reason: '$guidance $hjSeat');
      expect(
        find.byKey(const Key('act0_shell_wave1b_table_signal_text')),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byKey(const Key('act0_shell_option_not_sure_yet')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_option_not_sure_yet')))
            .bottom,
        lessThanOrEqualTo(874),
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_runner_action_dock')))
            .bottom,
        greaterThanOrEqualTo(862),
      );
      expect(
        find.byKey(const Key('act0_shell_poker_action_icon_check')),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_option_marker_not_sure_yet')),
          matching: find.text('?'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'compact seat instruction reserves a reachable lower panel and one learner identity',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'what_poker_is_find_hero',
      );

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_seat_tap_prompt')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_lower_stage_table_tap_decision')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_wave1_hero_you_badge')),
        findsOneWidget,
      );
      expect(find.text('BTN Hero'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_marker_btn_dealer')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('act0_shell_marker_btn_dealer')),
          matching: find.text('BTN'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_seat_tap_prompt')))
            .bottom,
        lessThanOrEqualTo(812),
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_runner_action_dock')))
            .bottom,
        greaterThanOrEqualTo(800),
      );
      final lowerSurface = tester.getRect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
      );
      final prompt = tester.getRect(
        find.byKey(const Key('act0_shell_seat_tap_prompt')),
      );
      final helper = tester.getRect(
        find.byKey(const Key('act0_shell_seat_tap_prompt_text')),
      );
      expect(prompt.top, lessThanOrEqualTo(lowerSurface.top + 16));
      expect(prompt.height, lessThan(lowerSurface.height - 48));
      expect(prompt.bottom, lessThanOrEqualTo(lowerSurface.bottom - 48));
      expect(helper.bottom, lessThanOrEqualTo(prompt.bottom - 8));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tall compact instruction rail keeps its content reachable without overflow',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'what_poker_is_theory',
      );

      tester.view.physicalSize = const Size(400, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(phase: Act0LessonPhaseV1.theory),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rail = find.byKey(const Key('act0_shell_learning_rail'));
      final lane = find.byKey(
        const Key('act0_shell_learning_rail_content_lane'),
      );
      final continueCta = find.byKey(const Key('act0_shell_continue_cta'));
      final railScroller = find.ancestor(
        of: lane,
        matching: find.byType(SingleChildScrollView),
      );

      expect(rail, findsOneWidget);
      expect(lane, findsOneWidget);
      expect(railScroller, findsNothing);
      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
      expect(continueCta, findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_lower_stage_instruction')),
        findsOneWidget,
      );
      final lowerSurface = tester.getRect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
      );
      final railRect = tester.getRect(rail);
      final footer = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
      );
      expect(railRect.top, lessThanOrEqualTo(lowerSurface.top + 16));
      expect(railRect.bottom, greaterThanOrEqualTo(lowerSurface.bottom - 28));
      expect(railRect.bottom - footer.bottom, inInclusiveRange(2, 18));
      expect(tester.getRect(continueCta).bottom, lessThanOrEqualTo(874));
      expect(find.byKey(const Key('act0_shell_runner_prompt')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'short table-read instruction composes its teaching copy with Continue without moving the table',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_recheck',
          );

      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(phase: Act0LessonPhaseV1.theory),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Read the table first'), findsOneWidget);
      expect(find.textContaining('Same scan, different spot.'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(const Key('act0_shell_learning_rail_content_lane')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final lowerStage = tester.getRect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
      );
      final content = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_content_lane')),
      );
      final footer = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
      );
      final continueCta = tester.getRect(
        find.byKey(const Key('act0_shell_continue_cta')),
      );

      expect(table.bottom, closeTo(lowerStage.top, 1));
      expect(content.top, greaterThan(lowerStage.top + 24));
      expect(footer.top - content.bottom, inInclusiveRange(0, 12));
      expect(continueCta.bottom, lessThanOrEqualTo(874));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tall compact decision panel owns its dock without stretching choices',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final runner = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );

      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final dock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      final panel = tester.getRect(
        find.byKey(const Key('act0_shell_compact_decision_surface')),
      );
      final first = tester.getRect(
        find.byKey(const Key('act0_shell_option_two_three_six')),
      );
      final second = tester.getRect(
        find.byKey(const Key('act0_shell_option_two_five_six')),
      );
      final third = tester.getRect(
        find.byKey(const Key('act0_shell_option_two_three_four')),
      );
      final notSure = tester.getRect(
        find.byKey(const Key('act0_shell_option_not_sure_yet')),
      );

      expect(panel.top, lessThanOrEqualTo(dock.top + 4));
      expect(panel.bottom, lessThan(dock.bottom - 24));
      expect(notSure.bottom, lessThanOrEqualTo(896));
      expect(notSure.height, greaterThanOrEqualTo(44));
      expect(notSure.height, lessThanOrEqualTo(72));
      expect(second.top - first.bottom, closeTo(third.top - second.bottom, 1));
      expect(third.top - second.bottom, closeTo(notSure.top - third.bottom, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compact feedback keeps its concise CTA state inside the shared lower slot',
    (tester) async {
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
      final task = lesson.taskList.firstWhere(
        (entry) => entry.taskId == 'what_poker_is_find_hero',
      );
      final selectedOption = task.runner.options.firstWhere(
        (option) => option.isCorrect,
      );

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: selectedOption.id,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_sharky_slot_proof')),
        findsNothing,
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_feedback_continue_cta')))
            .bottom,
        lessThanOrEqualTo(812),
      );
      expect(
        tester
            .getRect(find.byKey(const Key('act0_shell_runner_action_dock')))
            .bottom,
        greaterThanOrEqualTo(800),
      );
      final feedbackCard = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_card')),
      );
      final dock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      expect(feedbackCard.top, lessThanOrEqualTo(dock.top + 16));
      expect(feedbackCard.bottom, lessThan(dock.bottom - 24));
    },
  );

  testWidgets(
    'long First Table Guide repair keeps its CTA safe and body scrollable',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );

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
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: 'hand_first_only',
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              tablePresentation: task.tablePresentation,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              repairReasonLine:
                  'This rep repeats the same clue. Before choosing, name the table clue first.',
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cta = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      final scrollable = find.byKey(const Key('act0_shell_lower_stage_scroll'));
      expect(scrollable, findsOneWidget);
      expect(cta.bottom, lessThanOrEqualTo(840));
      expect(
        tester
            .state<ScrollableState>(
              find.descendant(
                of: scrollable,
                matching: find.byType(Scrollable),
              ),
            )
            .position
            .maxScrollExtent,
        greaterThan(0),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'seat-tap teaching decision and feedback keep one table geometry and complete lower profiles',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere((entry) => entry.taskId == 'what_poker_is_find_hero');
      var phase = Act0LessonPhaseV1.theory;
      String? selectedOptionId;
      StateSetter? setHostState;

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setHostState = setState;
                return Act0LessonRunnerShellV1(
                  runner: task.runner.copyWith(
                    phase: phase,
                    selectedOptionId: selectedOptionId,
                    teachingSteps: const <Act0TeachingStepV1>[],
                  ),
                  selectedTaskId: task.taskId,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                  onBack: () {},
                  onContinueTheory: () {},
                  onChooseOption: (_) {},
                  onContinueReview: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final teachingTable = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      expect(
        find.byKey(const Key('act0_shell_lower_stage_instruction')),
        findsOneWidget,
      );

      setHostState!(() => phase = Act0LessonPhaseV1.drill);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_lower_stage_table_tap_decision')),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_table'))),
        teachingTable,
      );

      setHostState!(() {
        selectedOptionId = task.runner.options
            .firstWhere((option) => option.isCorrect)
            .id;
        phase = Act0LessonPhaseV1.review;
      });
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_lower_stage_compact_feedback')),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_table'))),
        teachingTable,
      );

      final answerTask = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final answerRunner = placementQuickCheckRunnerV1(
        answerTask.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: answerRunner,
              selectedTaskFamily: answerTask.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_lower_stage_decision')),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_table'))),
        teachingTable,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Pro Max lower stage gives compact feedback an intrinsic card anchored at the safe bottom',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      var phase = Act0LessonPhaseV1.theory;
      String? selectedOptionId;
      StateSetter? setHostState;

      tester.view.physicalSize = const Size(440, 956);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                setHostState = setState;
                return Act0LessonRunnerShellV1(
                  runner: task.runner.copyWith(
                    phase: phase,
                    selectedOptionId: selectedOptionId,
                    teachingSteps: const <Act0TeachingStepV1>[],
                  ),
                  selectedTaskFamily: task.resolvedTaskFamily,
                  tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                  onBack: () {},
                  onContinueTheory: () {},
                  onChooseOption: (option) {
                    setState(() {
                      selectedOptionId = option.id;
                      phase = Act0LessonPhaseV1.review;
                    });
                  },
                  onContinueReview: () {},
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final instructionRail = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail')),
      );
      expect(
        instructionRail.top,
        greaterThanOrEqualTo(
          tester.getRect(find.byKey(const Key('act0_shell_table'))).bottom,
        ),
      );

      setHostState!(() => phase = Act0LessonPhaseV1.drill);
      await tester.pumpAndSettle();
      final decisionDock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      expect(
        find.byKey(const Key('act0_shell_lower_stage_decision')),
        findsOneWidget,
      );
      expect(decisionDock.bottom, closeTo(956, 1));
      for (final option in task.runner.options) {
        expect(
          find.byKey(Key('act0_shell_option_${option.id}')),
          findsOneWidget,
        );
      }

      await tester.tap(
        find.byKey(
          Key(
            'act0_shell_option_${task.runner.options.firstWhere((option) => option.isCorrect).id}',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final feedbackDock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      expect(
        find.byKey(const Key('act0_shell_shared_runner_lower_surface')),
        findsOneWidget,
      );
      final feedbackCard = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_card')),
      );
      final feedbackCta = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      expect(
        find.byKey(const Key('act0_shell_lower_stage_compact_feedback')),
        findsOneWidget,
      );
      expect(feedbackCard.height, lessThan(feedbackDock.height));
      expect(feedbackCard.top, lessThanOrEqualTo(feedbackDock.top + 16));
      expect(feedbackCard.bottom, lessThan(feedbackDock.bottom - 24));
      expect(feedbackCard.bottom - feedbackCta.bottom, inInclusiveRange(4, 12));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'prototype theory paginates first, middle, and final copy with a fixed footer',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere((entry) => entry.taskId == 'what_poker_is_theory');
      final runner = task.runner.copyWith(
        phase: Act0LessonPhaseV1.theory,
        teachingSteps: const <Act0TeachingStepV1>[],
        caption:
            'First page names one visible fact before a decision begins at the table.',
        hint:
            'Middle page turns that fact into one reusable read for the next hand. Final page prepares one clean continuation without hiding any theory copy.',
      );

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final footer = tester.getRect(
        find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
      );
      final lane = find.byKey(
        const Key('act0_shell_learning_rail_content_lane'),
      );
      expect(
        find.ancestor(of: lane, matching: find.byType(SingleChildScrollView)),
        findsNothing,
      );
      expect(find.text('Next'), findsOneWidget);

      await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
      expect(tester.getRect(find.byKey(const Key('act0_shell_table'))), table);
      expect(
        tester.getRect(
          find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
        ),
        footer,
      );

      for (
        var page = 0;
        page < 5 && find.text('Next').evaluate().isNotEmpty;
        page++
      ) {
        await tester.tap(find.byKey(const Key('act0_shell_continue_cta')));
        await tester.pumpAndSettle();
      }
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.getRect(find.byKey(const Key('act0_shell_table'))), table);
      expect(
        tester.getRect(
          find.byKey(const Key('act0_shell_learning_rail_fixed_footer')),
        ),
        footer,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'prototype repair uses short beats and an isolated expanded-reference body viewport',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final runner = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );
      final states = <Act0LowerSurfacePrototypeStateV1>[
        Act0LowerSurfacePrototypeStateV1.coreRepairBeat1,
        Act0LowerSurfacePrototypeStateV1.coreRepairBeat2,
        Act0LowerSurfacePrototypeStateV1.coreRepairFinalBeat,
      ];

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> pumpState(Act0LowerSurfacePrototypeStateV1 state) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: runner,
                selectedTaskFamily: task.resolvedTaskFamily,
                lowerSurfacePrototypeState: state,
                tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpState(states.first);
      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final footer = tester.getRect(
        find.byKey(const Key('act0_shell_prototype_repair_footer')),
      );
      for (final state in states) {
        await pumpState(state);
        final body = find.byKey(const Key('act0_shell_core_repair_body'));
        expect(body, findsOneWidget);
        expect(
          find.ancestor(of: body, matching: find.byType(SingleChildScrollView)),
          findsNothing,
        );
        expect(
          tester.getRect(find.byKey(const Key('act0_shell_table'))),
          table,
        );
        expect(
          tester.getRect(
            find.byKey(const Key('act0_shell_prototype_repair_footer')),
          ),
          footer,
        );
      }
      expect(find.text('Recheck'), findsOneWidget);

      await pumpState(Act0LowerSurfacePrototypeStateV1.expandedReference);
      final scroll = find.byKey(
        const Key('act0_shell_expanded_reference_body_scroll'),
      );
      final expandedFooter = tester.getRect(
        find.byKey(const Key('act0_shell_prototype_repair_footer')),
      );
      expect(scroll, findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(const Key('act0_shell_table')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: scroll, matching: find.byType(Scrollable)),
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      await tester.drag(scroll, const Offset(0, -240));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, greaterThan(0));
      expect(
        tester.getRect(
          find.byKey(const Key('act0_shell_prototype_repair_footer')),
        ),
        expandedFooter,
      );
      expect(tester.getRect(find.byKey(const Key('act0_shell_table'))), table);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'scaled four-option decision uses the bounded fallback lane at 1.09',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final runner = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );

      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(402, 874),
              textScaler: TextScaler.linear(1.09),
            ),
            child: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: runner,
                selectedTaskFamily: task.resolvedTaskFamily,
                tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final table = tester.getRect(find.byKey(const Key('act0_shell_table')));
      final options = <Finder>[
        find.byKey(const Key('act0_shell_option_two_three_six')),
        find.byKey(const Key('act0_shell_option_two_five_six')),
        find.byKey(const Key('act0_shell_option_two_three_four')),
        find.byKey(const Key('act0_shell_option_not_sure_yet')),
      ];
      expect(table.height, greaterThanOrEqualTo(480));
      for (final option in options) {
        final rect = tester.getRect(option);
        expect(rect.height, greaterThanOrEqualTo(44));
        expect(rect.bottom, lessThanOrEqualTo(874));
        expect(
          find.ancestor(
            of: option,
            matching: find.byType(SingleChildScrollView),
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'large-text accessibility flow keeps direct table decision and feedback in one shell',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
          .taskList
          .firstWhere(
            (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
          );
      final directRunner = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );
      var runner = directRunner;
      var step = Act0AccessibilityPrototypeStepV1.evidence;
      var choices = 0;
      final sink = Act0InMemoryTelemetrySinkV1();

      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      Future<void> pump() async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(fontFamily: 'Roboto'),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(402, 874),
                viewPadding: EdgeInsets.only(top: 59, bottom: 34),
                textScaler: TextScaler.linear(1.4),
              ),
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => Act0LessonRunnerShellV1(
                    runner: runner,
                    selectedTaskFamily: task.resolvedTaskFamily,
                    tableVisualVariant:
                        Act0ShellTableVisualVariantV1.refinedDev2,
                    accessibilityPrototypeStep: step,
                    telemetrySink: sink,
                    onAccessibilityPrototypeStepChanged: (next) {
                      setState(() => step = next);
                    },
                    onBack: () {},
                    onContinueTheory: () {},
                    onChooseOption: (option) => setState(() {
                      choices++;
                      runner = directRunner.copyWith(
                        phase: Act0LessonPhaseV1.review,
                        selectedOptionId: option.id,
                        feedbackTitle: option.feedbackTitle,
                        feedbackReason: option.feedbackReason,
                        primaryCtaLabel: 'Next hand',
                      );
                    }),
                    onContinueReview: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump();
      final evidenceTable = tester.getRect(
        find.byKey(const Key('act0_shell_table')),
      );
      final evidenceDock = tester.getRect(
        find.byKey(const Key('act0_shell_runner_action_dock')),
      );
      final decisionSurface = tester.getRect(
        find.byKey(const Key('act0_shell_accessibility_shared_surface')),
      );
      expect(decisionSurface.top - evidenceDock.top, inInclusiveRange(0, 2));
      expect(
        evidenceDock.bottom - decisionSurface.bottom,
        inInclusiveRange(0, 2),
      );
      expect(
        decisionSurface.width,
        greaterThanOrEqualTo(evidenceDock.width * 0.9),
      );
      expect(
        find.byKey(const Key('act0_shell_marker_btn_dealer')),
        findsOneWidget,
      );
      expect(find.text('Hero'), findsNothing);
      expect(find.byKey(const Key('act0_shell_runner_back')), findsOneWidget);
      expect(find.text('Step 1/3'), findsOneWidget);
      expect(directRunner.table.potLabel, 'Pot 6 BB');
      expect(directRunner.table.toCallLabel, isEmpty);
      expect(
        directRunner.options.where((option) => option.isCorrect).single.label,
        '2 private · 3 board · Pot 6 BB',
      );
      expect(tester.takeException(), isNull);

      expect(
        find.byKey(const Key('act0_shell_accessibility_question')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_accessibility_guidance')),
        findsOneWidget,
      );
      expect(
        find.text('Count private cards, board cards, then the pot.'),
        findsOneWidget,
      );
      final decisionModule = tester.getRect(
        find.byKey(const Key('act0_shell_accessibility_decision_module')),
      );
      final optionIds = runner.options.map((option) => option.id).toList();
      expect(optionIds.last, 'not_sure_yet');
      final answerRects = <Rect>[
        for (final id in optionIds)
          tester.getRect(find.byKey(Key('act0_shell_option_$id'))),
      ];
      expect(answerRects.map((rect) => rect.height).toSet(), hasLength(1));
      for (final rect in answerRects) {
        expect(rect.height, greaterThanOrEqualTo(48));
        expect(rect.bottom, lessThanOrEqualTo(evidenceDock.bottom));
      }
      expect(
        (decisionModule.top -
                evidenceDock.top -
                (evidenceDock.bottom - decisionModule.bottom))
            .abs(),
        lessThanOrEqualTo(evidenceDock.height * 0.15),
      );
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_table'))),
        evidenceTable,
      );
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_runner_action_dock'))),
        evidenceDock,
      );
      expect(find.byKey(const Key('act0_shell_runner_back')), findsOneWidget);
      expect(find.text('Step 1/3'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_accessibility_view_table_cta')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_accessibility_answer_cta')),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.byKey(const Key('act0_shell_option_not_sure_yet')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
      expect(choices, 0);

      await tester.tap(
        find.byKey(const Key('act0_shell_option_two_three_six')),
      );
      await tester.pumpAndSettle();
      expect(choices, 1);
      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
      final feedbackCard = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_card')),
      );
      final feedbackSurface = tester.getRect(
        find.byKey(const Key('act0_shell_accessibility_shared_surface')),
      );
      final feedbackTopContent = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_primary_result_block')),
      );
      final feedbackExplanation = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_reason')),
      );
      final feedbackCta = tester.getRect(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      expect(feedbackSurface.left, decisionSurface.left);
      expect(feedbackSurface.right, decisionSurface.right);
      expect(feedbackSurface.bottom, decisionSurface.bottom);
      expect(
        feedbackTopContent.top - feedbackSurface.top,
        inInclusiveRange(0, feedbackSurface.height * 0.14),
      );
      expect(feedbackCta.top, greaterThan(feedbackExplanation.bottom));
      expect(
        feedbackCta.top - feedbackExplanation.bottom,
        inInclusiveRange(
          feedbackSurface.height * 0.12,
          feedbackSurface.height * 0.55,
        ),
      );
      expect(
        feedbackSurface.bottom - feedbackCta.bottom,
        inInclusiveRange(
          feedbackSurface.height * 0.03,
          feedbackSurface.height * 0.2,
        ),
      );
      expect(
        find.text(
          'Right: two private cards, three board cards, and a 6 BB pot.',
        ),
        findsOneWidget,
      );
      expect(runner.lessonId, directRunner.lessonId);
      expect(runner.table.potLabel, directRunner.table.potLabel);
      expect(runner.table.toCallLabel, directRunner.table.toCallLabel);
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_table'))),
        evidenceTable,
      );
      expect(
        tester.getRect(find.byKey(const Key('act0_shell_runner_action_dock'))),
        evidenceDock,
      );
      expect(
        sink.events.where((event) => event.name == 'user_choice'),
        hasLength(1),
      );
      expect(
        sink.events.where((event) => event.name == 'accessibility_navigation'),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('accessibility activation has a deterministic compact boundary', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
        .taskList
        .firstWhere((entry) => entry.taskId == 'actions_call_drill');
    final runner = placementQuickCheckRunnerV1(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      ),
      signalId: 'table_read',
      checkIndex: 1,
      checkCount: 3,
    );
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<bool> activatesAt(double scale) async {
      var active = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(375, 812),
              textScaler: TextScaler.linear(scale),
            ),
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  active = act0ShouldActivateCompactAccessibilityPrototypeV1(
                    context,
                    question: runner.question,
                    options: runner.options,
                    tableCriticalLabels: <String>[
                      runner.table.potLabel,
                      runner.table.toCallLabel,
                    ],
                  );
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return active;
    }

    expect(await activatesAt(1.0), isFalse);
    expect(await activatesAt(1.4), isTrue);
  });

  testWidgets(
    'expanded localization uses true Pro Max measured demand deterministically',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
          .taskList
          .firstWhere((entry) => entry.taskId == 'actions_call_drill');
      final base = placementQuickCheckRunnerV1(
        task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const <Act0TeachingStepV1>[],
        ),
        signalId: 'table_read',
        checkIndex: 1,
        checkCount: 3,
      );
      final localized = base.copyWith(
        question: '${base.question} · table context',
        options: base.options.map(_expandedOptionV1).toList(growable: false),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(440, 956),
              textScaler: TextScaler.linear(1.4),
            ),
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  expect(
                    act0ShouldActivateCompactAccessibilityPrototypeV1(
                      context,
                      question: localized.question,
                      options: localized.options,
                      tableCriticalLabels: <String>[
                        localized.table.potLabel,
                        localized.table.toCallLabel,
                      ],
                    ),
                    isTrue,
                  );
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
