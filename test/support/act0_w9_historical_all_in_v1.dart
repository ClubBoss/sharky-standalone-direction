import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// The previous W9 trail is still the fixture for the missing-stack and
/// terminal-actor falsifiers. The live lesson now owns a sized raise and
/// starting stacks for both players.
Act0TableStateV1 act0W9HistoricalAllInV1() {
  final current = Act0ShellStateV1.sample
      .worldById('world_9')
      .lessons
      .expand((lesson) => lesson.taskList)
      .singleWhere((task) => task.taskId == 'w9_bubble_table_risk_transfer')
      .runner
      .table;
  final ledger = current.handContributions!;
  return current.copyWith(
    clearDecisionSeatId: true,
    toCallLabel: '',
    actionTrail: [
      ...current.actionTrail.take(current.actionTrail.length - 1),
      const Act0ActionTrailItemV1(label: 'BB all-in 18 BB'),
    ],
    handContributions: Act0HandContributionsV1(
      throughStreet: ledger.throughStreet,
      entries: ledger.entries,
      startingStackBbBySeat: const {'bb': 18},
    ),
    seats: [
      for (final seat in current.seats)
        Act0SeatStateV1(
          seatId: seat.seatId,
          seatLabel: seat.seatLabel,
          displayName: seat.displayName,
          isHero: seat.isHero,
          isDealerButton: seat.isDealerButton,
          isSmallBlind: seat.isSmallBlind,
          isBigBlind: seat.isBigBlind,
          isActive: seat.isActive,
          isInHand: seat.isInHand,
          isFolded: seat.isFolded,
          hasActed: seat.hasActed,
          isLastAggressor: seat.isLastAggressor,
          holeCards: seat.holeCards,
          cardsVisibleMode: seat.cardsVisibleMode,
          bet: seat.seatId == 'bb'
              ? const Act0SeatBetStateV1(
                  kind: Act0SeatBetKindV1.allIn,
                  label: 'BB',
                  amountLabel: '18 BB',
                )
              : seat.bet,
          currentBetLabel: seat.currentBetLabel,
        ),
    ],
  );
}
