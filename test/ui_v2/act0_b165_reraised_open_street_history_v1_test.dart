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
    act0TableD6HistoryProofPlanForTableV1(table);

void main() {
  for (final (shape, table, pot) in _shapes()) {
    test('$shape: legal replay, exact pot and decision actor', () {
      final plan = _proof(table)!;
      final history = plan.verifiedHistory!;
      expect(history.coverage, Act0HandHistoryCoverageV1.complete);
      expect(history.replayError(), isNull);
      expect(history.decisionError(table.decisionActorSeatId), isNull);
      expect(plan.verifiedHistoryEndsAtClosedStreet, isFalse);
      final amounts = history.contributions.amounts(
        seatIds: history.startingStacks.keys.toSet(),
        actorSeatId: table.decisionActorSeatId,
      );
      expect(amounts.potBb, pot);
      expect(amounts.toCallBb, 0);
      expect(
        history.contributions.entries.map(
          (e) => (e.street, e.seatId, e.amountBb),
        ),
        table.handContributions!.entries.map(
          (e) => (e.street, e.seatId, e.amountBb),
        ),
      );
      expect(history.contestablePots!.single.chips, (pot * 100).round());
      expect(
        plan.beats.last.kind,
        Act0TableChoreographyBeatKindV1.heroDecisionReady,
      );
      expect(act0TableChoreographyPlanForTableV1(table), isNull);
      expect(act0TableHistoryProofPlanForTableV1(table), isNull);
      if (shape.endsWith(':-')) {
        expect(
          history.eventsOn(history.street).whereType<Act0HandActionV1>(),
          isEmpty,
        );
        expect(
          history.eventsOn(history.street).whereType<Act0HandDealV1>(),
          hasLength(1),
        );
        final frame = act0TableChoreographyFrameAfterBeatV1(
          plan,
          plan.beats.length - 2,
        );
        expect(frame.commitments, isEmpty);
        expect(frame.street, plan.finalStreet);
        expect(frame.visibleBoardCardCount, table.boardCards.length);
      }
    });
  }

  test(
    'missing or falsified amounts, unknown actions and illegal replay stay unsupported',
    () {
      final table = _shapes().firstWhere((s) => s.$1.contains('(4-bet)')).$2;
      final labels = table.actionTrail.map((e) => e.label).toList();
      for (final (index, label) in labels.indexed) {
        if (!label.contains(' BB')) continue;
        final missing = label.replaceFirst(
          RegExp(r' (?:to )?\d+(?:\.\d+)? BB(?: more)?$'),
          '',
        );
        expect(
          _proof(_withTrail(table, [...labels]..[index] = missing)),
          isNull,
          reason: missing,
        );
      }
      for (final bad in [
        [...labels]..[7] = 'preflop: BB raises to 9 BB',
        [...labels]..[7] = 'preflop: BB raises to 10 BB (all-in)',
        [...labels]..[7] = 'preflop: BB straddles 10 BB',
        [...labels]..[8] = 'preflop: CO raises to 12 BB',
        [...labels]..removeAt(9),
        [...labels]..[10] = 'flop: CO checks',
        [...labels]..[10] = 'flop: BB waves',
      ]) {
        expect(_proof(_withTrail(table, bad)), isNull, reason: '$bad');
      }
    },
  );

  test(
    'terminal dealt markers cannot skip a street or replace a missing turn',
    () {
      final table = _shapes().firstWhere((s) => s.$1.endsWith('flop:-')).$2;
      final labels = table.actionTrail.map((e) => e.label).toList();
      expect(_proof(_withTrail(table, [...labels]..removeLast())), isNotNull);
      expect(
        _proof(_withTrail(table, [...labels]..[labels.length - 1] = 'flop:')),
        isNotNull,
      );
      for (final bad in [
        [...labels]..[labels.length - 1] = 'Turn dealt',
        [...labels, 'Flop dealt'],
        [...labels, 'flop: BB checks'],
        [...labels]..removeAt(labels.length - 2),
      ]) {
        expect(_proof(_withTrail(table, bad)), isNull, reason: '$bad');
      }
      final turn = _shapes().firstWhere((s) => s.$1.endsWith('turn:-')).$2;
      expect(
        _proof(
          _withTrail(
            turn,
            turn.actionTrail.map((e) => e.label).toList()..removeLast(),
          ),
        ),
        isNull,
      );
    },
  );

  test(
    'exact B165 catalog rows certify D6 with no FAIL or new animation rows',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds
          .where((w) => w.worldNumber >= 13 && w.worldNumber <= 24)
          .toList();
      final rows = auditTableTruth(worlds: worlds);
      final gained = <String>{};
      final remaining = <int, Set<String>>{};
      for (final world in worlds) {
        for (final task in world.lessons.expand((l) => l.taskList)) {
          final table = task.runner.table;
          final d6 = rows
              .where(
                (r) =>
                    r.taskId == task.taskId &&
                    r.invariant == 'D6.history_support',
              )
              .singleOrNull;
          if (d6 != null &&
              d6.result != 'PASS' &&
              !(d6.result == 'EXPLICIT_EXCEPTION' &&
                  task.phase == Act0LessonPhaseV1.theory &&
                  task.multiStreet == null &&
                  _noHandFacts(table) &&
                  task.runner.teachingSteps.every(
                    (step) => step.table == null || _noHandFacts(step.table!),
                  ))) {
            remaining.putIfAbsent(world.worldNumber, () => {}).add(task.taskId);
          }
          if (!_targetPots.containsKey(task.taskId)) continue;
          final plan = _proof(table)!;
          final history = plan.verifiedHistory!;
          expect(
            history.decisionError(table.decisionActorSeatId),
            isNull,
            reason: task.taskId,
          );
          expect(
            history.contestablePots!.single.chips,
            (_targetPots[task.taskId]! * 100).round(),
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
            act0TableChoreographyPlanForTableV1(table),
            isNull,
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
          gained.add(task.taskId);
        }
      }
      expect(gained, _targetPots.keys.toSet());
      for (final entry in remaining.entries) {
        expect(
          entry.value.difference(_remainingIds[entry.key] ?? {}),
          isEmpty,
          reason: 'W${entry.key}',
        );
      }
      for (final world in worlds) {
        final n = world.worldNumber;
        final after = remaining[n]?.length ?? 0;
        final before =
            (_remainingIds[n]?.length ?? 0) +
            world.lessons
                .expand((l) => l.taskList)
                .where((task) => _targetPots.containsKey(task.taskId))
                .length;
        print('B165 W$n D6 residue $before -> $after');
      }
      expect(rows.where((r) => r.result == 'FAIL'), isEmpty);
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
                _bytes(act0TableHistoryProofPlanForTableV1(table)),
                _bytes(plan),
                reason: task.taskId,
              );
              expect(
                _bytes(act0TableChoreographyPlanForTableV1(table)),
                _bytes(plan),
                reason: task.taskId,
              );
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
        renderCatalogSnapshot(excludePilot: act0CurriculumPilotEnabledV1),
        File('test/fixtures/act0_catalog_snapshot_v1.txt').readAsStringSync(),
      );
      final route = [
        for (final world in Act0ShellStateV1.sample.worlds.take(12))
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              [world.worldId, lesson.lessonId, task.taskId, task.rewardXp],
      ];
      expect(
        sha256.convert(utf8.encode(jsonEncode(route))).toString(),
        '4188b79e962253220a409352ab8859c06b09f6ccc0f543421ff5b11a2aa018d1',
      );
    },
  );
}

bool _noHandFacts(Act0TableStateV1 table) =>
    table.scope == Act0TableScopeV1.explanation &&
    table.seats.isEmpty &&
    table.actionTrail.isEmpty &&
    table.heroCards.isEmpty &&
    table.boardCards.isEmpty &&
    table.streetLabel.isEmpty &&
    table.potLabel.isEmpty &&
    table.toCallLabel.isEmpty &&
    table.handContributions == null &&
    table.handTimelinePrefix == null;

Act0TableStateV1 _withTrail(Act0TableStateV1 table, List<String> labels) =>
    table.copyWith(
      actionTrail: [
        for (final label in labels) Act0ActionTrailItemV1(label: label),
      ],
      handContributions: table.handContributions,
    );

Act0TableStateV1 _table(
  String hero,
  PokerStreet street,
  List<String> labels,
  Set<String> folded,
  List<(String, double)> wagers,
  double pot,
  double due,
) {
  const seats = ['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
  return Act0TableStateV1(
    scope: Act0TableScopeV1.explanation,
    autoPlayHistory: false,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    heroSeatId: hero,
    decisionSeatId: hero,
    activeSeatId: hero,
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
          isFolded: folded.contains(seat),
          isInHand: !folded.contains(seat),
        ),
    ],
    heroCards: const [],
    boardCards: [
      if (street.index >= 1) ...const [
        Act0CardStateV1(rank: 'K', suit: 'c'),
        Act0CardStateV1(rank: '7', suit: 'h'),
        Act0CardStateV1(rank: '2', suit: 's'),
      ],
      if (street.index >= 2) const Act0CardStateV1(rank: '3', suit: 'd'),
      if (street.index >= 3) const Act0CardStateV1(rank: '4', suit: 'c'),
    ],
    streetLabel: pokerStreetToString(street),
    potLabel: 'Pot $pot BB',
    toCallLabel: due == 0 ? '' : 'To call $due BB',
    centerLabel: '',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    actionTrail: [
      for (final label in labels) Act0ActionTrailItemV1(label: label),
    ],
    handContributions: Act0HandContributionsV1(
      throughStreet: street,
      startingStackBbBySeat: {for (final seat in seats) seat: 100},
      entries: [
        const Act0ContributionV1(
          PokerStreet.preflop,
          'sb',
          Act0ContributionKindV1.blind,
          .5,
        ),
        const Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.blind,
          1,
        ),
        for (final (seat, added) in wagers)
          Act0ContributionV1(
            PokerStreet.preflop,
            seat,
            Act0ContributionKindV1.wager,
            added,
          ),
      ],
    ),
  );
}

const _remainingIds = <int, Set<String>>{
  19: {
    'w19_3_guided_depth_split',
    'w19_4_read_predictable_single_size',
    'w19_5_transfer_no_attack_into_traps',
    'w19_5_read_cap_can_vanish',
    'w19_3_transfer_overcalls_draws',
  },
  20: {
    'w20_3_transfer_stakes_discomfort_caveat',
    'w20_1_guided_compare_matched_timing',
    'w20_5_guided_keep_table_welcoming',
    'w20_5_day7_dont_use_private_image',
  },
  22: {
    'w22_6_day7_read_lead_plan',
    'w22_1_day7_turn_chance_node',
    'w22_6_checkpoint_audit_pruned_solver_result',
  },
};
const _targetPots = {
  'w15_5_read_first_flop_actor': 5.5,
  'w16_4_read_probe_sequence': 5.5,
  'w16_5_day7_called_turn_overbet': 20.5,
  'w16_5_read_turn_overbet_leverage': 20.5,
  'w17_3_guided_count_caller_coverage': 20.5,
  'w17_4_day7_spr_after_four_bet': 48.5,
  'w17_6_read_lower_spr_mechanics': 50.5,
  'w22_4_day7_change_input_requires_new_query': 5.5,
};

List<(String, Act0TableStateV1, double)> _shapes() {
  const posts = ['preflop: SB posts 0.5 BB', 'preflop: BB posts 1 BB'];
  const coOpen = [
    ...posts,
    'preflop: UTG folds',
    'preflop: HJ folds',
    'preflop: CO raises to 2.5 BB',
    'preflop: BTN folds',
    'preflop: SB folds',
  ];
  const btnOpen = [
    ...posts,
    'preflop: UTG folds',
    'preflop: HJ folds',
    'preflop: CO folds',
    'preflop: BTN raises to 2.5 BB',
    'preflop: SB folds',
  ];
  return [
    (
      'ppffrffrrc|flop:x (4-bet)',
      _table(
        'co',
        PokerStreet.flop,
        [
          ...coOpen,
          'preflop: BB raises to 10 BB',
          'preflop: CO raises to 24 BB',
          'preflop: BB calls 14 BB more',
          'flop: BB checks',
        ],
        {'utg', 'hj', 'btn', 'sb'},
        [('co', 2.5), ('bb', 9), ('co', 21.5), ('bb', 14)],
        48.5,
        0,
      ),
      48.5,
    ),
    (
      'ppffrffrc|flop:x',
      _table(
        'co',
        PokerStreet.flop,
        [
          ...coOpen,
          'preflop: BB raises to 10 BB',
          'preflop: CO calls 7.5 BB more',
          'flop: BB checks',
        ],
        {'utg', 'hj', 'btn', 'sb'},
        [('co', 2.5), ('bb', 9), ('co', 7.5)],
        20.5,
        0,
      ),
      20.5,
    ),
    (
      'ppfffrfrc|flop:x-x|turn:x',
      _table(
        'btn',
        PokerStreet.turn,
        [
          ...btnOpen,
          'preflop: BB raises to 10 BB',
          'preflop: BTN calls 7.5 BB more',
          'flop: BB checks',
          'flop: BTN checks',
          'turn: BB checks',
        ],
        {'utg', 'hj', 'co', 'sb'},
        [('btn', 2.5), ('bb', 9), ('btn', 7.5)],
        20.5,
        0,
      ),
      20.5,
    ),
    for (final street in PokerStreet.values.skip(1))
      (
        'ppfffrfc|${street.name}:-',
        _table(
          'bb',
          street,
          [
            ...btnOpen,
            'preflop: BB calls 1.5 BB more',
            if (street.index >= 2) ...['flop: BB checks', 'flop: BTN checks'],
            if (street.index >= 3) ...['turn: BB checks', 'turn: BTN checks'],
            if (street == PokerStreet.flop) 'Flop dealt',
          ],
          {'utg', 'hj', 'co', 'sb'},
          [('btn', 2.5), ('bb', 1.5)],
          5.5,
          0,
        ),
        5.5,
      ),
  ];
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
