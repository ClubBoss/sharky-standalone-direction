import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_solver/poker_solver.dart';

void main() {
  group('Act0 Wave 1 canonical correctness and trust', () {
    Act0LessonTaskV1 taskFor({
      required String worldId,
      required String lessonId,
      required String taskId,
    }) {
      final world = Act0ShellStateV1.sample.worldById(worldId);
      final lesson = world.lessons.firstWhere(
        (lesson) => lesson.lessonId == lessonId,
      );

      return lesson.taskList.firstWhere((task) => task.taskId == taskId);
    }

    Act0RunnerOptionV1 correctOption(Act0LessonTaskV1 task) {
      return task.runner.options.firstWhere((option) => option.isCorrect);
    }

    test('W5 gap-board caption names the composed shared cards', () {
      final task = taskFor(
        worldId: 'world_5',
        lessonId: 'straight_draws',
        taskId: 'straight_draws_w5_gap_board',
      );
      expect(task.runner.table.boardCards.map((card) => card.label), <String>[
        'Ad',
        '6s',
        '2c',
      ]);
      expect(task.runner.caption, 'Look at the ranks on the flop.');
      expect(task.runner.options.map((option) => option.id), <String>[
        'yes',
        'no',
        'ace_to_six',
      ]);
      expect(correctOption(task).id, 'no');
      expect(task.rewardXp, 9);
    });

    test('W5 straight-out feedback separates private and shared ranks', () {
      final task = taskFor(
        worldId: 'world_5',
        lessonId: 'outs_improvement',
        taskId: 'outs_improvement_w5_straight_out',
      );
      expect(task.runner.table.heroCards.map((card) => card.label), <String>[
        '6h',
        '5c',
      ]);
      expect(task.runner.table.boardCards.map((card) => card.label), <String>[
        '8s',
        '7d',
        '2h',
      ]);
      expect(task.runner.options.map((option) => option.id), <String>[
        'nine',
        'king',
        'ten',
      ]);
      final correct = correctOption(task);
      expect(correct.id, 'nine');
      expect(correct.quality, Act0FeedbackQualityV1.correct);
      expect(
        correct.feedbackReason,
        'Private 5-6, shared board cards 7-8: any 9 completes the straight.',
      );
      expect(task.rewardXp, 9);
      // Copy must preserve the actual feedback clue and receipt. A factual
      // wording repair must not silently change the learner's skill signal.
      final feedback = task.runner.copyWith(selectedOptionId: correct.id);
      final table = act0FeedbackTableForRunnerV1(
        runner: feedback,
        taskFamily: task.resolvedTaskFamily,
      );
      expect(table.highlightedCardIds.toSet(), <String>{
        'hero_0',
        'hero_1',
        'board_0',
        'board_1',
        'board_2',
      });
      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: feedback,
        option: correct,
        taskFamily: task.resolvedTaskFamily,
      );
      expect(receipt, isNotNull);
      expect(receipt!.sourceSignalId, 'hero_cards_board_pot');
      expect(receipt.skillAtomId, 'table_read');
      expect(receipt.nextRepId, 'repeat_table_read');
    });

    test('W5 factual repairs preserve parents and overriding descendants', () {
      final disconnected = taskFor(
        worldId: 'world_5',
        lessonId: 'connected_boards',
        taskId: 'connected_boards_w5_disconnected_board',
      );
      expect(disconnected.runner.caption, 'Look at the flop ranks.');
      expect(correctOption(disconnected).id, 'disconnected');
      final draw = taskFor(
        worldId: 'world_5',
        lessonId: 'straight_draws',
        taskId: 'straight_draws_w5_straight_draw_find',
      );
      expect(draw.runner.caption, 'You have 6-5 and the board shows 8-7-2.');
      expect(correctOption(draw).id, 'straight_draw');
      expect(
        correctOption(draw).feedbackReason,
        'Your 5-6 and the board’s 7-8 form a four-card run. A 4 finishes it at the low end and a 9 at the high end.',
      );
      final transfer = taskFor(
        worldId: 'world_5',
        lessonId: 'outs_improvement',
        taskId: 'outs_improvement_w5_table_outs_straight_transfer',
      );
      expect(transfer.runner.options.map((option) => option.id), <String>[
        'four_or_nine',
        'blank_turn_killed',
        'fold_wrong_out_count',
      ]);
      expect(correctOption(transfer).id, 'four_or_nine');
      final risky = taskFor(
        worldId: 'world_5',
        lessonId: 'outs_improvement',
        taskId: 'outs_improvement_w5_clean_vs_risky_out_transfer',
      );
      expect(risky.runner.options.map((option) => option.id), <String>[
        'five_hearts_riskier',
        'neither_helps',
        'five_clubs_cleaner',
      ]);
      expect(
        correctOption(risky).feedbackReason,
        'Both cards complete the straight, but 5-club is safer because it helps you without adding a third heart. The straight is real either way, but this river keeps the board calmer.',
      );
    });

    test('W5 live draw feedback distinguishes making a hand from winning', () {
      const cases = [
        (
          taskId: 'outs_improvement_w5_table_outs_straight_transfer',
          correctId: 'four_or_nine',
          drawCards: ['4c', '4d', '4h', '4s', '9c', '9d', '9h', '9s'],
          river: '9c',
          opponentCards: ['Js', 'Td'],
          heroRank: 'Straight',
          opponentRank: 'Straight',
          exampleCopy: 'holding J-T a higher straight',
        ),
        (
          taskId: 'outs_improvement_w5_table_outs_flush_transfer',
          correctId: 'heart_outs',
          drawCards: ['2h', '3h', '5h', '6h', '8h', '9h', 'Jh', 'Qh', 'Kh'],
          river: '2h',
          opponentCards: ['Ts', 'Td'],
          heroRank: 'Flush',
          opponentRank: 'Full House',
          exampleCopy: 'holding two tens would make a full house',
        ),
      ];

      for (final example in cases) {
        final task = taskFor(
          worldId: 'world_5',
          lessonId: 'outs_improvement',
          taskId: example.taskId,
        );
        final table = task.runner.table;
        final board = table.boardCards.map((card) => card.label);
        final heroCards = table.heroCards.map((card) => card.label);
        final known = {...board, ...heroCards};
        for (final river in example.drawCards) {
          expect(known, isNot(contains(river)), reason: example.taskId);
          final hero = Hand.solveHand([...board, river, ...heroCards]);
          expect(
            hero.name,
            example.heroRank,
            reason: '${example.taskId} $river',
          );
        }

        final hero = Hand.solveHand([...board, example.river, ...heroCards]);
        final opponent = Hand.solveHand([
          ...board,
          example.river,
          ...example.opponentCards,
        ]);
        expect(
          {...known, example.river, ...example.opponentCards},
          hasLength(9),
          reason: example.taskId,
        );
        expect(opponent.name, example.opponentRank, reason: example.taskId);
        expect(Hand.winners([hero, opponent]).single, same(opponent));
        final correct = correctOption(task);
        expect(correct.id, example.correctId);
        expect(
          task.runner.options.map((option) => option.feedbackReason),
          anyElement(contains(example.exampleCopy)),
        );
        expect(task.rewardXp, 10);
      }
    });

    test(
      'W5 draw grades compare physical outs with the current call price',
      () {
        const cases = [
          (
            lesson: 'outs_improvement',
            task: 'outs_improvement_w5_table_outs_flush_transfer',
            rank: 'Flush',
            outs: 9,
            pot: 10,
            call: 2,
          ),
          (
            lesson: 'outs_improvement',
            task: 'outs_improvement_w5_table_outs_straight_transfer',
            rank: 'Straight',
            outs: 8,
            pot: 9,
            call: 3,
          ),
          (
            lesson: 'turn_river_changes',
            task: 'turn_river_changes_w5_board_checkpoint',
            rank: 'Straight',
            outs: 4,
            pot: 12,
            call: 1,
          ),
        ];
        const ranks = '23456789TJQKA';
        const suits = 'cdhs';
        for (final example in cases) {
          final task = taskFor(
            worldId: 'world_5',
            lessonId: example.lesson,
            taskId: example.task,
          );
          final table = task.runner.table;
          final seen = [
            ...table.heroCards.map((card) => card.label),
            ...table.boardCards.map((card) => card.label),
          ];
          final rivers = [
            for (final rank in ranks.split(''))
              for (final suit in suits.split(''))
                if (!seen.contains('$rank$suit')) '$rank$suit',
          ];
          final outs = rivers
              .where(
                (river) =>
                    Hand.solveHand([...seen, river]).name == example.rank,
              )
              .length;
          expect(rivers, hasLength(46), reason: example.task);
          expect(outs, example.outs, reason: example.task);
          expect(table.potLabel, 'Pot ${example.pot} BB');
          expect(table.toCallLabel, 'To call ${example.call} BB');
          final canCall =
              outs * (example.pot + example.call) >
              example.call * rivers.length;
          expect(
            correctOption(task).label,
            canCall ? 'Call ${example.call} BB' : 'Fold',
            reason: example.task,
          );
        }
      },
    );

    test('W6 the stronger example range changes with the flop', () {
      const raiser = [
        ['Ad', 'Ac'],
        ['Kh', 'Kd'],
        ['Ac', 'Kd'],
        ['Ac', 'Qs'],
      ];
      const caller = [
        ['8d', '8c'],
        ['7d', '7c'],
        ['6h', '6d'],
        ['Ts', '9s'],
      ];
      const strong = {'Two Pair', 'Three of a Kind', 'Straight'};
      for (final (id, raiserCount, callerCount) in [
        ('w6_value_wet_board', 0, 4),
        ('w6_board_fit_recap', 3, 0),
      ]) {
        final task = taskFor(
          worldId: 'world_6',
          lessonId: 'range_board_fit',
          taskId: id,
        );
        final board = task.runner.table.boardCards.map((card) => card.label);
        int strongHands(List<List<String>> range) => range.where((hand) {
          expect({...board, ...hand}, hasLength(5));
          return strong.contains(Hand.solveHand([...board, ...hand]).name);
        }).length;

        expect(strongHands(raiser), raiserCount, reason: id);
        expect(strongHands(caller), callerCount, reason: id);
        expect(
          correctOption(task).label,
          raiserCount > callerCount ? 'BTN, the raiser' : 'BB, the caller',
        );
      }
    });

    test('W3 model revisions keep five assessments anchored to current source', () {
      const expected = <String, String>{
        'same_hand_different_seat_same_hand_late_open':
            '5136e7f516c3e09e95d5c1cef082a9bc4a469e08ae394dcbc65b9f6b70048a51',
        'position_apply_late_open':
            'a3179df885b7501174615ef27f6f25f30b996f4fc06b584b5521c59cc3f92d3f',
        'position_checkpoint_position_checkpoint_late_open':
            '06b04f9855bad9e18c3db9e043ff42ada3beb56d2ca451bf61e31168e71cb687',
        'position_apply_recap':
            '07fb62d0d9bd16ecc4ac2247bb06407ecd112d97f63b8508303f9b46c5eeb9c8',
        'position_checkpoint_position_checkpoint_review':
            '2f66eb36d08df700ea1ac77f34d9be305b6754deba7a6cca921bd4fd3773a5ba',
      };
      final world = Act0ShellStateV1.sample.worldById('world_3');
      final observed = <String>{};
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          if (!expected.containsKey(task.taskId)) continue;
          observed.add(task.taskId);
          expect(
            act0AuthoredSourceFingerprintV1(
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              task: task,
            ),
            expected[task.taskId],
            reason: task.taskId,
          );
        }
      }
      expect(observed, expected.keys.toSet());
    });

    test('repaired correct options use semantic feedback titles', () {
      final cases = <({Act0LessonTaskV1 task, String title})>[
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'blinds_action_order',
            taskId: 'positions_button',
          ),
          title: 'BTN seat found.',
        ),
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'blinds_action_order',
            taskId: 'positions_utg',
          ),
          title: 'UTG seat found.',
        ),
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'positions',
            taskId: 'positions_late_seat',
          ),
          title: 'Late seat found.',
        ),
        (
          task: taskFor(
            worldId: 'world_1',
            lessonId: 'hand_rankings_table',
            taskId: 'hand_rankings_pair_drill',
          ),
          title: 'Pair found.',
        ),
        (
          task: taskFor(
            worldId: 'world_4',
            lessonId: 'price_checkpoint',
            taskId: 'w4_checkpoint_review',
          ),
          title: 'Purpose and price connected.',
        ),
        (
          task: taskFor(
            worldId: 'world_5',
            lessonId: 'straight_draws',
            taskId: 'straight_draws_w5_gap_board',
          ),
          title: 'Gap board identified.',
        ),
      ];

      final repairedTitles = <String>[];
      for (final testCase in cases) {
        final correct = correctOption(testCase.task);
        repairedTitles.add(correct.feedbackTitle);
        expect(
          correct.feedbackTitle,
          testCase.title,
          reason: testCase.task.taskId,
        );
      }

      expect(
        repairedTitles,
        isNot(
          containsAll(<String>[
            'Win can hide a leak.',
            'Reset before next hand.',
            'Log it, then reset.',
            'Process ignores table talk.',
            'Discipline: fold early trash.',
            'Discipline: open strong late.',
          ]),
        ),
      );
    });

    test('canonical W1 and inherited W3 feedback titles own their answer', () {
      const expected = <String, String>{
        'cards_ranks_suits_suit_drill': 'Hearts is the suit.',
        'cards_ranks_suits_private_board': 'Board cards are shared.',
        'cards_ranks_suits_best_five': 'Five cards form your hand.',
        'your_first_hand_turn': 'Turn is the fourth board card.',
        'your_first_hand_river': 'River is the fifth board card.',
        'actions_legal_context': 'Check is legal with no bet to call.',
        'actions_fold_drill': 'Fold gives up this hand.',
        'actions_call_drill': 'Call matches the current bet.',
        'blinds_postflop_button': 'BTN acts last after the flop.',
        'positions_cutoff': 'CO is the seat before BTN.',
        'hand_rankings_best_five_drill': 'Use the highest side card.',
        'button_advantage_button_last': 'BTN acts last after the flop.',
        'button_advantage_position_repair_btn_last_postflop':
            'BTN acts last after the flop.',
        'fold_discipline_facing_fold': 'J8o still folds versus a CO open.',
        'weak_ace_warning_weak_ace_pressure_fold': 'Use the Weak row.',
        'continue_or_let_go_weak_let_go': 'Use the Weak row.',
      };
      final tasks = <Act0LessonTaskV1>[
        for (var world = 1; world <= 3; world++)
          ...Act0ShellStateV1.sample
              .worldById('world_$world')
              .lessons
              .expand((lesson) => lesson.taskList),
      ];
      for (final row in expected.entries) {
        final task = tasks.firstWhere((task) => task.taskId == row.key);
        final correct = task.runner.options.firstWhere((o) => o.isCorrect);
        expect(correct.feedbackTitle, row.value, reason: task.taskId);
        expect(correct.feedbackReason.trim(), isNotEmpty);
      }
    });

    test(
      'W2 apply_hj_decision uses HJ medium-hand source without old UTG trash',
      () {
        final task = taskFor(
          worldId: 'world_2',
          lessonId: 'hand_discipline_apply',
          taskId: 'apply_hj_decision',
        );
        final runner = task.runner;
        final heroCards = runner.table.heroCards
            .map((card) => card.label)
            .toList(growable: false);

        expect(task.taskId, 'apply_hj_decision');
        expect(runner.lessonId, 'w1_apply_hj_medium');
        expect(runner.caption, contains('HJ'));
        expect(runner.caption, isNot(contains('UTG')));
        expect(runner.caption, isNot(contains('8♠ 4♦')));
        expect(runner.table.activeSeatId, 'hj');
        expect(runner.table.heroSeatId, 'hj');
        expect(runner.table.heroSeat.seatId, 'hj');
        expect(heroCards, <String>['Kd', 'Qc']);

        final correct = correctOption(task);
        expect(correct.id, 'raise');
        expect(correct.feedbackTitle, 'HJ open is clean.');
      },
    );

    test('W4-W6 canonical runners do not display adjacent stale subtitles', () {
      final staleAdjacentSubtitles = <String, Set<String>>{
        'world_4': <String>{'Board Awareness', 'Range Thinking'},
        'world_5': <String>{'Range Thinking', 'Visible Cards Change Ranges'},
        'world_6': <String>{'Visible Cards Change Ranges'},
      };

      for (final entry in staleAdjacentSubtitles.entries) {
        final world = Act0ShellStateV1.sample.worldById(entry.key);
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            expect(
              entry.value,
              isNot(contains(task.runner.lessonSubtitle)),
              reason: '${entry.key}/${lesson.lessonId}/${task.taskId}',
            );
          }
        }
      }
    });
  });
}
