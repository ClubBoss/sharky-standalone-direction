import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// REP-06 / REP-07 falsifiers observed on the exact native candidate
/// (b00cd4e0, EN iPhone 14 Pro): after one miss and one Quick-Hint-assisted
/// answer, the Session Summary still said "You are reading the table with
/// more control." under a "What improved" heading. A session with help or a
/// miss is practice, not demonstrated growth.
void main() {
  Future<void> pumpSummary(
    WidgetTester tester, {
    required int errorCount,
    required int assistedCount,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: Act0BlockCompletionSummaryV1(
              lessonTitle: 'Fold, check, call, raise',
              xpEarned: 25,
              errorCount: errorCount,
              assistedCount: assistedCount,
              taskCount: 5,
              correctCount: 5 - errorCount - assistedCount,
              startLevel: 1,
              endLevel: 1,
              startXp: 5,
              endXp: 30,
              xpTarget: 200,
              nextLessonTitle: 'Blinds & action order',
              sharkyLine: Act0SharkyCueV1.beginner.summaryLine,
            ),
            evidenceSummary: const Act0SessionSummaryEvidenceViewModelV1(
              hasEvidence: true,
              title: 'This run',
              runId: 'run_v1|world_1|fold_check_call_raise|lesson|4',
              runKind: 'lesson',
              spotsLine: 'You played 5 spots.',
              resultLine: '4 correct / 1 to review.',
              repairFocusLine: 'You missed No bet yet recently.',
              currentSessionOnly: true,
            ),
            earnedMomentConsumer: const Act0AchievementSeedConsumerV1(),
            onReplay: () {},
            onContinue: () {},
            onBackToMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('assisted session ends on a help line, not a growth claim', (
    tester,
  ) async {
    await pumpSummary(tester, errorCount: 1, assistedCount: 1);

    expect(
      find.text('You are reading the table with more control.'),
      findsNothing,
    );
    expect(
      find.text('Help showed the clue. Check it on your own next time.'),
      findsOneWidget,
    );
    expect(find.text('What improved'), findsNothing);
  });

  testWidgets('a miss without help keeps the clue, without a growth claim', (
    tester,
  ) async {
    await pumpSummary(tester, errorCount: 1, assistedCount: 0);

    expect(
      find.text('You are reading the table with more control.'),
      findsNothing,
    );
    expect(
      find.text('Keep this table clue and check it in the next hand.'),
      findsOneWidget,
    );
  });

  test('beginner summary cue makes no skill-growth claim', () {
    final line = Act0SharkyCueV1.beginner.summaryLine.toLowerCase();
    for (final claim in ['more control', 'improved', 'mastered', 'better at']) {
      expect(line, isNot(contains(claim)));
    }
  });
}
