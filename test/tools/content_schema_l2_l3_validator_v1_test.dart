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
