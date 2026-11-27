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
  for (final (shape, table, pot, due) in _shapes()) {
    test('$shape: exact contributions and next actor', () {
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
      expect(amounts.toCallBb, due);
      expect(
        history.contributions.entries.map((e) => (e.seatId, e.amountBb)),
        table.handContributions!.entries.map((e) => (e.seatId, e.amountBb)),
      );
      expect(
        plan.beats
            .where((b) => b.contribution != null)
            .map((b) => (b.contribution!.seatId, b.contribution!.amountBb)),
        table.handContributions!.entries.map((e) => (e.seatId, e.amountBb)),
      );
      expect(act0TableChoreographyPlanForTableV1(table), isNull);
      expect(act0TableHistoryProofPlanForTableV1(table), isNull);
      expect(
        plan.beats.last.kind,
        Act0TableChoreographyBeatKindV1.heroDecisionReady,
      );
      final frame = act0TableChoreographyFrameAfterBeatV1(
        plan,
        plan.beats.length - 2,
      );
      expect(frame.visibleBoardCardCount, table.boardCards.length);
      expect(
        frame.handContributions!
            .amounts(
              seatIds: history.startingStacks.keys.toSet(),
              actorSeatId: table.decisionActorSeatId,
            )
            .potBb,
        pot,
      );
    });
  }

  test(
    'reject missing amounts, unsupported grammar, wrong contributions and actor',
    () {
      final table = _shapes()
          .firstWhere(
            (row) => row.$1.startsWith('0way') && row.$1.contains('r-c'),
          )
          .$2;
      final labels = table.actionTrail.map((e) => e.label).toList();
      for (final bad in [
        [...labels]..[0] = 'preflop: SB posts',
        [...labels]..[0] = 'preflop: SB posts 0.25 BB',
        [...labels]..[0] = 'preflop: SB posts 0.5 BB ante',
        [...labels]..[0] = 'preflop: SB straddles 0.5 BB',
        [...labels]..[3] = 'preflop: HJ raises to',
        [...labels]..[3] = 'preflop: HJ raises to 2.5 BB (all-in)',
        [...labels]..[4] = 'preflop: CO calls',
        [...labels]..[4] = 'preflop: CO calls 1 BB',
        [...labels]..[4] = 'preflop: CO waves',
        [...labels]..removeAt(2),
        [...labels, 'flop: BB checks'],
      ]) {
        expect(_proof(_withTrail(table, bad)), isNull, reason: '$bad');
      }
      expect(_proof(table.copyWith(decisionSeatId: 'bb')), isNull);
      expect(_proof(table.copyWith(autoPlayHistory: true)), isNull);
      expect(
        _proof(table.copyWith(tableFormat: Act0TableFormatV1.nineMax)),
        isNull,
      );
      expect(
        _proof(table.copyWith(actionTrail: table.actionTrail.toList())),
        isNull,
        reason: 'No source contribution ledger',
      );
    },
  );

  test(
    'three-way: reject skipped or extra checks, wrong actor, and postflop wagers',
    () {
      final table = _shapes()
          .firstWhere(
            (row) => row.$1.startsWith('3way') && row.$1.contains('river'),
          )
          .$2;
      final labels = table.actionTrail.map((e) => e.label).toList();
      for (final bad in [
        [...labels]..removeAt(10),
        [...labels]..removeLast(),
        [...labels, 'river: ${table.decisionActorSeatId.toUpperCase()} checks'],
        [...labels]..[8] = 'flop: BB bets 1 BB',
        [...labels]..[8] = 'flop: BB checks 1 BB',
        [...labels]
          ..[8] = 'flop: ${table.decisionActorSeatId.toUpperCase()} checks',
      ]) {
        expect(_proof(_withTrail(table, bad)), isNull, reason: '$bad');
      }
    },
  );

  test('three-way turn decision after a fully checked flop', () {
    final river = _shapes()
        .firstWhere(
          (row) => row.$1.startsWith('3way') && row.$1.contains('river'),
        )
        .$2;
    final ledger = river.handContributions!;
    final table = river.copyWith(
      streetLabel: 'Turn',
      boardCards: river.boardCards.take(4).toList(),
      actionTrail: river.actionTrail.take(13).toList(),
      handContributions: Act0HandContributionsV1(
        throughStreet: PokerStreet.turn,
        startingStackBbBySeat: ledger.startingStackBbBySeat,
        entries: ledger.entries,
      ),
    );
    final plan = _proof(table)!;
    expect(plan.finalStreet, Act0TableChoreographyStreetV1.turn);
    expect(
      plan.verifiedHistory!.decisionError(table.decisionActorSeatId),
      isNull,
    );
    expect(
      plan.verifiedHistory!.contributions
          .amounts(
            seatIds: ledger.startingStackBbBySeat.keys.toSet(),
            actorSeatId: table.decisionActorSeatId,
          )
          .potBb,
      8,
    );
  });

  test(
    'three-way checks derive actors from the ledger, not one seat pattern',
    () {
      final table = _table(
        'co',
        PokerStreet.flop,
        const [
          'preflop: SB posts 0.5 BB',
          'preflop: BB posts 1 BB',
          'preflop: UTG raises to 2.5 BB',
          'preflop: HJ folds',
          'preflop: CO calls 2.5 BB',
          'preflop: BTN folds',
          'preflop: SB folds',
          'preflop: BB calls 1.5 BB more',
          'flop: BB checks',
          'flop: UTG checks',
        ],
        const {'hj', 'btn', 'sb'},
        const [('utg', 2.5), ('co', 2.5), ('bb', 1.5)],
        8,
        0,
      );
      final plan = _proof(table)!;
      expect(plan.verifiedHistory!.decisionError('co'), isNull);
      expect(plan.verifiedHistory!.contestablePots!.single.chips, 800);
      expect(plan.verifiedHistory!.contestablePots!.single.eligibleSeatIds, {
        'utg',
        'co',
        'bb',
      });
    },
  );

  test(
    '33 exact B164 rows certify D6 without new FAIL or animation rows',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds
          .where((w) => w.worldNumber >= 13 && w.worldNumber <= 24)
          .toList();
      final rows = auditTableTruth(worlds: worlds);
      final gained = <int, Set<String>>{};
      final actualRemaining = <int, Set<String>>{};
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
          if (_targetIds[world.worldNumber]?.contains(task.taskId) ?? false) {
            final plan = _proof(table)!;
            expect(
              plan.verifiedHistory!.decisionError(table.decisionActorSeatId),
              isNull,
              reason: task.taskId,
            );
            expect(d6?.result, 'PASS', reason: task.taskId);
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
            gained.putIfAbsent(world.worldNumber, () => {}).add(task.taskId);
          }
          if (d6 != null &&
              d6.result != 'PASS' &&
              !(d6.result == 'EXPLICIT_EXCEPTION' &&
                  task.phase == Act0LessonPhaseV1.theory &&
                  task.multiStreet == null &&
                  _noHandFacts(table) &&
                  task.runner.teachingSteps.every(
                    (step) => step.table == null || _noHandFacts(step.table!),
                  ))) {
            actualRemaining
                .putIfAbsent(world.worldNumber, () => {})
                .add(task.taskId);
          }
        }
      }
      expect(gained, _targetIds);
      expect(rows.where((r) => r.result == 'FAIL'), isEmpty);
      for (final entry in actualRemaining.entries) {
        expect(
          entry.value.difference(_remainingIds[entry.key] ?? {}),
          isEmpty,
          reason: 'W${entry.key}',
        );
      }
      for (final world in worlds) {
        final n = world.worldNumber;
        final before =
            (_targetIds[n]?.length ?? 0) + (_remainingIds[n]?.length ?? 0);
        final after = actualRemaining[n]?.length ?? 0;
        print('B164 W$n D6 residue $before -> $after');
      }
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
        '6cfeebdc6f2ab96c9811ddac244d52ff156cd94f1cba2a6e02f4ec694786106d',
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

List<(String, Act0TableStateV1, double, double)> _shapes() => [
  (
    '0way|6seats|preflop:p-p-f-f-r',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO raises to 2.5 BB',
      ],
      {'utg', 'hj'},
      [('co', 2.5)],
      4.0,
      2.5,
    ),
    4.0,
    2.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-r-f',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ raises to 2.5 BB',
        'preflop: CO folds',
      ],
      {'utg', 'co'},
      [('hj', 2.5)],
      4.0,
      2.5,
    ),
    4.0,
    2.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-r-c',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ raises to 2.5 BB',
        'preflop: CO calls 2.5 BB',
      ],
      {'utg'},
      [('hj', 2.5), ('co', 2.5)],
      6.5,
      2.5,
    ),
    6.5,
    2.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-r-f-f',
    _table(
      'bb',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO raises to 2.5 BB',
        'preflop: BTN folds',
        'preflop: SB folds',
      ],
      {'utg', 'sb', 'btn', 'hj'},
      [('co', 2.5)],
      4.0,
      1.5,
    ),
    4.0,
    1.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-r-r',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ raises to 2.5 BB',
        'preflop: CO raises to 8 BB',
      ],
      {'utg'},
      [('hj', 2.5), ('co', 8.0)],
      12.0,
      8.0,
    ),
    12.0,
    8.0,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-r-r-f-f',
    _table(
      'co',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO raises to 2.5 BB',
        'preflop: BTN raises to 8 BB',
        'preflop: SB folds',
        'preflop: BB folds',
      ],
      {'utg', 'sb', 'bb', 'hj'},
      [('co', 2.5), ('btn', 8.0)],
      12.0,
      5.5,
    ),
    12.0,
    5.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-f-f-l-r|limp',
    _table(
      'sb',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO folds',
        'preflop: BTN folds',
        'preflop: SB calls 0.5 BB more',
        'preflop: BB raises to 4 BB',
      ],
      {'utg', 'co', 'btn', 'hj'},
      [('sb', 0.5), ('bb', 3.0)],
      5.0,
      3.0,
    ),
    5.0,
    3.0,
  ),
  (
    '3way|6seats|preflop:p-p-f-r-c-f-f-c|flop:x-x-x|turn:x-x-x|river:x-x',
    _table(
      'co',
      PokerStreet.river,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ raises to 2.5 BB',
        'preflop: CO calls 2.5 BB',
        'preflop: BTN folds',
        'preflop: SB folds',
        'preflop: BB calls 1.5 BB more',
        'flop: BB checks',
        'flop: HJ checks',
        'flop: CO checks',
        'turn: BB checks',
        'turn: HJ checks',
        'turn: CO checks',
        'river: BB checks',
        'river: HJ checks',
      ],
      {'utg', 'sb', 'btn'},
      [('hj', 2.5), ('co', 2.5), ('bb', 1.5)],
      8.0,
      0.0,
    ),
    8.0,
    0.0,
  ),
  (
    '3way|6seats|preflop:p-p-f-r-c-f-f-c|flop:x-x',
    _table(
      'co',
      PokerStreet.flop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ raises to 2.5 BB',
        'preflop: CO calls 2.5 BB',
        'preflop: BTN folds',
        'preflop: SB folds',
        'preflop: BB calls 1.5 BB more',
        'flop: BB checks',
        'flop: HJ checks',
      ],
      {'utg', 'sb', 'btn'},
      [('hj', 2.5), ('co', 2.5), ('bb', 1.5)],
      8.0,
      0.0,
    ),
    8.0,
    0.0,
  ),
  (
    '3way|6seats|preflop:p-p-f-f-r-c-f-c|flop:x-x-x|turn:x-x-x|river:x-x',
    _table(
      'btn',
      PokerStreet.river,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO raises to 2.5 BB',
        'preflop: BTN calls 2.5 BB',
        'preflop: SB folds',
        'preflop: BB calls 1.5 BB more',
        'flop: BB checks',
        'flop: CO checks',
        'flop: BTN checks',
        'turn: BB checks',
        'turn: CO checks',
        'turn: BTN checks',
        'river: BB checks',
        'river: CO checks',
      ],
      {'utg', 'sb', 'hj'},
      [('co', 2.5), ('btn', 2.5), ('bb', 1.5)],
      8.0,
      0.0,
    ),
    8.0,
    0.0,
  ),
  (
    '3way|6seats|preflop:p-p-f-f-r-c-f-c|flop:x-x',
    _table(
      'btn',
      PokerStreet.flop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO raises to 2.5 BB',
        'preflop: BTN calls 2.5 BB',
        'preflop: SB folds',
        'preflop: BB calls 1.5 BB more',
        'flop: BB checks',
        'flop: CO checks',
      ],
      {'utg', 'sb', 'hj'},
      [('co', 2.5), ('btn', 2.5), ('bb', 1.5)],
      8.0,
      0.0,
    ),
    8.0,
    0.0,
  ),
  (
    '0way|6seats|preflop:p-p-f-l-l|limp',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ calls 1 BB',
        'preflop: CO calls 1 BB',
      ],
      {'utg'},
      [('hj', 1.0), ('co', 1.0)],
      3.5,
      1.0,
    ),
    3.5,
    1.0,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-f',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO folds',
      ],
      {'utg', 'co', 'hj'},
      [],
      1.5,
      1.0,
    ),
    1.5,
    1.0,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-f-r-f',
    _table(
      'bb',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO folds',
        'preflop: BTN raises to 2.5 BB',
        'preflop: SB folds',
      ],
      {'utg', 'sb', 'co', 'hj'},
      [('btn', 2.5)],
      4.0,
      1.5,
    ),
    4.0,
    1.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-f-f',
    _table(
      'sb',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO folds',
        'preflop: BTN folds',
      ],
      {'utg', 'co', 'btn', 'hj'},
      [],
      1.5,
      0.5,
    ),
    1.5,
    0.5,
  ),
  (
    '0way|6seats|preflop:p-p-f-f-f-r-f-r',
    _table(
      'btn',
      PokerStreet.preflop,
      [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        'preflop: CO folds',
        'preflop: BTN raises to 2.5 BB',
        'preflop: SB folds',
        'preflop: BB raises to 10 BB',
      ],
      {'utg', 'sb', 'co', 'hj'},
      [('btn', 2.5), ('bb', 9.0)],
      13.0,
      7.5,
    ),
    13.0,
    7.5,
  ),
];
const _targetIds = <int, Set<String>>{
  17: {
    'w17_5_day7_three_bet_dead_blind',
    'w17_5_guided_compare_deep_sizes',
    'w17_1_transfer_select_bluff_candidate',
    'w17_1_day7_light_bluff_signal',
    'w17_2_transfer_squeeze_all_fold',
    'w17_2_day7_squeeze_fails_if_one_stays',
    'w17_3_read_cold_call_identity',
    'w17_1_read_blocked_aces',
    'w17_2_guided_size_oop',
    'w17_5_read_blind_on_blind_trap',
    'w17_4_read_four_bet_additional_cost',
  },
  18: {
    'w18_2_read_joint_outcome',
    'w18_5_read_overlimp',
    'w18_1_day7_multiple_value_calls',
    'w18_2_transfer_profitable_joint_bluff',
    'w18_3_read_three_way_nuts',
    'w18_2_guided_joint_folds_price',
    'w18_6_day7_tie_with_three_players',
    'w18_4_guided_refund_uncalled',
    'w18_4_day7_award_eligible_pots',
    'w18_4_read_side_pot_layers',
    'w18_2_day7_conditional_fold_count',
    'w18_6_read_blockers_across_two_players',
    'w18_3_day7_connected_caller_edge',
    'w18_1_read_compression_vs_hand_label',
  },
  23: {
    'w23_6_guided_build_light_three_bet',
    'w23_3_transfer_open_size_buys_folds',
    'w23_5_guided_sb_mixed_tree',
    'w23_6_read_blocker_value_four_bet',
    'w23_2_read_notation_after_blocker',
    'w23_5_transfer_depth_changes_available_payoff',
    'w23_3_guided_bb_two_sizes_compare',
    'w23_2_guided_compare_wheel_and_broadway',
  },
};
const _remainingIds = <int, Set<String>>{
  15: {'w15_5_read_first_flop_actor'},
  16: {
    'w16_4_read_probe_sequence',
    'w16_5_read_turn_overbet_leverage',
    'w16_5_day7_called_turn_overbet',
  },
  17: {
    'w17_3_guided_count_caller_coverage',
    'w17_6_read_lower_spr_mechanics',
    'w17_4_day7_spr_after_four_bet',
  },
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
    'w22_4_day7_change_input_requires_new_query',
    'w22_6_checkpoint_audit_pruned_solver_result',
  },
};
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
