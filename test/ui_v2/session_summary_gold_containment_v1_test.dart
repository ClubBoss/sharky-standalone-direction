import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

void main() {
  testWidgets('Session Summary contains gold to the hero zone only', (
    tester,
  ) async {
    await _pumpGoldSummary(tester);

    final pageCard = tester.widget<Container>(
      find.byKey(const Key('act0_shell_block_summary_card')),
    );
    final pageDecoration = pageCard.decoration as BoxDecoration;
    expect(pageDecoration.gradient, isNull);
    expect(pageDecoration.color, Act0ShellTokensV1.surface);
    expect(pageDecoration.border, Border.all(color: Act0ShellTokensV1.border));

    final hero = tester.widget<Container>(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
    );
    final heroDecoration = hero.decoration as BoxDecoration;
    expect(
      heroDecoration.border,
      Border.all(color: Act0ShellTokensV1.gold.withValues(alpha: 0.28)),
    );

    for (final lowerCardKey in <String>[
      'act0_shell_block_summary_next_label',
      'act0_shell_block_summary_evidence_card',
      'act0_shell_block_summary_earned_moment',
    ]) {
      final lowerCard = tester.widget<Container>(find.byKey(Key(lowerCardKey)));
      final lowerDecoration = lowerCard.decoration as BoxDecoration;
      expect(
        lowerDecoration.border,
        Border.all(color: Act0ShellTokensV1.border),
        reason: '$lowerCardKey must use the standard navy-glass hairline',
      );
    }
  });

  testWidgets(
    'Practice this next is an inline action without a second border',
    (tester) async {
      await _pumpGoldSummary(tester);

      final button = tester.widget<TextButton>(
        find.byKey(const Key('act0_shell_session_summary_practice_cta')),
      );
      final resolvedForeground = button.style!.foregroundColor!.resolve(
        <WidgetState>{},
      );

      expect(resolvedForeground, Act0ShellTokensV1.info);
      expect(
        find.ancestor(
          of: find.text('Practice this next'),
          matching: find.byType(OutlinedButton),
        ),
        findsNothing,
      );
      expect(find.text('Practice this next'), findsOneWidget);
    },
  );

  testWidgets(
    'Session Summary proof and Sharky ceremony still render with gold hero',
    (tester) async {
      await _pumpGoldSummary(tester);

      expect(
        find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
        findsOneWidget,
      );
      expect(find.text('One clean table read is saved.'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_session_summary_payoff_sharky')),
        findsOneWidget,
      );
      expect(find.text('Collected read'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_block_summary_continue_cta')),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpGoldSummary(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0BlockCompletionShellV1(
          summary: const Act0BlockCompletionSummaryV1(
            lessonTitle: 'Action words',
            xpEarned: 20,
            errorCount: 0,
            taskCount: 2,
            correctCount: 2,
            startLevel: 1,
            endLevel: 2,
            startXp: 80,
            endXp: 20,
            xpTarget: 200,
            nextLessonTitle: 'Blinds and action order',
          ),
          evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
            hasEvidence: true,
            title: 'This run',
            runId: 'run_v1|world_1|fold_check_call_raise|lesson|1',
            runKind: 'lesson',
            spotsLine: 'You played 2 spots.',
            resultLine: '1 correct / 1 to review.',
            repairFocusLine: 'You missed Action reads recently.',
            practiceLaunchRequest: Act0PracticeRepairQueueLaunchRequestV1(
              targetWorldId: 'world_1',
              targetLessonId: 'fold_check_call_raise',
              targetTaskId: 'actions_check_drill',
              targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
              sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
              sourceTaskId: 'actions_legal_context',
              repairTaskId: 'actions_check_drill',
              repairFocusKey: 'actions_legal_context|no_bet_yet',
              queueItemId:
                  'practice_repair_queue_v1|concept_candidate|no_bet_yet',
            ),
            currentSessionOnly: true,
          ),
          earnedMomentConsumer: Act0AchievementSeedConsumerV1.fromProjection(
            Act0AchievementSeedProjectionV1(
              seeds: <Act0AchievementSeedV1>[
                Act0AchievementSeedV1(
                  id: act0AchievementSeedFirstCorrectReadV1,
                  internalTitle: act0AchievementSeedFirstCorrectReadV1,
                  sourceOwner: 'test_projection',
                  state: act0AchievementSeedStateEarnedV1,
                  earned: true,
                  earnedSequence: 1,
                  sourceSummary: const <String, Object?>{},
                  eligibilityState: act0AchievementSeedStateEarnedV1,
                ),
              ],
            ),
          ),
          onLaunchPracticeRepairQueueTarget: (_) {},
          onReplay: () {},
          onContinue: () {},
          onBackToMap: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
