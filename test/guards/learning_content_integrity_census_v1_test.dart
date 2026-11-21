import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_error_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_gap_adjudication_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_truth_audit_v1.dart'
    show
        q3AppendedChoicesV1,
        w4AddedOptionQualityV1,
        w4MinRaiseTaskIdsV1,
        w5AddedOptionQualityV1,
        w7AppliedTaskIdsV1;
import '../support/act0_w11_wave4_contract_v1.dart';
import '../support/act0_w12_wave4_contract_v1.dart';
import '../support/act0_w2_catalog_contract_v1.dart';
import '../support/act0_w3_catalog_contract_v1.dart';
import '../support/act0_w6_catalog_contract_v1.dart';

const _w9BubbleTableRiskId = 'w9_bubble_table_risk_transfer';

// The legacy mapper falls back once the unsupported table clue is removed.
// Current typed repairs are verified separately.
const _legacyFallbacksWithoutSourceClue = <String>{
  // W3 prompts now ask for the decision or consequence shown in the scene.
  'button_advantage_button_intro',
  'button_advantage_button_vs_cutoff',
  'button_advantage_button_recap',
  'position_checkpoint_position_checkpoint_intro',
  // W1 moved Hero off BTN. The legacy mapper used the old Hero seat as a clue.
  'positions_theory',
  'blinds_button_moves',
  // W9 concept questions receive the familiar-replay disposition.
  'w9_ev_two_results',
  'w9_survival_stack_tradeoff',
  'w9_survival_recap',
  'w9_m_ratio_lap_count',
  'w9_m_ratio_ante_cost',
  'w9_m_ratio_recap',
  'w9_bubble_premium_gap',
  'w9_bubble_cover_seat',
  'w9_bubble_recap',
  'w9_prize_model_inputs',
  'w10_find_limper',
  'w10_player_type_recap',
  'w10_isolate_limper_bb',
  'w10_one_lever_recap',
  'w10_find_turn_raiser',
  'w10_guardrails_recap',
  'w10_river_price_check',
  'w11_plan_focus_choice',
  'w11_plan_avoid_overload',
  'w11_plan_table_focus_transfer',
  'w11_trigger_overfold_blinds',
  'w11_trigger_overcall_flop',
  'w11_review_pick_leak',
  'w11_review_define_fix',
  'w11_checkpoint_plan_line',
  'w11_checkpoint_trigger_line',
  'w11_checkpoint_review_line',
  'w11_checkpoint_review',
  'w12_good_fold_bad_result',
  'w12_after_bad_beat_reset',
  'w12_after_mistake_reset',
  'w12_assertive_not_ego',
  'w12_discipline_under_pressure',
  'w12_checkpoint_reset_line',
  'w12_checkpoint_discipline_line',
  'w12_checkpoint_review',
};

const _asm05NewTaskIds = <String>{
  'asm05_new_known_holes_turn_call_10',
  'asm05_new_known_holes_turn_call_40',
};

// New F0 source meaning no longer identifies Hero as BTN. These four wrong
// choices have explicit open dispositions, not replacement repair admission.
const _newW01OrderGapIds = <String>{
  'blinds_postflop_button',
  'positions_late_seat',
  'positions_review',
};

/// Source inventory and legacy DECLARED-mapper regression, not semantic repair
/// admission or learner proof. Current typed eligibility is checked separately.
/// Full original zero-gap semantic coverage remains HOLD until independently
/// adjudicated; retaining these legacy counts does not award that gate.
void main() {
  test(
    'canonical W1-W12 census preserves raw IDs and legacy declared mappings',
    () {
      final allRows = _assessedRows(historical: true)
          .where(
            (row) =>
                !w7AppliedTaskIdsV1.contains(row.task.taskId) &&
                !w4MinRaiseTaskIdsV1.contains(row.task.taskId) &&
                row.task.taskId != 'first_table_guide_first_decision' &&
                row.task.taskId != 'hand_rankings_compare_ace_straights' &&
                row.task.taskId != 'w4_price_find_bettor' &&
                row.task.taskId != 'w8_effective_stack_seat' &&
                row.task.taskId != 'w8_spr_value_size',
          )
          .toList();
      expect(allRows, hasLength(316));
      expect(
        allRows
            .where((row) => _asm05NewTaskIds.contains(row.task.taskId))
            .map((row) => row.task.taskId),
        _asm05NewTaskIds,
      );
      // L2 adds a graded range recap and replaces three surplus W5 options.
      // The separate ASM05
      // test retains the full extension and legacy declared-map census.
      // Current semantic coverage is explicitly separate and incomplete.
      final rows = allRows
          .where((row) => !_asm05NewTaskIds.contains(row.task.taskId))
          .toList(growable: false);
      expect(rows, hasLength(314));

      final repairRows = rows.where((row) => row.incorrectOptions.isNotEmpty);
      final repair = repairRows.map(_declaredRepairRow).toList(growable: false);
      final incorrectOptions = <_IncorrectOptionRow>[
        for (final row in repairRows)
          for (final option in row.incorrectOptions)
            _incorrectOptionRow(row, option),
      ];
      final late = rows
          .where(
            (row) => const <String>{
              'world_9',
              'world_10',
              'world_11',
              'world_12',
            }.contains(row.worldId),
          )
          .map(_lateWorldRow)
          .toList(growable: false);

      final snapshot = <String, Object?>{
        'assessedRows': rows.length,
        'assessedByLesson': _countBy(
          rows,
          (row) => '${row.worldId}/${row.lessonId}',
        ),
        'optionCounts': _countBy(rows, (row) => '${row.optionCount}'),
        'optionCountsByWorld': _nestedCountBy(
          rows,
          outer: (row) => row.worldId,
          inner: (row) => '${row.optionCount}',
        ),
        'optionCountsCheckpoints': _countBy(
          rows.where((row) => row.isCheckpoint),
          (row) => '${row.optionCount}',
        ),
        'optionCountsRepairTargets': _countBy(
          rows.where((row) => row.isRepairTarget),
          (row) => '${row.optionCount}',
        ),
        'optionCountsW1W6': _countBy(
          rows.where((row) => row.worldNumber <= 6),
          (row) => '${row.optionCount}',
        ),
        'optionCountsW7W12': _countBy(
          rows.where((row) => row.worldNumber >= 7),
          (row) => '${row.optionCount}',
        ),
        'correctPositions': _countBy(rows, (row) => '${row.correctIndex}'),
        'longestCorrectPositionRun': _longestRun(
          rows.map((row) => row.correctIndex).toList(growable: false),
        ),
        'legacyDeclaredRepair': <String, Object?>{
          'incorrectOptions': incorrectOptions.length,
          'currentErrorTypes': _countBy(
            incorrectOptions,
            (row) => row.currentErrorType,
          ),
          'worldsByErrorType': _groupedDistinctCount(
            incorrectOptions,
            outer: (row) => row.currentErrorType,
            value: (row) => row.row.worldId,
          ),
          'currentSourceSignals': _countBy(
            incorrectOptions,
            (row) => row.intent?.missedSignalId ?? 'UNCLASSIFIED',
          ),
          'incorrectCapable': repair.length,
          'exactReplayCovered': repair.where((row) => row.exactReplay).length,
          'sameSignalMapped': repair
              .where((row) => row.sameSignalMapped)
              .length,
          'fallbackOnly': repair.where((row) => row.fallbackOnly).length,
          'intentionalExactReplay': repair
              .where((row) => row.mappingType == 'intentional_exact')
              .length,
          'unresolvedProductGap': repair
              .where((row) => row.mappingType == 'unresolved_product_gap')
              .length,
          'unrecordedFallback': repair
              .where((row) => row.mappingType == 'exact')
              .length,
          'unmapped': repair.where((row) => !row.intentAvailable).length,
          'byWorld': _countBy(repair, (row) => row.worldId),
          'mappedByWorld': _countBy(
            repair.where((row) => row.sameSignalMapped),
            (row) => row.worldId,
          ),
          'checkpointMapped': repair
              .where((row) => row.isCheckpoint && row.sameSignalMapped)
              .length,
          'checkpointTotal': repair.where((row) => row.isCheckpoint).length,
          'repairTargetMapped': repair
              .where((row) => row.isRepairTarget && row.sameSignalMapped)
              .length,
          'repairTargetTotal': repair.where((row) => row.isRepairTarget).length,
          'fallbackInventory': <Map<String, Object?>>[
            for (final row in repair.where((row) => row.fallbackOnly))
              row.toInventoryPayload(),
          ],
        },
        'lateWorldAuthenticity': _countBy(late, (row) => row.category),
        'lateWorldTableRequired': late.where((row) => row.tableRequired).length,
        'lateWorldActionConsequence': late
            .where((row) => row.actionConsequence)
            .length,
        'lateWorldTerminologyOnly': late
            .where((row) => row.terminologyOnly)
            .length,
      };
      // Kept in test output so the companion adjudication can record the full
      // machine-derived snapshot without maintaining a second source of truth.
      // ignore: avoid_print
      print('DECLARED_MAP_CENSUS_NOT_SEMANTIC_ADMISSION');
      print(const JsonEncoder.withIndent('  ').convert(snapshot));

      expect(snapshot['optionCounts'], <String, int>{
        '2': 100,
        '3': 213,
        '4': 1,
      });
      expect(snapshot['correctPositions'], <String, int>{
        '0': 122,
        '1': 129,
        '2': 63,
      });
      expect(snapshot['longestCorrectPositionRun'], 4);
      // A10: "all-in" counts as an action word like "jam", so W9+ all-in
      // decisions are action decisions (3 tasks moved from clue reading).
      expect(snapshot['lateWorldAuthenticity'], <String, int>{
        'TABLE_ACTION_DECISION': 60,
        'CONCEPTUAL_OR_VERBAL_RECALL': 20,
      });
      final repairSnapshot =
          snapshot['legacyDeclaredRepair']! as Map<String, Object?>;
      final currentGaps = repair
          .where((row) => _newW01OrderGapIds.contains(row.row.task.taskId))
          .toList();
      expect(
        currentGaps.map((row) => row.row.task.taskId).toSet(),
        _newW01OrderGapIds,
      );
      expect(
        currentGaps.every(
          (row) =>
              row.mappingType == 'unresolved_product_gap' &&
              row.fallbackOnly &&
              !row.exactReplay,
        ),
        isTrue,
      );
      expect(
        repairSnapshot['sameSignalMapped'],
        292 - _legacyFallbacksWithoutSourceClue.length,
      );
      expect(
        repairSnapshot['fallbackOnly'],
        22 + _legacyFallbacksWithoutSourceClue.length,
      );
      expect(repairSnapshot['unresolvedProductGap'], 3);
      expect(
        repairSnapshot['unrecordedFallback'],
        2 + _legacyFallbacksWithoutSourceClue.length,
      );
      // The historical comparison restores the old M-ratio price mapping
      // and the intro's old seat mapping. The live rows use their actual goals.
      final zone = repair.singleWhere(
        (row) => row.row.task.taskId == 'w9_m_ratio_table_window_transfer',
      );
      expect(zone.mappingType, 'exact');
      expect(zone.fallbackOnly, isTrue);
      final revisedButton = repair.singleWhere(
        (row) => row.row.task.taskId == 'button_advantage_find_button',
      );
      // The previous declared mapper used the learner's old seat.
      // The current same-goal rehearsal is covered by the typed census below.
      expect(revisedButton.mappingType, 'exact');
      final priorDeclaredMappings = currentGaps.length + 3;
      final historicalRepairComparison = <String, Object?>{
        ...repairSnapshot,
        'sameSignalMapped':
            (repairSnapshot['sameSignalMapped'] as int) +
            priorDeclaredMappings +
            _legacyFallbacksWithoutSourceClue.length,
        'fallbackOnly':
            (repairSnapshot['fallbackOnly'] as int) -
            priorDeclaredMappings -
            _legacyFallbacksWithoutSourceClue.length,
        'unresolvedProductGap':
            (repairSnapshot['unresolvedProductGap'] as int) -
            currentGaps.length,
      };
      expect(repairSnapshot['incorrectOptions'], 529);
      expect(repairSnapshot['exactReplayCovered'], 17);
      expect(historicalRepairComparison['sameSignalMapped'], 298);
      expect(historicalRepairComparison['fallbackOnly'], 15 + 1);
      expect(repairSnapshot['intentionalExactReplay'], 17);
      expect(historicalRepairComparison['unresolvedProductGap'], 0);
      expect(
        repairSnapshot['unrecordedFallback'],
        2 + _legacyFallbacksWithoutSourceClue.length,
      );
      expect(repairSnapshot['unmapped'], 0);
      expect(repairSnapshot['currentErrorTypes'], <String, int>{
        'confused_card_rank_suit': 6,
        'confused_chip_commitment_eligibility': 8,
        'confused_private_board_cards': 20,
        'confused_table_identity': 10,
        'misread_action_legality': 14,
        'misread_bet_price': 14,
        'misread_bet_purpose': 8,
        'misread_board_texture': 13,
        'misread_draw_outs': 19,
        'misread_mindset_discipline': 26,
        'misread_player_adjustment': 54,
        'misread_poker_win_condition': 8,
        'misread_position_action_order': 53,
        'misread_range_card_removal': 65,
        'misread_real_play_process': 28,
        'misread_showdown_hand_strength': 46,
        'misread_stack_depth_risk': 34,
        'misread_starting_hand_discipline': 37,
        'misread_table_position': 23,
        'misread_tournament_pressure': 43,
      });
      expect(act0ConceptErrorDefinitionsV1, hasLength(20));
      expect(act0RepairGapAdjudicationsV1.take(37), hasLength(37));
      expect(act0RepairGapAdjudicationsV1, hasLength(41));
      final fallbackInventory = (repairSnapshot['fallbackInventory'] as List)
          .cast<Map<String, Object?>>();
      // Both context questions have explicit same-task replay, preserving
      // the current question without claiming independent transfer.
      final introFallback = fallbackInventory.singleWhere(
        (row) => row['task'] == 'same_hand_different_seat_w3_same_hand_intro',
      );
      expect(introFallback['currentFallback'], 'intentional_exact');
      final contextFallback = fallbackInventory.singleWhere(
        (row) => row['task'] == 'same_hand_different_seat_w3_same_hand_recap',
      );
      expect(contextFallback['currentFallback'], 'intentional_exact');
      final contextIncorrect = (contextFallback['incorrectOptions'] as List)
          .cast<Map<String, Object?>>();
      expect(contextIncorrect.map((row) => row['optionId']), <String>[
        'one_answer',
      ]);
      expect(
        contextIncorrect.single['errorType'],
        'misread_position_action_order',
      );
      expect(contextIncorrect.single['skillAtomId'], 'position_action_order');
      expect(
        contextIncorrect.single['missedSignalId'],
        'position_action_order',
      );
      final coPlayersBehindFallback = fallbackInventory.singleWhere(
        (row) =>
            row['task'] ==
            'position_checkpoint_position_checkpoint_table_notice',
      );
      expect(coPlayersBehindFallback['lesson'], 'position_checkpoint');
      expect(coPlayersBehindFallback['currentFallback'], 'intentional_exact');
      expect(
        (coPlayersBehindFallback['incorrectOptions'] as List)
            .cast<Map<String, Object?>>()
            .map((row) => row['optionId']),
        <String>['acts_last', 'late_free_pass'],
      );
      for (final option
          in (coPlayersBehindFallback['incorrectOptions'] as List)
              .cast<Map<String, Object?>>()) {
        expect(option['errorType'], 'misread_position_action_order');
        expect(option['skillAtomId'], 'table_position_read');
        expect(option['missedSignalId'], 'players_behind');
        expect(option['missedSignalId'], isNot('hero_button'));
        expect(option['missedSignalId'], isNot('pot_to_call'));
      }

      final w7 = Act0ShellStateV1.sample.worldById('world_7');
      final w7Surface = w7.lessons
          .expand((lesson) => lesson.taskList)
          .map(
            (task) => <String>[
              task.title,
              task.runner.caption,
              task.runner.hint,
              task.runner.question,
              task.runner.feedbackTitle,
              task.runner.feedbackReason,
              for (final step in task.runner.teachingSteps) step.title,
              for (final step in task.runner.teachingSteps) step.body,
              for (final step in task.runner.teachingSteps) ...step.focusLabels,
            ].join(' '),
          )
          .join(' ')
          .toLowerCase();
      expect(
        w7Surface,
        isNot(contains('w7_combo_density_visible_card_removal')),
      );

      final firstTable = rows.singleWhere(
        (row) => row.task.taskId == 'what_poker_is_theory',
      );
      expect(
        firstTable.task.runner.question,
        contains('two cards you can use on your own'),
      );
      expect(firstTable.task.runner.question, isNot(contains('hero seat')));

      final value = rows.singleWhere(
        (row) => row.task.taskId == 'w4_value_missed',
      );
      expect(
        value.task.runner.question,
        contains('BB checks a weaker ace and calls 3 BB but folds to 6 BB'),
      );
      expect(
        value.task.runner.options.singleWhere((option) => option.isCorrect).id,
        'bet_half',
      );
    },
  );

  test('W9 M-ratio mistakes do not use the removed call-price cue', () {
    final source = _assessedRows().singleWhere(
      (row) => row.task.taskId == 'w9_m_ratio_table_window_transfer',
    );
    expect(source.task.runner.table.toCallLabel, isEmpty);
    for (final choice in source.incorrectOptions) {
      final intent = _incorrectOptionRow(source, choice).intent;
      expect(intent?.missedSignalId, 'misread_tournament_pressure');
      expect(intent?.targetWorldId, 'world_9');
      expect(intent?.targetLessonId, 'm_ratio_zones_lite');
      expect(intent?.targetTaskId, 'w9_m_ratio_yellow_zone');
      expect(intent?.mappingType, 'repair');
    }
  });

  test('W9 bubble repair keeps the exact decision with a proved price', () {
    final source = _assessedRows().singleWhere(
      (row) => row.task.taskId == _w9BubbleTableRiskId,
    );
    expect(source.task.runner.table.toCallLabel, 'To call 15.5 BB');
    final legacy = _declaredRepairRow(source);
    expect(legacy.fallbackOnly, isFalse);
    expect(legacy.mappingType, 'repair');
    for (final choice in source.incorrectOptions) {
      final intent = _incorrectOptionRow(source, choice).intent;
      expect(intent?.missedSignalId, 'pot_to_call');
      expect(intent?.targetWorldId, 'world_9');
      expect(intent?.targetTaskId, _w9BubbleTableRiskId);
      expect(intent?.mappingType, 'intentional_exact');
    }
  });

  test('both ASM05 scenarios allow only their own familiar replay', () {
    final rows = _assessedRows(historical: true)
        .where(
          (row) =>
              !w7AppliedTaskIdsV1.contains(row.task.taskId) &&
              !w4MinRaiseTaskIdsV1.contains(row.task.taskId) &&
              row.task.taskId != 'first_table_guide_first_decision' &&
              row.task.taskId != 'hand_rankings_compare_ace_straights' &&
              row.task.taskId != 'w4_price_find_bettor' &&
              row.task.taskId != 'w8_effective_stack_seat' &&
              row.task.taskId != 'w8_spr_value_size',
        )
        .toList();
    final additions = rows
        .where((row) => _asm05NewTaskIds.contains(row.task.taskId))
        .toList(growable: false);
    expect(rows, hasLength(316));
    expect(additions.map((row) => row.task.taskId), _asm05NewTaskIds);
    expect(rows.map((row) => row.task.taskId).toSet(), hasLength(316));
    expect(_countBy(rows, (row) => '${row.optionCount}'), <String, int>{
      '2': 102,
      '3': 213,
      '4': 1,
    });
    expect(_countBy(rows, (row) => '${row.correctIndex}'), <String, int>{
      '0': 123,
      '1': 130,
      '2': 63,
    });
    expect(_longestRun(rows.map((row) => row.correctIndex).toList()), 4);
    final late = rows.where((row) => row.worldNumber >= 9).map(_lateWorldRow);
    expect(_countBy(late, (row) => row.category), <String, int>{
      'TABLE_ACTION_DECISION': 62,
      'CONCEPTUAL_OR_VERBAL_RECALL': 20,
    });

    final extensionRepair = <_RepairRow>[];
    for (final row in additions) {
      final price = row.task.taskId.endsWith('_10') ? 10 : 40;
      expect(row.worldId, 'world_12');
      expect(row.lessonId, 'decision_over_outcome');
      expect(row.task.phase, Act0LessonPhaseV1.drill);
      expect(row.task.stepKind, Act0LessonStepKindV1.practice);
      expect(row.task.resolvedTaskFamily, Act0TaskFamilyV1.decision);
      expect(row.task.rewardXp, 0);
      expect(row.isCheckpoint, isFalse);
      expect(row.isRepairTarget, isFalse);
      expect(row.optionCount, 2);
      expect(row.correctIndex, price == 10 ? 1 : 0);
      expect(row.task.runner.options.map((option) => option.id), [
        'fold',
        'call',
      ]);
      expect(row.task.runner.options.map((option) => option.label), [
        'Fold',
        'Call',
      ]);
      expect(row.task.runner.options.map((option) => option.amountLabel), [
        '',
        '$price BB',
      ]);
      for (final option in row.task.runner.options) {
        expect(option.isCorrect, option.id == (price == 10 ? 'call' : 'fold'));
        expect(
          option.quality,
          option.isCorrect
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
        );
        expect(option.preferredLabel, price == 10 ? 'Call' : 'Fold');
      }
      final authenticity = _lateWorldRow(row);
      expect(authenticity.category, 'TABLE_ACTION_DECISION');
      expect(authenticity.tableRequired, isTrue);
      expect(authenticity.actionConsequence, isTrue);
      expect(authenticity.terminologyOnly, isFalse);
      expect(row.incorrectOptions, hasLength(1));
      final wrong = row.incorrectOptions.single;
      expect(wrong.id, price == 10 ? 'fold' : 'call');
      final incorrect = _incorrectOptionRow(row, wrong);
      expect(incorrect.currentErrorType, 'misread_mindset_discipline');
      final repair = _declaredRepairRow(row);
      expect(repair.intentAvailable, isTrue);
      expect(repair.intents, hasLength(1));
      final intent = repair.intents.single;
      expect(intent.sourceWorldId, 'world_12');
      expect(intent.sourceLessonId, 'decision_over_outcome');
      expect(intent.sourceTaskId, row.task.taskId);
      expect(intent.choiceId, wrong.id);
      expect(intent.result, 'incorrect');
      expect(intent.errorType, 'misread_mindset_discipline');
      expect(intent.skillAtomId, 'mindset_process_discipline');
      expect(intent.missedSignalId, 'process_over_outcome');
      expect(intent.mappingType, 'repair');
      expect(intent.targetWorldId, 'world_12');
      expect(intent.targetLessonId, 'decision_over_outcome');
      expect(
        intent.targetTaskId,
        price == 10
            ? 'asm05_new_known_holes_turn_call_40'
            : 'asm05_new_known_holes_turn_call_10',
      );
      expect(repair.sameSignalMapped, isTrue);
      expect(repair.fallbackOnly, isFalse);
      expect(repair.exactReplay, isFalse);
      // Preserve the raw mutual map for comparison. The live targets below
      // only rehearse the exact source question.
      expect(
        act0CurrentAuthoredSourceFingerprintForIdentityV1(
          worldId: row.worldId,
          lessonId: row.lessonId,
          taskId: row.task.taskId,
        ),
        price == 10
            ? 'dc7f1fe213d526a36bf6ad0b5748a9244d96686124616d92a4db40e5d9222184'
            : 'ad6d1a9044df2efcc2f806633b055052c22449605ef9347b38823c82e42fc9c7',
      );
      final current = _repairRow(row).intents.single;
      expect(current.mappingType, 'intentional_exact');
      expect(current.targetTaskId, row.task.taskId);
      final goal = act0RepairGoalResolutionForIntentV1(
        current,
        learningEvidence: const Act0LearningEvidenceHistoryV1(),
        currentFingerprintForIdentity:
            act0CurrentAuthoredSourceFingerprintForIdentityV1,
      );
      expect(goal.isHeld, isTrue);
      expect(goal.canLaunch, isFalse);
      expect(goal.canClaimIndependentApplication, isFalse);
      expect(goal.canClaimMatchedRecheck, isFalse);
      extensionRepair.add(repair);
    }

    final allRepair = rows.map(_declaredRepairRow).toList(growable: false);
    final incorrect = <_IncorrectOptionRow>[
      for (final row in rows)
        for (final option in row.incorrectOptions)
          _incorrectOptionRow(row, option),
    ];
    expect(incorrect, hasLength(531));
    final currentGaps = allRepair
        .where((row) => _newW01OrderGapIds.contains(row.row.task.taskId))
        .toList();
    expect(
      currentGaps.map((row) => row.row.task.taskId).toSet(),
      _newW01OrderGapIds,
    );
    expect(
      allRepair.where((row) => row.sameSignalMapped),
      hasLength(294 - _legacyFallbacksWithoutSourceClue.length),
    );
    expect(
      allRepair.where((row) => row.fallbackOnly),
      hasLength(22 + _legacyFallbacksWithoutSourceClue.length),
    );
    expect(
      allRepair.where((row) => row.sameSignalMapped).length +
          currentGaps.length +
          3 +
          _legacyFallbacksWithoutSourceClue.length,
      300,
    );
    expect(
      allRepair.where((row) => row.fallbackOnly).length -
          currentGaps.length -
          3 -
          _legacyFallbacksWithoutSourceClue.length,
      15 + 1,
    );
    expect(allRepair.where((row) => row.exactReplay), hasLength(17));
    expect(
      incorrect.where(
        (row) => row.currentErrorType == 'misread_mindset_discipline',
      ),
      hasLength(28),
    );
    // Preserve actual route output for a bounded probe before the admission
    // assertion. A raw 'exact' fallback is not an accepted repair disposition.
    print(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'cohort': 'ASM05_DECLARED_MAP_EXTENSION_2_WITH_AGGREGATE_316',
        'semanticAdmission': 'UNKNOWN_NOT_REVIEWED_NO_CREDIT',
        'sameSignalMapped': allRepair
            .where((row) => row.sameSignalMapped)
            .length,
        'fallbackOnly': allRepair.where((row) => row.fallbackOnly).length,
        'intentionalExactReplay': allRepair
            .where((row) => row.exactReplay)
            .length,
        'unrecordedFallback': allRepair
            .where((row) => row.mappingType == 'exact')
            .length,
        'newRows': <Map<String, Object?>>[
          for (final repair in extensionRepair)
            <String, Object?>{
              ...repair.toInventoryPayload(),
              'targetWorld': repair.intents.single.targetWorldId,
              'targetLesson': repair.intents.single.targetLessonId,
              'targetTask': repair.intents.single.targetTaskId,
            },
        ],
      }),
    );
    expect(
      allRepair
          .where((row) => row.mappingType == 'exact')
          .map((row) => row.row.task.taskId)
          .toSet(),
      {
        'button_advantage_find_button',
        'w9_m_ratio_table_window_transfer',
        ..._legacyFallbacksWithoutSourceClue,
      },
      reason: 'Legacy fallbacks do not stand in for checked typed repairs.',
    );
    expect(
      allRepair
          .where((row) => row.mappingType == 'unresolved_product_gap')
          .map((row) => row.row.task.taskId)
          .toSet(),
      _newW01OrderGapIds,
    );
    expect(allRepair.where((row) => !row.intentAvailable), isEmpty);
    for (final repair in extensionRepair) {
      expect(repair.sameSignalMapped || repair.exactReplay, isTrue);
    }
  });
  test('non-Hero BTN contexts rehearse the current seat-order question', () {
    final rows = _assessedRows()
        .where((row) => _newW01OrderGapIds.contains(row.task.taskId))
        .toList();
    expect(rows.map((row) => row.task.taskId).toSet(), _newW01OrderGapIds);
    final choices = <String>{};
    for (final row in rows) {
      final gap = act0RepairGapAdjudicationForSourceTaskV1(row.task.taskId)!;
      expect(gap.outcome, Act0RepairGapOutcomeV1.unresolvedProductGap);
      expect(gap.candidateTargetIds, isEmpty);
      expect(gap.targetWorldId, isNull);
      expect(gap.targetLessonId, isNull);
      expect(gap.targetTaskId, isNull);
      expect(row.task.runner.table.heroSeatId, 'co');
      for (final option in row.incorrectOptions) {
        choices.add('${row.task.taskId}/${option.id}');
        final intent = buildAct0RepairIntentV1(
          sourceWorldId: row.worldId,
          sourceLessonId: row.lessonId,
          sourceTaskId: row.task.taskId,
          runner: row.task.runner,
          selectedOption: option,
          mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
          currentFingerprintForIdentity:
              act0CurrentAuthoredSourceFingerprintForIdentityV1,
        )!;
        expect(intent.skillAtomId, 'table_read');
        expect(intent.missedSignalId, 'button');
        expect(intent.missedSignalId, isNot('hero_button'));
        final isRecap = row.task.taskId == 'positions_review';
        expect(intent.mappingType, isRecap ? 'repair' : 'intentional_exact');
        expect(
          intent.targetTaskId,
          isRecap ? 'blinds_postflop_button' : row.task.taskId,
        );
        final goal = act0RepairGoalResolutionForIntentV1(
          intent,
          learningEvidence: const Act0LearningEvidenceHistoryV1(),
          currentFingerprintForIdentity:
              act0CurrentAuthoredSourceFingerprintForIdentityV1,
        );
        expect(goal.isHeld, isTrue);
        expect(goal.canLaunch, isFalse);
        expect(goal.retainsObligation, isTrue);
        expect(goal.canClaimIndependentApplication, isFalse);
        expect(goal.reason, 'source_occurrence_unconfirmed');
      }
    }
    expect(choices, <String>{
      'blinds_postflop_button/utg',
      'blinds_postflop_button/bb',
      'positions_late_seat/utg',
      'positions_late_seat/bb',
      'positions_review/top',
      'positions_review/random',
    });
  });
  test('every wrong choice has a deterministic current typed disposition', () {
    final rows = _assessedRows();
    final order = {
      for (final (index, row) in rows.indexed) row.task.taskId: index,
    };
    final admitted = <String>{};
    final foundationDefaults = <String>{};
    final knownHeld = <String>{};
    final unknown = <String>{};
    final allChoices = <String>{};
    for (final row in rows) {
      final current = _repairRow(row);
      expect(current.intents, hasLength(row.incorrectOptions.length));
      for (final intent in current.intents) {
        final key =
            '${row.worldId}/${row.lessonId}/${row.task.taskId}/${intent.choiceId}';
        expect(allChoices.add(key), isTrue);
        expect(intent.sourceWorldId, row.worldId);
        expect(intent.sourceLessonId, row.lessonId);
        expect(intent.sourceTaskId, row.task.taskId);
        expect(
          Act0RepairIntentV1.tryParse(intent.toPayload())!.toPayload(),
          intent.toPayload(),
        );
        final option = row.incorrectOptions.singleWhere(
          (o) => o.id == intent.choiceId,
        );
        final repeated = buildAct0RepairIntentV1(
          sourceWorldId: row.worldId,
          sourceLessonId: row.lessonId,
          sourceTaskId: row.task.taskId,
          runner: row.task.runner,
          selectedOption: option,
          currentFingerprintForIdentity:
              act0CurrentAuthoredSourceFingerprintForIdentityV1,
        )!;
        expect(repeated.toPayload(), intent.toPayload());
        final contract = act0RepairGoalContractForSourceV1(
          worldId: row.worldId,
          lessonId: row.lessonId,
          taskId: row.task.taskId,
          choiceId: intent.choiceId,
        );
        if (contract?.hasValidatedTarget == true) {
          final admittedContract = contract!;
          if (admittedContract.relationId.startsWith('foundation_replay/')) {
            foundationDefaults.add(key);
            expect(
              row.worldNumber,
              lessThanOrEqualTo(act0SameGoalReplayThroughWorldV1),
            );
            expect(admittedContract.canClaimIndependentApplication, isFalse);
            expect(admittedContract.canClaimMatchedRecheck, isFalse);
          } else {
            admitted.add(key);
          }
          expect(intent.mappingType, admittedContract.mappingType);
          expect(intent.targetWorldId, admittedContract.targetWorldId);
          expect(intent.targetLessonId, admittedContract.targetLessonId);
          expect(intent.targetTaskId, admittedContract.targetTaskId);
          expect(intent.sourceFingerprint, admittedContract.sourceFingerprint);
          expect(intent.targetFingerprint, admittedContract.targetFingerprint);
          if (row.worldNumber >= 5 &&
              row.worldNumber <= act0SameGoalReplayThroughWorldV1 &&
              !row.task.repairOnly) {
            final targetIndex = order[intent.targetTaskId]!;
            final target = rows[targetIndex];
            if (target.task.repairOnly) {
              expect(target.worldId, row.worldId, reason: key);
              expect(target.lessonId, row.lessonId, reason: key);
            } else {
              expect(
                targetIndex,
                lessThanOrEqualTo(order[row.task.taskId]!),
                reason: key,
              );
            }
            if (row.task.taskId == 'visible_king_combo_reduction_intro') {
              expect(intent.targetTaskId, row.task.taskId);
              expect(intent.mappingType, 'intentional_exact');
            }
          }
        } else {
          (contract == null ? unknown : knownHeld).add(key);
          expect(
            row.worldNumber > act0SameGoalReplayThroughWorldV1 ||
                row.task.repairOnly,
            isTrue,
            reason: key,
          );
          expect(intent.mappingType, 'unresolved_product_gap');
          // Structural source IDs preserve the held entry; they are not a
          // fallback target or evidence that the source has been corrected.
          expect(intent.targetTaskId, row.task.taskId);
        }
        final withoutOccurrence = act0RepairGoalResolutionForIntentV1(
          intent,
          learningEvidence: const Act0LearningEvidenceHistoryV1(),
          currentFingerprintForIdentity:
              act0CurrentAuthoredSourceFingerprintForIdentityV1,
        );
        expect(withoutOccurrence.canLaunch, isFalse);
        expect(withoutOccurrence.canClaimIndependentApplication, isFalse);
        expect(withoutOccurrence.retainsObligation, isTrue);
      }
    }
    final addedContracts = {
      ...w11Wave4ChoiceContractV1,
      ...w12Wave4ChoiceContractV1,
    };
    final addedRows = rows
        .where((row) => addedContracts.containsKey(row.task.taskId))
        .toList();
    expect(
      addedRows.map((row) => row.task.taskId).toSet(),
      addedContracts.keys.toSet(),
    );
    final addedWrongChoices = {
      for (final row in addedRows)
        for (final [choiceId, _, correct, _, _]
            in addedContracts[row.task.taskId]!.$2)
          if (correct == false)
            'world_${row.worldNumber}/${row.lessonId}/${row.task.taskId}/$choiceId',
    };
    expect(rows, hasLength(346 + addedContracts.length));
    expect(
      rows.map((r) => r.task.taskId).toSet(),
      hasLength(346 + addedContracts.length),
    );
    expect(
      allChoices,
      hasLength(
        647 +
            w4AddedOptionQualityV1.length +
            w5AddedOptionQualityV1.length +
            addedWrongChoices.length,
      ),
    );
    expect(
      foundationDefaults.where(addedWrongChoices.contains).toSet(),
      addedWrongChoices,
    );
    final ordinaryContracts = act0RepairGoalContractsV1
        .where((row) => !row.isDiagnosticLearningEntry)
        .toList();
    final diagnosticEntries = act0RepairGoalContractsV1
        .where((row) => row.isDiagnosticLearningEntry)
        .toList();
    expect(ordinaryContracts, hasLength(32));
    expect(diagnosticEntries, hasLength(2));
    expect(
      ordinaryContracts.length + diagnosticEntries.length,
      act0RepairGoalContractsV1.length,
    );
    expect(
      diagnosticEntries
          .map(
            (row) =>
                '${row.diagnosticVariantId}/${row.sourceChoiceId}/${row.targetTaskId}',
          )
          .toSet(),
      <String>{
        'board_private_cards/hero_private_cards/cards_ranks_suits_private_board',
        'action_basics/not_sure_yet/actions_check_drill',
      },
    );
    for (final row in diagnosticEntries) {
      expect(row.evidenceClass, 'diagnostic_learning_entry');
      expect(row.mappingType, 'diagnostic_learning_entry');
      expect(row.canClaimIndependentApplication, isFalse);
      expect(row.canClaimMatchedRecheck, isFalse);
      expect(
        act0RepairGoalContractForSourceV1(
          worldId: row.sourceWorldId,
          lessonId: row.sourceLessonId,
          taskId: row.sourceTaskId,
          choiceId: row.sourceChoiceId,
        ),
        isNull,
        reason: 'Teaching navigation is not ordinary assessed repair coverage.',
      );
    }
    expect(admitted, <String>{
      'world_1/blinds_order_practice/blinds_first_actor/btn',
      'world_1/blinds_order_practice/blinds_last_actor/sb',
      'world_1/blinds_order_practice/blinds_review/btn',
      'world_1/blinds_action_order/positions_utg/hj',
      'world_1/cards_ranks_suits/cards_ranks_suits_rank_drill/king',
      'world_1/cards_ranks_suits/cards_ranks_suits_rank_drill/suit',
      'world_1/fold_check_call_raise/actions_check_drill/pay_small_blind',
      'world_1/fold_check_call_raise/actions_check_drill/pay_big_blind',
      'world_1/fold_check_call_raise/actions_legal_context/fold',
      'world_1/fold_check_call_raise/actions_legal_context/call',
      'world_3/same_hand_different_seat/same_hand_different_seat_w3_same_hand_recap/one_answer',
      'world_1/what_poker_is/what_poker_is_find_hero/top',
      'world_3/position_six_seats/position_six_seats_positions_button/co',
      'world_3/button_advantage/button_advantage_find_button/co',
      'world_3/position_six_seats/position_six_seats_positions_utg/hj',
      'world_3/button_advantage/button_advantage_button_last/utg',
      'world_3/early_vs_late/early_vs_late_early_pressure_choice/same_as_btn',
      'world_3/same_hand_different_seat/same_hand_different_seat_same_hand_early_fold/raise',
      'world_6/range_pressure_lines/w6_value_range_action/bet_bluff',
      'world_6/range_board_fit/w6_board_fit_recap/caller',
      'world_6/range_board_fit/w6_board_fit_recap/same',
      'world_5/straight_draws/straight_draws_w5_gutshot_contrast_transfer/gutshot',
      'world_5/turn_river_changes/turn_river_changes_w5_turn_texture_shift_transfer/nothing_changed',
      'world_6/range_pressure_lines/w6_turn_pressure_shift_transfer/barrel_big',
    });
    expect(knownHeld, isEmpty);
    expect(
      foundationDefaults,
      hasLength(
        609 +
            w4AddedOptionQualityV1.length +
            w5AddedOptionQualityV1.length +
            addedWrongChoices.length,
      ),
    );
    expect(
      unknown.intersection(w3AppendedRepairChoiceIdsV1),
      w3AppendedRepairChoiceIdsV1,
    );
    expect(unknown.difference(w3AppendedRepairChoiceIdsV1), hasLength(10));
    expect(
      admitted.length +
          foundationDefaults.length +
          knownHeld.length +
          unknown.length,
      allChoices.length,
    );
    print(
      const JsonEncoder.withIndent('  ').convert({
        'scope': 'CURRENT_TYPED_DISPOSITION_NOT_FULL_SEMANTIC_COVERAGE',
        'originalZeroGapDoD': 'HOLD_NOT_AWARDED',
        'assessedRows': rows.length,
        'wrongChoices': allChoices.length,
        'staticAdmittedFamiliarChoices': admitted.length,
        'foundationDefaultChoices': foundationDefaults.length,
        'heldKnownChoices': knownHeld.length,
        'heldUnreviewedChoices': unknown.length,
        'allRawTaskIds': rows.map((r) => r.task.taskId).toList(),
        'allRawWrongChoiceIds': allChoices.toList(),
      }),
    );
  });
}

List<_Row> _assessedRows({bool historical = false}) => <_Row>[
  for (final world in Act0ShellStateV1.sample.worlds)
    if (RegExp(r'^world_([1-9]|1[0-2])$').hasMatch(world.worldId))
      for (final lesson in world.lessons)
        for (final task in lesson.taskList)
          // The P8 orientation item is launched only for an existing miss.
          // Its one wrong answer cannot create a standalone course obligation.
          if (task.taskId != 'first_table_guide_shared_cards_repair' &&
              (!historical ||
                  (!w2Q9ChoiceContractV1.containsKey(task.taskId) &&
                      !w3NewChoiceContractV1.containsKey(task.taskId) &&
                      !w6NewChoiceContractV1.containsKey(task.taskId) &&
                      !w11Wave4ChoiceContractV1.containsKey(task.taskId) &&
                      !w12Wave4ChoiceContractV1.containsKey(task.taskId) &&
                      preW2ReasonChoicesV1[task.taskId]?.isEmpty != true)) &&
              task.runner.options.length >= 2 &&
              task.runner.options.where((option) => option.isCorrect).length ==
                  1)
            _Row(
              world.worldId,
              historical && w6MovedToRangeReadingV1.contains(task.taskId)
                  ? 'range_thinking_checkpoint'
                  : lesson.lessonId,
              task,
              omittedChoiceId: historical
                  ? q3AppendedChoicesV1[task.taskId] ??
                        w2AppendedWrongChoicesV1[task.taskId] ??
                        w3AppendedWrongChoicesV1[task.taskId] ??
                        w4AddedOptionQualityV1[task.taskId]?.$1 ??
                        w5AddedOptionQualityV1[task.taskId]?.$1
                  : null,
              historicalChoices: historical
                  ? preW2ReasonChoicesV1[task.taskId] ??
                        preW3ReasonChoicesV1[task.taskId] ??
                        preW6ChoiceContractV1[task.taskId]
                  : null,
            ),
];

_RepairRow _repairRow(_Row row, {bool declaredMetadataOnly = false}) {
  final intents = row.incorrectOptions
      .map(
        (option) => declaredMetadataOnly
            ? _declaredIntent(row, option)
            : buildAct0RepairIntentV1(
                sourceWorldId: row.worldId,
                sourceLessonId: row.lessonId,
                sourceTaskId: row.task.taskId,
                runner: row.task.runner,
                selectedOption: option,
                mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
                currentFingerprintForIdentity:
                    act0CurrentAuthoredSourceFingerprintForIdentityV1,
              ),
      )
      .whereType<Act0RepairIntentV1>()
      .toList(growable: false);
  final sameSignal = intents.any(
    (intent) =>
        intent.mappingType != 'exact' && intent.targetTaskId != row.task.taskId,
  );
  return _RepairRow(
    row,
    intents,
    row.worldId,
    isCheckpoint: row.isCheckpoint,
    isRepairTarget: row.isRepairTarget,
    exactReplay: intents.any(
      (intent) => intent.mappingType == 'intentional_exact',
    ),
    sameSignalMapped: sameSignal,
  );
}

_IncorrectOptionRow _incorrectOptionRow(_Row row, Act0RunnerOptionV1 option) {
  final intent = buildAct0RepairIntentV1(
    sourceWorldId: row.worldId,
    sourceLessonId: row.lessonId,
    sourceTaskId: row.task.taskId,
    runner: row.task.runner,
    selectedOption: option,
    mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
    currentFingerprintForIdentity:
        act0CurrentAuthoredSourceFingerprintForIdentityV1,
  );
  return _IncorrectOptionRow(row, option, intent);
}

_LateWorldRow _lateWorldRow(_Row row) {
  final copy = <String>[
    row.task.title,
    row.task.runner.caption,
    row.task.runner.hint,
    row.task.runner.question,
    for (final option in row.task.runner.options) option.label,
  ].join(' ').toLowerCase();
  final action = RegExp(
    r'\b(fold|call|check|bet|raise|jam|all-in)\b',
  ).hasMatch(copy);
  final table =
      row.task.runner.table.boardCards.isNotEmpty ||
      row.task.runner.table.heroCards.isNotEmpty ||
      row.task.runner.table.actionTrail.isNotEmpty;
  final category = action
      ? 'TABLE_ACTION_DECISION'
      : table
      ? 'TABLE_CLUE_OR_RANGE_INFERENCE'
      : 'CONCEPTUAL_OR_VERBAL_RECALL';
  return _LateWorldRow(
    category,
    tableRequired: table,
    actionConsequence: action,
    terminologyOnly: !table && !action,
  );
}

Map<String, int> _countBy<T>(Iterable<T> values, String Function(T) key) {
  final result = <String, int>{};
  for (final value in values) {
    result.update(key(value), (count) => count + 1, ifAbsent: () => 1);
  }
  return Map<String, int>.fromEntries(
    result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

Map<String, Map<String, int>> _nestedCountBy<T>(
  Iterable<T> values, {
  required String Function(T) outer,
  required String Function(T) inner,
}) {
  final grouped = <String, List<T>>{};
  for (final value in values) {
    grouped.putIfAbsent(outer(value), () => <T>[]).add(value);
  }
  return Map<String, Map<String, int>>.fromEntries(
    grouped.entries.map(
      (entry) => MapEntry(entry.key, _countBy(entry.value, inner)),
    ),
  );
}

Map<String, int> _groupedDistinctCount<T>(
  Iterable<T> values, {
  required String Function(T) outer,
  required String Function(T) value,
}) {
  final grouped = <String, Set<String>>{};
  for (final item in values) {
    grouped.putIfAbsent(outer(item), () => <String>{}).add(value(item));
  }
  return Map<String, int>.fromEntries(
    grouped.entries.map((entry) => MapEntry(entry.key, entry.value.length)),
  );
}

int _longestRun(List<int> values) {
  var longest = 0;
  var current = 0;
  int? previous;
  for (final value in values) {
    current = value == previous ? current + 1 : 1;
    previous = value;
    if (current > longest) longest = current;
  }
  return longest;
}

class _Row {
  const _Row(
    this.worldId,
    this.lessonId,
    this.task, {
    this.omittedChoiceId,
    this.historicalChoices,
  });
  final String worldId;
  final String lessonId;
  final Act0LessonTaskV1 task;
  final String? omittedChoiceId;
  final List<List<Object?>>? historicalChoices;

  List<Act0RunnerOptionV1> get options {
    final previous = historicalChoices;
    if (previous != null) {
      return [
        for (final choice in previous)
          task.runner.options.singleWhere((option) => option.id == choice[0]),
      ];
    }
    return omittedChoiceId == null
        ? task.runner.options
        : task.runner.options
              .where((option) => option.id != omittedChoiceId)
              .toList();
  }

  int get optionCount => options.length;
  int get correctIndex => options.indexWhere((option) => option.isCorrect);
  int get worldNumber => int.parse(worldId.substring('world_'.length));
  bool get isCheckpoint =>
      lessonId.contains('checkpoint') || task.taskId.contains('checkpoint');
  bool get isRepairTarget =>
      task.stepKind == Act0LessonStepKindV1.fixMistakes ||
      task.resolvedTaskFamily == Act0TaskFamilyV1.repair ||
      task.taskId.contains('repair') ||
      task.runner.options.any(
        (option) =>
            option.repairFocusSeatIds.isNotEmpty ||
            option.repairFocusCardIds.isNotEmpty ||
            option.repairFocusLabels.isNotEmpty,
      );
  Iterable<Act0RunnerOptionV1> get incorrectOptions =>
      options.where((option) => !option.isCorrect);
}

class _RepairRow {
  const _RepairRow(
    this.row,
    this.intents,
    this.worldId, {
    required this.isCheckpoint,
    required this.isRepairTarget,
    required this.exactReplay,
    required this.sameSignalMapped,
  });
  final _Row row;
  final List<Act0RepairIntentV1> intents;
  final String worldId;
  final bool isCheckpoint;
  final bool isRepairTarget;
  final bool exactReplay;
  final bool sameSignalMapped;
  bool get fallbackOnly => !sameSignalMapped;
  bool get intentAvailable => intents.length == row.incorrectOptions.length;
  String get mappingType =>
      intents.isEmpty ? 'unclassified' : intents.first.mappingType;

  Map<String, Object?> toInventoryPayload() => <String, Object?>{
    'world': row.worldId,
    'lesson': row.lessonId,
    'task': row.task.taskId,
    'taskFamily': row.task.resolvedTaskFamily.name,
    'incorrectOptions': <Map<String, Object?>>[
      for (final incorrect in row.incorrectOptions.map(
        (option) => _incorrectOptionRow(row, option),
      ))
        <String, Object?>{
          'optionId': incorrect.option.id,
          'result': incorrect.intent?.result ?? 'unclassified',
          'errorType': incorrect.currentErrorType,
          'skillAtomId': incorrect.intent?.skillAtomId ?? '',
          'missedSignalId': incorrect.intent?.missedSignalId ?? '',
          'repairFocusLabels': incorrect.option.repairFocusLabels,
        },
    ],
    'currentFallback': intents.isEmpty
        ? 'unclassified'
        : intents.first.mappingType,
  };
}

class _IncorrectOptionRow {
  const _IncorrectOptionRow(this.row, this.option, this.intent);

  final _Row row;
  final Act0RunnerOptionV1 option;
  final Act0RepairIntentV1? intent;

  String get currentErrorType =>
      intent?.errorType ?? 'UNCLASSIFIED_NO_REPAIR_INTENT';
}

class _LateWorldRow {
  const _LateWorldRow(
    this.category, {
    required this.tableRequired,
    required this.actionConsequence,
    required this.terminologyOnly,
  });
  final String category;
  final bool tableRequired;
  final bool actionConsequence;
  final bool terminologyOnly;
}

// Historical declaration adapter ONLY. Never call this to launch a task,
// resolve an occurrence, generate learner history or bank a repair.
_RepairRow _declaredRepairRow(_Row row) =>
    _repairRow(row, declaredMetadataOnly: true);
Act0RepairIntentV1? _declaredIntent(_Row row, Act0RunnerOptionV1 option) {
  final base = buildAct0RepairIntentV1(
    sourceWorldId: row.worldId,
    sourceLessonId: row.lessonId,
    sourceTaskId: row.task.taskId,
    runner: row.task.runner,
    selectedOption: option,
    currentFingerprintForIdentity:
        act0CurrentAuthoredSourceFingerprintForIdentityV1,
  );
  if (base == null) return null;
  final isContextReview =
      row.task.taskId == 'same_hand_different_seat_w3_same_hand_recap';
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: row.task.runner,
    option: option,
    taskFamily: isContextReview
        ? Act0TaskFamilyV1.review
        : Act0TaskFamilyV1.decision,
  );
  final mapping = act0FirstValueSameSignalRepMappingV1(
    nextRepId:
        receipt != null &&
            receipt.skillAtomId == base.skillAtomId &&
            receipt.sourceSignalId == base.missedSignalId
        ? receipt.nextRepId
        : 'repeat_${base.skillAtomId}',
    skillAtomId: base.skillAtomId,
    sourceSignalId: base.missedSignalId,
    sourceTaskId: row.task.taskId,
    receiptOutcome: option.quality == Act0FeedbackQualityV1.suboptimal
        ? 'needs_rep'
        : 'repair_started',
  );
  return Act0RepairIntentV1.tryParse({
    ...base.toPayload(),
    'goalId': '',
    'relationId': '',
    'relationRevision': 0,
    'sourceFingerprint': '',
    'targetFingerprint': '',
    'targetWorldId': mapping?.worldId ?? row.worldId,
    'targetLessonId': mapping?.lessonId ?? row.lessonId,
    'targetTaskId': mapping?.taskId ?? row.task.taskId,
    'mappingType': mapping?.mappingType ?? 'exact',
  });
}
