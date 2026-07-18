import 'package:flutter_test/flutter_test.dart';
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

  test('all 34 prior exact fallbacks have one explicit safe disposition', () {
    const expectedSources = <String>[
      'world_1/what_poker_is/what_poker_is_table_read_recheck',
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
      'world_1/blinds_action_order/blinds_first_actor',
      'world_1/blinds_action_order/blinds_last_actor',
      'world_1/blinds_action_order/blinds_review',
      'world_1/positions/positions_utg',
      'world_1/positions/positions_cutoff',
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
    ];
    final rows = act0RepairGapAdjudicationsV1;
    expect(rows, hasLength(34));
    expect(
      rows
          .map(
            (row) =>
                '${row.sourceWorldId}/${row.sourceLessonId}/${row.sourceTaskId}',
          )
          .toList(),
      expectedSources,
    );
    expect(rows.map((row) => row.sourceTaskId).toSet(), hasLength(34));

    final counts = <Act0RepairGapOutcomeV1, int>{};
    for (final row in rows) {
      counts.update(row.outcome, (value) => value + 1, ifAbsent: () => 1);
      expect(row.priorFallback, 'unrecorded_exact_source_fallback');
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
      Act0RepairGapOutcomeV1.intentionalExactReplay: 13,
      Act0RepairGapOutcomeV1.unresolvedProductGap: 1,
    });
    final unresolved = rows.singleWhere(
      (row) => row.outcome == Act0RepairGapOutcomeV1.unresolvedProductGap,
    );
    expect(unresolved.sourceTaskId, 'blinds_review');
    expect(unresolved.targetTaskId, isNull);
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
