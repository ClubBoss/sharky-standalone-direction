import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_proof_icon_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _worldOneCompleteSummary = Act0BlockCompletionSummaryV1(
  lessonTitle: 'Showdown winning',
  xpEarned: 24,
  errorCount: 0,
  taskCount: 4,
  correctCount: 4,
  startLevel: 1,
  endLevel: 2,
  startXp: 188,
  endXp: 12,
  xpTarget: 200,
  skillGains: <Act0SkillGainV1>[
    Act0SkillGainV1(label: 'Hand reading', gain: 8, source: 'Poker from Zero'),
  ],
  milestoneTier: Act0ProgressMilestoneTierV1.world,
  worldNumber: 1,
  worldTitle: 'Poker from Zero',
  nextWorldNumber: 2,
  nextWorldTitle: 'Hand Discipline',
  perfectClearCount: 12,
  completedClearCount: 12,
);

void main() {
  testWidgets('incomplete W1 does not show completion payoff', (tester) async {
    await tester.pumpWidget(
      _host(
        const Act0BlockCompletionSummaryV1(
          lessonTitle: 'Action words',
          xpEarned: 20,
          errorCount: 0,
          taskCount: 4,
          correctCount: 4,
          startLevel: 1,
          endLevel: 1,
          startXp: 40,
          endXp: 60,
          xpTarget: 200,
          nextLessonTitle: 'Blinds & action order',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world1_completion_payoff')),
      findsNothing,
    );
    expect(find.text('Next: Hand Discipline'), findsNothing);
    expect(find.text('Open next lesson'), findsOneWidget);
  });

  testWidgets('completed W1 shows milestone role and full copy hierarchy', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldOneCompleteSummary));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world1_completion_payoff')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_proof_icon_v1_milestone')),
      findsOneWidget,
    );
    expect(find.text('You banked the first table read.'), findsOneWidget);
    expect(
      find.text('You learned how to read the table before acting.'),
      findsOneWidget,
    );
    expect(find.text('Next: Hand Discipline'), findsOneWidget);
    expect(
      find.text(
        'World 2 starts with a simple question: which hands deserve action?',
      ),
      findsOneWidget,
    );
    expect(find.text('Open next world'), findsOneWidget);
    expect(
      tester
          .getTopLeft(
            find.byKey(const Key('act0_shell_block_summary_continue_cta')),
          )
          .dy,
      lessThan(
        tester
            .getTopLeft(
              find.byKey(const Key('act0_shell_block_summary_xp_progress')),
            )
            .dy,
      ),
    );
    expect(find.textContaining('mastered'), findsNothing);
    expect(find.textContaining('36-world'), findsNothing);
    expect(find.textContaining('36 worlds'), findsNothing);
    expect(find.textContaining('pro-level'), findsNothing);
  });

  testWidgets('no-proof completion shows the safe fallback line', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldOneCompleteSummary));
    await tester.pumpAndSettle();

    expect(
      find.text('Repair result saves the next time you fix one.'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.byKey(const Key('act0_proof_icon_v1_reinforced')),
      ),
      findsNothing,
    );
  });

  testWidgets('completed fix shows repairCompleted proof role', (tester) async {
    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes);

    await tester.pumpWidget(
      _host(
        _worldOneCompleteSummary,
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.text('1 repair completed'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('later-supported fix shows reinforced proof role', (
    tester,
  ) async {
    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes, reinforced: true);

    await tester.pumpWidget(
      _host(
        _worldOneCompleteSummary,
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.byKey(const Key('act0_proof_icon_v1_reinforced')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsNothing,
    );
  });

  testWidgets('ordinary activity count alone does not create earned proof', (
    tester,
  ) async {
    final outcomes = _repairOutcomes();

    await tester.pumpWidget(
      _host(
        _worldOneCompleteSummary,
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.byKey(const Key('act0_proof_icon_v1_repairCompleted')),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.text('Good fixes: 1'),
      ),
      findsNothing,
    );
    expect(
      find.text('Repair result saves the next time you fix one.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'next-world preview uses the summary route data, not a fixed value',
    (tester) async {
      const summary = Act0BlockCompletionSummaryV1(
        lessonTitle: 'Showdown winning',
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
        worldNumber: 1,
        worldTitle: 'Poker from Zero',
        nextWorldNumber: 2,
        nextWorldTitle: 'A Different Next World',
        perfectClearCount: 12,
        completedClearCount: 12,
      );
      await tester.pumpWidget(_host(summary));
      await tester.pumpAndSettle();

      expect(find.text('Next: A Different Next World'), findsOneWidget);
      expect(find.text('Next: Hand Discipline'), findsNothing);
    },
  );

  testWidgets('primary CTA routes to the valid next destination', (
    tester,
  ) async {
    var continued = 0;
    await tester.pumpWidget(
      _host(
        _worldOneCompleteSummary,
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

  testWidgets(
    'reopening completion is idempotent and writes no duplicate proof',
    (tester) async {
      final outcomes = _repairOutcomes();
      final fixProof = _bankedFixProof(outcomes);
      final consumer = Act0RepairOutcomeConsumerV1.fromProjection(
        outcomes,
        fixProofProjection: fixProof,
      );
      final beforeLines = List<String>.from(consumer.sessionReceipt!.lines);

      await tester.pumpWidget(
        _host(_worldOneCompleteSummary, repairOutcomeConsumer: consumer),
      );
      await tester.pumpAndSettle();
      final worldOneProofLine = find.descendant(
        of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
        matching: find.text('1 repair completed'),
      );
      expect(worldOneProofLine, findsOneWidget);

      // Simulate reopening the same completion state.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        _host(_worldOneCompleteSummary, repairOutcomeConsumer: consumer),
      );
      await tester.pumpAndSettle();

      expect(worldOneProofLine, findsOneWidget);
      expect(consumer.sessionReceipt!.lines, beforeLines);
    },
  );

  testWidgets('no XP, level, mastery, or percentage language appears', (
    tester,
  ) async {
    final outcomes = _repairOutcomes();
    final fixProof = _bankedFixProof(outcomes, reinforced: true);
    await tester.pumpWidget(
      _host(
        _worldOneCompleteSummary,
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final text = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world1_completion_payoff')),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'xp',
      'level',
      'mastered',
      'mastery',
      '%',
      'rank',
      'rarity',
      'coins',
    ]) {
      expect(text, isNot(contains(forbidden)));
    }
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
        _worldOneCompleteSummary,
        repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
          outcomes,
          fixProofProjection: fixProof,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('World 8 completion uses the ordinary W2-W12 payoff card', (
    tester,
  ) async {
    // World 8 is now inside the accepted W2-W12 payoff coverage. World 1
    // still keeps its dedicated payoff card, while W8 uses the ordinary
    // world-completion payoff card.
    const otherWorldSummary = Act0BlockCompletionSummaryV1(
      lessonTitle: 'Hand ranges',
      xpEarned: 24,
      errorCount: 0,
      taskCount: 4,
      correctCount: 4,
      startLevel: 2,
      endLevel: 3,
      startXp: 188,
      endXp: 12,
      xpTarget: 200,
      milestoneTier: Act0ProgressMilestoneTierV1.world,
      worldNumber: 8,
      worldTitle: 'Advanced Reads',
      nextWorldNumber: 9,
      nextWorldTitle: 'Range Construction',
      perfectClearCount: 12,
      completedClearCount: 12,
    );

    expect(otherWorldSummary.hasWorldOneCompletionPayoff, isFalse);
    expect(otherWorldSummary.hasWorldCompletionPayoff, isTrue);

    await tester.pumpWidget(_host(otherWorldSummary));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world1_completion_payoff')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('act0_shell_world_completion_payoff')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('act0_shell_block_summary_title')))
          .data,
      'World 8 complete',
    );
    expect(find.text('Open next world'), findsOneWidget);
  });

  testWidgets('no blank CTA or template token appears', (tester) async {
    await tester.pumpWidget(_host(_worldOneCompleteSummary));
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

  testWidgets('W1 payoff does not render for unlocked next lesson only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const Act0BlockCompletionSummaryV1(
          lessonTitle: 'Action words',
          xpEarned: 20,
          errorCount: 0,
          taskCount: 4,
          correctCount: 4,
          startLevel: 1,
          endLevel: 1,
          startXp: 40,
          endXp: 60,
          xpTarget: 200,
          nextLessonTitle: 'Blinds & action order',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world1_completion_payoff')),
      findsNothing,
    );
    expect(find.text('First table read banked.'), findsNothing);
    expect(find.text('Next: Hand Discipline'), findsNothing);
    expect(find.text('Open next lesson'), findsOneWidget);
  });
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
                recordedAtUtc: DateTime.utc(2025, 12, 30),
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
                recordedAtUtc: DateTime.utc(2026, 1, 1),
                reviewKind: Act0ReviewKindV1.alternateSameSignal,
              ),
              Act0LearningEvidenceRecordV1(
                recordId: 'record_3',
                createdOrder: 6,
                worldId: 'world_1',
                lessonId: 'fold_check_call_raise',
                taskId: 'actions_call_drill',
                choiceId: 'call',
                expectedChoiceId: 'call',
                isCorrect: true,
                errorType: 'none',
                conceptFamilyId: 'no_bet_yet',
                repairFocusId: 'no_bet_yet',
                skillAtomId: 'action_read',
                decisionTimeBucket: 'under_3s',
                resultKind: 'correct',
                sessionId: 'session_4',
                recordedAtUtc: DateTime.utc(2026, 1, 1, 12),
                reviewKind: Act0ReviewKindV1.alternateSameSignal,
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
