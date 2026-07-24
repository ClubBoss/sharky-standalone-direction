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

  Future<void> pumpFeedbackAt(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required String state,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final recovered = state == 'recovered';
    final failedSourceRecheck = state == 'failed-recheck';
    final wrong = state == 'wrong' || failedSourceRecheck;
    final repair = state == 'repair';
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Act0FeedbackShellV1(
              title: wrong ? 'Good spot to fix.' : 'Correct.',
              reason: 'The table clue keeps the next action clear.',
              quality: wrong
                  ? Act0FeedbackQualityV1.wrong
                  : Act0FeedbackQualityV1.correct,
              sharkyLine: 'Keep the table clue in view.',
              sharkyMood: wrong
                  ? Act0SharkyMoodV1.repair
                  : Act0SharkyMoodV1.celebrate,
              selectedLabel: wrong ? 'Fold' : 'Check',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              refined: true,
              repairReasonLine: wrong
                  ? 'This next hand keeps the missed table clue in view.'
                  : null,
              repairResultReceiptLine: repair
                  ? 'Repair fixed: you caught the table clue.'
                  : null,
              repairContinuesToSourceRecheck: repair,
              isSourceRecheckAttempt: failedSourceRecheck,
              repairOutcomeProofLine: recovered
                  ? "You missed Hero's seat first. On the recheck, you used it correctly."
                  : null,
              forceShowRepairOutcomeProof: recovered,
              onContinue: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('wrong feedback uses primary result block and table clue proof', (
    tester,
  ) async {
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
    expect(find.text('Clue from table'), findsOneWidget);
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
  });

  testWidgets(
    'long feedback clue wraps without fading and keeps the CTA reachable',
    (tester) async {
      await pumpCompactRunner(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0FeedbackShellV1(
              title: 'Correct.',
              reason: 'You used the visible table clue.',
              quality: Act0FeedbackQualityV1.correct,
              sharkyLine: 'Good read.',
              sharkyMood: Act0SharkyMoodV1.happy,
              selectedLabel: 'Check',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              signalProof: const Act0FeedbackSignalProofV1(
                signalId: 'no_bet_yet',
                label: 'No bet yet',
                proofLine: 'Signal: No bet yet',
              ),
              onContinue: () {},
            ),
          ),
        ),
      );

      final clue = tester.widget<Text>(
        find.byKey(const Key('act0_shell_feedback_signal_proof_label')),
      );
      expect(clue.data, 'Nobody had bet yet - that was the clue.');
      expect(clue.maxLines, 2);
      expect(clue.softWrap, isTrue);
      expect(clue.overflow, TextOverflow.visible);
      expect(
        tester
            .getBottomLeft(
              find.byKey(const Key('act0_shell_feedback_continue_cta')),
            )
            .dy,
        lessThanOrEqualTo(812),
      );
    },
  );

  testWidgets('short feedback clue remains a single compact line', (
    tester,
  ) async {
    await pumpCompactRunner(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Correct.',
            reason: 'You used the visible table clue.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Good read.',
            sharkyMood: Act0SharkyMoodV1.happy,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'position',
              label: 'Position',
              proofLine: 'Button.',
            ),
            onContinue: () {},
          ),
        ),
      ),
    );

    final clueFinder = find.byKey(
      const Key('act0_shell_feedback_signal_proof_label'),
    );
    expect(find.text('Button.'), findsOneWidget);
    expect(tester.getSize(clueFinder).height, lessThan(18));
  });

  testWidgets(
    'responsive feedback matrix keeps intrinsic cards and reachable CTAs',
    (tester) async {
      const matrix = <(Size, double)>[
        (Size(375, 812), 1.0),
        (Size(375, 812), 1.4),
        (Size(402, 874), 1.0),
        (Size(402, 874), 1.4),
        (Size(440, 956), 1.0),
        (Size(440, 956), 1.4),
      ];
      const states = <String>[
        'wrong',
        'repair',
        'recovered',
        'failed-recheck',
        'correct-first',
      ];

      for (final configuration in matrix) {
        for (final state in states) {
          await pumpFeedbackAt(
            tester,
            size: configuration.$1,
            textScale: configuration.$2,
            state: state,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$configuration $state',
          );
          final card = find.byKey(const Key('act0_shell_feedback_card'));
          final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
          expect(card, findsOneWidget);
          expect(cta, findsOneWidget);
          expect(
            tester.getSize(card).height,
            lessThan(configuration.$1.height),
          );
          expect(
            tester.getRect(cta).bottom,
            lessThanOrEqualTo(configuration.$1.height),
            reason: '$configuration $state',
          );
        }
      }
    },
  );

  testWidgets('correct feedback shows skill proof before proof reward', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Correct.',
            reason: 'Nobody had bet yet - that was the clue.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Good read.',
            sharkyMood: Act0SharkyMoodV1.happy,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            signalProof: const Act0FeedbackSignalProofV1(
              signalId: 'no_bet_yet',
              label: 'No bet yet',
              proofLine: 'Signal: No bet yet',
            ),
            firstValueReceiptLine: 'First read logged. Next: use it once more.',
            completionSummary: const Act0RunnerCompletionSummaryV1(
              xpGain: 12,
              startLevel: 1,
              endLevel: 1,
              startXp: 20,
              endXp: 32,
              xpTarget: 100,
            ),
            onContinue: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_first_value_receipt')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_completion_toast')),
      findsOneWidget,
    );
    final receiptTop = tester
        .getTopLeft(find.byKey(const Key('act0_shell_first_value_receipt')))
        .dy;
    final xpTop = tester
        .getTopLeft(find.byKey(const Key('act0_shell_completion_toast')))
        .dy;
    expect(receiptTop, lessThan(xpTop));
  });

  testWidgets('correct-first stays calm without a Sharky reward treatment', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Correct.',
            reason: 'You used the visible table clue.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Good read.',
            sharkyMood: Act0SharkyMoodV1.happy,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Correct read'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_sharky_slot_proof')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_sharky_slot_proof_earned')),
      findsNothing,
    );
  });

  testWidgets('wrong repair feedback keeps one teaching block before the CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Good spot to fix.',
            reason: 'Checking keeps the free option when nobody has bet.',
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
            repairReasonLine: 'This next hand starts with no bet facing Hero.',
            repairResultReceiptLine:
                'Repair started: the missed table clue was no bet yet.',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_feedback_proof_stack')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_signal_proof')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_action_contrast_block')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_hero_action')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_visible_repair_reason')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('act0_shell_feedback_reason')), findsNothing);
    expect(
      find.byKey(const Key('act0_shell_feedback_continue_cta')),
      findsOneWidget,
    );
    expect(find.text('Try same clue'), findsOneWidget);

    final actionTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_feedback_action_contrast_block')),
        )
        .dy;
    final repairTop = tester
        .getTopLeft(find.byKey(const Key('act0_shell_visible_repair_reason')))
        .dy;
    final ctaTop = tester
        .getTopLeft(find.byKey(const Key('act0_shell_feedback_continue_cta')))
        .dy;

    expect(actionTop, lessThan(repairTop));
    expect(repairTop, lessThan(ctaTop));
  });

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

    expect(find.text('Repair landed'), findsOneWidget);
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
      find.byKey(const Key('act0_shell_repair_result_outcome_line')),
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
    expect(
      find.byKey(const Key('act0_shell_session_repair_closure_strip')),
      findsOneWidget,
    );
    expect(find.text('Session result'), findsOneWidget);
    expect(find.text('Session proof'), findsNothing);
    expect(
      find.text('Today you repaired the no-bet-yet clue.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_verdict_pill')),
      findsNothing,
    );
    final resultTop = tester
        .getTopLeft(find.byKey(const Key('act0_shell_repair_result_receipt')))
        .dy;
    final sessionTop = tester
        .getTopLeft(
          find.byKey(const Key('act0_shell_session_repair_closure_strip')),
        )
        .dy;
    expect(resultTop, lessThan(sessionTop));
  });

  testWidgets('repair outcome proof renders compact local proof only', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Nice choice.',
            reason: 'Checking keeps the free option when nobody has bet.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Good rep.',
            sharkyMood: Act0SharkyMoodV1.neutral,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            repairOutcomeProofLine: 'Nice — you chose the better action.',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_repair_outcome_proof')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_repair_outcome_motion_reveal')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_card_motion_reveal')),
      findsOneWidget,
    );
    expect(find.byType(AnimatedSlide), findsWidgets);
    expect(find.byType(AnimatedOpacity), findsWidgets);
    expect(find.byType(AnimatedScale), findsWidgets);
    expect(find.text('Repair landed'), findsOneWidget);
    expect(find.text('Nice — you chose the better action.'), findsOneWidget);
    expect(find.textContaining('fixed'), findsNothing);
    expect(find.textContaining('cleared'), findsNothing);
    expect(find.textContaining('resolved'), findsNothing);
    expect(find.textContaining('completed'), findsNothing);
    expect(find.textContaining('mastered'), findsNothing);
  });

  testWidgets('canonical source recheck makes recovery distinct and bounded', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Correct.',
            reason: 'Hero\'s seat is the table clue.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'You checked the original read.',
            sharkyMood: Act0SharkyMoodV1.celebrate,
            selectedLabel: 'Continue',
            preferredLabel: 'Continue',
            betterLabel: 'Continue',
            repairOutcomeProofLine:
                "You missed Hero's seat first. On the recheck, you used it correctly.",
            forceShowRepairOutcomeProof: true,
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(find.text('Original read proven'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_repair_outcome_proof_title')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_feedback_sharky_slot_proof_earned')),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    expect(find.textContaining('mastered'), findsNothing);
  });

  testWidgets(
    'repair success remains partial and points to the source recheck',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0FeedbackShellV1(
              title: 'Repair fixed.',
              reason: 'The table clue is visible again.',
              quality: Act0FeedbackQualityV1.correct,
              sharkyLine: 'Good repair.',
              sharkyMood: Act0SharkyMoodV1.celebrate,
              selectedLabel: 'Check',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              repairResultReceiptLine:
                  'Repair fixed: you caught the no-bet-yet clue.',
              repairContinuesToSourceRecheck: true,
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(find.text('Repair landed'), findsOneWidget);
      expect(find.text('Check original read'), findsOneWidget);
      expect(find.text('Original read proven'), findsNothing);
      expect(
        find.byKey(const Key('act0_shell_feedback_sharky_slot_proof_earned')),
        findsNothing,
      );
    },
  );

  testWidgets('repair CTA names only its actual next destination', (
    tester,
  ) async {
    Future<void> pumpFeedback({
      required bool directSourceRecheck,
      required bool failedSourceRecheck,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0FeedbackShellV1(
              title: failedSourceRecheck ? 'Still missed.' : 'Repair fixed.',
              reason: 'The table clue is visible again.',
              quality: failedSourceRecheck
                  ? Act0FeedbackQualityV1.wrong
                  : Act0FeedbackQualityV1.correct,
              sharkyLine: 'Keep the clue in view.',
              sharkyMood: Act0SharkyMoodV1.repair,
              selectedLabel: 'Fold',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              repairResultReceiptLine: failedSourceRecheck
                  ? null
                  : 'Repair fixed: you caught the table clue.',
              repairContinuesToSourceRecheck: directSourceRecheck,
              isSourceRecheckAttempt: failedSourceRecheck,
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpFeedback(directSourceRecheck: true, failedSourceRecheck: false);
    expect(find.text('Check original read'), findsOneWidget);

    await pumpFeedback(directSourceRecheck: false, failedSourceRecheck: false);
    expect(find.text('Continue to Review'), findsOneWidget);
    expect(find.text('Check original read'), findsNothing);

    await pumpFeedback(directSourceRecheck: false, failedSourceRecheck: true);
    expect(find.text('Original read needs one more rep'), findsOneWidget);
    expect(find.text('Continue to Review'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_feedback_icon_wrong')),
      findsOneWidget,
    );
  });

  testWidgets('compact recovered feedback keeps a restrained Sharky marker', (
    tester,
  ) async {
    await pumpCompactRunner(
      tester,
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Correct.',
            reason: 'Hero\'s seat is the table clue.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'You checked the original read.',
            sharkyMood: Act0SharkyMoodV1.celebrate,
            selectedLabel: 'Continue',
            preferredLabel: 'Continue',
            betterLabel: 'Continue',
            refined: true,
            repairOutcomeProofLine:
                "You missed Hero's seat first. On the recheck, you used it correctly.",
            forceShowRepairOutcomeProof: true,
            onContinue: () {},
          ),
        ),
      ),
    );

    final sharky = find.byKey(
      const Key('act0_shell_feedback_sharky_slot_proof_earned'),
    );
    expect(sharky, findsOneWidget);
    expect(tester.getSize(sharky).height, lessThanOrEqualTo(30));
    expect(find.text('Original read proven'), findsOneWidget);
  });

  testWidgets(
    'recovered feedback uses the existing reveal and honors reduced motion',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Act0FeedbackShellV1(
                title: 'Correct.',
                reason: 'Hero\'s seat is the table clue.',
                quality: Act0FeedbackQualityV1.correct,
                sharkyLine: 'You checked the original read.',
                sharkyMood: Act0SharkyMoodV1.celebrate,
                selectedLabel: 'Continue',
                preferredLabel: 'Continue',
                betterLabel: 'Continue',
                repairOutcomeProofLine:
                    "You missed Hero's seat first. On the recheck, you used it correctly.",
                forceShowRepairOutcomeProof: true,
                onContinue: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('act0_shell_feedback_card_motion_reveal')),
        findsOneWidget,
      );
      expect(find.byType(AnimatedScale), findsNothing);
      expect(find.byType(AnimatedSlide), findsNothing);
      expect(find.byType(AnimatedOpacity), findsNothing);
    },
  );

  testWidgets('repair outcome proof renders nothing when absent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0FeedbackShellV1(
            title: 'Nice choice.',
            reason: 'Checking keeps the free option when nobody has bet.',
            quality: Act0FeedbackQualityV1.correct,
            sharkyLine: 'Good rep.',
            sharkyMood: Act0SharkyMoodV1.neutral,
            selectedLabel: 'Check',
            preferredLabel: 'Check',
            betterLabel: 'Check',
            onContinue: () {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('act0_shell_repair_outcome_proof')),
      findsNothing,
    );
    expect(find.text('Repair landed'), findsNothing);
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
                'You missed that nobody has bet yet. This rep repeats the same clue.',
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
    expect(
      find.text(
        'This rep repeats the same clue. Before choosing, ask whether a bet faces you.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('You missed that nobody has bet yet.'),
      findsNothing,
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
      findsNothing,
    );
    expect(find.text('Repair result'), findsNothing);
    expect(
      find.text(
        'Still missed: nobody had bet yet. One more repair hand will help.',
      ),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_proof_block')),
      findsOneWidget,
    );
    expect(find.text('Session result'), findsOneWidget);
    expect(find.text('Session proof'), findsNothing);
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

    expect(find.text('Session result'), findsOneWidget);
    expect(find.text('Session proof'), findsNothing);
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

  testWidgets(
    'runner decision keeps table evidence above an anchored prompt action surface',
    (tester) async {
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

      expect(find.byKey(const Key('act0_shell_table')), findsOneWidget);
      expect(
        find.byKey(const Key('act0_shell_runner_decision_rhythm_surface')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_action_prompt_panel')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('act0_shell_action_panel')), findsOneWidget);

      final tableBottom = tester
          .getBottomLeft(find.byKey(const Key('act0_shell_table')))
          .dy;
      final rhythmTop = tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_runner_decision_rhythm_surface')),
          )
          .dy;
      final promptTop = tester
          .getTopLeft(find.byKey(const Key('act0_shell_action_question')))
          .dy;
      final actionTop = tester
          .getTopLeft(find.byKey(const Key('act0_shell_action_panel')))
          .dy;

      expect(tableBottom, lessThan(rhythmTop));
      expect(promptTop, lessThan(actionTop));
    },
  );
}
