import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets(
    'wrong feedback uses primary result block and missed clue proof',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0FeedbackShellV1(
              title: 'Good spot to fix.',
              reason: 'Checking is better because nobody has bet yet.',
              quality: Act0FeedbackQualityV1.wrong,
              sharkyLine: 'Good spot to fix.',
              sharkyMood: Act0SharkyMoodV1.repair,
              selectedLabel: 'Fold',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              signalProof: const Act0FeedbackSignalProofV1(
                signalId: 'no_bet_yet',
                label: 'No bet yet',
                proofLine: 'Signal: No bet yet',
              ),
              contextLabels: const <String>['No bet yet'],
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('act0_shell_feedback_primary_result_block')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_primary_result_label')),
        findsOneWidget,
      );
      expect(find.text('Missed clue'), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_feedback_verdict_pill')),
        findsNothing,
      );
      expect(
        find.text('Nobody had bet yet - that was the clue.'),
        findsOneWidget,
      );
      expect(find.textContaining('No bet yet'), findsNothing);
      expect(find.textContaining('Signal:'), findsNothing);
    },
  );

  testWidgets('repair feedback promotes receipt and summary proof blocks', (
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
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'no_bet_yet',
              label: 'No bet yet',
              proofLine: 'Signal: No bet yet',
            ),
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

    expect(find.text('Repair fixed'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_primary_result_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_repair_receipt_proof_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_repair_result_receipt_title')),
      findsOneWidget,
    );
    expect(find.text('Repair result'), findsOneWidget);
    expect(
      find.text('Repair fixed: you caught the no-bet-yet clue.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_proof_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_ceremony_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_ceremony_label')),
      findsOneWidget,
    );
    expect(find.text('Session proof'), findsOneWidget);
    expect(
      find.text('Today you repaired the no-bet-yet clue.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_verdict_pill')),
      findsNothing,
    );
  });

  testWidgets('wrong repair feedback shows visible repair reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Good spot to fix.',
            reason: 'No bet faces Hero yet. Check is the clean action.',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine: 'Good spot to fix.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Bet',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'no_bet_yet',
              label: 'No bet yet',
              proofLine: 'Signal: No bet yet',
            ),
            contextLabels: const <String>['No bet yet'],
            repairReasonLine:
                'You missed that nobody has bet yet. This hand repeats that table clue.',
            repairResultReceiptLine:
                'Repair started: the missed table clue was no bet yet.',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_visible_repair_reason')),
      findsOneWidget,
    );
    expect(find.text('Repair focus'), findsOneWidget);
    expect(find.text('You missed the no-bet-yet clue.'), findsOneWidget);
    expect(
      find.text(
        'You missed that nobody has bet yet. This hand repeats that table clue.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Before choosing, ask whether a bet faces you.'),
      findsOneWidget,
    );
    expect(find.textContaining('AI'), findsNothing);
    expect(find.textContaining('solver'), findsNothing);
    expect(find.textContaining('GTO'), findsNothing);
    expect(find.textContaining('optimal'), findsNothing);
  });

  testWidgets('repeated repair feedback labels still fragile calmly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Still missed.',
            reason: 'Checking keeps the free option when nobody has bet.',
            quality: Act0FeedbackQualityV1.wrong,
            sharkyLine: 'One more calm repair.',
            sharkyMood: Act0SharkyMoodV1.repair,
            selectedLabel: 'Fold',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'no_bet_yet',
              label: 'No bet yet',
              proofLine: 'Signal: No bet yet',
            ),
            repairResultReceiptLine:
                'Still missed: nobody had bet yet. One more repair hand will help.',
            repairSessionSummaryLines: const <String>[
              'Still fragile: the no-bet-yet clue.',
              'Next focus: one more no-bet-yet repair hand.',
            ],
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Still fragile'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_repair_receipt_proof_block')),
      findsOneWidget,
    );
    expect(find.text('Repair result'), findsOneWidget);
    expect(
      find.text(
        'Still missed: nobody had bet yet. One more repair hand will help.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_proof_block')),
      findsOneWidget,
    );
    expect(find.text('Session proof'), findsOneWidget);
    expect(find.text('Still fragile: the no-bet-yet clue.'), findsOneWidget);
    expect(
      find.text('Next focus: one more no-bet-yet repair hand.'),
      findsOneWidget,
    );
    expect(find.textContaining('mastered forever'), findsNothing);
    expect(find.textContaining('guarantee'), findsNothing);
  });

  testWidgets('exact replay summary uses replay-only ceremony copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Replay fixed.',
            reason: 'This replay checks the same spot, not a broader signal.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Replay handled.',
            sharkyMood: Act0SharkyMoodV1.celebrate,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            repairResultReceiptLine:
                'Replay fixed: you handled this spot correctly.',
            repairSessionSummaryLines: const <String>[
              'Replay fixed: you handled that spot correctly.',
            ],
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Session proof'), findsOneWidget);
    expect(
      find.text('Replay fixed: you handled that spot correctly.'),
      findsOneWidget,
    );
    expect(find.textContaining('same-signal'), findsNothing);
    expect(find.textContaining('general skill'), findsNothing);
    expect(find.textContaining('no-bet-yet clue'), findsNothing);
  });

  testWidgets('non-repair feedback has no session ceremony block', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Good read.',
            reason: 'You saw the table clue before choosing.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Keep using it.',
            sharkyMood: Act0SharkyMoodV1.happy,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            firstValueReceiptLine: 'First read logged. Next: use it once more.',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_session_summary_ceremony_block')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_proof_block')),
      findsNothing,
    );
    expect(find.text('Session proof'), findsNothing);
  });
}
