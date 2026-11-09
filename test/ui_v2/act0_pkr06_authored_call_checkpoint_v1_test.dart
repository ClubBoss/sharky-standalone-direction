import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_pkr06_authored_call_checkpoint_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

// PRIVATE SOURCE candidate. Runtime NOT_RUN. No mock proof or catalog mutation.
Act0LessonTaskV1 _task() => act0Pkr06AuthoredCallCheckpointV1(
  lessonId: 'private_authored_call',
  lessonTitle: 'Private call-price exercise',
  beatIndex: 0,
  beatCount: 1,
  rewardXp: 0,
  returnTarget: 'learn',
  nextLessonId: null,
);

Act0RunnerOptionV1 _correct(Act0LessonTaskV1 task) =>
    task.runner.options.singleWhere(act0RunnerOptionIsAuthoredCorrectV1);

// Negative controls are confined to tests. They never overwrite authored facts.
Act0RunnerOptionV1 _overCapRaise() => const Act0RunnerOptionV1(
  id: 'test_only_over_cap',
  label: 'Raise',
  amountLabel: '101 BB',
  isCorrect: true,
  quality: Act0FeedbackQualityV1.correct,
  preferredLabel: '',
  feedbackTitle: '',
  feedbackReason: '',
);

Act0SeatStateV1 _withoutStack(Act0SeatStateV1 seat) => Act0SeatStateV1(
  seatId: seat.seatId,
  seatLabel: seat.seatLabel,
  displayName: seat.displayName,
  isHero: seat.isHero,
  isDealerButton: seat.isDealerButton,
  isSmallBlind: seat.isSmallBlind,
  isBigBlind: seat.isBigBlind,
  blindAmountLabel: seat.blindAmountLabel,
  isActive: seat.isActive,
  isTarget: seat.isTarget,
  isInHand: seat.isInHand,
  isFolded: seat.isFolded,
  hasActed: seat.hasActed,
  isLastAggressor: seat.isLastAggressor,
  isOccupied: seat.isOccupied,
  holeCards: seat.holeCards,
  cardsVisibleMode: seat.cardsVisibleMode,
  currentBetLabel: seat.currentBetLabel,
  bet: seat.bet,
);

void main() {
  const basis = act0Pkr06AuthoredCallBasisV1;
  const table = act0Pkr06AuthoredCallTableV1;

  test('new real task asks price only and authors 2 additional, 3 total', () {
    final task = _task();
    expect(basis.provenance, 'NEW_AUTHORING_2026_11_08');
    expect(task.taskId, 'pkr06_authored_call_price_checkpoint');
    expect(task.taskFamily, Act0TaskFamilyV1.counting);
    expect(task.phase, Act0LessonPhaseV1.drill);
    expect(task.rewardXp, 0); // Private harness, not a reward policy decision.
    expect(
      task.runner.question,
      'If BB calls, how many more BB must be added?',
    );
    expect(task.runner.options.map((o) => o.amountLabel), [
      '1 BB',
      '2 BB',
      '3 BB',
    ]);
    expect(_correct(task).amountLabel, '2 BB');
    expect(_correct(task).label, 'Call');
    expect(_correct(task).preferredLabel, 'Add 2 BB (3 BB total)');
    expect(basis.expectedAdditionalCallBb, 2);
    expect(basis.resultingBbCommitmentBb, 3);
    expect(task.runner.feedbackReason, contains('not hand strength'));
    expect(task.runner.options.every((o) => o.seatId == null), isTrue);
  });

  test('explicit new budgets conserve chips at the pre-action snapshot', () {
    expect(basis.anteBb, 0);
    expect(basis.startingBudgetBb, {
      'utg': 100,
      'hj': 100,
      'co': 100,
      'btn': 100,
      'sb': 100,
      'bb': 100,
    });
    final sb = table.seats.singleWhere((s) => s.seatId == 'sb');
    final bb = table.heroSeat;
    expect(sb.stackLabel, '97 BB');
    expect(sb.currentBetLabel, '3 BB');
    expect(bb.stackLabel, '99 BB');
    expect(bb.currentBetLabel, '1 BB');
    expect(97 + basis.sbRaiseToBb, basis.startingBudgetBb['sb']);
    expect(99 + basis.bbAlreadyCommittedBb, basis.startingBudgetBb['bb']);
    expect(4 * 100 + 97 + 99 + basis.snapshotPotBb, 600);
    expect(basis.snapshotPotBb, 4);
    expect(table.potLabel, 'Pot 4 BB');
    expect(table.toCallLabel, 'To call 2 BB');
    expect(99 - basis.expectedAdditionalCallBb, 97);
  });

  test('history stops after SB raise, with BB still owing a decision', () {
    expect(table.scope, Act0TableScopeV1.playedHand);
    expect(table.tableFormat, Act0TableFormatV1.sixMax);
    expect(table.playerCount, 6);
    expect(table.seats.map((s) => s.seatLabel), table.canonicalSeatOrder);
    expect(table.actionTrail.map((a) => a.label), [
      'SB posts 0.5 BB',
      'BB posts 1 BB',
      'UTG folds',
      'HJ folds',
      'CO folds',
      'BTN folds',
      'SB raises to 3 BB',
    ]);
    expect(table.actionTrail.every((a) => !a.isNote), isTrue);
    expect(table.activeSeatId, basis.pendingActorSeatId);
    expect(table.heroSeatId, 'bb');
    expect(table.heroSeat.isActive, isTrue);
    expect(
      table.heroSeat.hasActed,
      isFalse,
    ); // Posting is not a voluntary turn.
    for (final id in basis.zeroContributionFoldedSeatIds) {
      final seat = table.seats.singleWhere((s) => s.seatId == id);
      expect(seat.isFolded, isTrue);
      expect(seat.isInHand, isFalse);
      expect(seat.stackLabel, '100 BB');
      expect(seat.currentBetLabel, '0 BB');
      expect(seat.bet, isNull);
    }
  });

  test(
    'unknown cards stay absent and no later street or outcome is invented',
    () {
      expect(table.heroCards, isEmpty);
      expect(table.boardCards, isEmpty);
      expect(table.streetLabel, 'Preflop');
      for (final seat in table.seats) {
        expect(seat.holeCards, isEmpty);
        expect(
          seat.cardsVisibleMode,
          seat.isFolded
              ? Act0CardsVisibleModeV1.none
              : Act0CardsVisibleModeV1.faceDown,
        );
      }
      expect(
        table.actionTrail.any(
          (a) => RegExp(
            r'call|flop:|turn|river|win|award|payout|showdown',
            caseSensitive: false,
          ).hasMatch(a.label),
        ),
        isFalse,
      );
    },
  );

  test(
    'unmocked price and order route agrees with the authored call amount',
    () {
      final price = act0BettingPriceForOptionV1(table, _correct(_task()));
      expect(
        act0BettingRoundOrderTruthForTableV1(table),
        Act0BettingRoundOrderTruthV1.consistent,
      );
      expect(price.truth, Act0BettingPriceTruthV1.consistent);
      expect(price.reason, 'numeric_action_consistent');
      expect(price.callCostBb, 2);
      expect(price.amountToMatchBb, 2);
      expect(price.actorCommittedBb, 1);
      expect(price.minimumRaiseToBb, 5);
      expect(
        act0BettingPriceBlocksAuthoredSuccessV1(table, _correct(_task())),
        isFalse,
      );
      // Numerical/order consistency is not whole-hand or consumer admission.
    },
  );

  test('same unchanged basis rejects raise-to 101 above the 100 BB budget', () {
    final negative = _overCapRaise();
    final price = act0BettingPriceForOptionV1(table, negative);
    expect(101 - basis.bbAlreadyCommittedBb, 100); // Only 99 remain.
    expect(price.truth, Act0BettingPriceTruthV1.contradiction);
    expect(price.reason, 'wager_exceeds_stack');
    expect(act0BettingPriceBlocksAuthoredSuccessV1(table, negative), isTrue);
    expect(table.heroSeat.stackLabel, '99 BB');
    expect(_task().runner.options.any((o) => o.id == negative.id), isFalse);
  });

  test(
    '1 and 3 additional BB are wrong call amounts, not strategic choices',
    () {
      for (final option in _task().runner.options.where((o) => !o.isCorrect)) {
        final price = act0BettingPriceForOptionV1(table, option);
        expect(price.truth, Act0BettingPriceTruthV1.contradiction);
        expect(price.reason, 'call_cost_mismatch');
        // Intended wrong answers remain teachable, not authored-success errors.
        expect(act0BettingPriceBlocksAuthoredSuccessV1(table, option), isFalse);
      }
    },
  );

  test(
    'wrong actor and ambiguous participant cannot establish the positive',
    () {
      final option = _correct(_task());
      final wrongActor = act0BettingPriceForOptionV1(
        table.copyWith(activeSeatId: 'sb'),
        option,
      );
      expect(wrongActor.truth, Act0BettingPriceTruthV1.unproved);
      expect(wrongActor.reason, 'not_hero_action');
      final duplicate = act0BettingPriceForOptionV1(
        table.copyWith(seats: [...table.seats.take(5), table.seats.first]),
        option,
      );
      expect(duplicate.truth, Act0BettingPriceTruthV1.unproved);
      expect(duplicate.reason, 'ambiguous_participants');
    },
  );

  test('missing actor stack remains unknown instead of becoming zero', () {
    final unknown = table.copyWith(
      seats: [
        for (final seat in table.seats)
          seat.isHero ? _withoutStack(seat) : seat,
      ],
    );
    final price = act0BettingPriceForOptionV1(unknown, _correct(_task()));
    expect(price.truth, Act0BettingPriceTruthV1.unproved);
    expect(price.reason, 'missing_actor_stack');
    expect(price.callCostBb, isNull);
    expect(price.amountToMatchBb, 2);
  });

  test('snapshot time mismatch is not accepted as the preflop positive', () {
    final price = act0BettingPriceForOptionV1(
      table.copyWith(streetLabel: 'Flop'),
      _correct(_task()),
    );
    expect(price.truth, Act0BettingPriceTruthV1.unproved);
    expect(price.reason, 'unrecorded_current_street');
  });

  test('honest grammar still has no choreography plan at the pinned base', () {
    // posts and raise-to are valid source facts, not rewritten to fit a parser.
    // This is a current missing seam, NOT proof of callback safety.
    expect(act0TableChoreographyPlanForTableV1(table), isNull);
  });
}
