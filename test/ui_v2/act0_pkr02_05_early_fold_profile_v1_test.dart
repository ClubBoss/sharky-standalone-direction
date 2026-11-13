import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Independent guard-only falsifier. No source, grades or state are persisted.
Act0SeatStateV1 change(
  Act0SeatStateV1 s, {
  String? seatLabel,
  bool? occupied,
  bool? inHand,
  bool? folded,
  String? stack,
  String? currentBet,
  String? blind,
}) => Act0SeatStateV1(
  seatId: s.seatId,
  seatLabel: seatLabel ?? s.seatLabel,
  displayName: s.displayName,
  isHero: s.isHero,
  isDealerButton: s.isDealerButton,
  isSmallBlind: s.isSmallBlind,
  isBigBlind: s.isBigBlind,
  blindAmountLabel: blind ?? s.blindAmountLabel,
  isActive: s.isActive,
  isTarget: s.isTarget,
  isInHand: inHand ?? s.isInHand,
  isFolded: folded ?? s.isFolded,
  hasActed: s.hasActed,
  isLastAggressor: s.isLastAggressor,
  isOccupied: occupied ?? s.isOccupied,
  stackLabel: stack ?? s.stackLabel,
  holeCards: s.holeCards,
  cardsVisibleMode: s.cardsVisibleMode,
  currentBetLabel: currentBet ?? s.currentBetLabel,
  bet: s.bet,
);

void main() {
  test(
    'exact early-fold conceptual admission rejects material scene mutations',
    () {
      final ids = <String>{
        'fold_discipline_early_fold',
        'apply_utg_fold',
        'position_checkpoint_position_checkpoint_early_fold',
      };
      final tasks = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .where((t) => ids.contains(t.taskId));
      final unsafe = <String>[];
      for (final task in tasks) {
        final t = task.runner.table;
        final option = task.runner.options.singleWhere((o) => o.id == 'fold');
        print(
          'SOURCE_PROFILE ${jsonEncode({
            'task': task.taskId,
            'format': t.tableFormat.name,
            'count': t.playerCount,
            'board': t.boardCards.map((c) => c.label).toList(),
            'seats': [
              for (final s in t.seats) {'id': s.seatId, 'label': s.seatLabel, 'occupied': s.isOccupied, 'inHand': s.isInHand, 'folded': s.isFolded, 'hero': s.isHero, 'stack': s.stackLabel, 'currentBet': s.currentBetLabel, 'blind': s.blindAmountLabel, 'betKind': s.bet?.kind.name, 'betAmount': s.bet?.amountLabel, 'betLabel': s.bet?.label},
            ],
          })}',
        );
        expect(
          act0BettingPriceBlocksAuthoredSuccessV1(
            t,
            option,
            taskId: task.taskId,
            question: task.runner.question,
          ),
          isFalse,
        );
        final mutations = <String, Act0TableStateV1>{
          'scope_orientation': t.copyWith(scope: Act0TableScopeV1.orientation),
          'scope_explanation': t.copyWith(scope: Act0TableScopeV1.explanation),
          'board_on_preflop': t.copyWith(
            boardCards: const [
              Act0CardStateV1(rank: '2', suit: 'c'),
              Act0CardStateV1(rank: '3', suit: 'd'),
              Act0CardStateV1(rank: '4', suit: 'h'),
            ],
          ),
          'nine_max_roster': Act0TableStateV1(
            scope: t.scope,
            tableFormat: Act0TableFormatV1.nineMax,
            playerCount: 9,
            density: t.density,
            heroCards: t.heroCards,
            boardCards: t.boardCards,
            streetLabel: t.streetLabel,
            potLabel: t.potLabel,
            toCallLabel: t.toCallLabel,
            centerLabel: t.centerLabel,
            focusCalloutLabel: t.focusCalloutLabel,
            emptyBoardLabel: t.emptyBoardLabel,
            actionTrail: t.actionTrail,
            activeSeatId: t.activeSeatId,
            heroSeatId: t.heroSeatId,
            highlightedSeatIds: t.highlightedSeatIds,
            highlightedCardIds: t.highlightedCardIds,
            selectableSeatIds: t.selectableSeatIds,
            selectedSeatId: t.selectedSeatId,
            instructionAnchor: t.instructionAnchor,
            seats: [
              ...t.seats,
              const Act0SeatStateV1(
                seatId: 'utg1',
                seatLabel: 'UTG+1',
                displayName: 'Seat',
              ),
              const Act0SeatStateV1(
                seatId: 'utg2',
                seatLabel: 'UTG+2',
                displayName: 'Seat',
              ),
              const Act0SeatStateV1(
                seatId: 'lj',
                seatLabel: 'LJ',
                displayName: 'Seat',
              ),
            ],
          ),
          'duplicate_position': t.copyWith(
            seats: [
              for (final s in t.seats)
                s.seatId == 'co' ? change(s, seatLabel: 'UTG') : s,
            ],
          ),
          'small_blind_unoccupied': t.copyWith(
            seats: [
              for (final s in t.seats)
                s.seatId == 'sb' ? change(s, occupied: false) : s,
            ],
          ),
          'opponent_folded': t.copyWith(
            seats: [
              for (final s in t.seats)
                s.seatId == 'hj' ? change(s, inHand: false, folded: true) : s,
            ],
          ),
          'hero_zero_stack': t.copyWith(
            seats: [
              for (final s in t.seats) s.isHero ? change(s, stack: '0 BB') : s,
            ],
          ),
          'hero_short_stack': t.copyWith(
            seats: [
              for (final s in t.seats) s.isHero ? change(s, stack: '1 BB') : s,
            ],
          ),
          'opponent_new_stack': t.copyWith(
            seats: [
              for (final s in t.seats)
                s.seatId == 'bb' ? change(s, stack: '2 BB') : s,
            ],
          ),
          'hero_commitment': t.copyWith(
            seats: [
              for (final s in t.seats)
                s.isHero ? change(s, currentBet: '9 BB') : s,
            ],
          ),
          'blind_projection': t.copyWith(
            seats: [
              for (final s in t.seats)
                s.seatId == 'sb' ? change(s, blind: '9 BB') : s,
            ],
          ),
        };
        for (final e in mutations.entries) {
          final result = act0BettingPriceForOptionV1(
            e.value,
            option,
            taskId: task.taskId,
            question: task.runner.question,
          );
          final blocked = act0BettingPriceBlocksAuthoredSuccessV1(
            e.value,
            option,
            taskId: task.taskId,
            question: task.runner.question,
          );
          print(
            'MUTATION ${jsonEncode({'task': task.taskId, 'mutation': e.key, 'reason': result.reason, 'blocked': blocked})}',
          );
          if (!blocked) unsafe.add('${task.taskId}/${e.key}');
        }
      }
      expect(
        unsafe,
        isEmpty,
        reason: 'Material scene changes must lose exact-source admission',
      );
    },
  );
}
