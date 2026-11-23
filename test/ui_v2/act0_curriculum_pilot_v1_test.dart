import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
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
      // N3 baseline, including task order and each task's award.
      expect(
        sha256.convert(utf8.encode(jsonEncode(route))).toString(),
        '58a0269a4fb9bc31cf3f172af93cd766b22e330ad54070b995284c0338907380',
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
      expect(played, hasLength(144));
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
    'W17–W18 use the accepted C1 pots and call prices',
    () {
      final rows = catalogTasks.where(
        (row) => row.world.worldNumber == 17 || row.world.worldNumber == 18,
      );
      for (final world in [17, 18]) {
        expect(
          rows.where((row) => row.world.worldNumber == world),
          hasLength(30),
        );
      }
      final played = rows.where(
        (row) => row.task.runner.table.scope == Act0TableScopeV1.playedHand,
      );
      expect(
        played.map((row) => row.task.taskId),
        unorderedEquals(_b4Prices.keys),
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
          _b4Prices[id],
          reason: id,
        );
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );

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
      if (row.lesson.lessonId == 'turn_card_impact') {
        expect(table.boardCards, hasLength(4), reason: id);
        expect(table.highlightedCardIds, ['board_3'], reason: id);
        expect(table.toCallLabel, isEmpty, reason: id);
      }
      if (row.lesson.lessonId == 'slightly_harder') {
        expect(task.resolvedTaskFamily, Act0TaskFamilyV1.transfer, reason: id);
      }
    }
  });
}

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
