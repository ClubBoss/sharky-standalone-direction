import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  Future<void> pumpCompactRunner(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  testWidgets('repair surfaces share one calm repair proof system', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Repair fixed.',
            reason: 'Checking keeps the free option when nobody has bet.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Clean repair.',
            sharkyMood: Act0SharkyMoodV1.celebrate,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            repairResultReceiptLine:
                'Repair fixed: you caught the no-bet-yet clue.',
            repairSessionSummaryLines: const <String>[
              'Today you repaired the no-bet-yet clue.',
            ],
            onContinue: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('act0_shell_repair_system_block')),
      findsWidgets,
    );
    expect(
      find.byKey(const Key('act0_shell_repair_result_system_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_repair_closure_system_card')),
      findsOneWidget,
    );
    expect(find.text('Result'), findsOneWidget);
    expect(
      find.text('Repair fixed: you caught the no-bet-yet clue.'),
      findsOneWidget,
    );
    expect(find.text('Session result'), findsOneWidget);
    expect(find.textContaining('warning'), findsNothing);
    expect(find.textContaining('error'), findsNothing);
    expect(find.textContaining('XP'), findsNothing);
    expect(find.textContaining('level'), findsNothing);
    expect(find.textContaining('master'), findsNothing);
  });

  testWidgets('decision action panel exposes subtle commit motion wrapper', (
    tester,
  ) async {
    final lesson = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere(
          (candidate) => candidate.lessonId == 'fold_check_call_raise',
        );
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == 'actions_check_drill',
    );
    final runner = task.runner.copyWith(
      phase: Act0LessonPhaseV1.drill,
      teachingStepIndex: task.runner.teachingSteps.length,
    );

    await pumpCompactRunner(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: runner,
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

    expect(
      find.byKey(const Key('act0_shell_decision_commit_motion')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);
    expect(find.byType(AnimatedScale), findsWidgets);
  });

  testWidgets('proof motion respects reduced motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Act0FeedbackShellV1(
              title: 'Nice choice.',
              reason: 'Checking keeps the free option when nobody has bet.',
              quality: Act0FeedbackQualityV1.correct,
              sharkyLine: 'Good rep.',
              sharkyMood: Act0SharkyMoodV1.neutral,
              selectedLabel: 'Check',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              repairOutcomeProofLine: 'Nice - you chose the better action.',
              onContinue: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_repair_outcome_motion_reveal')),
      findsOneWidget,
    );
    expect(find.byType(AnimatedSlide), findsNothing);
    expect(find.byType(AnimatedOpacity), findsNothing);
    expect(find.byType(AnimatedScale), findsNothing);
  });

  testWidgets(
    'Street Replay reveals with shared motion and no rebuild replay',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_streetReplayHost());
      await tester.pump();

      const motionKey = Key('act0_shell_street_replay_step_motion_0');
      expect(find.byKey(motionKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(motionKey),
          matching: find.byType(AnimatedScale),
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AnimatedScale>(
              find.descendant(
                of: find.byKey(motionKey),
                matching: find.byType(AnimatedScale),
              ),
            )
            .scale,
        1.0,
      );

      await tester.pumpWidget(_streetReplayHost());
      await tester.pump();
      expect(
        tester
            .widget<AnimatedScale>(
              find.descendant(
                of: find.byKey(motionKey),
                matching: find.byType(AnimatedScale),
              ),
            )
            .scale,
        1.0,
      );
    },
  );

  testWidgets('Street Replay reduced motion is immediately complete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_streetReplayHost(disableAnimations: true));
    await tester.pump();

    const motionKey = Key('act0_shell_street_replay_step_motion_0');
    expect(find.byKey(motionKey), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(motionKey),
        matching: find.byType(AnimatedScale),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_street_replay_step_0')),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
  });

  test('motion evidence helper documents local-only frame output', () {
    final file = File('tools/act0_motion_evidence_capture_v1.dart');
    expect(file.existsSync(), isTrue);
    final source = file.readAsStringSync();
    expect(source, contains('output/motion_evidence/current'));
    expect(source, contains('decision_feedback_reveal'));
    expect(source, contains('repair_result_fix_landed'));
    expect(source, contains('session_summary_proof_hero'));
    expect(source, contains('Generated motion evidence is local-only'));
  });
}

Widget _streetReplayHost({bool disableAnimations = false}) {
  final task = Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .firstWhere((lesson) => lesson.lessonId == 'your_first_hand')
      .taskList
      .firstWhere((task) => task.taskId == 'your_first_hand_action_trail');
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Act0LessonRunnerShellV1(
          runner: task.runner.copyWith(
            phase: Act0LessonPhaseV1.drill,
            teachingStepIndex: task.runner.teachingSteps.length,
            table: task.runner.table.copyWith(
              activeSeatId: 'btn',
              heroSeatId: 'btn',
            ),
          ),
          tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    ),
  );
}
