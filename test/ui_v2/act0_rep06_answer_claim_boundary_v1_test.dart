import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('one source-correct choice records an answer, not improvement', () {
    final task = Act0ShellStateV1.sample.worlds
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.tasks)
        .firstWhere(
          (task) =>
              task.taskId ==
              'position_checkpoint_position_checkpoint_table_notice',
        );
    final receipt = act0FirstValueSkillReceiptForRunnerV1(
      runner: task.runner,
      option: task.runner.options.firstWhere((option) => option.isCorrect),
      taskFamily: task.resolvedTaskFamily,
    )!;
    expect(receipt.sourceSignalId, 'players_behind');
    expect(receipt.title, 'Correct answer recorded');
    expect(receipt.detail, 'Your answer matched the check for Players behind.');
    // Legacy telemetry keys do not establish learning or change repair routing.
    expect(receipt.outcomeId, 'learned');
  });

  test('legacy learned receipt cannot display a skill improvement claim', () {
    const receipt = Act0SkillReceiptV1(
      skillAtomId: 'action_read',
      skillLabel: 'Action read',
      sourceSignalId: 'no_bet_yet',
      sourceSignalLabel: 'No bet yet',
      outcome: Act0SkillReceiptOutcomeV1.learned,
      nextRepId: 'repeat_action_read',
      nextRepLabel: 'Try another read',
    );
    expect(receipt.title, 'Correct answer recorded');
    expect(receipt.detail, isNot(contains('before choosing')));
  });

  for (final gain in <int>[0, 12]) {
    testWidgets(
      'completion toast keeps XP ($gain) internal without growth claims',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: Act0FeedbackShellV1(
                  title: 'Correct.',
                  reason: 'Nobody has bet yet.',
                  quality: Act0FeedbackQualityV1.correct,
                  sharkyLine: 'Check the table clue.',
                  sharkyMood: Act0SharkyMoodV1.happy,
                  selectedLabel: 'Check',
                  preferredLabel: 'Check',
                  betterLabel: 'Check',
                  completionSummary: Act0RunnerCompletionSummaryV1(
                    xpGain: gain,
                    startLevel: 1,
                    endLevel: 1,
                    startXp: 20,
                    endXp: 20 + gain,
                    xpTarget: 100,
                  ),
                  onContinue: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_shell_completion_toast')),
          findsOneWidget,
        );
        expect(find.text('Answer checked'), findsOneWidget);
        expect(find.text('Keep practicing'), findsOneWidget);
        expect(find.textContaining('XP'), findsNothing);
        expect(find.textContaining('Level'), findsNothing);
        expect(find.text('Table read improved'), findsNothing);
        expect(find.text('Read banked'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
