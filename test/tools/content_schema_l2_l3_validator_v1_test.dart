import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/content_schema_l2_l3_validator_v1.dart';

void main() {
  test('reports L2 coverage metrics and excludes preview-only tasks', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_schema_foundation/'
          'w1_l2_l3_coverage_ready_fixture_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 5);
    expect(world.previewOnlyTasks, 1);
    expect(
      world
          .sameSignalGroupCounts['w1.position_action_order.first_in_or_facing_pressure'],
      5,
    );
    expect(world.transferSurfaceCounts['table_seat_action_order_v1'], 3);
    expect(world.transferSurfaceCounts['table_first_in_raise_v1'], 2);
    expect(world.repairFocusCounts['position_before_action'], 5);
    expect(world.sourceTruthStatusCounts['canonical'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 5);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports real W1 factory coverage pilot as L2 route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(
      world
          .sameSignalGroupCounts['w1.position_action_order.first_in_or_facing_pressure'],
      6,
    );
    expect(world.transferSurfaceCounts['first_in_action_order_v1'], 2);
    expect(world.transferSurfaceCounts['facing_open_pressure_v1'], 3);
    expect(world.transferSurfaceCounts['multiway_pressure_v1'], 1);
    expect(world.repairFocusCounts['position_before_action'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports real W1 starting hand discipline batch as L2 route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w1_starting_hand_discipline_migration_batch1_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(world.conceptFamilyCounts['starting_hand_discipline'], 6);
    expect(
      world
          .sameSignalGroupCounts['w1.starting_hand_discipline.clean_start_or_release'],
      6,
    );
    expect(world.transferSurfaceCounts['clean_first_in_start_v1'], 3);
    expect(
      world.transferSurfaceCounts['facing_open_continue_or_release_v1'],
      1,
    );
    expect(world.transferSurfaceCounts['oop_weak_start_release_v1'], 2);
    expect(world.repairFocusCounts['release_weak_or_dominated_start'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports real W1 seat role orientation PR2 as L2 route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w1_seat_role_orientation_migration_pr2_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(world.conceptFamilyCounts['seat_role_orientation'], 6);
    expect(
      world
          .sameSignalGroupCounts['w1.seat_role_orientation.blind_button_seat_identity'],
      6,
    );
    expect(world.transferSurfaceCounts['button_role_find_v1'], 3);
    expect(world.transferSurfaceCounts['blind_role_find_v1'], 3);
    expect(world.repairFocusCounts['role_before_action'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports real W1 card board orientation PR2 as L2 route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w1_card_board_orientation_migration_pr2_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(world.conceptFamilyCounts['card_board_orientation'], 6);
    expect(
      world
          .sameSignalGroupCounts['w1.card_board_orientation.board_slot_identity'],
      6,
    );
    expect(world.transferSurfaceCounts['flop_slot_find_v1'], 2);
    expect(world.transferSurfaceCounts['turn_slot_find_v1'], 2);
    expect(world.transferSurfaceCounts['river_slot_find_v1'], 2);
    expect(world.repairFocusCounts['board_slot_before_action'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports real W1 bet size vocabulary PR3 as L2 route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w1_bet_size_vocabulary_preview_migration_pr3_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(world.conceptFamilyCounts['bet_size_vocabulary_preview'], 6);
    expect(
      world
          .sameSignalGroupCounts['w1.bet_size_vocabulary_preview.size_label_recognition'],
      6,
    );
    expect(world.transferSurfaceCounts['cheap_price_label_v1'], 2);
    expect(world.transferSurfaceCounts['value_size_label_v1'], 2);
    expect(world.transferSurfaceCounts['reopen_label_v1'], 1);
    expect(world.transferSurfaceCounts['pressure_size_label_v1'], 1);
    expect(world.repairFocusCounts['size_label_before_strategy'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports real W1 checkpoint synthesis PR3 as L2 route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w1_checkpoint_synthesis_migration_pr3_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);

    final world = result.worldReports['world_1']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(world.conceptFamilyCounts['world1_checkpoint_synthesis'], 6);
    expect(
      world
          .sameSignalGroupCounts['w1.world1_checkpoint_synthesis.seat_pressure_hand_quality_chain'],
      6,
    );
    expect(world.transferSurfaceCounts['blind_button_chain_v1'], 1);
    expect(world.transferSurfaceCounts['action_order_chain_v1'], 1);
    expect(world.transferSurfaceCounts['position_stability_chain_v1'], 1);
    expect(world.transferSurfaceCounts['start_quality_chain_v1'], 1);
    expect(world.transferSurfaceCounts['mixed_checkpoint_chain_v1'], 1);
    expect(world.transferSurfaceCounts['final_checkpoint_chain_v1'], 1);
    expect(world.repairFocusCounts['connect_seat_pressure_hand_quality'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('explicit W1 coverage fixture list excludes the L1 tiny sample', () {
    expect(
      w1ContentFactoryCoverageFixturePathsV1,
      isNot(
        contains(
          'test/fixtures/content_factory_mvp/w1_import_export_sample_v1.json',
        ),
      ),
    );

    final result = validateContentSchemaL2L3FixturePathsV1(
      w1ContentFactoryCoverageFixturePathsV1,
    );

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.fixtureCount, w1ContentFactoryCoverageFixturePathsV1.length);
    expect(result.coverageCountableTasks, 36);
    expect(result.worldReports['world_1']!.coverageReady, true);
  });

  test('real W1 pilot fails L2 threshold when trimmed below five reps', () {
    final file = File(
      'test/fixtures/content_factory_mvp/w1_world_coverage_pilot_v1.json',
    );
    final decoded = (jsonDecode(file.readAsStringSync()) as Map)
        .cast<String, Object?>();
    final tasks = (decoded['tasks']! as List<Object?>).take(4).toList();

    final result = validateContentSchemaL2L3MapV1({'tasks': tasks});

    expect(
      result.errors,
      contains(
        'world_1 same_signal_group_id '
        'w1.position_action_order.first_in_or_facing_pressure has 4 '
        'coverage_countable tasks; minimum is 5',
      ),
    );
  });

  test(
    'keeps factory bridge fixture reportable but not launch coverage-ready',
    () {
      final result = validateContentSchemaL2L3FixturePathsV1([
        'test/fixtures/content_factory_mvp/'
            'w2_bridge_or_legacy_import_export_sample_v1.json',
      ]);

      expect(result.errors, isEmpty);
      expect(result.routeAdmissionErrors, isEmpty);

      final world = result.worldReports['world_2']!;
      expect(world.totalTasks, 1);
      expect(world.coverageCountableTasks, 1);
      expect(world.sourceTruthStatusCounts['bridge_or_legacy'], 1);
      expect(world.coverageReady, false);
      expect(world.transferReady, false);
      expect(world.routeAdmissionStatus, 'bridge_or_legacy_limited');
      expect(
        result.warnings,
        contains(
          'world_2 bridge_or_legacy content is reportable but not canonical '
          'launch coverage',
        ),
      );
    },
  );

  test('reports W2 schema migration pilot as bridge-limited', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w2_bridge_or_legacy_schema_migration_pilot_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    final world = result.worldReports['world_2']!;
    expect(world.totalTasks, 3);
    expect(world.coverageCountableTasks, 3);
    expect(world.previewOnlyTasks, 0);
    expect(world.conceptFamilyCounts['position_btn_vs_early'], 3);
    expect(
      world
          .sameSignalGroupCounts['w2.position_btn_vs_early.bridge_action_default'],
      3,
    );
    expect(world.transferSurfaceCounts['early_position_release_v1'], 1);
    expect(world.transferSurfaceCounts['facing_open_price_v1'], 1);
    expect(world.transferSurfaceCounts['late_position_open_v1'], 1);
    expect(world.repairFocusCounts['position_price_action_default'], 3);
    expect(world.sourceTruthStatusCounts['bridge_or_legacy'], 3);
    expect(world.validationStatusCounts['source_validated'], 3);
    expect(world.migrationSourceCount, 3);
    expect(world.coverageReady, false);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'bridge_or_legacy_limited');
  });

  test('reports W2 canonical certification pilot as route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w2_canonical_certification_pilot_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    final world = result.worldReports['world_2']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.previewOnlyTasks, 0);
    expect(
      world.conceptFamilyCounts['hand_discipline_position_price_defaults'],
      6,
    );
    expect(
      world
          .sameSignalGroupCounts['w2.hand_discipline.position_price_action_defaults'],
      6,
    );
    expect(world.transferSurfaceCounts['early_position_release_v1'], 2);
    expect(world.transferSurfaceCounts['facing_open_price_v1'], 2);
    expect(world.transferSurfaceCounts['late_position_open_v1'], 2);
    expect(world.repairFocusCounts['position_price_hand_discipline'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.validationStatusCounts['source_validated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports W2 canonical PR2 facing price discipline as route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w2_facing_price_discipline_canonical_pr2_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    final world = result.worldReports['world_2']!;
    expect(world.totalTasks, 8);
    expect(world.coverageCountableTasks, 8);
    expect(
      world.conceptFamilyCounts['facing_price_continue_release_discipline'],
      8,
    );
    expect(
      world
          .sameSignalGroupCounts['w2.hand_discipline.facing_price_continue_release'],
      8,
    );
    expect(world.transferSurfaceCounts['facing_bet_price_continue_v1'], 2);
    expect(world.transferSurfaceCounts['facing_bet_price_release_v1'], 2);
    expect(world.transferSurfaceCounts['bridge_price_continue_v1'], 2);
    expect(world.transferSurfaceCounts['bridge_price_release_v1'], 2);
    expect(
      world.repairFocusCounts['facing_price_continue_release_discipline'],
      8,
    );
    expect(world.sourceTruthStatusCounts['migrated'], 8);
    expect(world.migrationSourceCount, 8);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('reports W2 canonical PR3 approved raise discipline as route-ready', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w2_approved_raise_discipline_canonical_pr3_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    final world = result.worldReports['world_2']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.conceptFamilyCounts['approved_raise_discipline'], 6);
    expect(
      world.sameSignalGroupCounts['w2.hand_discipline.approved_raise_only'],
      6,
    );
    expect(world.transferSurfaceCounts['clear_aggression_trigger_raise_v1'], 1);
    expect(world.transferSurfaceCounts['approved_isolation_raise_v1'], 1);
    expect(world.transferSurfaceCounts['value_intent_raise_v1'], 2);
    expect(world.transferSurfaceCounts['denial_raise_v1'], 1);
    expect(
      world.transferSurfaceCounts['approved_pressure_counter_raise_v1'],
      1,
    );
    expect(
      world.repairFocusCounts['approved_raise_only_when_source_grants_trigger'],
      6,
    );
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.migrationSourceCount, 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test(
    'reports W2 canonical pilot through PR3 as multiple route-ready families',
    () {
      final result = validateContentSchemaL2L3FixturePathsV1([
        'test/fixtures/content_factory_mvp/'
            'w2_canonical_certification_pilot_v1.json',
        'test/fixtures/content_factory_mvp/'
            'w2_facing_price_discipline_canonical_pr2_v1.json',
        'test/fixtures/content_factory_mvp/'
            'w2_approved_raise_discipline_canonical_pr3_v1.json',
      ]);

      expect(result.errors, isEmpty);
      expect(result.routeAdmissionErrors, isEmpty);
      expect(result.warnings, isEmpty);

      final world = result.worldReports['world_2']!;
      expect(world.totalTasks, 20);
      expect(world.coverageCountableTasks, 20);
      expect(
        world.conceptFamilyCounts['hand_discipline_position_price_defaults'],
        6,
      );
      expect(
        world.conceptFamilyCounts['facing_price_continue_release_discipline'],
        8,
      );
      expect(world.conceptFamilyCounts['approved_raise_discipline'], 6);
      expect(world.sourceTruthStatusCounts['migrated'], 20);
      expect(world.coverageReady, true);
      expect(world.transferReady, true);
      expect(world.repairReady, true);
      expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
    },
  );

  test('reports W3-W6 bridge expansion fixtures as bridge-limited', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w3_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w4_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w5_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w6_bridge_or_legacy_schema_migration_pilot_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    _expectBridgeWorldReport(
      result.worldReports['world_3']!,
      conceptFamilyId: 'preflop_framework_bridge',
      sameSignalGroupId: 'w3.preflop_framework.bridge_action_default',
      repairFocusId: 'preflop_frame_action_default',
      transferSurfaceIds: {
        'late_position_open_v1',
        'facing_open_continue_v1',
        'earlier_position_release_v1',
      },
    );
    _expectBridgeWorldReport(
      result.worldReports['world_4']!,
      conceptFamilyId: 'bet_purpose_price_bridge',
      sameSignalGroupId: 'w4.bet_purpose_price.bridge_action_default',
      repairFocusId: 'purpose_price_action_default',
      transferSurfaceIds: {
        'denial_raise_v1',
        'control_call_v1',
        'release_when_denial_gone_v1',
      },
    );
    _expectBridgeWorldReport(
      result.worldReports['world_5']!,
      conceptFamilyId: 'board_awareness_bridge',
      sameSignalGroupId: 'w5.board_awareness.bridge_texture_action_default',
      repairFocusId: 'texture_before_action',
      transferSurfaceIds: {
        'dry_texture_pressure_v1',
        'connected_texture_control_v1',
        'wet_texture_release_v1',
      },
    );
    _expectBridgeWorldReport(
      result.worldReports['world_6']!,
      conceptFamilyId: 'range_thinking_bridge',
      sameSignalGroupId: 'w6.range_thinking.bridge_range_action_default',
      repairFocusId: 'range_before_action',
      transferSurfaceIds: {
        'range_strength_raise_v1',
        'equity_realization_call_v1',
        'range_weak_release_v1',
      },
    );
  });

  test('reports W3 canonical certification pilot as route-ready coverage', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w3_canonical_certification_pilot_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    final world = result.worldReports['world_3']!;
    expect(world.totalTasks, 6);
    expect(world.coverageCountableTasks, 6);
    expect(world.conceptFamilyCounts['position_sensitive_preflop_decision'], 6);
    expect(
      world
          .sameSignalGroupCounts['w3.position_thinking.position_before_preflop_action'],
      6,
    );
    expect(world.repairFocusCounts['position_before_preflop_action'], 6);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.coverageReady, true);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'learner_playable_route_ready');
  });

  test('keeps W3 bridge plus canonical pilot bridge-limited', () {
    final result = validateContentSchemaL2L3FixturePathsV1([
      'test/fixtures/content_factory_mvp/'
          'w3_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w3_canonical_certification_pilot_v1.json',
    ]);

    expect(result.errors, isEmpty);
    expect(result.routeAdmissionErrors, isEmpty);
    expect(result.warnings, isEmpty);

    final world = result.worldReports['world_3']!;
    expect(world.totalTasks, 9);
    expect(world.coverageCountableTasks, 9);
    expect(world.sourceTruthStatusCounts['bridge_or_legacy'], 3);
    expect(world.sourceTruthStatusCounts['migrated'], 6);
    expect(world.coverageReady, false);
    expect(world.transferReady, true);
    expect(world.repairReady, true);
    expect(world.routeAdmissionStatus, 'bridge_or_legacy_limited');
  });

  test('blocks bridge pilot launch coverage claims', () {
    final file = File(
      'test/fixtures/content_factory_mvp/'
      'w2_bridge_or_legacy_schema_migration_pilot_v1.json',
    );
    final decoded = (jsonDecode(file.readAsStringSync()) as Map)
        .cast<String, Object?>();
    final tasks = (decoded['tasks']! as List<Object?>)
        .map(
          (task) =>
              Map<String, Object?>.from((task! as Map).cast<String, Object?>())
                ..['launch_coverage_claimed'] = true,
        )
        .toList();

    final result = validateContentSchemaL2L3MapV1({'tasks': tasks});

    expect(
      result.routeAdmissionErrors,
      contains(
        'world_2 bridge_or_legacy content must not claim launch coverage',
      ),
    );
  });

  test('blocks W3-W6 bridge expansion launch coverage claims', () {
    final tasks = <Object?>[];
    for (final path in [
      'test/fixtures/content_factory_mvp/'
          'w3_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w4_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w5_bridge_or_legacy_schema_migration_pilot_v1.json',
      'test/fixtures/content_factory_mvp/'
          'w6_bridge_or_legacy_schema_migration_pilot_v1.json',
    ]) {
      final decoded = (jsonDecode(File(path).readAsStringSync()) as Map)
          .cast<String, Object?>();
      tasks.addAll(
        (decoded['tasks']! as List<Object?>).map(
          (task) =>
              Map<String, Object?>.from((task! as Map).cast<String, Object?>())
                ..['launch_coverage_claimed'] = true,
        ),
      );
    }

    final result = validateContentSchemaL2L3MapV1({'tasks': tasks});

    for (final worldId in ['world_3', 'world_4', 'world_5', 'world_6']) {
      expect(
        result.routeAdmissionErrors,
        contains(
          '$worldId bridge_or_legacy content must not claim launch coverage',
        ),
      );
    }
  });

  test('reports route admission errors for locked and deferred worlds', () {
    final result = validateContentSchemaL2L3MapV1({
      'tasks': [
        _task({
          'world_id': 'world_7',
          'route_world_id': 'world_7',
          'content_owner_world_id': 'world_7',
          'route_gate_status': 'learner_playable',
        }),
        _task({
          'world_id': 'world_11',
          'route_world_id': 'world_11',
          'content_owner_world_id': 'world_11',
          'route_gate_status': 'learner_playable',
          'task_id': 'w11.s01.transfer.r01',
        }),
        _task({
          'world_id': 'world_13',
          'route_world_id': 'world_13',
          'content_owner_world_id': 'world_13',
          'route_gate_status': 'planned_only',
          'task_id': 'w13.s01.future.r01',
          'launch_available': true,
        }),
      ],
    }, path: '<route-claims>');

    expect(
      result.routeAdmissionErrors,
      contains('world_7 must not be learner_playable before route admission'),
    );
    expect(
      result.routeAdmissionErrors,
      contains(
        'world_11 learner_playable requires explicit route admission metadata',
      ),
    );
    expect(
      result.routeAdmissionErrors,
      contains('world_13 must not be marked launch_available before launch'),
    );
  });

  test(
    'reports L2 blockers for thin same-signal, transfer, and repair fields',
    () {
      final result = validateContentSchemaL2L3MapV1({
        'tasks': [
          _task({
            'claims_transfer': true,
            'transfer_surface_id': 'table_seat_action_order_v1',
            'repairable': true,
            'repair_focus_id': '',
          }),
        ],
      });

      expect(
        result.errors,
        contains(
          'world_1 same_signal_group_id '
          'w1.position_action_order.first_in_or_facing_pressure has 1 '
          'coverage_countable tasks; minimum is 5',
        ),
      );
      expect(
        result.errors,
        contains(
          'world_1 concept_family_id position_action_order has 1 transfer '
          'surface; minimum is 2',
        ),
      );
      expect(
        result.errors,
        contains(
          'world_1 repairable concept_family_id position_action_order is '
          'missing repair_focus_id',
        ),
      );
    },
  );

  test('CLI exits non-zero for invalid L3 route admission claims', () async {
    final tempDir = Directory.systemTemp.createTempSync(
      'content_schema_l2_l3_validator_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    final file = File('${tempDir.path}/invalid_route.json')
      ..writeAsStringSync(
        jsonEncode({
          'tasks': [
            _task({
              'world_id': 'world_8',
              'route_world_id': 'world_8',
              'content_owner_world_id': 'world_8',
              'route_gate_status': 'learner_playable',
            }),
          ],
        }),
      );

    final process = await Process.run('dart', [
      'run',
      'tools/content_schema_l2_l3_validator_v1.dart',
      file.path,
    ]);

    expect(process.exitCode, 2);
    expect(
      '${process.stdout}${process.stderr}',
      contains('world_8 must not be learner_playable before route admission'),
    );
  });
}

Map<String, Object?> _task([Map<String, Object?> overrides = const {}]) {
  return <String, Object?>{
    'schema_version': 'content_schema_foundation_v1',
    'world_id': 'world_1',
    'route_world_id': 'world_1',
    'display_world_title': 'Poker from Zero',
    'content_owner_world_id': 'world_1',
    'route_gate_status': 'learner_playable',
    'lesson_id': 'w1.l01',
    'session_id': 'w1.s01',
    'pack_id': 'world1_spine_campaign_v1',
    'task_id': 'w1.s01.position_action_order.r01',
    'concept_family_id': 'position_action_order',
    'repairable': true,
    'repair_focus_id': 'position_before_action',
    'claims_same_signal': true,
    'same_signal_group_id':
        'w1.position_action_order.first_in_or_facing_pressure',
    'claims_transfer': false,
    'transfer_surface_id': null,
    'misconception_id': 'acts_without_reading_position',
    'drill_kind': 'action_choice',
    'correct_action': 'raise',
    'acceptable_actions': <String>[],
    'feedback_reason': 'Use position before action.',
    'validation_status': 'source_validated',
    'preview_only': false,
    'source_truth_status': 'canonical',
    ...overrides,
  };
}

void _expectBridgeWorldReport(
  ContentSchemaWorldL2L3ReportV1 world, {
  required String conceptFamilyId,
  required String sameSignalGroupId,
  required String repairFocusId,
  required Set<String> transferSurfaceIds,
}) {
  expect(world.totalTasks, 3);
  expect(world.coverageCountableTasks, 3);
  expect(world.previewOnlyTasks, 0);
  expect(world.conceptFamilyCounts[conceptFamilyId], 3);
  expect(world.sameSignalGroupCounts[sameSignalGroupId], 3);
  expect(world.transferSurfaceCounts.keys.toSet(), transferSurfaceIds);
  expect(world.repairFocusCounts[repairFocusId], 3);
  expect(world.sourceTruthStatusCounts['bridge_or_legacy'], 3);
  expect(world.validationStatusCounts['source_validated'], 3);
  expect(world.migrationSourceCount, 3);
  expect(world.coverageReady, false);
  expect(world.transferReady, true);
  expect(world.repairReady, true);
  expect(world.routeAdmissionStatus, 'bridge_or_legacy_limited');
}
