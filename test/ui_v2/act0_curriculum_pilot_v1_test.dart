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
      expect(worlds.map((w) => w.worldNumber), List.generate(16, (i) => i + 1));
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
      expect(played, hasLength(96));
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
