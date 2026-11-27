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

void main() {
  for (final hero in ['co', 'btn']) {
    for (final river in [false, true]) {
      test(
        '$hero open, ${river ? 'checked through to river' : 'flop check'}',
        () {
          final table = _table(hero, river);
          final plan = act0TableChoreographyPlanForTableV1(table)!;
          expect(table.autoPlayHistory, isFalse);
          final history = plan.verifiedHistory!;
          expect(history.coverage, Act0HandHistoryCoverageV1.complete);
          expect(history.decisionError(hero), isNull);
          final pot = history.contestablePots!.single;
          expect(pot.chips, 550);
          expect(pot.eligibleSeatIds, {hero, 'bb'});
          expect(history.contributions.entries.map((e) => e.amountBb), [
            0.5,
            1,
            2.5,
            1.5,
          ]);
          expect(
            history.events
                .whereType<Act0HandActionV1>()
                .where((e) => e.verb == Act0HandVerbV1.check)
                .map((e) => e.seat),
            river ? ['bb', hero, 'bb', hero, 'bb'] : ['bb'],
          );
          expect(
            plan.beats.where(
              (b) => b.kind == Act0TableChoreographyBeatKindV1.commitmentMove,
            ),
            hasLength(4),
          );
          final frame = act0TableChoreographyFrameAfterBeatV1(
            plan,
            plan.beats.length - 2,
          );
          expect(frame.visibleBoardCardCount, river ? 5 : 3);
          expect(frame.commitments, isEmpty);
          expect(
            act0TableForChoreographyFrameV1(table, frame).potLabel,
            'Pot 5.5 BB',
          );
          expect(
            plan.beats.last.kind,
            Act0TableChoreographyBeatKindV1.heroDecisionReady,
          );
        },
      );
    }
  }

  test('rejects illegal, incomplete and unknown checked histories', () {
    final table = _table('co', true);
    final trail = table.actionTrail.map((e) => e.label).toList();
    for (final bad in [
      [...trail]..[8] = 'flop: CO checks',
      [...trail]..[8] = 'flop: BB waves',
      [...trail]..[8] = 'flop: BB checks 1 BB',
      [...trail]..[7] = 'preflop: BB calls 1 BB more',
      [...trail]..removeAt(9),
      [...trail]..removeLast(),
      [...trail, 'river: CO checks'],
      [...trail]..[12] = 'river: BB bets 1 BB',
      <String>[],
    ]) {
      final changed = table.copyWith(
        actionTrail: [
          for (final label in bad) Act0ActionTrailItemV1(label: label),
        ],
        handContributions: table.handContributions,
      );
      expect(
        act0TableChoreographyPlanForTableV1(changed),
        isNull,
        reason: '$bad',
      );
    }
    expect(
      act0TableChoreographyPlanForTableV1(table.copyWith(decisionSeatId: 'bb')),
      isNull,
    );
    expect(
      act0TableChoreographyPlanForTableV1(
        table.copyWith(autoPlayHistory: true),
      ),
      isNull,
    );
    expect(
      act0TableChoreographyPlanForTableV1(
        table.copyWith(scope: Act0TableScopeV1.orientation),
      ),
      isNull,
    );
  });

  test(
    'pilot checked-history cohort is certified through D6, not animated',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds
          .where((w) => w.worldNumber >= 13 && w.worldNumber <= 24)
          .toList();
      final rows = auditTableTruth(worlds: worlds);
      final counts = <String, int>{};
      final accepted = <String>{};
      final noHistory = <String>{};
      for (final world in worlds) {
        for (final lesson in world.lessons) {
          for (final task in lesson.taskList) {
            final table = task.runner.table;
            if (table.scope != Act0TableScopeV1.explanation ||
                table.tableFormat != Act0TableFormatV1.sixMax)
              continue;
            final labels = table.actionTrail
                .where((e) => !e.isNote)
                .map((e) => e.label)
                .toList();
            if (labels.isEmpty) noHistory.add(task.taskId);
            final shape = labels
                .map((label) => RegExp(r'^(\w+): \S+ (\w+)').firstMatch(label))
                .map((m) => m == null ? '?' : '${m[1]}:${m[2]}')
                .join(' ');
            const pre =
                'preflop:posts preflop:posts preflop:folds preflop:folds ';
            const call = 'preflop:calls flop:checks';
            final co = '${pre}preflop:raises preflop:folds preflop:folds $call';
            final btn =
                '${pre}preflop:folds preflop:raises preflop:folds $call';
            const checked = ' flop:checks turn:checks turn:checks river:checks';
            final expected = [
              co,
              btn,
              '$co$checked',
              '$btn$checked',
            ].contains(shape);
            final proof = act0TableChoreographyPlanForTableV1(table);
            expect(proof != null, expected, reason: task.taskId);
            if (!expected) continue;
            accepted.add(task.taskId);
            counts.update(shape, (n) => n + 1, ifAbsent: () => 1);
            expect(table.autoPlayHistory, isFalse, reason: task.taskId);
            expect(
              proof!.verifiedHistory!.coverage,
              Act0HandHistoryCoverageV1.complete,
              reason: task.taskId,
            );
            expect(
              proof.verifiedHistory!.decisionError(table.decisionActorSeatId),
              isNull,
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
          }
        }
      }
      expect(counts.values.toList()..sort(), [10, 13, 17, 17]);
      expect(accepted, hasLength(57));
      expect(
        rows.where(
          (r) =>
              accepted.contains(r.taskId) &&
              r.variant.startsWith('choreography/'),
        ),
        isEmpty,
        reason: 'Explanation history proof must not add animation frames',
      );
      final baseline =
          jsonDecode(
                File(
                  'test/fixtures/act0_catalog_vol2_baseline_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final remaining = <String>{
        for (final world in baseline.values)
          for (final finding in (world['D6.history_support'] ?? []) as List)
            finding as String,
      };
      final actual = {
        for (final row in rows)
          if (row.invariant == 'D6.history_support' && row.result != 'PASS')
            '${row.taskId}|${row.variant}|${row.detail}',
      };
      expect(
        actual.difference(remaining),
        isEmpty,
        reason: 'D6 must not introduce any new census finding',
      );
      expect(
        remaining.where((row) => accepted.contains(row.split('|').first)),
        isEmpty,
        reason: 'Remove only the source-proven checked-history findings',
      );

      expect(rows.where((r) => r.result == 'FAIL'), isEmpty);
      expect(noHistory, hasLength(72));
      expect(
        rows.where(
          (r) =>
              noHistory.contains(r.taskId) &&
              r.invariant == 'D6.history_support' &&
              r.result == 'EXPLICIT_EXCEPTION',
        ),
        hasLength(72),
      );
      expect(
        rows
            .where(
              (r) => r.invariant == 'D6.history_support' && r.result != 'PASS',
            )
            .length,
        lessThanOrEqualTo(160),
      );
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  test(
    'W1–W12 all table plans, catalog snapshot, route and XP are unchanged',
    () {
      final worlds = Act0ShellStateV1.authoredCatalog.worlds.where(
        (w) => w.worldNumber <= 12,
      );
      for (final world in worlds) {
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
              final actual = act0TableChoreographyPlanForTableV1(table);
              expect(
                _bytes(actual),
                _bytes(originChoreographyPlanV1(table)),
                reason: task.taskId,
              );
              expect(actual?.verifiedHistory, isNull, reason: task.taskId);
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

Act0TableStateV1 _table(String hero, bool river) {
  final street = river ? PokerStreet.river : PokerStreet.flop;
  const seats = ['utg', 'hj', 'co', 'btn', 'sb', 'bb'];
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
          isInHand: seat == hero || seat == 'bb',
          isFolded: seat != hero && seat != 'bb',
        ),
    ],
    heroCards: const [],
    boardCards: [
      const Act0CardStateV1(rank: 'K', suit: 'c'),
      const Act0CardStateV1(rank: '7', suit: 'h'),
      const Act0CardStateV1(rank: '2', suit: 's'),
      if (river) ...[
        const Act0CardStateV1(rank: '3', suit: 'd'),
        const Act0CardStateV1(rank: '4', suit: 'c'),
      ],
    ],
    streetLabel: river ? 'River' : 'Flop',
    potLabel: 'Pot 5.5 BB',
    toCallLabel: '',
    centerLabel: '',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    actionTrail: [
      for (final label in [
        'preflop: SB posts 0.5 BB',
        'preflop: BB posts 1 BB',
        'preflop: UTG folds',
        'preflop: HJ folds',
        if (hero == 'btn') 'preflop: CO folds',
        'preflop: ${hero.toUpperCase()} raises to 2.5 BB',
        if (hero == 'co') 'preflop: BTN folds',
        'preflop: SB folds',
        'preflop: BB calls 1.5 BB more',
        'flop: BB checks',
        if (river) ...[
          'flop: ${hero.toUpperCase()} checks',
          'turn: BB checks',
          'turn: ${hero.toUpperCase()} checks',
          'river: BB checks',
        ],
      ])
        Act0ActionTrailItemV1(label: label),
    ],
    handContributions: Act0HandContributionsV1(
      throughStreet: street,
      startingStackBbBySeat: {for (final seat in seats) seat: 100},
      entries: [
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
        Act0ContributionV1(
          PokerStreet.preflop,
          hero,
          Act0ContributionKindV1.wager,
          2.5,
        ),
        const Act0ContributionV1(
          PokerStreet.preflop,
          'bb',
          Act0ContributionKindV1.wager,
          1.5,
        ),
      ],
    ),
  );
}
