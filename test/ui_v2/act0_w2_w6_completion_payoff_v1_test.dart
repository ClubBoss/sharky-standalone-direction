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

class _WorldCase {
  const _WorldCase({
    required this.worldNumber,
    required this.worldTitle,
    required this.nextWorldNumber,
    required this.nextWorldTitle,
    required this.learningLabel,
  });

  final int worldNumber;
  final String worldTitle;
  final int nextWorldNumber;
  final String nextWorldTitle;
  final String learningLabel;
}

// Real, live curriculum truth from lib/ui_v2/act0_shell/act0_shell_state_v1.dart
// (`_act0PreviewWorlds`), not invented. World 4 is intentionally absent here:
// it now receives the stronger, dedicated W4->W5 band-transition milestone
// instead of this ordinary card (see
// test/ui_v2/act0_w4_w5_band_transition_milestone_v1_test.dart).
const _worldCases = <_WorldCase>[
  _WorldCase(
    worldNumber: 2,
    worldTitle: 'Hand Discipline',
    nextWorldNumber: 3,
    nextWorldTitle: 'Position Thinking',
    learningLabel:
        'You learned how to separate playable hands from tempting ones.',
  ),
  _WorldCase(
    worldNumber: 3,
    worldTitle: 'Position Thinking',
    nextWorldNumber: 4,
    nextWorldTitle: 'Bet Purpose / Price',
    learningLabel: 'You learned how position changes what a hand can do.',
  ),
  _WorldCase(
    worldNumber: 5,
    worldTitle: 'Board Awareness',
    nextWorldNumber: 6,
    nextWorldTitle: 'Range Thinking',
    learningLabel:
        'You learned how to read board texture and let streets change '
        'your plan.',
  ),
  _WorldCase(
    worldNumber: 6,
    worldTitle: 'Range Thinking',
    nextWorldNumber: 7,
    nextWorldTitle: 'Visible Cards Change Ranges',
    learningLabel:
        'You learned how to group hands into ranges and compare who is '
        'ahead.',
  ),
  _WorldCase(
    worldNumber: 7,
    worldTitle: 'Visible Cards Change Ranges',
    nextWorldNumber: 8,
    nextWorldTitle: 'Stack Depth And Risk',
    learningLabel:
        'You learned how visible cards remove combinations and narrow '
        'ranges.',
  ),
  _WorldCase(
    worldNumber: 8,
    worldTitle: 'Stack Depth And Risk',
    nextWorldNumber: 9,
    nextWorldTitle: 'Tournament Pressure',
    learningLabel:
        'You learned how effective stack depth changes commitment and risk.',
  ),
  _WorldCase(
    worldNumber: 9,
    worldTitle: 'Tournament Pressure',
    nextWorldNumber: 10,
    nextWorldTitle: 'Player Adjustment',
    learningLabel:
        'You learned how survival pressure, ladder pressure, and risk '
        'premium change decisions.',
  ),
];

void main() {
  for (final worldCase in _worldCases) {
    group('World ${worldCase.worldNumber} completion payoff', () {
      testWidgets('incomplete world does not show payoff', (tester) async {
        await tester.pumpWidget(
          _host(
            Act0BlockCompletionSummaryV1(
              lessonTitle: 'A lesson in this world',
              xpEarned: 20,
              errorCount: 0,
              taskCount: 4,
              correctCount: 4,
              startLevel: 1,
              endLevel: 1,
              startXp: 40,
              endXp: 60,
              xpTarget: 200,
              nextLessonTitle: 'Next lesson in the same world',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('act0_shell_world_completion_payoff')),
          findsNothing,
        );
      });

      testWidgets('completed world shows correct identity, milestone role, and '
          'learning takeaway', (tester) async {
        await tester.pumpWidget(_host(_summaryFor(worldCase)));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('act0_shell_world_completion_payoff')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<Text>(
                find.byKey(const Key('act0_shell_block_summary_title')),
              )
              .data,
          'World ${worldCase.worldNumber} complete',
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
            matching: find.byKey(const Key('act0_proof_icon_v1_milestone')),
          ),
          findsOneWidget,
        );
        expect(find.text(worldCase.learningLabel), findsOneWidget);
        expect(find.text('Next: ${worldCase.nextWorldTitle}'), findsOneWidget);
      });

      testWidgets('no-proof completion shows the safe fallback', (
        tester,
      ) async {
        await tester.pumpWidget(_host(_summaryFor(worldCase)));
        await tester.pumpAndSettle();

        expect(
          find.text('Repair proof banks the next time you fix one.'),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
            matching: find.byKey(
              const Key('act0_proof_icon_v1_repairCompleted'),
            ),
          ),
          findsNothing,
        );
      });

      testWidgets('banked proof maps to repairCompleted', (tester) async {
        final outcomes = _repairOutcomes();
        final fixProof = _bankedFixProof(outcomes);

        await tester.pumpWidget(
          _host(
            _summaryFor(worldCase),
            repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
              outcomes,
              fixProofProjection: fixProof,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
            matching: find.byKey(
              const Key('act0_proof_icon_v1_repairCompleted'),
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
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
            _summaryFor(worldCase),
            repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
              outcomes,
              fixProofProjection: fixProof,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
            matching: find.byKey(const Key('act0_proof_icon_v1_reinforced')),
          ),
          findsOneWidget,
        );
      });

      testWidgets('activity-only fallback earns no proof icon', (tester) async {
        final outcomes = _repairOutcomes();

        await tester.pumpWidget(
          _host(
            _summaryFor(worldCase),
            repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
              outcomes,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
            matching: find.byType(Act0ProofIconV1),
          ),
          findsOneWidget, // the milestone icon only, no proof icon
        );
        expect(
          find.text('Repair proof banks the next time you fix one.'),
          findsOneWidget,
        );
      });

      testWidgets('next-world preview uses route truth, not a fixed value', (
        tester,
      ) async {
        final summary = Act0BlockCompletionSummaryV1(
          lessonTitle: 'A lesson in this world',
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
          worldNumber: worldCase.worldNumber,
          worldTitle: worldCase.worldTitle,
          nextWorldNumber: worldCase.nextWorldNumber,
          nextWorldTitle: 'A Different Next World',
          perfectClearCount: 12,
          completedClearCount: 12,
        );

        await tester.pumpWidget(_host(summary));
        await tester.pumpAndSettle();

        expect(find.text('Next: A Different Next World'), findsOneWidget);
        expect(find.text('Next: ${worldCase.nextWorldTitle}'), findsNothing);
      });

      testWidgets('primary CTA routes to the valid next destination', (
        tester,
      ) async {
        var continued = 0;
        await tester.pumpWidget(
          _host(
            _summaryFor(worldCase),
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
          _host(_summaryFor(worldCase), repairOutcomeConsumer: consumer),
        );
        await tester.pumpAndSettle();
        final proofLine = find.descendant(
          of: find.byKey(const Key('act0_shell_world_completion_payoff')),
          matching: find.text('1 repair completed'),
        );
        expect(proofLine, findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(
          _host(_summaryFor(worldCase), repairOutcomeConsumer: consumer),
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
            _summaryFor(worldCase),
            repairOutcomeConsumer: Act0RepairOutcomeConsumerV1.fromProjection(
              outcomes,
              fixProofProjection: fixProof,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('no XP/level/mastery/percentage language appears', (
        tester,
      ) async {
        final outcomes = _repairOutcomes();
        final fixProof = _bankedFixProof(outcomes, reinforced: true);
        await tester.pumpWidget(
          _host(
            _summaryFor(worldCase),
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
                of: find.byKey(const Key('act0_shell_world_completion_payoff')),
                matching: find.byType(Text),
              ),
            )
            .map(
              (widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '',
            )
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

      testWidgets('no retired W8 or W9 identity copy appears', (tester) async {
        await tester.pumpWidget(_host(_summaryFor(worldCase)));
        await tester.pumpAndSettle();

        final text = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const Key('act0_shell_world_completion_payoff')),
                matching: find.byType(Text),
              ),
            )
            .map(
              (widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '',
            )
            .join(' ')
            .toLowerCase();

        for (final forbidden in <String>[
          'full range mastery',
          'solver',
          'draw improvement',
          'flush draw',
          'pot odds',
          'price-to-call',
          'complete tournament mastery',
          'spr mastery',
          'stack-off strategy',
        ]) {
          expect(text, isNot(contains(forbidden)));
        }
      });

      testWidgets('no blank CTA or template token appears', (tester) async {
        await tester.pumpWidget(_host(_summaryFor(worldCase)));
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
    });
  }

  testWidgets(
    'World 4 no longer uses the ordinary card; it is now owned by the '
    'dedicated W4->W5 band-transition milestone',
    (tester) async {
      const world4Case = _WorldCase(
        worldNumber: 4,
        worldTitle: 'Bet Purpose / Price',
        nextWorldNumber: 5,
        nextWorldTitle: 'Board Awareness',
        learningLabel:
            "You learned why a bet happens and what price it's asking you "
            'to risk.',
      );

      await tester.pumpWidget(_host(_summaryFor(world4Case)));
      await tester.pumpAndSettle();

      // World 4 now renders the dedicated band-transition card, not the
      // ordinary World 2-6 card. See
      // test/ui_v2/act0_w4_w5_band_transition_milestone_v1_test.dart for the
      // full band-transition contract.
      expect(
        find.byKey(const Key('act0_shell_world_completion_payoff')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_band_transition_completion_payoff')),
        findsOneWidget,
      );
    },
  );

  testWidgets('World 6 completion does not claim Volume I or W12 completion', (
    tester,
  ) async {
    const world6Case = _WorldCase(
      worldNumber: 6,
      worldTitle: 'Range Thinking',
      nextWorldNumber: 7,
      nextWorldTitle: 'Visible Cards Change Ranges',
      learningLabel:
          'You learned how to group hands into ranges and compare who is '
          'ahead.',
    );

    await tester.pumpWidget(_host(_summaryFor(world6Case)));
    await tester.pumpAndSettle();

    final text = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('act0_shell_world_completion_payoff')),
            matching: find.byType(Text),
          ),
        )
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
        .join(' ')
        .toLowerCase();

    for (final forbidden in <String>[
      'volume i',
      'volume 1',
      'w12',
      '12 worlds',
      'volume complete',
    ]) {
      expect(text, isNot(contains(forbidden)));
    }
  });

  testWidgets('World 10+ remains outside ordinary completion payoff', (
    tester,
  ) async {
    const summary = Act0BlockCompletionSummaryV1(
      lessonTitle: 'A lesson in world 10',
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
      worldNumber: 10,
      worldTitle: 'Player Adjustment',
      nextWorldNumber: 11,
      nextWorldTitle: 'Future World',
      perfectClearCount: 12,
      completedClearCount: 12,
    );

    expect(summary.hasWorldOneCompletionPayoff, isFalse);
    expect(summary.hasWorldCompletionPayoff, isFalse);

    await tester.pumpWidget(_host(summary));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('act0_shell_world_completion_payoff')),
      findsNothing,
    );
    expect(find.byKey(const Key('act0_proof_icon_v1_milestone')), findsNothing);
  });
}

Act0BlockCompletionSummaryV1 _summaryFor(_WorldCase worldCase) {
  return Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in this world',
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
    worldNumber: worldCase.worldNumber,
    worldTitle: worldCase.worldTitle,
    nextWorldNumber: worldCase.nextWorldNumber,
    nextWorldTitle: worldCase.nextWorldTitle,
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
