import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';

const _terminalKey = Key('act0_shell_terminal_completion_payoff');
const _ordinaryKey = Key('act0_shell_world_completion_payoff');
const _bandTransitionKey = Key('act0_shell_band_transition_completion_payoff');
const _emphasisRingKey = Key('act0_proof_icon_v1_milestone_emphasis_ring');

void main() {
  testWidgets('incomplete World 12 does not show the terminal card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Act0BlockCompletionSummaryV1(
          lessonTitle: 'A lesson in World 12',
          xpEarned: 20,
          errorCount: 0,
          taskCount: 4,
          correctCount: 4,
          startLevel: 1,
          endLevel: 1,
          startXp: 40,
          endXp: 60,
          xpTarget: 200,
          nextLessonTitle: 'Next lesson in World 12',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(_terminalKey), findsNothing);
  });

  testWidgets('completed World 12 shows the Volume I complete identity', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldTwelveSummary()));
    await tester.pumpAndSettle();

    expect(find.byKey(_terminalKey), findsOneWidget);
    expect(find.byKey(_ordinaryKey), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(_terminalKey),
        matching: find.text('Volume I complete.'),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'You learned how to judge process, reset tilt, and keep discipline '
        'before deeper strategy.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'World 12 uses the stronger emphasized milestone seal; ordinary worlds '
    'do not',
    (tester) async {
      await tester.pumpWidget(_host(_worldTwelveSummary()));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(_terminalKey),
          matching: find.byKey(_emphasisRingKey),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(_host(_worldElevenSummary()));
      await tester.pumpAndSettle();
      expect(find.byKey(_terminalKey), findsNothing);
      expect(find.byKey(_emphasisRingKey), findsNothing);
    },
  );

  testWidgets('World 12 next-step label reads Next: Volume I review', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldTwelveSummary()));
    await tester.pumpAndSettle();

    expect(find.text('Next: Volume I review'), findsOneWidget);
    expect(
      find.text(
        'Volume I review brings the route together while later worlds '
        'stay locked.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('terminal copy is claim-safe and does not activate W13+', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldTwelveSummary()));
    await tester.pumpAndSettle();

    final text = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(_terminalKey),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'mastered',
      'mastered poker',
      'ready for real money',
      'advanced player',
      'ai coach proved',
      'world 13',
      'w13',
      'volume ii',
      'intermediate',
      'level 12',
      'skill increased',
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
    await tester.pumpWidget(_host(_worldTwelveSummary()));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(_terminalKey),
        matching: find.text('Repair result saves the next time you fix one.'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_terminalKey),
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
        _worldTwelveSummary(),
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(_terminalKey),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_terminalKey),
        matching: find.text('1 repair completed'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'terminal card requires exact World 12 route truth; World 13 remains '
    'blocked from any completion payoff',
    (tester) async {
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
        worldTitle: 'Future Locked World',
        nextWorldNumber: 14,
        nextWorldTitle: 'Future World',
        perfectClearCount: 12,
        completedClearCount: 12,
      );

      expect(summary.hasTerminalCompletionPayoff, isFalse);
      expect(summary.hasWorldCompletionPayoff, isFalse);
      expect(summary.hasBandTransitionPayoff, isFalse);

      await tester.pumpWidget(_host(summary));
      await tester.pumpAndSettle();

      expect(find.byKey(_terminalKey), findsNothing);
      expect(find.byKey(_ordinaryKey), findsNothing);
      expect(find.byKey(_bandTransitionKey), findsNothing);
    },
  );

  testWidgets('primary CTA routes to the valid next destination', (
    tester,
  ) async {
    var continued = 0;
    await tester.pumpWidget(
      _host(
        _worldTwelveSummary(),
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

  testWidgets('compact layout has no overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes, reinforced: true);
    await tester.pumpWidget(
      _host(
        _worldTwelveSummary(),
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
    await tester.pumpWidget(_host(_worldTwelveSummary()));
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

Act0BlockCompletionSummaryV1 _worldTwelveSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 12',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 11,
    endLevel: 12,
    startXp: 176,
    endXp: 0,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 12,
    worldTitle: 'Mindset Bridge',
    nextWorldTitle: 'Volume I review',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Act0BlockCompletionSummaryV1 _worldElevenSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 11',
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
    worldNumber: 11,
    worldTitle: 'Real Play Transfer',
    nextWorldNumber: 12,
    nextWorldTitle: 'Mindset Bridge',
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
    transferMeasurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
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
