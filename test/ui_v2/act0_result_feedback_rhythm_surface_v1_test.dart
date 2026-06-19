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
      find.byKey(const Key('act0_shell_session_summary_proof_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_verdict_pill')),
      findsNothing,
    );
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
    expect(
      find.byKey(const Key('act0_shell_session_summary_proof_block')),
      findsOneWidget,
    );
    expect(find.textContaining('mastered forever'), findsNothing);
    expect(find.textContaining('guarantee'), findsNothing);
  });
}
