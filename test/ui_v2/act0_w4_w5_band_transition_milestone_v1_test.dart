import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_improvement_observation_v1.dart';

const _bandTransitionKey = Key('act0_shell_band_transition_completion_payoff');
const _ordinaryKey = Key('act0_shell_world_completion_payoff');
const _emphasisRingKey = Key('act0_proof_icon_v1_milestone_emphasis_ring');

void main() {
  testWidgets('incomplete World 4 does not show the band-transition card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Act0BlockCompletionSummaryV1(
          lessonTitle: 'A lesson in World 4',
          xpEarned: 20,
          errorCount: 0,
          taskCount: 4,
          correctCount: 4,
          startLevel: 1,
          endLevel: 1,
          startXp: 40,
          endXp: 60,
          xpTarget: 200,
          nextLessonTitle: 'Next lesson in World 4',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(_bandTransitionKey), findsNothing);
  });

  testWidgets('completed World 4 shows the Foundation-complete identity', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pumpAndSettle();

    expect(find.byKey(_bandTransitionKey), findsOneWidget);
    expect(find.byKey(_ordinaryKey), findsNothing);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('act0_shell_block_summary_title')))
          .data,
      'World 4 complete',
    );
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.text('Foundation complete'),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'You can now read the table, hand, action, and position before '
        'deciding.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'World 4 uses the stronger emphasized milestone seal; ordinary worlds '
    'do not',
    (tester) async {
      await tester.pumpWidget(_host(_worldFourSummary()));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(_bandTransitionKey),
          matching: find.byKey(_emphasisRingKey),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(_host(_worldThreeSummary()));
      await tester.pumpAndSettle();
      expect(find.byKey(_bandTransitionKey), findsNothing);
      expect(find.byKey(_emphasisRingKey), findsNothing);

      await tester.pumpWidget(_host(_worldFiveSummary()));
      await tester.pumpAndSettle();
      expect(find.byKey(_bandTransitionKey), findsNothing);
      expect(find.byKey(_emphasisRingKey), findsNothing);
    },
  );

  testWidgets('World 4 next-band label reads Next: Developing Player', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pumpAndSettle();

    expect(find.text('Next: Developing Player'), findsOneWidget);
    expect(
      find.text(
        'World 5 starts connecting board texture and street changes into '
        'one plan.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('band-transition copy is claim-safe', (tester) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pumpAndSettle();

    final text = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(_bandTransitionKey),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'mastered',
      'intermediate',
      'level 5',
      'skill increased',
      'completed all beginner poker',
      'ai verified',
      'fixed forever',
      'launch-ready',
      'xp',
      'rank',
      'rarity',
      'coins',
      '%',
    ]) {
      expect(text, isNot(contains(forbidden)));
    }
  });

  testWidgets('no-proof completion shows the safe fallback', (tester) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.text('Repair result saves the next time you fix one.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsNothing,
    );
  });

  testWidgets('banked proof maps to repairCompleted', (tester) async {
    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes);

    await tester.pumpWidget(
      _host(
        _worldFourSummary(),
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
          improvementObservationProjection:
              Act0SharkyImprovementObservationProjectionV1.fromFixProof(
                fixProof,
                completedSessionId: 'session_3',
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.text('1 repair completed'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('reinforced proof maps to reinforced', (tester) async {
    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes, reinforced: true);

    await tester.pumpWidget(
      _host(
        _worldFourSummary(),
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.byKey(const Key('act0_proof_icon_v1_reinforced')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('activity-only evidence earns no proof icon', (tester) async {
    final outcomes = _repairOutcomes();

    await tester.pumpWidget(
      _host(
        _worldFourSummary(),
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(_bandTransitionKey),
        matching: find.byType(Act0ProofIconV1),
      ),
      findsOneWidget, // the milestone icon only, no proof icon
    );
  });

  testWidgets(
    'band transition requires exact World 5 route truth; a mismatched '
    'next world shows neither payoff card',
    (tester) async {
      final summary = Act0BlockCompletionSummaryV1(
        lessonTitle: 'A lesson in World 4',
        xpEarned: 24,
        errorCount: 0,
        taskCount: 4,
        correctCount: 4,
        startLevel: 1,
        endLevel: 2,
        startXp: 188,
        endXp: 12,
        xpTarget: 200,
        milestoneTier: Act0ProgressMilestoneTierV1.world,
        worldNumber: 4,
        worldTitle: 'Bet Purpose / Price',
        nextWorldNumber: 6,
        nextWorldTitle: 'Range Thinking',
        perfectClearCount: 12,
        completedClearCount: 12,
      );

      expect(summary.hasBandTransitionPayoff, isFalse);
      expect(summary.hasWorldCompletionPayoff, isFalse);

      await tester.pumpWidget(_host(summary));
      await tester.pumpAndSettle();

      expect(find.byKey(_bandTransitionKey), findsNothing);
      expect(find.byKey(_ordinaryKey), findsNothing);
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('act0_shell_block_summary_title')),
            )
            .data,
        'World 4 complete',
      );
    },
  );

  testWidgets('World 13+ remains blocked from any completion payoff', (
    tester,
  ) async {
    const summary = Act0BlockCompletionSummaryV1(
      lessonTitle: 'A lesson in world 13',
      xpEarned: 24,
      errorCount: 0,
      taskCount: 4,
      correctCount: 4,
      startLevel: 1,
      endLevel: 2,
      startXp: 188,
      endXp: 12,
      xpTarget: 200,
      milestoneTier: Act0ProgressMilestoneTierV1.world,
      worldNumber: 13,
      worldTitle: 'A later world',
      nextWorldNumber: 14,
      nextWorldTitle: 'Another later world',
      perfectClearCount: 12,
      completedClearCount: 12,
    );

    expect(summary.hasBandTransitionPayoff, isFalse);

    await tester.pumpWidget(_host(summary));
    await tester.pumpAndSettle();

    expect(find.byKey(_bandTransitionKey), findsNothing);
    expect(find.byKey(_ordinaryKey), findsNothing);
  });

  testWidgets('primary CTA routes to the valid next destination', (
    tester,
  ) async {
    var continued = 0;
    await tester.pumpWidget(
      _host(
        _worldFourSummary(),
        onContinue: () {
          continued += 1;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();

    expect(continued, 1);
  });

  testWidgets('reopening completion is idempotent, no duplicate proof', (
    tester,
  ) async {
    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes);
    final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
      outcomes,
      fixProofProjection: fixProof,
    );
    final beforeLines = List<String>.from(consumer.sessionReceipt!.lines);

    await tester.pumpWidget(
      _host(_worldFourSummary(), repairOutcomeConsumer: consumer),
    );
    await tester.pumpAndSettle();
    final proofLine = find.descendant(
      of: find.byKey(_bandTransitionKey),
      matching: find.text('1 repair completed'),
    );
    expect(proofLine, findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      _host(_worldFourSummary(), repairOutcomeConsumer: consumer),
    );
    await tester.pumpAndSettle();

    expect(proofLine, findsOneWidget);
    expect(consumer.sessionReceipt!.lines, beforeLines);
  });

  testWidgets('compact layout has no overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes, reinforced: true);
    await tester.pumpWidget(
      _host(
        _worldFourSummary(),
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('no blank CTA or template token appears', (tester) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pumpAndSettle();

    final button = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('act0_shell_block_summary_continue_cta')),
        matching: find.byType(Text),
      ),
    );
    expect(button.data, isNotNull);
    expect(button.data!.trim(), isNotEmpty);
    expect(button.data, isNot(contains('{')));
    expect(button.data, isNot(contains('null')));
    expect(button.data, isNot(contains('TODO')));
  });
}

Act0BlockCompletionSummaryV1 _worldFourSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 4',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 2,
    startXp: 188,
    endXp: 12,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 4,
    worldTitle: 'Bet Purpose / Price',
    nextWorldNumber: 5,
    nextWorldTitle: 'Board Awareness',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Act0BlockCompletionSummaryV1 _worldThreeSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 3',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 2,
    startXp: 188,
    endXp: 12,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 3,
    worldTitle: 'Position Thinking',
    nextWorldNumber: 4,
    nextWorldTitle: 'Bet Purpose / Price',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Act0BlockCompletionSummaryV1 _worldFiveSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 5',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 2,
    startXp: 188,
    endXp: 12,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 5,
    worldTitle: 'Board Awareness',
    nextWorldNumber: 6,
    nextWorldTitle: 'Range Thinking',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Widget _host(
  Act0BlockCompletionSummaryV1 summary, {
  Act0RepairOutcomeConsumerV1 repairOutcomeConsumer =
      const Act0RepairOutcomeConsumerV1(),
  VoidCallback? onContinue,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Act0BlockCompletionShellV1(
        summary: summary,
        repairOutcomeConsumer: repairOutcomeConsumer,
        onReplay: () {},
        onContinue: onContinue ?? () {},
        onBackToMap: () {},
      ),
    ),
  );
}

Act0RepairOutcomeProjectionV1 _repairOutcomes() {
  return const Act0RepairOutcomeProjectionV1(
    outcomes: <Act0RepairOutcomeV1>[
      Act0RepairOutcomeV1(
        sourceTaskId: 'actions_legal_context',
        repairTaskId: 'actions_check_drill',
        repairFocusKey: 'no_bet_yet',
        queueItemId: 'queue_item',
        targetWorldId: 'world_1',
        targetLessonId: 'fold_check_call_raise',
        targetTaskId: 'actions_check_drill',
        selectedChoiceId: 'check',
        correctChoiceId: 'check',
        isCorrect: true,
        outcomeState: act0RepairOutcomeStateCorrectV1,
        sequence: 1,
        sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
        sessionId: 'session_2',
      ),
    ],
  );
}

Act0FixProofProjectionV1 _bankedFixProof(
  Act0RepairOutcomeProjectionV1 outcomes, {
  bool reinforced = false,
}) {
  Act0LearningTransferMeasurementV1? transferMeasurement;
  if (reinforced) {
    transferMeasurement =
        Act0LearningTransferMeasurementV1.fromLearningEvidence(
          Act0LearningEvidenceHistoryV1(
            records: <Act0LearningEvidenceRecordV1>[
              Act0LearningEvidenceRecordV1(
                recordId: 'record_1',
                createdOrder: 1,
                worldId: 'world_1',
                lessonId: 'fold_check_call_raise',
                taskId: 'actions_legal_context',
                choiceId: 'fold',
                expectedChoiceId: 'check',
                isCorrect: false,
                errorType: 'missed_action_read',
                conceptFamilyId: 'no_bet_yet',
                repairFocusId: 'no_bet_yet',
                skillAtomId: 'action_read',
                decisionTimeBucket: 'under_3s',
                resultKind: 'incorrect',
                sessionId: 'session_1',
                recordedAtUtc: DateTime.utc(2026, 1, 1),
                reviewKind: Act0ReviewKindV1.initialAssessment,
              ),
              Act0LearningEvidenceRecordV1(
                recordId: 'record_2',
                createdOrder: 5,
                worldId: 'world_1',
                lessonId: 'fold_check_call_raise',
                taskId: 'actions_check_drill',
                choiceId: 'check',
                expectedChoiceId: 'check',
                isCorrect: true,
                errorType: 'none',
                conceptFamilyId: 'no_bet_yet',
                repairFocusId: 'no_bet_yet',
                skillAtomId: 'action_read',
                decisionTimeBucket: 'under_3s',
                resultKind: 'correct',
                sessionId: 'session_3',
                recordedAtUtc: DateTime.utc(2026, 1, 5),
                reviewKind: Act0ReviewKindV1.unseenTransfer,
              ),
            ],
          ),
        );
  }
  return Act0FixProofProjectionV1.fromSources(
    repairOutcomeProjection: outcomes,
    reviewResolutionReceiptHistory: const Act0ReviewResolutionReceiptHistoryV1(
      receipts: <Act0ReviewResolutionReceiptV1>[
        Act0ReviewResolutionReceiptV1(
          reviewItemId: 'review_queue_item',
          conceptFamilyId: 'no_bet_yet',
          sourceTaskId: 'actions_legal_context',
          sourceSessionId: 'session_1',
          reviewState: act0ReviewResolutionStateResolvedV1,
          resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
          repairOutcomeId: 'repair_outcome_v1|1|queue_item',
          resolvedAtOrder: 1,
        ),
      ],
    ),
    transferMeasurement: transferMeasurement,
  );
}
