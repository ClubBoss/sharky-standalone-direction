import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_route_practice_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_decision_copy_v1.dart';
import '../support/act0_catalog_reasoning_audit_v1.dart';
import '../support/act0_catalog_rubric_guards_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_day7_coverage_v1.dart';
import '../support/act0_table_truth_v1.dart';

const _principles = {
  'range_advantage',
  'nut_advantage',
  'backdoor_equity',
  'deny_equity',
  'earned_slowplay',
  'equity_realization',
  'flop_raise_shape',
  'flop_texture_coverage',
  'induce_raise',
  'initiative',
  'lead_and_stab',
  'polarized_sizing',
  'price_vs_equity',
  'size_range_signal',
  'spr_commitment',
  'texture_cbet_frequency',
  'merged_sizing',
};

void main() {
  test('Vol1 course order and XP are unchanged by principle transfer', () {
    final route = [
      for (final world in Act0ShellStateV1.sample.worlds)
        if (world.worldNumber <= 12)
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              [world.worldId, lesson.lessonId, task.taskId, task.rewardXp],
    ];
    // B151: W11 review-loop intro changes lesson; task order and XP stay fixed.
    expect(
      sha256.convert(utf8.encode(jsonEncode(route))).toString(),
      '4188b79e962253220a409352ab8859c06b09f6ccc0f543421ff5b11a2aa018d1',
    );
  });

  test('Day 7 pilot isolation, unique principles and novel spots', () {
    // act0NewReviewTasksV1 also owns the two original W1 check hands.
    final day7 = act0NewReviewTasksV1.where(
      (entry) => !const {
        'spaced_review_check_turn_v1',
        'spaced_review_check_river_v1',
      }.contains(entry.task.taskId),
    );
    final ids = act0NewReviewTasksV1.map((entry) => entry.task.taskId);
    expect(ids.toSet(), hasLength(ids.length));
    final pilot = day7
        .where((entry) => int.parse(entry.worldId.substring(6)) >= 13)
        .toList();
    // The main-branch Vol1 catalog has 168 _day7ExampleV1 entries plus
    // 37 explicit W9–W12 records (8 W9, 15 W10, 7 W11, 7 W12).
    const vol1Day7Count = 205;
    expect(day7.length - pilot.length, vol1Day7Count);
    if (!act0CurriculumPilotEnabledV1) {
      expect(pilot, isEmpty);
      expect(day7, hasLength(vol1Day7Count));
      return;
    }
    expect(pilot, hasLength(17));
    final lessonRows = catalogTasks.where(
      (row) => row.world.worldNumber >= 13 && row.world.worldNumber <= 24,
    );
    final lessonPrinciples = lessonRows
        .map((row) => act0DecisionReasoningV1[row.task.taskId]?.principleId)
        .whereType<String>()
        .toSet();
    expect(lessonPrinciples, containsAll(_principles));
    final seen = <String>{};
    final seenHands = <String>{};
    // A different seat or a permuted flop alone is not a new hand.
    String spotCards(Act0TableStateV1 table) {
      final hand = table.heroCards.map(cardIdentity).toList()..sort();
      final board = table.boardCards.map(cardIdentity).toList();
      final flop = board.take(3).toList()..sort();
      return '${hand.join(',')}|${[...flop, ...board.skip(3)].join(',')}';
    }

    final courseHands = catalogTasks
        .map((row) => spotCards(row.task.runner.table))
        .toSet();
    final courseIds = catalogTasks.map((row) => row.task.taskId).toSet();
    for (final entry in pilot) {
      final id = entry.task.taskId;
      final meta = act0DecisionReasoningV1[id]!;
      expect(seen.add(meta.principleId), isTrue, reason: id);
      expect(entry.conceptFamilyId, meta.principleId, reason: id);
      expect(
        id,
        'spaced_review_w${entry.worldId.substring(6)}_${entry.lessonId}_${entry.conceptFamilyId}_v1',
      );
      expect(courseIds, isNot(contains(id)));
      expect(
        seenHands.add(spotCards(entry.task.runner.table)),
        isTrue,
        reason: id,
      );
      expect(entry.task.rewardXp, 0);
      expect(
        entry.task.runner.options.where((option) => option.isCorrect),
        hasLength(1),
      );
      expect(
        courseHands,
        isNot(contains(spotCards(entry.task.runner.table))),
        reason: id,
      );
      final sources = lessonRows.where(
        (row) =>
            row.world.worldId == entry.worldId &&
            row.lesson.lessonId == entry.lessonId &&
            act0DecisionReasoningV1[row.task.taskId]?.principleId ==
                meta.principleId,
      );
      expect(sources, isNotEmpty, reason: id);
      expect(
        act0Day7MissSourcesV1.containsKey((
          entry.worldId,
          entry.lessonId,
          entry.conceptFamilyId,
        )),
        isTrue,
        reason: 'No current due-review source for $id',
      );
      expect(
        atlasDay7CoversV1((
          entry.worldId,
          entry.lessonId,
          entry.conceptFamilyId,
        )),
        isTrue,
        reason: id,
      );
      for (final source in sources) {
        expect(
          act0Day7FamilyForSourceV1(
            worldId: entry.worldId,
            lessonId: entry.lessonId,
            taskId: source.task.taskId,
            family: 'hero_cards_board_pot',
          ),
          entry.conceptFamilyId,
        );
      }
      expect(
        act0ReviewOnlyTaskV1(entry.worldId, entry.lessonId, id),
        same(entry.task),
      );
      expect(act0RoutePracticeRepsByIdV1[id]?.task, same(entry.task));
      expect(
        act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: entry.worldId,
          lessonId: entry.lessonId,
          taskId: id,
        ),
        isNotNull,
      );
      final table = entry.task.runner.table;
      final amounts = table.handContributions!.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: table.heroSeatId,
      );
      final pot = amounts.potBb;
      final due = amounts.toCallBb ?? 0;
      // Independently evaluate the stated terminal response models using the
      // physical contribution ledger, not the amounts written in feedback.
      double betEv(double size, double folds, double share) =>
          folds * pot + (1 - folds) * (share * (pot + 2 * size) - size);
      final edge = switch (meta.principleId) {
        'range_advantage' => .8 * 2 - .2 * 2,
        'nut_advantage' => .5 * (6 - 3),
        'price_vs_equity' => .30 * (pot + due) - due,
        'equity_realization' => .6 * pot + 4,
        'backdoor_equity' => due - (10 / 47 * 9 / 46) * (pot + due),
        'initiative' => betEv(2, .4, .2) - .35 * pot,
        'merged_sizing' => (.7 * 2 - .3 * 2) - (-.3 * 6),
        'polarized_sizing' => betEv(7, .65, 0) - betEv(2, .25, 0),
        'size_range_signal' => due - .15 * (pot + due),
        'spr_commitment' => due - .18 * (pot + due),
        'induce_raise' => .5 * (8 - 6),
        'texture_cbet_frequency' => .20 * pot - betEv(3, .15, .12),
        'deny_equity' => .25 * pot,
        'earned_slowplay' => .98 * (pot + 4) - 2 - pot,
        'flop_texture_coverage' => .22 * pot - betEv(4, .20, .10),
        'lead_and_stab' => betEv(4, .5, .30),
        'flop_raise_shape' =>
          .4 * pot +
              .6 * (.75 * (pot + 12 + 8) - 12) -
              (.8 * (pot + due) - due),
        _ => throw StateError('Missing model for $id'),
      };
      expect(meta.edgeBb, closeTo(edge, .005), reason: id);
      expect(edge, greaterThan(0), reason: id);
      final row = day7CatalogTasks.singleWhere((row) => row.task.taskId == id);
      expect(auditCatalogReasoningV1(row)!.findings, isEmpty, reason: id);
      expect(auditDecisionCopyV1(row), isEmpty, reason: id);
      expect(catalogRubricFindingsV1(entry.task), isEmpty, reason: id);
      expect(
        auditTableContributionsV1(
          id,
          'day7',
          entry.task.runner.table,
        ).where((finding) => finding.result != 'PASS'),
        isEmpty,
        reason: id,
      );
    }
    expect(seen, _principles);
  });
}
