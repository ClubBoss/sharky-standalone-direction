import 'package:poker_analyzer/ui_v2/act0_shell/act0_b19_turn_truth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test('Live Room is independent of the numbered curriculum pilot', () {
    final disabled = Act0ShellStateV1.catalog(liveRoomV1: false);
    final enabled = Act0ShellStateV1.catalog(liveRoomV1: true);
    expect(disabled.liveRoom, isNull);
    expect(
      enabled.liveRoom!.lessons.expand((lesson) => lesson.taskList),
      hasLength(27),
    );
    expect(enabled.worlds, same(disabled.worlds));
    expect(
      enabled.worlds.last.worldNumber,
      act0CurriculumPilotEnabledV1 ? 24 : 12,
    );
  });

  test(
    'flag off preserves the ordered W1–W12 learner route and XP',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      expect(
        worlds.map((world) => world.worldNumber),
        List.generate(12, (i) => i + 1),
      );
      final route = [
        for (final world in worlds)
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              [world.worldId, lesson.lessonId, task.taskId, task.rewardXp],
      ];
      // Pre-B92 HEAD baseline (498 tasks), including order and XP.
      expect(
        sha256.convert(utf8.encode(jsonEncode(route))).toString(),
        '6cfeebdc6f2ab96c9811ddac244d52ff156cd94f1cba2a6e02f4ec694786106d',
      );
    },
    skip: act0CurriculumPilotEnabledV1,
  );

  test(
    'pilot keeps lesson identities distinct and passes C1 for every dealt frame',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      final lessons = worlds.expand((world) => world.lessons).toList();
      expect(lessons.map((l) => l.lessonId).toSet(), hasLength(lessons.length));
      expect(
        worlds
            .singleWhere((w) => w.worldNumber == 14)
            .lessons
            .singleWhere((l) => l.lessonId == 'w14_spr_and_commitment')
            .authoredLessonId,
        'spr_and_commitment',
      );
      expect(
        worlds
            .singleWhere((w) => w.worldNumber == 15)
            .lessons
            .singleWhere((l) => l.lessonId == 'w15_protection_and_denial')
            .authoredLessonId,
        'protection_and_denial',
      );
      expect(
        worlds.map((w) => w.worldNumber),
        List.generate(act0LastCurriculumWorldV1, (i) => i + 1),
      );
      final options = catalogTasks
          .where(
            (row) =>
                row.world.worldNumber >= 13 &&
                !_b19Lessons.contains(row.lesson.lessonId),
          )
          .expand((row) => row.task.runner.options)
          .where(
            (option) => option.quality == Act0FeedbackQualityV1.acceptable,
          );
      expect(options, hasLength(3));
      expect(options.every(act0RunnerOptionIsAuthoredCorrectV1), isTrue);
      expect(options.any(act0RunnerOptionIsPreferredV1), isFalse);
      final played = catalogTasks.where(
        (row) =>
            row.world.worldNumber >= 13 &&
            !_b19Lessons.contains(row.lesson.lessonId) &&
            row.task.runner.table.scope == Act0TableScopeV1.playedHand,
      );
      expect(played, hasLength(291));
      for (final row in played) {
        final checks = auditTableContributionsV1(
          row.task.taskId,
          'decision',
          row.task.runner.table,
        );
        expect(
          checks.map((check) => check.invariant),
          contains('D2.pot_feasibility'),
        );
        expect(
          checks.map((check) => check.result),
          everyElement('PASS'),
          reason: row.task.taskId,
        );
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  test(
    'W17–W24 use the accepted C1 pots and call prices',
    () {
      const prices = {..._b4Prices, ..._b5Prices, ..._b6Prices, ..._b7Prices};
      final rows = catalogTasks.where(
        (row) => row.world.worldNumber >= 17 && row.world.worldNumber <= 24,
      );
      for (final world in [17, 18, 19, 20, 21, 22, 23, 24]) {
        expect(
          rows.where((row) => row.world.worldNumber == world),
          hasLength(30),
        );
      }
      // E39: W21–W24 mechanisms have no catalog enum equivalent.
      expect(
        rows
            .where((row) => row.world.worldNumber >= 21)
            .map((row) => act0DecisionReasoningV1[row.task.taskId]),
        everyElement(isNull),
      );
      final played = rows.where(
        (row) => row.task.runner.table.scope == Act0TableScopeV1.playedHand,
      );
      expect(
        played.map((row) => row.task.taskId),
        unorderedEquals(prices.keys),
      );
      for (final row in played) {
        final id = row.task.taskId;
        final table = row.task.runner.table;
        final ledger = table.handContributions!;
        final hero = table.heroSeat.seatId;
        final amounts = ledger.amounts(
          seatIds: table.seats.map((seat) => seat.seatId).toSet(),
          actorSeatId: hero,
        );
        final paid = <String, double>{};
        for (final entry in ledger.entries) {
          final delta = entry.kind == Act0ContributionKindV1.uncalledReturn
              ? -entry.amountBb
              : entry.amountBb;
          paid.update(
            entry.seatId,
            (total) => total + delta,
            ifAbsent: () => delta,
          );
        }
        final due = amounts.toCallBb!;
        final cap = (paid[hero] ?? 0) + due;
        final eligiblePot = paid.values.fold<double>(
          0,
          (sum, amount) => sum + (amount > cap ? cap : amount),
        );
        expect(
          (
            amounts.potBb,
            due,
            due == 0 ? null : (1000 * due / (eligiblePot + due)).round() / 10,
          ),
          prices[id],
          reason: id,
        );
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  test('turn choices reject flop, private and fixed-opponent cards', () {
    const hero = ['Ah', '6h'];
    const flop = ['Kh', '8h', '3c'];
    const range = [
      ['Ks', 'Kd'],
    ];
    for (final illegal in ['Kh', 'Ah', 'Ks', '2c', 'ZZ']) {
      expect(
        () => act0B92TurnChoicesV1(
          hero: hero,
          flop: flop,
          range: range,
          reference: '2c',
          candidates: {'turn': illegal},
          price: 1 / 3,
        ),
        throwsArgumentError,
      );
    }
    final atPrice = act0B92TurnChoicesV1(
      hero: hero,
      flop: flop,
      range: range,
      reference: '2c',
      candidates: {'heart': 'Qh', 'blank': '4c'},
      price: 1 / 3,
    );
    expect(atPrice.changingIds, {'heart'});
    final highPrice = act0B92TurnChoicesV1(
      hero: hero,
      flop: flop,
      range: range,
      reference: '2c',
      candidates: {'heart': 'Qh', 'blank': '4c', 'none': null},
      price: 0.95,
    );
    expect(highPrice.changingIds, {'none'});
  });

  test(
    'mistake grade follows the contribution ledger, not a pinned answer',
    () {
      final task = catalogTasks
          .singleWhere((row) => row.task.taskId == 'mistake_already_committed')
          .task;
      final table = task.runner.table;
      final ledger = table.handContributions!;
      // Raising to 12 instead of 9 makes the 9 BB call annotation true and
      // the old raise annotation false. It must not retain the original grade.
      final changed = Act0HandContributionsV1(
        throughStreet: ledger.throughStreet,
        startingStackBbBySeat: ledger.startingStackBbBySeat,
        entries: [
          for (final e in ledger.entries)
            if (e.street == ledger.throughStreet && e.seatId == 'bb')
              Act0ContributionV1(e.street, e.seatId, e.kind, 12)
            else
              e,
        ],
      );
      final truth = act0B92MistakeTruthV1(
        task.taskId,
        table.copyWith(handContributions: changed),
      );
      expect(truth.mistakes['price'], isFalse);
      expect(truth.mistakes['raise'], isTrue);
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

  for (final taskId in ['mistake_half_pot', 'turn_heart_completes']) {
    for (final chooseCorrect in [true, false]) {
      testWidgets(
        'B92 existing runner grades $taskId (correct=$chooseCorrect)',
        (tester) async {
          final row = catalogTasks.singleWhere(
            (row) => row.task.taskId == taskId,
          );
          final task = row.task;
          final chosen = task.runner.options.firstWhere(
            (o) => o.isCorrect == chooseCorrect,
          );
          final taps = <Act0RunnerOptionV1>[];
          tester.view.physicalSize = const Size(393, 852);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Act0LessonRunnerShellV1(
                  runner: task.runner,
                  selectedWorldId: row.world.worldId,
                  selectedLessonId: row.lesson.lessonId,
                  selectedTaskId: taskId,
                  selectedTaskFamily: task.resolvedTaskFamily,
                  onBack: () {},
                  onContinueTheory: () {},
                  onChooseOption: taps.add,
                  onContinueReview: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final option in task.runner.options) {
            expect(
              find.byKey(Key('act0_shell_option_${option.id}')),
              findsOneWidget,
            );
          }
          final target = find.byKey(Key('act0_shell_option_${chosen.id}'));
          await tester.ensureVisible(target);
          await tester.tap(target);
          await tester.pumpAndSettle();
          expect(taps.single.id, chosen.id);
          expect(taps.single.isCorrect, chooseCorrect);
          expect(
            taps.single.feedbackReason,
            contains(taskId.startsWith('mistake') ? 'Mistake:' : '33.3%'),
          );
          expect(tester.takeException(), isNull);
        },
        skip: !act0CurriculumPilotEnabledV1,
      );
    }
  }

  test('B19 flag, drill shape and accepted C1 prices', () {
    final drills = catalogTasks.where(
      (row) => _b19Lessons.contains(row.lesson.lessonId),
    );
    if (!act0CurriculumPilotEnabledV1) {
      expect(drills, isEmpty);
      return;
    }
    expect(
      drills.map((row) => row.task.taskId),
      unorderedEquals(_b19Prices.keys),
    );
    for (final lesson in _b19Lessons) {
      expect(
        drills.where((row) => row.lesson.lessonId == lesson),
        hasLength(10),
      );
    }
    for (final row in drills) {
      final task = row.task;
      final runner = task.runner;
      final table = runner.table;
      final ledger = table.handContributions!;
      final id = task.taskId;
      final amounts = ledger.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: table.heroSeat.seatId,
      );
      final due = amounts.toCallBb!;
      final streetCommitment = ledger.entries
          .where((entry) => entry.street == ledger.throughStreet)
          .fold<double>(
            0,
            (net, entry) => entry.kind == Act0ContributionKindV1.uncalledReturn
                ? net - entry.amountBb
                : net + entry.amountBb,
          );
      expect(
        (
          due == 0 ? amounts.potBb : amounts.potBb - streetCommitment,
          amounts.potBb,
          due,
          due == 0 ? null : (1000 * due / (amounts.potBb + due)).round() / 10,
        ),
        _b19Prices[id],
        reason: id,
      );
      final checks = auditTableContributionsV1(id, 'decision', table);
      expect(
        checks.map((check) => check.invariant),
        contains('D2.pot_feasibility'),
      );
      expect(
        checks.map((check) => check.result),
        everyElement('PASS'),
        reason: id,
      );
      expect(row.world.worldNumber, 14, reason: id);
      expect(task.phase, Act0LessonPhaseV1.drill, reason: id);
      expect(runner.teachingSteps, isEmpty, reason: id);
      expect(runner.sizingConfig.isEnabled, isFalse, reason: id);
      expect(
        runner.options.where(act0RunnerOptionIsPreferredV1),
        hasLength(1),
        reason: id,
      );
      expect(
        runner.options.map((option) => option.id).toSet(),
        hasLength(runner.options.length),
        reason: id,
      );
      expect(table.heroCards, hasLength(2), reason: id);
      if (row.lesson.lessonId == 'where_is_the_mistake') {
        final truth = act0B92MistakeTruthV1(id, table);
        expect(
          truth.mistakes.values.where((wrong) => wrong),
          hasLength(1),
          reason: id,
        );
        expect(
          truth.mistakes.keys,
          unorderedEquals(runner.options.map((o) => o.id)),
        );
        final wrong = runner.options.singleWhere((o) => truth.mistakes[o.id]!);
        expect(wrong.id, _b92MistakeIds[id], reason: id);
        expect(wrong.quality, Act0FeedbackQualityV1.correct, reason: id);
        for (final option in runner.options) {
          expect(
            option.quality,
            truth.mistakes[option.id]!
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            reason: id,
          );
          expect(option.feedbackReason, contains(wrong.label), reason: id);
          expect(option.feedbackReason, contains(truth.correction), reason: id);
        }
      }
      if (row.lesson.lessonId == 'turn_card_impact') {
        expect(table.boardCards, hasLength(3), reason: id);
        expect(table.highlightedCardIds, isEmpty, reason: id);
        expect(table.toCallLabel, isEmpty, reason: id);
        final (rangeText, reference, correctId, refEquity, correctEquity) =
            _b92TurnCases[id]!;
        final hero = table.heroCards.map((card) => card.label).toList();
        final flop = table.boardCards.map((card) => card.label).toList();
        final range = rangeText
            .split(' ')
            .map((combo) => [combo.substring(0, 2), combo.substring(2)])
            .toList();
        final candidates = {
          for (final o in runner.options)
            o.id: o.label == 'None of these' ? null : o.label,
        };
        final price = act0B92TurnPriceV1(
          ledger,
          seats: table.seats.map((s) => s.seatId).toSet(),
          hero: table.heroSeat.seatId,
          opponent: 'bb',
        );
        expect(price.bet, amounts.potBb, reason: id);
        expect(price.pot, 19, reason: id);
        expect(price.due, 9.5, reason: id);
        expect(price.price, closeTo(1 / 3, 1e-12), reason: id);
        for (final card in candidates.values.whereType<String>()) {
          expect(act0B19DeckV1, contains(card), reason: id);
          expect([...hero, ...flop], isNot(contains(card)), reason: id);
          expect(range.any((hand) => !hand.contains(card)), isTrue, reason: id);
        }
        final result = act0B92TurnChoicesV1(
          hero: hero,
          flop: flop,
          range: range,
          reference: reference,
          candidates: candidates,
          price: price.price,
        );
        expect(result.changingIds, {correctId}, reason: id);
        expect(result.referenceShare, closeTo(refEquity, 0.0001), reason: id);
        if (correctEquity != null)
          expect(
            result.shares[correctId],
            closeTo(correctEquity, 0.0001),
            reason: id,
          );
        for (final option in runner.options) {
          expect(
            option.quality,
            option.id == correctId
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            reason: id,
          );
          expect(option.feedbackReason, contains('33.3%'), reason: id);
          expect(option.feedbackReason, contains('showdown share'), reason: id);
        }
      }
      if (row.lesson.lessonId == 'slightly_harder') {
        expect(task.resolvedTaskFamily, Act0TaskFamilyV1.transfer, reason: id);
      }
    }
  });
}

// Independently pinned answer identities and evaluator shares for the ten
// recognition drills; the third B19 lesson retains its accepted grades.
const _b92MistakeIds = {
  'mistake_half_pot': 'river_bet',
  'mistake_minimum_raise': 'short_raise',
  'mistake_already_committed': 'price',
  'mistake_turn_straight_call': 'bad_call',
  'mistake_turn_flush_fold': 'fold',
  'mistake_worse_calls': 'check',
  'mistake_bluff_calls': 'big',
  'mistake_known_blocker': 'count',
  'mistake_matched_amount': 'all',
  'mistake_implied_cap': 'extra',
};
const _b92TurnCases = <String, (String, String, String, double, double?)>{
  'turn_heart_completes': ('KsKd KcKd 8s8d', '2c', 'good', 7 / 44, 102 / 132),
  'turn_heart_pairs_board': ('KsKd KcKd 8s8d', 'Qh', 'bad', 102 / 132, 0),
  'turn_straight_completes': (
    'AsAd AcAs QhQc',
    '2d',
    'good',
    24 / 132,
    128 / 132,
  ),
  'turn_overcard_beats_pair': (
    'AcKc AdKd AcTd',
    '2c',
    'bad',
    117 / 132,
    6 / 132,
  ),
  'turn_remove_high_draw': (
    'AhKc AhJc ThTc Ah9h',
    'As',
    'good',
    44 / 176,
    111 / 132,
  ),
  'turn_counterfeit_two_pair': (
    'AcAd AsAh QcQd',
    '2c',
    'bad',
    108 / 132,
    12 / 132,
  ),
  'turn_redraw_good': ('AhJh AhTh QhJh', '2h', 'good', 30 / 132, 1),
  'turn_board_four_to_straight': (
    'JdTd JcTh Tc5c',
    '2c',
    'bad',
    105 / 132,
    1.5 / 132,
  ),
  'turn_dead_draw': ('Js8s JsTs Js9s', '3c', 'unchanged', 0, null),
  'turn_turn_makes_set': ('AhQh AsKd AcJd', '2c', 'good', 6 / 132, 1),
};

const _b19Lessons = {
  'where_is_the_mistake',
  'turn_card_impact',
  'slightly_harder',
};

// Accepted B17 values: pot before the street's bets when facing a wager,
// pot including matched stakes, amount to call, and percent needed.
const _b19Prices = <String, (double, double, double, double?)>{
  "mistake_half_pot": (6.0, 6.0, 0, null),
  "mistake_minimum_raise": (5.5, 9.5, 4.0, 29.6),
  "mistake_already_committed": (5.5, 17.5, 6.0, 25.5),
  "mistake_turn_straight_call": (5.5, 9.5, 4.0, 29.6),
  "mistake_turn_flush_fold": (5.5, 6.5, 1.0, 13.3),
  "mistake_worse_calls": (5.5, 5.5, 0, null),
  "mistake_bluff_calls": (5.5, 5.5, 0, null),
  "mistake_known_blocker": (5.5, 5.5, 0, null),
  "mistake_matched_amount": (5.5, 11.5, 6.0, 34.3),
  "mistake_implied_cap": (5.5, 8.5, 3.0, 26.1),
  "turn_heart_completes": (9.5, 9.5, 0, null),
  "turn_heart_pairs_board": (9.5, 9.5, 0, null),
  "turn_straight_completes": (9.5, 9.5, 0, null),
  "turn_overcard_beats_pair": (9.5, 9.5, 0, null),
  "turn_remove_high_draw": (9.5, 9.5, 0, null),
  "turn_counterfeit_two_pair": (9.5, 9.5, 0, null),
  "turn_redraw_good": (9.5, 9.5, 0, null),
  "turn_board_four_to_straight": (9.5, 9.5, 0, null),
  "turn_dead_draw": (9.5, 9.5, 0, null),
  "turn_turn_makes_set": (9.5, 9.5, 0, null),
  "harder_dirty_flush": (11.5, 14.5, 3.0, 17.1),
  "harder_straight_price_rises": (11.5, 18.0, 6.5, 26.5),
  "harder_remove_missed_hearts": (11.5, 18.5, 7.0, 27.5),
  "harder_leave_misses_unblocked": (11.5, 19.5, 8.0, 29.1),
  "harder_river_value_added": (11.5, 20.5, 9.0, 30.5),
  "harder_paired_river_boats": (11.5, 21.5, 10.0, 31.7),
  "harder_worse_calls_larger": (11.5, 11.5, 0, null),
  "harder_overbet_passes_value": (11.5, 11.5, 0, null),
  "harder_block_weaker_flushes": (11.5, 11.5, 0, null),
  "harder_shorter_implied_payment": (11.5, 16.0, 4.5, 22.0),
};

// Accepted W17–W18 values: total pot, call amount, and eligible-pot equity.
const _b4Prices = <String, (double, double, double?)>{
  'w17_1_read_blocked_aces': (4, 2.5, 38.5),
  'w17_1_guided_choose_value_job': (4, 2.5, 38.5),
  'w17_1_transfer_select_bluff_candidate': (4, 2.5, 38.5),
  'w17_1_day7_light_bluff_signal': (4, 2.5, 38.5),
  'w17_2_read_squeeze_price': (6.5, 2.5, 27.8),
  'w17_2_guided_size_oop': (4, 1.5, 27.3),
  'w17_2_transfer_squeeze_all_fold': (6.5, 2.5, 27.8),
  'w17_2_day7_squeeze_fails_if_one_stays': (6.5, 2.5, 27.8),
  'w17_3_read_cold_call_identity': (12, 8, 40.0),
  'w17_3_guided_count_caller_coverage': (20.5, 0, null),
  'w17_3_transfer_defend_dry_3bet': (26.5, 6, 18.5),
  'w17_3_day7_coverage_still_prices_call': (43.5, 23, 34.6),
  'w17_4_read_four_bet_additional_cost': (12, 5.5, 31.4),
  'w17_4_guided_four_bet_bluff_model': (12, 5.5, 31.4),
  'w17_4_transfer_short_three_bet_shove': (32.5, 12, 27.0),
  'w17_4_day7_spr_after_four_bet': (48.5, 0, null),
  'w17_5_read_blind_on_blind_trap': (5, 3, 37.5),
  'w17_5_guided_compare_deep_sizes': (4, 1.5, 27.3),
  'w17_5_transfer_trap_not_triggered': (1.5, 0.5, 25.0),
  'w17_5_day7_three_bet_dead_blind': (12, 5.5, 31.4),
  'w17_6_read_lower_spr_mechanics': (50.5, 0, null),
  'w17_6_guided_small_cbet_three_bet': (20.5, 0, null),
  'w17_6_checkpoint_four_bet_shove': (125.5, 75, 37.4),
  'w17_6_day7_narrow_range_small_call': (63.5, 15, 19.1),
  'w18_1_read_compression_vs_hand_label': (8, 0, null),
  'w18_1_guided_check_top_pair': (8, 0, null),
  'w18_1_transfer_set_value_two_callers': (8, 0, null),
  'w18_1_day7_multiple_value_calls': (8, 0, null),
  'w18_2_read_joint_outcome': (8, 0, null),
  'w18_2_guided_joint_folds_price': (8, 0, null),
  'w18_2_transfer_profitable_joint_bluff': (8, 0, null),
  'w18_2_day7_conditional_fold_count': (8, 0, null),
  'w18_3_read_three_way_nuts': (8, 0, null),
  'w18_3_guided_check_closes': (8, 0, null),
  'w18_3_transfer_oop_check_may_face_bet': (8, 0, null),
  'w18_3_day7_connected_caller_edge': (8, 0, null),
  'w18_4_read_side_pot_layers': (8, 0, null),
  'w18_4_guided_refund_uncalled': (8, 0, null),
  'w18_4_transfer_call_only_eligible_pot': (50, 5, 14.3),
  'w18_4_day7_award_eligible_pots': (8, 0, null),
  'w18_5_read_overlimp': (3.5, 1, 22.2),
  'w18_5_guided_short_raise_no_reopen': (32, 3, 8.6),
  'w18_5_transfer_overcall_price': (16, 4, 20.0),
  'w18_5_day7_full_raise_reopens': (35, 6, 14.6),
  'w18_6_read_blockers_across_two_players': (8, 0, null),
  'w18_6_guided_value_on_blank': (8, 0, null),
  'w18_6_checkpoint_two_caller_check': (8, 0, null),
  'w18_6_day7_tie_with_three_players': (8, 0, null),
};

// Accepted W19–W20 values: total pot, call amount, and eligible-pot equity.
const _b5Prices = <String, (double, double, double?)>{
  'w19_1_read_information_value': (9.5, 4, 29.6),
  'w19_1_guided_respond_to_extra_bluffs': (10.5, 5, 32.3),
  'w19_1_transfer_pick_baseline_when_uncertain': (11.5, 6, 34.3),
  'w19_1_day7_counter_changes_with_strategy': (10.5, 5, 32.3),
  'w19_2_read_overfold_denominator': (5.5, 0, null),
  'w19_2_guided_bluff_pool_overfold': (5.5, 0, null),
  'w19_2_transfer_pool_underfold': (5.5, 0, null),
  'w19_2_day7_pool_overbluffs_size': (18.5, 8, 30.2),
  'w19_3_read_site_and_type': (5.5, 0, null),
  'w19_3_guided_depth_split': (5.5, 0, null),
  'w19_3_transfer_overcalls_draws': (5.5, 0, null),
  'w19_3_day7_anonymous_fastfold': (10.5, 5, 32.3),
  'w19_4_read_predictable_single_size': (5.5, 0, null),
  'w19_4_guided_adaptation_before': (5.5, 0, null),
  'w19_4_transfer_adaptation_after': (5.5, 0, null),
  'w19_4_day7_simplify_mix': (5.5, 0, null),
  'w19_5_read_cap_can_vanish': (5.5, 0, null),
  'w19_5_guided_attack_a_proven_cap': (5.5, 0, null),
  'w19_5_transfer_no_attack_into_traps': (6.5, 0, null),
  'w19_5_day7_runout_nuts_after_check': (5.5, 0, null),
  'w19_6_read_self_audit_ratio': (11, 5.5, 33.3),
  'w19_6_guided_depth_changes_counter': (32.5, 12, 27.0),
  'w19_6_checkpoint_which_data_controls': (8.5, 0, null),
  'w19_6_day7_audit_which_hands_fold': (13.5, 8, 37.2),
  'w20_1_read_time_bank_context': (10.5, 5, 32.3),
  'w20_1_guided_compare_matched_timing': (5.5, 0, null),
  'w20_1_transfer_live_baseline_break': (11.5, 6, 34.3),
  'w20_1_day7_distracted_online_sample': (13.5, 8, 37.2),
  'w20_2_read_filter_action_chain': (15.5, 6, 27.9),
  'w20_2_guided_value_heavy_size': (17.5, 8, 31.4),
  'w20_2_transfer_large_size_polar': (20.5, 9, 30.5),
  'w20_2_day7_unfamiliar_size_fold': (23.5, 12, 33.8),
  'w20_3_read_reg_vs_crusher': (5.5, 0, null),
  'w20_3_guided_raise_larger_inelastic': (5.5, 0, null),
  'w20_3_transfer_stakes_discomfort_caveat': (5.5, 0, null),
  'w20_3_day7_table_captain_vs_overbluffer': (11.5, 6, 34.3),
  'w20_4_read_more_limpers_change_price': (3.5, 1, 22.2),
  'w20_4_guided_isolation_two_sizes': (3.5, 1, 22.2),
  'w20_4_transfer_skip_marginal_isolation': (5, 0, null),
  'w20_4_day7_value_adjust_to_sticky': (7.5, 2, 21.1),
  'w20_5_read_third_level': (5.5, 0, null),
  'w20_5_guided_keep_table_welcoming': (5.5, 0, null),
  'w20_5_transfer_image_changes_value': (5.5, 0, null),
  'w20_5_day7_dont_use_private_image': (5.5, 0, null),
  'w20_6_read_confirmation_counterexample': (11.5, 6, 34.3),
  'w20_6_guided_short_price_with_read': (32.5, 12, 27.0),
  'w20_6_checkpoint_filter_then_call': (19.5, 8, 29.1),
  'w20_6_day7_late_sizing_update': (19.5, 8, 29.1),
};

// Accepted W21–W22 values: total pot, call amount, and eligible-pot equity.
const _b6Prices = <String, (double, double, double?)>{
  'w21_1_read_variance_vs_process': (5.5, 0, null),
  'w21_1_guided_follow_pause_protocol': (5.5, 0, null),
  'w21_1_transfer_loss_with_sound_process': (5.5, 0, null),
  'w21_1_day7_win_checks_still_apply': (5.5, 0, null),
  'w21_2_read_time_vs_condition': (5.5, 0, null),
  'w21_2_guided_warmup_play_review': (5.5, 0, null),
  'w21_2_transfer_stop_win_based_on_behavior': (5.5, 0, null),
  'w21_2_day7_leave_when_time_expires': (5.5, 0, null),
  'w21_3_read_seat_change_current_game': (5.5, 0, null),
  'w21_3_guided_find_own_leak': (5.5, 0, null),
  'w21_3_transfer_switch_table_when_behind': (5.5, 0, null),
  'w21_3_day7_better_table_not_enough': (5.5, 0, null),
  'w21_4_read_slowplay_cost': (5.5, 0, null),
  'w21_4_guided_simple_value_over_disguise': (5.5, 0, null),
  'w21_4_transfer_short_stack_limits_call': (32.5, 12, 27.0),
  'w21_4_day7_take_worse_pair_payment': (5.5, 0, null),
  'w21_5_read_useful_tag': (5.5, 0, null),
  'w21_5_guided_choose_review_priority': (5.5, 0, null),
  'w21_5_transfer_review_without_result': (10.5, 5, 32.3),
  'w21_5_day7_filter_by_same_opportunity': (5.5, 0, null),
  'w21_6_read_outcome_not_repair': (5.5, 0, null),
  'w21_6_guided_plan_if_then': (5.5, 0, null),
  'w21_6_checkpoint_select_end_and_tag': (5.5, 0, null),
  'w21_6_day7_reset_next_block': (5.5, 0, null),
  'w22_1_read_actions_in_order': (5.5, 0, null),
  'w22_1_guided_count_tree_leaves': (5.5, 0, null),
  'w22_1_transfer_river_no_chance_node': (9.5, 4, 29.6),
  'w22_1_day7_turn_chance_node': (5.5, 0, null),
  'w22_2_read_one_matrix_cell': (5.5, 0, null),
  'w22_2_guided_indifference_mix': (5.5, 0, null),
  'w22_2_transfer_best_response_not_equilibrium': (5.5, 0, null),
  'w22_2_day7_equilibrium_deviation_test': (5.5, 0, null),
  'w22_3_read_hand_vs_range': (5.5, 0, null),
  'w22_3_guided_compute_regret': (5.5, 0, null),
  'w22_3_transfer_sample_frequency_not_quota': (5.5, 0, null),
  'w22_3_day7_regret_for_check': (5.5, 0, null),
  'w22_4_read_pruned_action': (5.5, 0, null),
  'w22_4_guided_compress_only_like_states': (5.5, 0, null),
  'w22_4_transfer_short_tree_price': (32.5, 12, 27.0),
  'w22_4_day7_change_input_requires_new_query': (5.5, 0, null),
  'w22_5_read_output_as_scope': (5.5, 0, null),
  'w22_5_guided_heuristic_tolerance': (5.5, 0, null),
  'w22_5_transfer_population_query': (5.5, 0, null),
  'w22_5_day7_simplification_does_not_transfer': (5.5, 0, null),
  'w22_6_read_plan_gaps': (5.5, 0, null),
  'w22_6_guided_compare_branch_plans': (5.5, 0, null),
  'w22_6_checkpoint_audit_pruned_solver_result': (5.5, 0, null),
  'w22_6_day7_read_lead_plan': (5.5, 0, null),
};

// Accepted W23–W24 values: total pot, call amount, and eligible-pot equity.
const _b7Prices = <String, (double, double, double?)>{
  'w23_1_read_utg_medium_hj': (1.5, 1, 40.0),
  'w23_1_guided_hj_opens_medium': (1.5, 1, 40.0),
  'w23_1_transfer_co_opens_sevens': (1.5, 1, 40.0),
  'w23_1_day7_btn_medium_queen': (1.5, 1, 40.0),
  'w23_2_read_notation_after_blocker': (1.5, 1, 40.0),
  'w23_2_guided_compare_wheel_and_broadway': (1.5, 1, 40.0),
  'w23_2_transfer_connectivity_vs_nut_potential': (5.5, 0, null),
  'w23_2_day7_which_flush_is_nut': (5.5, 0, null),
  'w23_3_read_bb_minraise': (3.5, 1, 22.2),
  'w23_3_guided_bb_two_sizes_compare': (4, 1.5, 27.3),
  'w23_3_transfer_open_size_buys_folds': (1.5, 1, 40.0),
  'w23_3_day7_different_prices_different_calls': (4.5, 2, 30.8),
  'w23_4_read_raise_number': (31.5, 14, 30.8),
  'w23_4_guided_third_seat_facing_reraise': (13.5, 9, 40.0),
  'w23_4_transfer_five_bet_price_flips': (58.5, 13, 18.2),
  'w23_4_day7_four_bet_value_response': (12, 5.5, 31.4),
  'w23_5_read_sb_uncovered': (1.5, 0.5, 25.0),
  'w23_5_guided_sb_mixed_tree': (1.5, 0.5, 25.0),
  'w23_5_transfer_depth_changes_available_payoff': (13, 7.5, 36.6),
  'w23_5_day7_bb_raise_reprices_complete': (5, 3, 37.5),
  'w23_6_read_blocker_value_four_bet': (13, 7.5, 36.6),
  'w23_6_guided_build_light_three_bet': (4, 2.5, 38.5),
  'w23_6_checkpoint_combine_coverage_price_and_depth': (13.5, 9, 40.0),
  'w23_6_day7_choose_chart_only_matching_line': (4, 2.5, 38.5),
  'w24_1_read_classify_river_groups': (5.5, 0, null),
  'w24_1_guided_condensed_bluff_catcher': (19.5, 8, 29.1),
  'w24_1_transfer_keep_middle_check': (5.5, 0, null),
  'w24_1_day7_condensed_calls_sized_bluffs': (13.5, 8, 37.2),
  'w24_2_read_price_vs_alpha': (23, 11.5, 33.3),
  'w24_2_guided_overbet_mdf': (20, 12, 37.5),
  'w24_2_transfer_bluff_threshold_overpot': (11.5, 0, null),
  'w24_2_day7_call_price_vs_range_mdf': (35.5, 15, 29.7),
  'w24_3_read_ratio_three_quarter': (5.5, 0, null),
  'w24_3_guided_fractional_bluff_weight': (5.5, 0, null),
  'w24_3_transfer_indifferent_range_blocks': (11, 5.5, 33.3),
  'w24_3_day7_ratio_for_double_pot': (5.5, 0, null),
  'w24_4_read_nut_flush_removal': (5.5, 0, null),
  'w24_4_guided_overbet_collect_nut_value': (5.5, 0, null),
  'w24_4_transfer_effective_price_river': (35.5, 9, 20.2),
  'w24_4_day7_blocker_vs_fold_group': (5.5, 0, null),
  'w24_5_read_what_thin_raise_costs': (7.5, 2, 21.1),
  'w24_5_guided_thin_value_raise': (7.5, 2, 21.1),
  'w24_5_transfer_thin_raise_becomes_call': (7.5, 2, 21.1),
  'w24_5_day7_check_marginal_showdown': (5.5, 0, null),
  'w24_6_read_raise_bluff_risk': (15.5, 4, 20.5),
  'w24_6_guided_raise_blocker_bluff': (15.5, 4, 20.5),
  'w24_6_checkpoint_value_check_raise': (15.5, 4, 20.5),
  'w24_6_day7_no_bluff_without_folds': (13.5, 8, 37.2),
};
