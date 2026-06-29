import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/content_factory_import_export_mvp_v1.dart';
import '../../tools/content_schema_foundation_validator_v1.dart';

void main() {
  test('imports W1 source and exports a deterministic validated fixture', () {
    final first = exportTinyContentFactorySamplesV1(writeFiles: false);
    final second = exportTinyContentFactorySamplesV1(writeFiles: false);

    final w1 = first.singleWhere(
      (result) => result.outputPath.endsWith('w1_import_export_sample_v1.json'),
    );
    final w1Again = second.singleWhere(
      (result) => result.outputPath.endsWith('w1_import_export_sample_v1.json'),
    );

    expect(jsonEncode(w1.fixture), jsonEncode(w1Again.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      w1.fixture,
      path: w1.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 1);
    expect(validation.coverageCountableTasks, 1);

    final task = _singleTask(w1.fixture);
    expect(task['schema_version'], 'content_schema_foundation_v1');
    expect(task['world_id'], 'world_1');
    expect(task['route_world_id'], 'world_1');
    expect(task['display_world_title'], 'Poker from Zero');
    expect(task['content_owner_world_id'], 'world_1');
    expect(task['route_gate_status'], 'learner_playable');
    expect(task['lesson_id'], 'w1.l01');
    expect(task['task_id'], 'w1.s01.choose_fold.import_export_sample_v1');
    expect(task['concept_family_id'], 'starting_hand_discipline');
    expect(task['drill_kind'], 'action_choice');
    expect(task['correct_action'], 'fold');
    expect(task['feedback_reason'], contains('Fold preserves the stack'));
    expect(task['validation_status'], 'source_validated');
    expect(task['preview_only'], false);
    expect(task['source_truth_status'], 'migrated');
    expect(
      task['migration_source'],
      containsPair(
        'source_path',
        'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json',
      ),
    );
  });

  test('exports W2 bridge sample with normalized route/content fields', () {
    final results = exportTinyContentFactorySamplesV1(writeFiles: false);
    final w2 = results.singleWhere(
      (result) => result.outputPath.endsWith(
        'w2_bridge_or_legacy_import_export_sample_v1.json',
      ),
    );

    final validation = validateContentSchemaFoundationMapV1(
      w2.fixture,
      path: w2.outputPath,
    );
    expect(validation.errors, isEmpty);

    final task = _singleTask(w2.fixture);
    expect(task['world_id'], 'world_2');
    expect(task['route_world_id'], 'world_2');
    expect(task['display_world_title'], 'Hand Discipline');
    expect(task['content_owner_world_id'], 'world_2');
    expect(task['route_gate_status'], 'learner_playable');
    expect(task['source_truth_status'], 'bridge_or_legacy');
    expect(task['concept_family_id'], 'position_btn_vs_early');
    expect(task['correct_action'], 'fold');
    expect(task['feedback_reason'], contains('Early-position weakness'));
    expect(
      task['migration_source'],
      containsPair(
        'source_path',
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_fold_early.json',
      ),
    );
  });

  test('exports W1 world coverage pilot from real source tasks', () {
    final first = exportW1WorldCoveragePilotV1(writeFiles: false);
    final second = exportW1WorldCoveragePilotV1(writeFiles: false);

    expect(first.outputPath, endsWith('w1_world_coverage_pilot_v1.json'));
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'position_action_order',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.position_action_order.first_in_or_facing_pressure',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'position_before_action',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'first_in_action_order_v1',
      'facing_open_pressure_v1',
      'multiway_pressure_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'raise',
      'call',
      'fold',
      'raise',
      'call',
      'fold',
    ]);
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world1/v1/sessions/w1.s02/drills/'
            'd.choose_button_open_clean_v1.json',
        'content/worlds/world1/v1/sessions/w1.s03/drills/'
            'd.choose_fold_when_multiway_pressure_stacks_v1.json',
      ]),
    );
  });

  test('exports W1 starting hand discipline batch from real source tasks', () {
    final first = exportW1StartingHandDisciplineBatch1V1(writeFiles: false);
    final second = exportW1StartingHandDisciplineBatch1V1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w1_starting_hand_discipline_migration_batch1_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_1'});
    expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_1'});
    expect(tasks.map((task) => task['display_world_title']).toSet(), {
      'Poker from Zero',
    });
    expect(tasks.map((task) => task['content_owner_world_id']).toSet(), {
      'world_1',
    });
    expect(tasks.map((task) => task['route_gate_status']).toSet(), {
      'learner_playable',
    });
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'starting_hand_discipline',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.starting_hand_discipline.clean_start_or_release',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'release_weak_or_dominated_start',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'clean_first_in_start_v1',
      'facing_open_continue_or_release_v1',
      'oop_weak_start_release_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'raise',
      'fold',
      'raise',
      'call',
      'raise',
      'fold',
    ]);
    expect(tasks.map((task) => task['validation_status']).toSet(), {
      'source_validated',
    });
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.choose_cutoff_raise_clean_start_v1.json',
        'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.choose_small_blind_fold_weak_start_v1.json',
        'content/worlds/world1/v1/sessions/w1.s06/drills/'
            'd.choose_raise_clean_first_in_checkpoint_v1.json',
        'content/worlds/world1/v1/sessions/w1.s08/drills/'
            'd.choose_big_blind_call_oop_defend_focus_v1.json',
        'content/worlds/world1/v1/sessions/w1.s09/drills/'
            'd.choose_raise_when_action_folds_to_you_focus_v1.json',
        'content/worlds/world1/v1/sessions/w1.s09/drills/'
            'd.choose_fold_when_pressure_and_position_fail_focus_v1.json',
      ]),
    );
  });

  test('exports W1 seat role orientation PR2 from real source tasks', () {
    final first = exportW1SeatRoleOrientationPr2V1(writeFiles: false);
    final second = exportW1SeatRoleOrientationPr2V1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w1_seat_role_orientation_migration_pr2_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_1'});
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'seat_role_orientation',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.seat_role_orientation.blind_button_seat_identity',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'role_before_action',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'button_role_find_v1',
      'blind_role_find_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'btn',
      'sb',
      'bb',
      'btn',
      'sb',
      'btn',
    ]);
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world1/v1/sessions/w1.s01/drills/d.find_btn.json',
        'content/worlds/world1/v1/sessions/w1.s02/drills/d.find_sb.json',
        'content/worlds/world1/v1/sessions/w1.s03/drills/d.find_bb.json',
        'content/worlds/world1/v1/sessions/w1.s07/drills/'
            'd.find_btn_focus.json',
        'content/worlds/world1/v1/sessions/w1.s08/drills/'
            'd.find_sb_focus.json',
        'content/worlds/world1/v1/sessions/w1.s10/drills/'
            'd.find_btn_focus.json',
      ]),
    );
  });

  test('exports W1 card board orientation PR2 from real source tasks', () {
    final first = exportW1CardBoardOrientationPr2V1(writeFiles: false);
    final second = exportW1CardBoardOrientationPr2V1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w1_card_board_orientation_migration_pr2_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_1'});
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'card_board_orientation',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.card_board_orientation.board_slot_identity',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'board_slot_before_action',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'flop_slot_find_v1',
      'turn_slot_find_v1',
      'river_slot_find_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'flop_right',
      'turn',
      'river',
      'flop_right',
      'turn',
      'river',
    ]);
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.tap_flop_right.json',
        'content/worlds/world1/v1/sessions/w1.s02/drills/d.tap_turn.json',
        'content/worlds/world1/v1/sessions/w1.s03/drills/d.tap_river.json',
        'content/worlds/world1/v1/sessions/w1.s04/drills/'
            'd.tap_flop_right_repeat.json',
        'content/worlds/world1/v1/sessions/w1.s05/drills/'
            'd.tap_turn_repeat.json',
        'content/worlds/world1/v1/sessions/w1.s06/drills/'
            'd.tap_river_repeat.json',
      ]),
    );
  });

  test('exports W1 bet size vocabulary preview PR3 from real source tasks', () {
    final first = exportW1BetSizeVocabularyPreviewPr3V1(writeFiles: false);
    final second = exportW1BetSizeVocabularyPreviewPr3V1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w1_bet_size_vocabulary_preview_migration_pr3_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'bet_size_vocabulary_preview',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.bet_size_vocabulary_preview.size_label_recognition',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'size_label_before_strategy',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'cheap_price_label_v1',
      'value_size_label_v1',
      'reopen_label_v1',
      'pressure_size_label_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'one_third_pot',
      'half_pot',
      'min_raise',
      'pot',
      'one_third_pot',
      'half_pot',
    ]);
    for (final task in tasks) {
      expect(task['acceptable_actions'], isEmpty);
    }

    final minRaiseTask = tasks.singleWhere(
      (task) => (task['task_id']! as String).contains('choose_min_raise'),
    );
    final potTask = tasks.singleWhere(
      (task) => (task['task_id']! as String).contains('choose_pot_pressure'),
    );
    expect(
      minRaiseTask['feedback_reason'],
      contains('smallest legal raise label'),
    );
    expect(potTask['feedback_reason'], contains('largest pressure-size label'));
    for (final task in tasks) {
      final feedback = task['feedback_reason']! as String;
      expect(feedback, isNot(contains('gets paid')));
      expect(feedback, isNot(contains('marginal hands')));
      expect(feedback, isNot(contains('worse hands')));
    }

    const strictSourcePaths = [
      'content/worlds/world1/v1/sessions/w1.s01/drills/'
          'd.choose_one_third_pot_keep_price.json',
      'content/worlds/world1/v1/sessions/w1.s01/drills/'
          'd.choose_half_pot_value.json',
      'content/worlds/world1/v1/sessions/w1.s01/drills/'
          'd.choose_min_raise_reopen.json',
      'content/worlds/world1/v1/sessions/w1.s01/drills/'
          'd.choose_pot_pressure.json',
    ];
    for (final sourcePath in strictSourcePaths) {
      final source = jsonDecode(File(sourcePath).readAsStringSync())! as Map;
      expect(
        source['acceptable_preset_ids'],
        anyOf(isNull, isEmpty),
        reason: sourcePath,
      );
    }

    final chainSource =
        jsonDecode(
              File(
                'content/worlds/world1/v1/sessions/w1.s01/drills/'
                'd.chain_world1_first_bridge_v1.json',
              ).readAsStringSync(),
            )!
            as Map;
    final chainSteps = (chainSource['steps']! as List).cast<Map>();
    for (final step in chainSteps.where(
      (step) =>
          {'one_third_pot', 'half_pot'}.contains(step['expected_preset_id']),
    )) {
      expect(
        step['acceptable_preset_ids'],
        anyOf(isNull, isEmpty),
        reason: '${chainSource['id']} step ${step['index']}',
      );
    }
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_one_third_pot_keep_price.json',
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_half_pot_value.json',
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_min_raise_reopen.json',
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.choose_pot_pressure.json',
        'content/worlds/world1/v1/sessions/w1.s01/drills/'
            'd.chain_world1_first_bridge_v1.json',
      ]),
    );
    expect(
      tasks
          .map(
            (task) => (task['migration_source']! as Map)['source_step_index'],
          )
          .whereType<int>()
          .toList(),
      [2, 3],
    );
  });

  test('exports W1 checkpoint synthesis PR3 from real chain roots', () {
    final first = exportW1CheckpointSynthesisPr3V1(writeFiles: false);
    final second = exportW1CheckpointSynthesisPr3V1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w1_checkpoint_synthesis_migration_pr3_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'world1_checkpoint_synthesis',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w1.world1_checkpoint_synthesis.seat_pressure_hand_quality_chain',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'connect_seat_pressure_hand_quality',
    });
    expect(tasks.map((task) => task['drill_kind']).toSet(), {'hand_chain_v1'});
    expect(tasks.map((task) => task['correct_action']).toSet(), {
      'complete_chain',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'blind_button_chain_v1',
      'action_order_chain_v1',
      'position_stability_chain_v1',
      'start_quality_chain_v1',
      'mixed_checkpoint_chain_v1',
      'final_checkpoint_chain_v1',
    });
    expect(
      tasks.map(
        (task) => (task['migration_source']! as Map)['source_chain_id'],
      ),
      containsAll([
        'w1_s02_blind_button_intro_v1',
        'w1_s03_action_order_checkpoint_v1',
        'w1_s04_position_stability_v1',
        'w1_s05_start_quality_reinforcement_v1',
        'w1_s06_mixed_checkpoint_v1',
        'w1_s10_final_checkpoint_v1',
      ]),
    );
  });

  test('exports W2 bridge schema migration pilot from real source tasks', () {
    final first = exportW2BridgeSchemaMigrationPilotV1(writeFiles: false);
    final second = exportW2BridgeSchemaMigrationPilotV1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w2_bridge_or_legacy_schema_migration_pilot_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 3);
    expect(validation.coverageCountableTasks, 3);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(3));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['display_world_title']).toSet(), {
      'Hand Discipline',
    });
    expect(tasks.map((task) => task['content_owner_world_id']).toSet(), {
      'world_2',
    });
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'bridge_or_legacy',
    });
    expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
      'limited_bridge',
    });
    expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
      false,
    });
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'position_btn_vs_early',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w2.position_btn_vs_early.bridge_action_default',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'position_price_action_default',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'early_position_release_v1',
      'facing_open_price_v1',
      'late_position_open_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'fold',
      'call',
      'raise',
    ]);
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_fold_early.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_call_vs_open.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_raise_btn.json',
      ]),
    );
  });

  test('exports W2 canonical certification pilot from real source tasks', () {
    final first = exportW2CanonicalCertificationPilotV1(writeFiles: false);
    final second = exportW2CanonicalCertificationPilotV1(writeFiles: false);

    expect(
      first.outputPath,
      endsWith('w2_canonical_certification_pilot_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['display_world_title']).toSet(), {
      'Hand Discipline',
    });
    expect(tasks.map((task) => task['content_owner_world_id']).toSet(), {
      'world_2',
    });
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
      'canonical_pilot',
    });
    expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
      false,
    });
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'hand_discipline_position_price_defaults',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w2.hand_discipline.position_price_action_defaults',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'position_price_hand_discipline',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'early_position_release_v1',
      'facing_open_price_v1',
      'late_position_open_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'fold',
      'call',
      'raise',
      'fold',
      'call',
      'raise',
    ]);
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_fold_early.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_call_vs_open.json',
        'content/worlds/world2/v1/sessions/w2.s01/drills/'
            'd.choose_raise_btn.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/'
            'd.choose_fold_utg_open.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/'
            'd.choose_call_btn_defend.json',
        'content/worlds/world2/v1/sessions/w2.s02/drills/'
            'd.choose_raise_btn_open.json',
      ]),
    );
  });

  test('exports W2 facing price discipline PR2 from real source tasks', () {
    final first = exportW2FacingPriceDisciplineCanonicalPr2V1(
      writeFiles: false,
    );
    final second = exportW2FacingPriceDisciplineCanonicalPr2V1(
      writeFiles: false,
    );

    expect(
      first.outputPath,
      endsWith('w2_facing_price_discipline_canonical_pr2_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 8);
    expect(validation.coverageCountableTasks, 8);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(8));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['display_world_title']).toSet(), {
      'Hand Discipline',
    });
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
      'canonical_pilot',
    });
    expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
      false,
    });
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'facing_price_continue_release_discipline',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w2.hand_discipline.facing_price_continue_release',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'facing_price_continue_release_discipline',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'facing_bet_price_continue_v1',
      'facing_bet_price_release_v1',
      'bridge_price_continue_v1',
      'bridge_price_release_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'call',
      'fold',
      'call',
      'fold',
      'call',
      'fold',
      'call',
      'fold',
    ]);
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world2/v1/sessions/w2.s03/drills/'
            'd.choose_call_facing_bet.json',
        'content/worlds/world2/v1/sessions/w2.s03/drills/'
            'd.choose_fold_facing_bet.json',
        'content/worlds/world2/v1/sessions/w2.s07/drills/'
            'd.choose_call_facing_open_price_ok.json',
        'content/worlds/world2/v1/sessions/w2.s07/drills/'
            'd.choose_fold_facing_open_price_bad.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/'
            'd.choose_call_bridge_tocall_price_ok.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/'
            'd.choose_fold_bridge_tocall_price_bad.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/'
            'd.choose_call_checkpoint_tocall_price_ok.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/'
            'd.choose_fold_checkpoint_tocall_price_bad.json',
      ]),
    );
  });

  test('exports W2 approved raise discipline PR3 from real source tasks', () {
    final first = exportW2ApprovedRaiseDisciplineCanonicalPr3V1(
      writeFiles: false,
    );
    final second = exportW2ApprovedRaiseDisciplineCanonicalPr3V1(
      writeFiles: false,
    );

    expect(
      first.outputPath,
      endsWith('w2_approved_raise_discipline_canonical_pr3_v1.json'),
    );
    expect(jsonEncode(first.fixture), jsonEncode(second.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      first.fixture,
      path: first.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(first.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_2'});
    expect(tasks.map((task) => task['display_world_title']).toSet(), {
      'Hand Discipline',
    });
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
      'canonical_pilot',
    });
    expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
      false,
    });
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'approved_raise_discipline',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w2.hand_discipline.approved_raise_only',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'approved_raise_only_when_source_grants_trigger',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'clear_aggression_trigger_raise_v1',
      'approved_isolation_raise_v1',
      'value_intent_raise_v1',
      'denial_raise_v1',
      'approved_pressure_counter_raise_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'raise',
      'raise',
      'raise',
      'raise',
      'raise',
      'raise',
    ]);
    expect(
      tasks.map((task) => (task['migration_source']! as Map)['source_path']),
      containsAll([
        'content/worlds/world2/v1/sessions/w2.s03/drills/'
            'd.choose_raise_to_facing_bet.json',
        'content/worlds/world2/v1/sessions/w2.s07/drills/'
            'd.choose_raise_facing_open_isolation.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/'
            'd.choose_raise_flop_value.json',
        'content/worlds/world2/v1/sessions/w2.s04/drills/'
            'd.choose_raise_flop_denial.json',
        'content/worlds/world2/v1/sessions/w2.s09/drills/'
            'd.choose_raise_bridge_pressure_counter.json',
        'content/worlds/world2/v1/sessions/w2.s10/drills/'
            'd.choose_raise_checkpoint_value_branch.json',
      ]),
    );
  });

  test(
    'exports W3-W6 bridge schema migration pilots from real source tasks',
    () {
      final pilots = [
        _BridgePilotExpectation(
          result: exportW3BridgeSchemaMigrationPilotV1(writeFiles: false),
          secondResult: exportW3BridgeSchemaMigrationPilotV1(writeFiles: false),
          outputPath: 'w3_bridge_or_legacy_schema_migration_pilot_v1.json',
          worldId: 'world_3',
          displayWorldTitle: 'Position Thinking',
          conceptFamilyId: 'preflop_framework_bridge',
          sameSignalGroupId: 'w3.preflop_framework.bridge_action_default',
          repairFocusId: 'preflop_frame_action_default',
          transferSurfaceIds: {
            'late_position_open_v1',
            'facing_open_continue_v1',
            'earlier_position_release_v1',
          },
          correctActions: ['raise', 'call', 'fold'],
          sourcePaths: {
            'content/worlds/world3/v1/sessions/w3.s06/drills/'
                'd.choose_raise_mixed_context_checkpoint_v1.json',
            'content/worlds/world3/v1/sessions/w3.s03/drills/'
                'd.choose_call_preflop_checkpoint_v1.json',
            'content/worlds/world3/v1/sessions/w3.s10/drills/'
                'd.choose_fold_final_preflop_checkpoint_v1.json',
          },
        ),
        _BridgePilotExpectation(
          result: exportW4BridgeSchemaMigrationPilotV1(writeFiles: false),
          secondResult: exportW4BridgeSchemaMigrationPilotV1(writeFiles: false),
          outputPath: 'w4_bridge_or_legacy_schema_migration_pilot_v1.json',
          worldId: 'world_4',
          displayWorldTitle: 'Bet Purpose / Price',
          conceptFamilyId: 'bet_purpose_price_bridge',
          sameSignalGroupId: 'w4.bet_purpose_price.bridge_action_default',
          repairFocusId: 'purpose_price_action_default',
          transferSurfaceIds: {
            'denial_raise_v1',
            'control_call_v1',
            'release_when_denial_gone_v1',
          },
          correctActions: ['raise', 'call', 'fold'],
          sourcePaths: {
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
                'd.choose_raise_focus.json',
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
                'd.choose_call_focus.json',
            'content/worlds/world4/v1/sessions/w4.s10/drills/'
                'd.choose_fold_focus.json',
          },
        ),
        _BridgePilotExpectation(
          result: exportW5BridgeSchemaMigrationPilotV1(writeFiles: false),
          secondResult: exportW5BridgeSchemaMigrationPilotV1(writeFiles: false),
          outputPath: 'w5_bridge_or_legacy_schema_migration_pilot_v1.json',
          worldId: 'world_5',
          displayWorldTitle: 'Board Awareness',
          conceptFamilyId: 'board_awareness_bridge',
          sameSignalGroupId: 'w5.board_awareness.bridge_texture_action_default',
          repairFocusId: 'texture_before_action',
          transferSurfaceIds: {
            'dry_texture_pressure_v1',
            'connected_texture_control_v1',
            'wet_texture_release_v1',
          },
          correctActions: ['raise', 'call', 'fold'],
          sourcePaths: {
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
                'd.classify_texture_synthesis_dry_raise_v1.json',
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
                'd.classify_texture_synthesis_connected_call_v1.json',
            'content/worlds/world5/v1/sessions/w5.s10/drills/'
                'd.classify_texture_synthesis_wet_fold_v1.json',
          },
        ),
        _BridgePilotExpectation(
          result: exportW6BridgeSchemaMigrationPilotV1(writeFiles: false),
          secondResult: exportW6BridgeSchemaMigrationPilotV1(writeFiles: false),
          outputPath: 'w6_bridge_or_legacy_schema_migration_pilot_v1.json',
          worldId: 'world_6',
          displayWorldTitle: 'Range Thinking',
          conceptFamilyId: 'range_thinking_bridge',
          sameSignalGroupId: 'w6.range_thinking.bridge_range_action_default',
          repairFocusId: 'range_before_action',
          transferSurfaceIds: {
            'range_strength_raise_v1',
            'equity_realization_call_v1',
            'range_weak_release_v1',
          },
          correctActions: ['raise', 'call', 'fold'],
          sourcePaths: {
            'content/worlds/world6/v1/sessions/w6.s10/drills/'
                'd.choose_raise_synthesis.json',
            'content/worlds/world6/v1/sessions/w6.s10/drills/'
                'd.choose_call_synthesis.json',
            'content/worlds/world6/v1/sessions/w6.s03/drills/'
                'd.choose_fold_trap.json',
          },
        ),
      ];

      for (final pilot in pilots) {
        expect(pilot.result.outputPath, endsWith(pilot.outputPath));
        expect(
          jsonEncode(pilot.result.fixture),
          jsonEncode(pilot.secondResult.fixture),
        );

        final validation = validateContentSchemaFoundationMapV1(
          pilot.result.fixture,
          path: pilot.result.outputPath,
        );
        expect(validation.errors, isEmpty);
        expect(validation.tasksChecked, 3);
        expect(validation.coverageCountableTasks, 3);

        final tasks = _tasks(pilot.result.fixture);
        expect(tasks.map((task) => task['task_id']).toSet(), hasLength(3));
        expect(tasks.map((task) => task['world_id']).toSet(), {pilot.worldId});
        expect(tasks.map((task) => task['route_world_id']).toSet(), {
          pilot.worldId,
        });
        expect(tasks.map((task) => task['display_world_title']).toSet(), {
          pilot.displayWorldTitle,
        });
        expect(tasks.map((task) => task['content_owner_world_id']).toSet(), {
          pilot.worldId,
        });
        expect(tasks.map((task) => task['source_truth_status']).toSet(), {
          'bridge_or_legacy',
        });
        expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
          'limited_bridge',
        });
        expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
          false,
        });
        expect(tasks.map((task) => task['concept_family_id']).toSet(), {
          pilot.conceptFamilyId,
        });
        expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
          pilot.sameSignalGroupId,
        });
        expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
          pilot.repairFocusId,
        });
        expect(
          tasks.map((task) => task['transfer_surface_id']).toSet(),
          pilot.transferSurfaceIds,
        );
        expect(
          tasks.map((task) => task['correct_action']).toList(),
          pilot.correctActions,
        );
        expect(
          tasks.map(
            (task) => (task['migration_source']! as Map)['source_path'],
          ),
          containsAll(pilot.sourcePaths),
        );
      }
    },
  );

  test(
    'exports W3 canonical certification pilot from position-thinking chains',
    () {
      final result = exportW3CanonicalCertificationPilotV1(writeFiles: false);
      final secondResult = exportW3CanonicalCertificationPilotV1(
        writeFiles: false,
      );

      expect(
        result.outputPath,
        endsWith('w3_canonical_certification_pilot_v1.json'),
      );
      expect(jsonEncode(result.fixture), jsonEncode(secondResult.fixture));

      final validation = validateContentSchemaFoundationMapV1(
        result.fixture,
        path: result.outputPath,
      );
      expect(validation.errors, isEmpty);
      expect(validation.tasksChecked, 6);
      expect(validation.coverageCountableTasks, 6);

      final tasks = _tasks(result.fixture);
      expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
      expect(tasks.map((task) => task['world_id']).toSet(), {'world_3'});
      expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_3'});
      expect(tasks.map((task) => task['display_world_title']).toSet(), {
        'Position Thinking',
      });
      expect(tasks.map((task) => task['content_owner_world_id']).toSet(), {
        'world_3',
      });
      expect(tasks.map((task) => task['route_gate_status']).toSet(), {
        'learner_playable',
      });
      expect(tasks.map((task) => task['source_truth_status']).toSet(), {
        'migrated',
      });
      expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
        'canonical_pilot',
      });
      expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
        false,
      });
      expect(tasks.map((task) => task['concept_family_id']).toSet(), {
        'position_sensitive_preflop_decision',
      });
      expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
        'w3.position_thinking.position_before_preflop_action',
      });
      expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
        'position_before_preflop_action',
      });
      expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
        'position_identity_v1',
        'unopened_late_position_open_v1',
        'facing_open_in_position_continue_v1',
        'facing_open_in_position_release_v1',
        'unopened_late_position_release_v1',
        'same_hand_position_shift_release_v1',
      });
      expect(tasks.map((task) => task['correct_action']).toList(), [
        'hero',
        'raise',
        'call',
        'fold',
        'fold',
        'fold',
      ]);

      final migrationSources = tasks
          .map((task) => (task['migration_source']! as Map))
          .toList();
      expect(
        migrationSources.map((source) => source['source_chain_id']).toSet(),
        {
          'w3_s11_position_open_call_v1',
          'w3_s12_position_continue_fold_v1',
          'w3_s13_position_open_fold_v1',
          'w3_s14_position_sensitive_open_fold_v1',
        },
      );
      expect(
        migrationSources.map((source) => source['source_step_index']).toSet(),
        {0, 1, 2},
      );
      expect(migrationSources.map((source) => source['source_job']).toSet(), {
        'position_thinking_canonical_pilot',
      });
    },
  );

  test('exports W3 hand bucket action frame PR2 from existing chains', () {
    final result = exportW3HandBucketActionFrameCanonicalPr2V1(
      writeFiles: false,
    );
    final secondResult = exportW3HandBucketActionFrameCanonicalPr2V1(
      writeFiles: false,
    );

    expect(
      result.outputPath,
      endsWith('w3_hand_bucket_action_frame_canonical_pr2_v1.json'),
    );
    expect(jsonEncode(result.fixture), jsonEncode(secondResult.fixture));

    final validation = validateContentSchemaFoundationMapV1(
      result.fixture,
      path: result.outputPath,
    );
    expect(validation.errors, isEmpty);
    expect(validation.tasksChecked, 6);
    expect(validation.coverageCountableTasks, 6);

    final tasks = _tasks(result.fixture);
    expect(tasks.map((task) => task['task_id']).toSet(), hasLength(6));
    expect(tasks.map((task) => task['world_id']).toSet(), {'world_3'});
    expect(tasks.map((task) => task['route_world_id']).toSet(), {'world_3'});
    expect(tasks.map((task) => task['display_world_title']).toSet(), {
      'Position Thinking',
    });
    expect(tasks.map((task) => task['content_owner_world_id']).toSet(), {
      'world_3',
    });
    expect(tasks.map((task) => task['source_truth_status']).toSet(), {
      'migrated',
    });
    expect(tasks.map((task) => task['safe_claim_status']).toSet(), {
      'canonical_pilot',
    });
    expect(tasks.map((task) => task['launch_coverage_claimed']).toSet(), {
      false,
    });
    expect(tasks.map((task) => task['concept_family_id']).toSet(), {
      'hand_bucket_action_frame_discipline',
    });
    expect(tasks.map((task) => task['same_signal_group_id']).toSet(), {
      'w3.position_thinking.hand_bucket_action_frame',
    });
    expect(tasks.map((task) => task['repair_focus_id']).toSet(), {
      'hand_bucket_before_preflop_action',
    });
    expect(tasks.map((task) => task['transfer_surface_id']).toSet(), {
      'unopened_premium_open_v1',
      'facing_open_playable_call_v1',
      'out_of_position_weak_release_v1',
      'facing_open_weak_release_v1',
      'facing_open_suited_continue_v1',
      'earlier_position_weak_release_v1',
    });
    expect(tasks.map((task) => task['correct_action']).toList(), [
      'raise',
      'call',
      'fold',
      'fold',
      'call',
      'fold',
    ]);

    final migrationSources = tasks
        .map((task) => (task['migration_source']! as Map))
        .toList();
    expect(
      migrationSources.map((source) => source['source_chain_id']).toSet(),
      {
        'w3_s01_preflop_framework_intro_v1',
        'w3_s02_preflop_category_reuse_v1',
        'w3_s08_preflop_continue_fold_discipline_v1',
        'w3_s10_preflop_final_checkpoint_v1',
      },
    );
    expect(
      migrationSources.map((source) => source['source_step_index']).toSet(),
      {0, 1, 2},
    );
    expect(migrationSources.map((source) => source['source_job']).toSet(), {
      'w3_canonical_coverage_pr2_hand_bucket_action_frame',
    });
  });

  test(
    'factory output rejects duplicate task IDs and missing required fields',
    () {
      final fixture = exportTinyContentFactorySamplesV1(
        writeFiles: false,
      ).first.fixture;
      final task = Map<String, Object?>.from(_singleTask(fixture));

      final duplicateResult = validateContentSchemaFoundationMapV1({
        'tasks': [task, Map<String, Object?>.from(task)],
      });
      expect(
        duplicateResult.errors,
        contains('tasks[1] duplicate task_id: ${task['task_id']}'),
      );

      final missingRequired = Map<String, Object?>.from(task)
        ..remove('feedback_reason');
      final missingResult = validateContentSchemaFoundationMapV1({
        'tasks': [missingRequired],
      });
      expect(
        missingResult.errors,
        contains('tasks[0] missing required field feedback_reason'),
      );
    },
  );

  test('non-ASCII output fails under existing schema validator', () {
    final fixture = exportTinyContentFactorySamplesV1(
      writeFiles: false,
    ).first.fixture;
    final task = Map<String, Object?>.from(_singleTask(fixture))
      ..['feedback_reason'] = 'Fold \u2192 preserve the stack.';

    final result = validateContentSchemaFoundationMapV1({
      'tasks': [task],
    });

    expect(result.errors, contains('tasks[0] contains non-ASCII text'));
  });

  test('preview-only samples remain excluded from coverage count', () {
    final fixture = exportTinyContentFactorySamplesV1(
      writeFiles: false,
    ).first.fixture;
    final task = Map<String, Object?>.from(_singleTask(fixture))
      ..['preview_only'] = true;

    final result = validateContentSchemaFoundationMapV1({
      'tasks': [task],
    });

    expect(result.errors, isEmpty);
    expect(result.coverageCountableTasks, 0);
  });

  test('writing fixtures preserves runtime source content', () {
    const sourcePath =
        'content/worlds/world1/v1/sessions/w1.s01/drills/d.choose_fold.json';
    final before = File(sourcePath).readAsStringSync();

    final results = exportTinyContentFactorySamplesV1(writeFiles: true);

    expect(results, hasLength(18));
    expect(File(sourcePath).readAsStringSync(), before);
  });
}

class _BridgePilotExpectation {
  const _BridgePilotExpectation({
    required this.result,
    required this.secondResult,
    required this.outputPath,
    required this.worldId,
    required this.displayWorldTitle,
    required this.conceptFamilyId,
    required this.sameSignalGroupId,
    required this.repairFocusId,
    required this.transferSurfaceIds,
    required this.correctActions,
    required this.sourcePaths,
  });

  final ContentFactoryImportExportResultV1 result;
  final ContentFactoryImportExportResultV1 secondResult;
  final String outputPath;
  final String worldId;
  final String displayWorldTitle;
  final String conceptFamilyId;
  final String sameSignalGroupId;
  final String repairFocusId;
  final Set<String> transferSurfaceIds;
  final List<String> correctActions;
  final Set<String> sourcePaths;
}

Map<String, Object?> _singleTask(Map<String, Object?> fixture) {
  final tasks = _tasks(fixture);
  expect(tasks, hasLength(1));
  return tasks.single;
}

List<Map<String, Object?>> _tasks(Map<String, Object?> fixture) {
  final tasks = fixture['tasks']! as List<Object?>;
  return tasks.map((task) => (task! as Map).cast<String, Object?>()).toList();
}
