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
          displayWorldTitle: 'Preflop Framework',
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
          displayWorldTitle: 'Bet Purpose And Price',
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
          displayWorldTitle: 'Board And Draws',
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

    expect(results, hasLength(8));
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
