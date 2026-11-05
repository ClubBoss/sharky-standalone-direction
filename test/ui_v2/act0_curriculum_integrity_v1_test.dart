import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  Act0LessonTaskV1 task(String worldId, String taskId) => Act0ShellStateV1
      .sample
      .worldById(worldId)
      .lessons
      .expand((lesson) => lesson.taskList)
      .firstWhere((task) => task.taskId == taskId);

  group('Act0 curriculum integrity', () {
    test('W4 sizing-family histories reconcile to the graded 6 BB pot', () {
      const expectedAnswers = <String, List<String>>{
        'w4_bad_bluff': <String>['check'],
        'w4_bluff_intro': <String>[],
        'w4_bluff_pressure': <String>['bet_small'],
        'w4_bluff_purpose': <String>['bluff'],
        'w4_bluff_recap': <String>[],
        'w4_checkpoint_intro': <String>[],
        'w4_checkpoint_review': <String>['purpose_price'],
        'w4_checkpoint_value': <String>['value'],
        'w4_half_pot_bet': <String>['three'],
        'w4_pot_bet': <String>['six'],
        'w4_protection_bet': <String>['bet_half'],
        'w4_protection_check': <String>['free_card'],
        'w4_protection_intro': <String>[],
        'w4_protection_recap': <String>[],
        'w4_purpose_intro': <String>[],
        'w4_purpose_recap': <String>[],
        'w4_sizing_intro': <String>[],
        'w4_sizing_recap': <String>[],
        'w4_small_bet': <String>['two'],
        'w4_value_bet': <String>['bet_half'],
        'w4_value_intro': <String>[],
        'w4_value_missed': <String>['bet_half'],
        'w4_value_purpose': <String>['value'],
        'w4_value_recap': <String>[],
      };
      const expectedTrail = <String>[
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG folds',
        'HJ folds',
        'CO folds',
        'BTN raises 2.75 BB',
        'SB folds',
        'BB calls 2.75 BB',
        'Flop: BB checks',
      ];
      const priorThreeBbHistory = <String>[
        'SB blind 0.5 BB',
        'BB blind 1 BB',
        'UTG folds',
        'HJ folds',
        'CO folds',
        'BTN raises 3 BB',
        'SB folds',
        'BB calls 3 BB',
        'Flop: BB checks',
      ];
      expect(
        act0CalcTrailPotV1(priorThreeBbHistory, 8).potBb,
        closeTo(6.5, 0.001),
        reason: 'the previously authored 3 BB open/call plus dead SB is 6.5',
      );
      final world = Act0ShellStateV1.sample.worldById('world_4');
      final tasks = <String, Act0LessonTaskV1>{
        for (final task in world.lessons.expand((lesson) => lesson.taskList))
          task.taskId: task,
      };

      expect(
        tasks.keys.toSet().intersection(expectedAnswers.keys.toSet()),
        expectedAnswers.keys.toSet(),
      );
      for (final entry in expectedAnswers.entries) {
        final task = tasks[entry.key]!;
        final correctIds = task.runner.options
            .where((option) => option.isCorrect)
            .map((option) => option.id)
            .toList();
        expect(correctIds, entry.value, reason: entry.key);
        final table = task.runner.table;
        expect(table.potLabel, 'Pot 6 BB', reason: entry.key);
        final decisionIndex = table.actionTrail.length - 1;
        final potAtDecision = act0CalcTableTrailPotV1(table, decisionIndex);
        expect(potAtDecision.potBb, closeTo(6, 0.001), reason: entry.key);
        expect(potAtDecision.street, 'Flop', reason: entry.key);
        expect(
          act0CalcTableTrailPotV1(table, 7).potBb,
          closeTo(6, 0.001),
          reason: '${entry.key}: BB call amount is total, not incremental',
        );
        expect(
          act0CalcTableTrailPotV1(table, decisionIndex - 1).potBb,
          closeTo(6, 0.001),
          reason: '${entry.key}: pot stays 6 at the source decision prefix',
        );
        final tableWithTypedNote = table.copyWith(
          actionTrail: <Act0ActionTrailItemV1>[
            table.actionTrail.first,
            const Act0ActionTrailItemV1.note(label: 'Context only'),
            ...table.actionTrail.skip(1),
          ],
        );
        expect(
          act0CalcTableTrailPotV1(
            tableWithTypedNote,
            tableWithTypedNote.actionTrail.length - 1,
          ).potBb,
          closeTo(6, 0.001),
          reason: '${entry.key}: typed notes do not add chips',
        );
        expect(
          table.actionTrail.where((item) => item.label == 'BB blind 1 BB'),
          hasLength(1),
          reason: entry.key,
        );
        final expectedTaskTrail = <String>[
          ...expectedTrail,
          if (entry.key == 'w4_protection_check') 'BTN checks',
        ];
        expect(
          table.actionTrail.map((item) => item.label).toList(),
          expectedTaskTrail,
          reason: entry.key,
        );
        final seats = <String, Act0SeatStateV1>{
          for (final seat in table.seats) seat.seatId: seat,
        };
        for (final seatId in <String>['utg', 'hj', 'co', 'sb']) {
          expect(seats[seatId]?.isFolded, isTrue, reason: entry.key);
          expect(seats[seatId]?.isInHand, isFalse, reason: entry.key);
        }
        expect(seats['bb']?.isFolded, isFalse, reason: entry.key);
        expect(seats['bb']?.hasActed, isTrue, reason: entry.key);
        final closedRound = entry.key == 'w4_protection_check';
        expect(table.activeSeatId, closedRound ? '' : 'btn', reason: entry.key);
        expect(seats['btn']?.hasActed, closedRound, reason: entry.key);
        if (closedRound) {
          expect(
            table.seats.where((seat) => seat.isActive),
            isEmpty,
            reason: entry.key,
          );
        }
      }

      final missingSmallBlind = expectedTrail.skip(1).toList();
      expect(
        act0CalcTrailPotV1(
          missingSmallBlind,
          missingSmallBlind.length - 1,
        ).potBb,
        -1,
        reason: 'history without the required first SB blind fails closed',
      );
    });

    test('W4 price decisions show the opponent source of Hero call price', () {
      final expectedPrices = <String, String>{
        'w4_good_price_call': '1 BB',
        'w4_bad_price_fold': '7 BB',
        'w4_cheap_price_marginal_call': '1 BB',
        'w4_big_price_marginal_fold': '6 BB',
      };

      for (final entry in expectedPrices.entries) {
        final runner = task('world_4', entry.key).runner;
        final hero = runner.table.heroSeat;
        final bettor = runner.table.seats.firstWhere(
          (seat) => seat.seatId == 'hj',
        );
        expect(hero.bet, isNull, reason: entry.key);
        expect(bettor.bet?.amountLabel, entry.value, reason: entry.key);
        expect(runner.table.toCallLabel, 'To call ${entry.value}');
        expect(runner.table.actionTrail.map((item) => item.label), <String>[
          'HJ bets ${entry.value}',
          'Hero acts',
        ], reason: entry.key);
      }
    });

    test(
      'W7 visible-card tasks render the board named by their source spec',
      () {
        final expectedBoards = <String, List<String>>{
          'visible_ace_combo_reduction_intro': <String>['A', '7', '2'],
          'visible_king_combo_reduction_intro': <String>['K', '8', '4'],
          'paired_board_texture_lite_intro': <String>['7', '7', '2'],
          'visible_card_combo_density_transfer_check': <String>['Q', 'J', '5'],
        };

        for (final entry in expectedBoards.entries) {
          final table = task('world_7', entry.key).runner.table;
          final cards = table.boardCards;
          expect(
            cards.map((card) => card.rank),
            entry.value,
            reason: entry.key,
          );
          expect(
            cards.map((card) => '${card.rank}${card.suit}').toSet().length,
            cards.length,
            reason: entry.key,
          );
          expect(
            <String>{
              for (final card in <Act0CardStateV1>[
                ...table.heroCards,
                ...cards,
              ])
                '${card.rank}${card.suit}',
            },
            hasLength(table.heroCards.length + cards.length),
            reason: '${entry.key} must not reuse a visible card',
          );
        }
      },
    );

    test('W8 side-pot intro uses one contribution ledger', () {
      final runner = task('world_8', 'what_poker_is_side_pot_intro').runner;
      final seats = <String, Act0SeatStateV1>{
        for (final seat in runner.table.seats) seat.seatId: seat,
      };
      const contributions = <String, double>{
        'hero': 20,
        'co': 50,
        'bb': 50,
        'folded_sb': 0.5,
      };
      const mainEligible = <String, double>{
        'hero': 20,
        'co': 20,
        'bb': 20,
        'folded_sb': 0.5,
      };
      const sideEligible = <String, double>{'co': 30, 'bb': 30};

      expect(contributions.values.reduce((a, b) => a + b), 120.5);
      expect(mainEligible.values.reduce((a, b) => a + b), 60.5);
      expect(sideEligible.values.reduce((a, b) => a + b), 60);
      expect(runner.table.potLabel, 'Main 60.5 BB; side 60 BB');
      expect(seats['btn']?.currentBetLabel, '20 BB');
      expect(seats['co']?.currentBetLabel, '50 BB');
      expect(seats['bb']?.currentBetLabel, '50 BB');
      expect(seats['co']?.bet?.label, 'Total in');
      expect(seats['co']?.bet?.amountLabel, '50 BB');
      expect(seats['bb']?.bet?.label, 'Total in');
      expect(seats['bb']?.bet?.amountLabel, '50 BB');
      expect(runner.table.actionTrail.map((item) => item.label), <String>[
        'SB posts 0.5 BB, then folds',
        'BB post is included in BB total',
        'Hero all-in 20 BB',
        'CO contributes 50 BB total',
        'BB contributes 50 BB total',
        'CO and BB: 30 BB each to side',
      ]);
    });
  });
}
