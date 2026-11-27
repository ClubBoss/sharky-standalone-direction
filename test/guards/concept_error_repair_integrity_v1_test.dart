import 'package:flutter_test/flutter_test.dart';

import '../../tools/transfer_novelty_check_v1.dart';
import '../support/act0_b153_transfer_novelty_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('concept taxonomy is exact, unique, internal, and route-complete', () {
    final definitions = act0ConceptErrorDefinitionsV1;
    expect(definitions, hasLength(20));
    expect(definitions.map((entry) => entry.id).toSet(), hasLength(20));
    for (final definition in definitions) {
      expect(definition.id, matches(RegExp(r'^[a-z][a-z0-9_]+$')));
      expect(definition.learnerInterpretation.trim(), isNotEmpty);
      expect(definition.sourceConceptOwner.trim(), isNotEmpty);
      expect(definition.eligibleRepairFamily.trim(), isNotEmpty);
      expect(definition.learnerVisible, isFalse);
      expect(definition.persisted, isTrue);
      expect(definition.emittedInTelemetry, isTrue);
      expect(act0IsReadableErrorTypeV1(definition.id), isTrue);
    }
    for (final legacy in act0LegacyGenericErrorTypesV1) {
      expect(act0IsReadableErrorTypeV1(legacy), isTrue);
    }

    final used = <String>{};
    for (final row in _assessedRows()) {
      final definition = act0ConceptErrorDefinitionForTaskV1(
        worldId: row.worldId,
        lessonId: row.lessonId,
        taskId: row.task.taskId,
      );
      expect(definition, isNotNull, reason: row.path);
      used.add(definition!.id);
      for (final option in row.task.runner.options.where(
        (option) => !option.isCorrect,
      )) {
        final intent = buildAct0RepairIntentV1(
          sourceWorldId: row.worldId,
          sourceLessonId: row.lessonId,
          sourceTaskId: row.task.taskId,
          runner: row.task.runner,
          selectedOption: option,
          mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
        );
        expect(intent, isNotNull, reason: '${row.path}/${option.id}');
        expect(intent!.errorType, definition.id);
        expect(
          act0LegacyGenericErrorTypesV1,
          isNot(contains(intent.errorType)),
        );
      }
    }
    expect(used, definitions.map((entry) => entry.id).toSet());
  });

  test('all adjudicated routes have one explicit truthful disposition', () {
    const expectedSources = <String>[
      'world_1/what_poker_is/what_poker_is_find_hero',
      'world_3/position_checkpoint/position_checkpoint_position_checkpoint_table_notice',
      'world_1/first_table_guide/what_poker_is_table_read_recheck',
      'world_1/what_poker_is_content/what_poker_is_pot_stack',
      'world_1/what_poker_is_content/what_poker_is_win_ways',
      'world_1/what_poker_is_content/what_poker_is_all_in_meaning',
      'world_1/what_poker_is_content/what_poker_is_matched_chips_transfer',
      'world_1/what_poker_is_content/what_poker_is_live_win_transfer',
      'world_1/what_poker_is_content/what_poker_is_review',
      'world_1/cards_ranks_suits/cards_ranks_suits_theory',
      'world_1/cards_ranks_suits/cards_ranks_suits_rank_drill',
      'world_1/cards_ranks_suits/cards_ranks_suits_suit_drill',
      'world_1/your_first_hand/your_first_hand_private_cards_recheck',
      'world_1/fold_check_call_raise/actions_check_drill',
      'world_1/fold_check_call_raise/actions_call_drill',
      'world_1/blinds_action_order/blinds_posts_drill',
      'world_1/blinds_order_practice/blinds_first_actor',
      'world_1/blinds_order_practice/blinds_last_actor',
      'world_1/blinds_order_practice/blinds_review',
      'world_1/blinds_action_order/positions_utg',
      'world_1/blinds_action_order/positions_cutoff',
      'world_1/positions/positions_early_late',
      'world_2/hand_discipline_apply/apply_hj_decision',
      'world_3/position_six_seats/position_six_seats_positions_utg',
      'world_3/position_six_seats/position_six_seats_hj_co_contrast',
      'world_3/position_six_seats/position_six_seats_positions_cutoff',
      'world_3/position_six_seats/position_six_seats_sb_recognition',
      'world_3/position_six_seats/position_six_seats_bb_recognition',
      'world_3/position_six_seats/position_six_seats_position_repair_seat_id_utg',
      'world_3/position_six_seats/position_six_seats_positions_review',
      'world_3/early_vs_late/early_vs_late_w2_early_position',
      'world_3/early_vs_late/early_vs_late_early_pressure_choice',
      'world_3/early_vs_late/early_vs_late_position_repair_utg_players_behind',
      'world_3/early_vs_late/early_vs_late_late_info_choice',
      'world_3/same_hand_different_seat/same_hand_different_seat_position_repair_same_hand_different_seat',
      'world_8/spr_and_commitment/what_poker_is_side_pot_intro',
      'world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_recap',
    ];
    // Preserve the original 37 dispositions as a cohort when lesson ownership moves.
    expect(act0RepairGapAdjudicationsV1, hasLength(306));
    final rows = act0RepairGapAdjudicationsV1.take(37).toList();
    expect(rows, hasLength(37));
    expect(
      rows
          .map(
            (row) =>
                '${row.sourceWorldId}/${row.sourceLessonId}/${row.sourceTaskId}',
          )
          .toList(),
      expectedSources,
    );
    expect(rows.map((row) => row.sourceTaskId).toSet(), hasLength(37));

    final counts = <Act0RepairGapOutcomeV1, int>{};
    for (final row in rows) {
      counts.update(row.outcome, (value) => value + 1, ifAbsent: () => 1);
      expect(
        row.priorFallback,
        row.sourceTaskId == 'what_poker_is_find_hero'
            ? 'mapped_wrong_signal:world_3/position_checkpoint/'
                  'position_checkpoint_position_checkpoint_table_notice:'
                  'players_behind'
            : row.sourceTaskId == 'same_hand_different_seat_w3_same_hand_recap'
            ? 'mapped_wrong_signal:world_3/position_checkpoint/'
                  'position_checkpoint_position_checkpoint_table_notice:hero_button'
            : 'unrecorded_exact_source_fallback',
      );
      expect(row.leaksOriginalAnswer, isFalse);
      expect(row.requiresFutureKnowledge, isFalse);
      expect(
        _find(row.sourceWorldId, row.sourceLessonId, row.sourceTaskId),
        isNotNull,
        reason: row.sourceTaskId,
      );
      final definition = act0ConceptErrorDefinitionForTaskV1(
        worldId: row.sourceWorldId,
        lessonId: row.sourceLessonId,
        taskId: row.sourceTaskId,
      );
      expect(definition?.id, row.conceptErrorId);

      final mapped = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_${definition!.eligibleRepairFamily}',
        skillAtomId: definition.eligibleRepairFamily,
        sourceSignalId: definition.id,
        sourceTaskId: row.sourceTaskId,
        receiptOutcome: 'repair_started',
      );
      expect(mapped?.mappingType, row.mappingType);
      if (row.outcome == Act0RepairGapOutcomeV1.alternateSameSignalTarget) {
        final source = _find(
          row.sourceWorldId,
          row.sourceLessonId,
          row.sourceTaskId,
        )!;
        final target = _find(
          row.targetWorldId!,
          row.targetLessonId!,
          row.targetTaskId!,
        );
        expect(target, isNotNull, reason: row.targetTaskId);
        expect(target!.phase, Act0LessonPhaseV1.drill);
        expect(target.taskId, isNot(source.taskId));
        expect(target.runner.question, isNot(source.runner.question));
        expect(
          int.parse(row.targetWorldId!.substring('world_'.length)),
          lessThanOrEqualTo(
            int.parse(row.sourceWorldId.substring('world_'.length)),
          ),
        );
      }
    }
    expect(counts, <Act0RepairGapOutcomeV1, int>{
      Act0RepairGapOutcomeV1.alternateSameSignalTarget: 20,
      // B153 removes the old W8 alternate: both offered the answer 20 BB.
      Act0RepairGapOutcomeV1.unresolvedProductGap: 1,
      // The prior 15 dispositions remain; this one context definition adds one.
      Act0RepairGapOutcomeV1.intentionalExactReplay: 15 + 1,
    });
    expect(
      rows
          .where(
            (row) => row.outcome == Act0RepairGapOutcomeV1.unresolvedProductGap,
          )
          .map((row) => row.sourceTaskId),
      ['what_poker_is_side_pot_intro'],
    );
    final blindsReview = rows.singleWhere(
      (row) => row.sourceTaskId == 'blinds_review',
    );
    expect(blindsReview.outcome, Act0RepairGapOutcomeV1.intentionalExactReplay);
    expect(blindsReview.targetTaskId, isNull);
    final w1HeroButton = rows.singleWhere(
      (row) => row.sourceTaskId == 'what_poker_is_find_hero',
    );
    expect(w1HeroButton.priorFallback, contains('players_behind'));
    expect(
      w1HeroButton.outcome,
      Act0RepairGapOutcomeV1.alternateSameSignalTarget,
    );
    expect(w1HeroButton.targetLessonId, w1HeroButton.sourceLessonId);
    expect(w1HeroButton.targetTaskId, 'first_table_guide_shared_cards_repair');
    final coPlayersBehind = rows.singleWhere(
      (row) =>
          row.sourceTaskId ==
          'position_checkpoint_position_checkpoint_table_notice',
    );
    expect(
      coPlayersBehind.outcome,
      Act0RepairGapOutcomeV1.intentionalExactReplay,
    );
    expect(coPlayersBehind.priorFallback, 'unrecorded_exact_source_fallback');
    expect(coPlayersBehind.targetWorldId, isNull);
    expect(coPlayersBehind.targetLessonId, isNull);
    expect(coPlayersBehind.targetTaskId, isNull);
  });
  test('B153 accounts for every G1 miss with earlier, non-exact targets', () {
    final snapshot = readB153Snapshot();
    final routeIndex = {
      for (final (index, task) in snapshot.values.indexed) task.id: index,
    };
    final lessonOrder = <(int, String), int>{};
    for (final task in snapshot.values.where((task) => task.course)) {
      lessonOrder.putIfAbsent((
        task.world,
        task.lesson,
      ), () => lessonOrder.length);
    }
    final live = {
      for (final row in [...catalogTasks, ...day7CatalogTasks])
        '${row.world.worldId}/${row.lesson.lessonId}/${row.task.taskId}':
            row.task,
    };
    final expected = snapshot.values
        .where((task) => task.world >= 7 && task.world <= 12 && task.hasMiss)
        .map((task) => task.id)
        .toSet();
    final rows = act0RepairGapAdjudicationsV1
        .where((row) => int.parse(row.sourceWorldId.substring(6)) >= 7)
        .toList();
    expect(rows.map((row) => row.sourceTaskId).toSet(), expected);
    expect(
      rows.length,
      expected.length,
      reason: 'Exactly one disposition per source',
    );
    final counts = <int, List<int>>{
      for (var w = 7; w <= 12; w++) w: [0, 0, 0],
    };
    final alternates = <String>{};
    String label(Act0RunnerOptionV1 option) => option.amountLabel.isEmpty
        ? option.label.trim()
        : '${option.label.trim()} [${option.amountLabel.trim()}]';
    for (final row in rows) {
      final source = snapshot[row.sourceTaskId]!;
      final sourceTask =
          live['${row.sourceWorldId}/${row.sourceLessonId}/${row.sourceTaskId}'];
      expect(sourceTask, isNotNull, reason: row.sourceTaskId);
      expect(source.world, int.parse(row.sourceWorldId.substring(6)));
      expect(source.lesson, row.sourceLessonId);
      expect(
        sourceTask!.runner.options.any(
          (option) =>
              option.quality == Act0FeedbackQualityV1.wrong ||
              option.quality == Act0FeedbackQualityV1.suboptimal,
        ),
        isTrue,
      );
      expect(
        act0ConceptErrorDefinitionForTaskV1(
          worldId: row.sourceWorldId,
          lessonId: row.sourceLessonId,
          taskId: row.sourceTaskId,
        )?.id,
        row.conceptErrorId,
      );
      expect(row.leaksOriginalAnswer, isFalse);
      expect(row.requiresFutureKnowledge, isFalse);
      final concept = act0ConceptErrorDefinitionForTaskV1(
        worldId: row.sourceWorldId,
        lessonId: row.sourceLessonId,
        taskId: row.sourceTaskId,
      )!;
      final mapping = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_${concept.eligibleRepairFamily}',
        skillAtomId: concept.eligibleRepairFamily,
        sourceSignalId: concept.id,
        sourceTaskId: row.sourceTaskId,
        receiptOutcome: 'repair_started',
      );
      expect(mapping?.mappingType, row.mappingType, reason: row.sourceTaskId);
      expect(
        mapping?.taskId,
        row.targetTaskId ?? row.sourceTaskId,
        reason: row.sourceTaskId,
      );
      expect(row.learnerEquivalenceRationale, isNotEmpty);
      expect(
        row.learnerEquivalenceRationale,
        isNot('same concept and signal; different authored decision'),
      );
      if (row.outcome == Act0RepairGapOutcomeV1.alternateSameSignalTarget) {
        counts[source.world]![0]++;
        alternates.add(row.sourceTaskId);
        expect(row.candidateTargetIds, [row.targetTaskId]);
        final target = snapshot[row.targetTaskId]!;
        final targetTask =
            live['${row.targetWorldId}/${row.targetLessonId}/${row.targetTaskId}'];
        expect(targetTask, isNotNull, reason: row.targetTaskId);
        expect(
          target.course,
          isTrue,
          reason: 'Day 7-only content is not a route target',
        );
        expect(targetTask!.phase, Act0LessonPhaseV1.drill);
        expect(routeIndex[target.id], lessThan(routeIndex[source.id]!));
        expect(target.world, lessThanOrEqualTo(source.world));
        expect(
          lessonOrder[(target.world, target.lesson)],
          lessThanOrEqualTo(lessonOrder[(source.world, source.lesson)]!),
          reason: 'Review-only sources cannot point to later lessons',
        );
        expect(target.world, int.parse(row.targetWorldId!.substring(6)));
        expect(target.lesson, row.targetLessonId);
        expect(
          act0ConceptErrorDefinitionForTaskV1(
            worldId: row.targetWorldId!,
            lessonId: row.targetLessonId!,
            taskId: target.id,
          )?.id,
          row.conceptErrorId,
        );
        expect(
          source.correct.toSet().intersection(target.choices.toSet()),
          isEmpty,
          reason: row.sourceTaskId,
        );
        expect(
          sourceTask.runner.options
              .where((o) => o.quality.isPreferred)
              .map(label)
              .toSet()
              .intersection(targetTask.runner.options.map(label).toSet()),
          isEmpty,
          reason: row.sourceTaskId,
        );
        final witness = b153Witnesses[source.id]!;
        expect(witness.$1, target.id);
        final novelty = classifyTransferPairV2(
          b153Spot(source, witness.$2, witness.$4, witness.$5),
          b153Spot(target, witness.$3, witness.$4, witness.$6),
        );
        expect(novelty.exactReplay, isFalse);
        expect(
          novelty.result.classification,
          TransferNoveltyV1.changedDecision,
          reason: row.sourceTaskId,
        );
      } else {
        expect(row.candidateTargetIds, isEmpty);
        expect(row.targetTaskId, isNull);
        expect(row.targetWorldId, isNull);
        expect(row.targetLessonId, isNull);
        switch (row.outcome) {
          case Act0RepairGapOutcomeV1.intentionalExactReplay:
            counts[source.world]![1]++;
          case Act0RepairGapOutcomeV1.unresolvedProductGap:
            counts[source.world]![2]++;
          default:
            fail('B153 must not declare new content: ${row.sourceTaskId}');
        }
      }
    }
    expect(alternates, b153Witnesses.keys.toSet());
    expect(counts, {
      7: [5, 0, 16],
      8: [14, 1, 35],
      9: [5, 9, 23],
      10: [5, 7, 33],
      11: [4, 11, 40],
      12: [11, 13, 34],
    });
    for (final entry in counts.entries) {
      // ignore: avoid_print
      print(
        'B153 W${entry.key}: ${entry.value[0]} alternate / ${entry.value[1]} exact / ${entry.value[2]} gap',
      );
    }
  });
}

List<_RouteRow> _assessedRows() => <_RouteRow>[
  for (final world in Act0ShellStateV1.sample.worlds)
    if (RegExp(r'^world_([1-9]|1[0-2])$').hasMatch(world.worldId))
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          if (task.runner.options.length >= 2 &&
              task.runner.options.where((option) => option.isCorrect).length ==
                  1)
            _RouteRow(world.worldId, lesson.lessonId, task),
];

Act0LessonTaskV1? _find(String worldId, String lessonId, String taskId) {
  final world = Act0ShellStateV1.sample.worlds
      .where((item) => item.worldId == worldId)
      .firstOrNull;
  final lesson = world?.lessons
      .where((item) => item.lessonId == lessonId)
      .firstOrNull;
  return lesson?.taskList.where((item) => item.taskId == taskId).firstOrNull;
}

class _RouteRow {
  const _RouteRow(this.worldId, this.lessonId, this.task);
  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
  String get path => '$worldId/$lessonId/${task.taskId}';
}
