import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';

void main() {
  testWidgets('Session Summary promotes one earned proof hero payoff', (
    tester,
  ) async {
    await _pumpPayoffSummary(tester);

    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsOneWidget,
    );
    expect(find.text('Proof banked'), findsWidgets);
    expect(find.text('You turned one miss into a fix.'), findsOneWidget);
    expect(find.text('First read banked. Fix landed.'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_payoff_sharky')),
      findsOneWidget,
    );

    final heroTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
        )
        .dy;
    final nextTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_block_summary_next_label')),
        )
        .dy;
    expect(heroTop, lessThan(nextTop));
  });

  testWidgets('earned moment uses collected proof treatment without RPG copy', (
    tester,
  ) async {
    await _pumpPayoffSummary(tester);

    final earnedMoment = find.byKey(
      const Key('act0_shell_block_summary_earned_moment'),
    );
    expect(earnedMoment, findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment_mark')),
      findsOneWidget,
    );
    expect(find.text('Collected proof'), findsOneWidget);
    expect(find.text('Small win earned. Sharky can prove it.'), findsOneWidget);

    final blockText = tester
        .widgetList<Text>(
          find.descendant(of: earnedMoment, matching: find.byType(Text)),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'achievement unlocked',
      'xp',
      'level',
      'rank',
      'radar',
      'rating',
      'mastered',
      'pro',
      'reward',
    ]) {
      expect(_containsForbiddenTokenInText(blockText, forbidden), isFalse);
    }
  });

  testWidgets('Session Summary payoff keeps callbacks route-neutral', (
    tester,
  ) async {
    var continued = 0;
    await _pumpPayoffSummary(tester, onContinue: () => continued += 1);

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    button.onPressed!();
    await tester.pumpAndSettle();

    expect(continued, 1);
    expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
  });
}

Future<void> _pumpPayoffSummary(
  WidgetTester tester, {
  VoidCallback? onContinue,
}) async {
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
            endLevel: 1,
            startXp: 80,
            endXp: 100,
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
            currentSessionOnly: true,
          ),
          earnedMomentConsumer: Act0AchievementSeedConsumerV1.fromProjection(
            Act0AchievementSeedProjectionV1(
              seeds: <Act0AchievementSeedV1>[
                _seed(act0AchievementSeedFirstCorrectReadV1, sequence: 1),
              ],
            ),
          ),
          repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
            Act0RepairOutcomeProjectionV1(
              outcomes: <Act0RepairOutcomeV1>[
                _repairOutcome(outcomeState: act0RepairOutcomeStateCorrectV1),
              ],
            ),
          ),
          onReplay: () {},
          onContinue: onContinue ?? () {},
          onBackToMap: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Act0AchievementSeedV1 _seed(String id, {int? sequence}) {
  return Act0AchievementSeedV1(
    id: id,
    internalTitle: id,
    sourceOwner: 'test_projection',
    state: act0AchievementSeedStateEarnedV1,
    earned: true,
    earnedSequence: sequence,
    sourceSummary: const <String, Object?>{},
    eligibilityState: act0AchievementSeedStateEarnedV1,
  );
}

Act0RepairOutcomeV1 _repairOutcome({required String outcomeState}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey: 'focus_key',
    queueItemId: 'queue_item',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    selectedChoiceId: 'check',
    correctChoiceId: 'check',
    isCorrect: true,
    outcomeState: outcomeState,
    sequence: 1,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}

bool _containsForbiddenTokenInText(String text, String token) {
  final pattern = RegExp(
    r'(^|[^a-z0-9])' + RegExp.escape(token) + r'([^a-z0-9]|$)',
  );
  return pattern.hasMatch(text.toLowerCase());
}
