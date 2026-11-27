import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_table_truth_v1.dart';
import 'act0_b132_origin_choreography_reference.dart';

Act0TableChoreographyPlanV1? _proof(Act0TableStateV1 table) =>
    act0TableHistoryProofPlanForTableV1(table);

void main() {
  test(
    'B132 W13: blind posts precede folds and produce no history findings',
    () {
      final world = Act0ShellStateV1.authoredCatalog.worlds.singleWhere(
        (world) => world.worldNumber == 13,
      );
      final task = world.lessons
          .expand((lesson) => lesson.taskList)
          .singleWhere((task) => task.taskId == 'w13_1_read_ace_king_low');
      final table = task.runner.table;
      final plan = _proof(table)!;
      final history = plan.verifiedHistory!;
      expect(history.coverage, Act0HandHistoryCoverageV1.complete);
      expect(history.replayError(), isNull);
      expect(history.decisionError('btn'), isNull);
      final actions = history.events.whereType<Act0HandActionV1>().toList();
      expect(
        actions
            .take(2)
            .map((action) => (action.seat, action.verb, action.chipsAdded)),
        [
          ('sb', Act0HandVerbV1.smallBlind, 50),
          ('bb', Act0HandVerbV1.bigBlind, 100),
        ],
      );
      final sbPost = plan.beats.indexWhere(
        (beat) =>
            beat.contribution?.seatId == 'sb' &&
            beat.contribution?.kind == Act0ContributionKindV1.blind,
      );
      final sbFold = plan.beats.indexWhere(
        (beat) =>
            beat.actorSeatId == 'sb' &&
            beat.kind == Act0TableChoreographyBeatKindV1.foldRecess,
      );
      expect(sbPost, greaterThanOrEqualTo(0));
      expect(sbFold, greaterThan(sbPost));
      final posting = act0TableChoreographyFrameAfterBeatV1(plan, sbPost);
      expect(posting.foldedSeatIds, isNot(contains('sb')));
      final folded = act0TableChoreographyFrameAfterBeatV1(plan, sbFold);
      expect(folded.foldedSeatIds, contains('sb'));
      final rows = auditTableTruth(
        worlds: [world],
      ).where((row) => row.taskId == task.taskId).toList();
      expect(
        rows.singleWhere((row) => row.invariant == 'D6.history_support').result,
        'PASS',
      );
      expect(
        rows.where((row) => row.result == 'FAIL').map((row) => row.key),
        isEmpty,
      );
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  for (final (shape, flop, turn, river, hero, pot, due, closed) in [
    ('flop:x-b-c', 'xbc', '', '', 'co', 9.5, 0.0, true),
    ('flop:x-b', 'xb', '', '', 'bb', 7.5, 2.0, false),
    ('river:b', 'xx', 'xx', 'b', 'co', 9.5, 4.0, false),
    ('river:x-b', 'xbc', 'xx', 'xb', 'bb', 13.5, 4.0, false),
    ('turn:x-b-c', 'xbc', 'xbc', 'x', 'co', 15.5, 0.0, false),
  ]) {
    test('$shape: exact commitments, legal boundary and pot', () {
      final table = _table(flop, turn, river, hero);
      final plan = _proof(table)!;
      final history = plan.verifiedHistory!;
      expect(history.coverage, Act0HandHistoryCoverageV1.complete);
      expect(history.replayError(), isNull);
      expect(plan.verifiedHistoryEndsAtClosedStreet, closed);
      if (closed) {
        for (final seat in history.startingStacks.keys) {
          expect(history.decisionError(seat), isNotNull);
        }
      } else {
        expect(history.decisionError(hero), isNull);
      }
      final amounts = history.contributions.amounts(
        seatIds: history.startingStacks.keys.toSet(),
        actorSeatId: hero,
      );
      expect(amounts.potBb, pot);
      expect(amounts.toCallBb, due);
      expect(
        history.contributions.entries.map((e) => e.amountBb),
        table.handContributions!.entries.map((e) => e.amountBb),
      );
      final frame = act0TableChoreographyFrameAfterBeatV1(
        plan,
        plan.beats.length - 2,
      );
      expect(
        act0TableForChoreographyFrameV1(table, frame).potLabel,
        'Pot $pot BB',
      );
      expect(
        act0TableChoreographyPlanForTableV1(table),
        isNull,
        reason:
            'Proof-only parsing does not enable runtime/replay choreography',
      );
    });
  }

  test(
    'reject missing/wrong amounts, bad actor, unknown actions, raises and incomplete rounds',
    () {
      final table = _table('xbc', 'xx', 'b', 'co');
      final labels = table.actionTrail.map((e) => e.label).toList();
      for (final bad in [
        [...labels]..[9] = 'flop: CO bets',
        [...labels]..[10] = 'flop: BB calls',
        [...labels]..[10] = 'flop: BB calls 1 BB',
        [...labels]..[9] = 'flop: BB bets 2 BB',
        [...labels]..[9] = 'flop: CO waves',
        [...labels]..[10] = 'flop: BB raises to 5 BB',
        [...labels]..removeAt(10),
        [...labels]..removeAt(5), // missing fourth fold (three-way)
        [...labels]..removeAt(7), // missing preflop call
        [...labels]..[labels.length - 1] = 'river: CO bets 4 BB',
      ]) {
        final changed = table.copyWith(
          actionTrail: [
            for (final label in bad) Act0ActionTrailItemV1(label: label),
          ],
          handContributions: table.handContributions,
        );
        expect(_proof(changed), isNull, reason: '$bad');
      }
      expect(_proof(table.copyWith(decisionSeatId: 'bb')), isNull);
      expect(_proof(table.copyWith(autoPlayHistory: true)), isNull);
      expect(
        _proof(
          _table(
            'xbc',
            '',
            '',
            'co',
          ).copyWith(scope: Act0TableScopeV1.playedHand),
        ),
        isNull,
        reason:
            'Closed-street proof cannot waive the actual decision actor check',
      );
      expect(
        _proof(_table('xx', 'xx', 'b', 'bb')),
        isNull,
        reason: 'BB cannot act again after BB bets',
      );
    },
  );

  test(
    '35 exact B163 catalog rows pass D6; no new failures or findings',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds
          .where((w) => w.worldNumber >= 13 && w.worldNumber <= 24)
          .toList();
      final rows = auditTableTruth(worlds: worlds);
      final gained = <int, Set<String>>{};
      for (final world in worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final table = task.runner.table;
            final plan = _proof(table);
            if (plan == null ||
                act0TableChoreographyPlanForTableV1(table) != null)
              continue;
            gained.putIfAbsent(world.worldNumber, () => {}).add(task.taskId);
            expect(table.scope, Act0TableScopeV1.explanation);
            expect(table.autoPlayHistory, isFalse);
            expect(
              plan.verifiedHistory!.replayError(),
              isNull,
              reason: task.taskId,
            );
            expect(
              plan.verifiedHistoryEndsAtClosedStreet,
              world.worldNumber == 14,
              reason: task.taskId,
            );
            expect(
              rows
                  .singleWhere(
                    (r) =>
                        r.taskId == task.taskId &&
                        r.invariant == 'D6.history_support',
                  )
                  .result,
              'PASS',
              reason: task.taskId,
            );
            expect(
              rows.where(
                (r) =>
                    r.taskId == task.taskId &&
                    r.variant.startsWith('choreography/'),
              ),
              isEmpty,
            );
          }
        }
      }
      expect(gained, _targetIds);
      expect(rows.where((r) => r.result == 'FAIL'), isEmpty);
      final baseline =
          jsonDecode(
                File(
                  'test/fixtures/act0_catalog_vol2_baseline_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final remaining = {
        for (final world in baseline.values)
          for (final row in (world['D6.history_support'] ?? []) as List)
            row as String,
      };
      final actual = {
        for (final row in rows)
          if (row.invariant == 'D6.history_support' && row.result != 'PASS')
            '${row.taskId}|${row.variant}|${row.detail}',
      };
      expect(actual.difference(remaining), isEmpty);
      expect(actual.length, lessThanOrEqualTo(125));
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  test(
    'W1–W12 proof-enabled plans, catalog snapshot, route and XP match origin',
    () {
      for (final world in Act0ShellStateV1.authoredCatalog.worlds.where(
        (w) => w.worldNumber <= 12,
      )) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final runner = task.runner;
            final tables = [
              runner.table,
              for (final step in runner.teachingSteps) ...[
                step.table ?? runner.table,
                act0TeachingTableForRunnerV1(runner.table, step),
              ],
              for (final option in runner.options)
                act0FeedbackTableForRunnerV1(
                  runner: runner.copyWith(
                    phase: Act0LessonPhaseV1.review,
                    selectedOptionId: option.id,
                    teachingStepIndex: runner.teachingSteps.length,
                  ),
                  taskFamily: task.resolvedTaskFamily,
                ),
              act0FeedbackTableForRunnerV1(
                runner: runner.copyWith(phase: Act0LessonPhaseV1.review),
                taskFamily: task.resolvedTaskFamily,
              ),
            ];
            for (final table in tables) {
              final plan = _proof(table);
              expect(
                _bytes(plan),
                _bytes(originChoreographyPlanV1(table)),
                reason: task.taskId,
              );
              expect(plan?.verifiedHistory, isNull, reason: task.taskId);
              expect(plan?.verifiedHistoryEndsAtClosedStreet ?? false, isFalse);
            }
          }
        }
      }
      expect(
        renderCatalogSnapshot(
          excludePilot: act0CurriculumPilotEnabledV1,
        ).trimRight(),
        File(
          'test/fixtures/act0_catalog_snapshot_v1.txt',
        ).readAsStringSync().trimRight(),
      );
      final route = [
        for (final world in Act0ShellStateV1.sample.worlds.take(12))
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              [world.worldId, lesson.lessonId, task.taskId, task.rewardXp],
      ];
      expect(
        sha256.convert(utf8.encode(jsonEncode(route))).toString(),
        '6cfeebdc6f2ab96c9811ddac244d52ff156cd94f1cba2a6e02f4ec694786106d',
      );
    },
  );
}

String _bytes(Act0TableChoreographyPlanV1? plan) => jsonEncode(
  plan == null
      ? null
      : [
          plan.initialStreet.name,
          plan.finalStreet.name,
          plan.heroSeatId,
          [
            for (final b in plan.beats)
              [
                b.kind.name,
                b.street.name,
                b.actorSeatId,
                b.actorLabel,
                b.sourceIndex,
                b.commitment?.kind.name,
                b.commitment?.label,
                b.commitment?.amountLabel,
                b.contribution?.amountBb,
              ],
          ],
        ],
);

Act0TableStateV1 _table(String flop, String turn, String river, String hero) {
  const seats = ['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
  final street = river.isNotEmpty
      ? PokerStreet.river
      : turn.isNotEmpty
      ? PokerStreet.turn
      : PokerStreet.flop;
  final labels = [
    'preflop: SB posts 0.5 BB',
    'preflop: BB posts 1 BB',
    'preflop: UTG folds',
    'preflop: HJ folds',
    'preflop: CO raises to 2.5 BB',
    'preflop: BTN folds',
    'preflop: SB folds',
    'preflop: BB calls 1.5 BB more',
  ];
  final entries = [
    const Act0ContributionV1(
      PokerStreet.preflop,
      'sb',
      Act0ContributionKindV1.blind,
      0.5,
    ),
    const Act0ContributionV1(
      PokerStreet.preflop,
      'bb',
      Act0ContributionKindV1.blind,
      1,
    ),
    const Act0ContributionV1(
      PokerStreet.preflop,
      'co',
      Act0ContributionKindV1.wager,
      2.5,
    ),
    const Act0ContributionV1(
      PokerStreet.preflop,
      'bb',
      Act0ContributionKindV1.wager,
      1.5,
    ),
  ];
  for (final (round, actions, size) in [
    (PokerStreet.flop, flop, 2.0),
    (PokerStreet.turn, turn, 3.0),
    (PokerStreet.river, river, 4.0),
  ]) {
    for (final (i, action) in actions.split('').indexed) {
      if (action.isEmpty) continue;
      final actor = i.isEven ? 'bb' : 'co';
      final verb = switch (action) {
        'x' => 'checks',
        'b' => 'bets $size BB',
        'c' => 'calls $size BB more',
        _ => throw StateError(action),
      };
      labels.add('${round.name}: ${actor.toUpperCase()} $verb');
      if (action != 'x')
        entries.add(
          Act0ContributionV1(round, actor, Act0ContributionKindV1.wager, size),
        );
    }
  }
  final ledger = Act0HandContributionsV1(
    throughStreet: street,
    startingStackBbBySeat: {for (final seat in seats) seat: 100},
    entries: entries,
  );
  final amounts = ledger.amounts(seatIds: seats.toSet(), actorSeatId: hero);
  return Act0TableStateV1(
    scope: Act0TableScopeV1.explanation,
    autoPlayHistory: false,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: hero,
    activeSeatId: hero,
    decisionSeatId: hero,
    seats: [
      for (final seat in seats)
        Act0SeatStateV1(
          seatId: seat,
          seatLabel: seat.toUpperCase(),
          displayName: seat,
          isHero: seat == hero,
          isActive: seat == hero,
          isDealerButton: seat == 'btn',
          isSmallBlind: seat == 'sb',
          isBigBlind: seat == 'bb',
          isInHand: seat == 'co' || seat == 'bb',
          isFolded: seat != 'co' && seat != 'bb',
        ),
    ],
    heroCards: const [],
    boardCards: [
      const Act0CardStateV1(rank: 'K', suit: 'c'),
      const Act0CardStateV1(rank: '7', suit: 'h'),
      const Act0CardStateV1(rank: '2', suit: 's'),
      if (street.index >= PokerStreet.turn.index)
        const Act0CardStateV1(rank: '3', suit: 'd'),
      if (street == PokerStreet.river)
        const Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    streetLabel: pokerStreetToString(street),
    potLabel: 'Pot ${amounts.potBb} BB',
    toCallLabel: amounts.toCallBb == 0 ? '' : 'To call ${amounts.toCallBb} BB',
    centerLabel: '',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    actionTrail: [
      for (final label in labels) Act0ActionTrailItemV1(label: label),
    ],
    handContributions: ledger,
  );
}

const _targetIds = <int, Set<String>>{
  14: {
    'turn_heart_completes',
    'turn_heart_pairs_board',
    'turn_straight_completes',
    'turn_overcard_beats_pair',
    'turn_remove_high_draw',
    'turn_counterfeit_two_pair',
    'turn_redraw_good',
    'turn_board_four_to_straight',
    'turn_dead_draw',
    'turn_turn_makes_set',
  },
  15: {'w15_6_read_polar_on_two_tone'},
  16: {
    'w16_1_read_nut_change',
    'w16_1_day7_pair_changes_nuts',
    'w16_2_read_mdf_vs_price',
    'w16_3_read_value_streets',
    'w16_6_read_runout_two_sides',
  },
  19: {
    'w19_1_read_information_value',
    'w19_1_transfer_pick_baseline_when_uncertain',
    'w19_1_day7_counter_changes_with_strategy',
    'w19_3_day7_anonymous_fastfold',
    'w19_6_read_self_audit_ratio',
    'w19_6_day7_audit_which_hands_fold',
  },
  20: {
    'w20_1_read_time_bank_context',
    'w20_1_transfer_live_baseline_break',
    'w20_1_day7_distracted_online_sample',
    'w20_2_read_filter_action_chain',
    'w20_3_day7_table_captain_vs_overbluffer',
    'w20_6_read_confirmation_counterexample',
  },
  21: {'w21_5_transfer_review_without_result'},
  22: {'w22_1_transfer_river_no_chance_node'},
  24: {
    'w24_1_day7_condensed_calls_sized_bluffs',
    'w24_2_read_price_vs_alpha',
    'w24_2_guided_overbet_mdf',
    'w24_5_read_what_thin_raise_costs',
    'w24_6_read_raise_bluff_risk',
  },
};
