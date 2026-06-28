import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../../tools/content_schema_foundation_validator_v1.dart';

void main() {
  test('L0 fixture passes Wave 6.1 schema foundation rules', () {
    final result = validateContentSchemaFoundationFixtureV1(
      File(
        'test/fixtures/content_schema_foundation/'
        'w1_schema_l0_valid_fixture_v1.json',
      ),
    );

    expect(result.errors, isEmpty);
    expect(result.tasksChecked, 1);
    expect(result.coverageCountableTasks, 1);
  });

  test('missing required fields are reported with task path', () {
    final result = validateContentSchemaFoundationMapV1({
      'tasks': [
        {
          'schema_version': 'content_schema_foundation_v1',
          'world_id': 'world_1',
        },
      ],
    });

    expect(
      result.errors,
      contains('tasks[0] missing required field route_world_id'),
    );
    expect(
      result.errors,
      contains('tasks[0] missing required field feedback_reason'),
    );
  });

  test('allowed value and W7-W12 learner-playable violations are reported', () {
    final result = validateContentSchemaFoundationMapV1({
      'tasks': [
        _validTask({
          'world_id': 'world_7',
          'route_world_id': 'world_7',
          'content_owner_world_id': 'world_7',
          'route_gate_status': 'learner_playable',
          'source_truth_status': 'unknown',
          'validation_status': 'trusted',
        }),
      ],
    });

    expect(
      result.errors,
      contains('tasks[0] invalid source_truth_status: unknown'),
    );
    expect(
      result.errors,
      contains('tasks[0] invalid validation_status: trusted'),
    );
    expect(
      result.errors,
      contains(
        'tasks[0] world_7 cannot use learner_playable route_gate_status',
      ),
    );
  });

  test('conditional repair, same-signal, transfer, and action rules run', () {
    final result = validateContentSchemaFoundationMapV1({
      'tasks': [
        _validTask({
          'repairable': true,
          'repair_focus_id': '',
          'claims_same_signal': true,
          'same_signal_group_id': '',
          'claims_transfer': true,
          'transfer_surface_id': '',
          'correct_action': '',
          'acceptable_actions': [],
        }),
      ],
    });

    expect(
      result.errors,
      contains('tasks[0] repairable task missing repair_focus_id'),
    );
    expect(
      result.errors,
      contains('tasks[0] same-signal task missing same_signal_group_id'),
    );
    expect(
      result.errors,
      contains('tasks[0] transfer task missing transfer_surface_id'),
    );
    expect(
      result.errors,
      contains('tasks[0] missing correct_action or acceptable_actions'),
    );
  });

  test('ASCII, ID format, and duplicate task_id rules run', () {
    final result = validateContentSchemaFoundationMapV1({
      'tasks': [
        _validTask({
          'task_id': 'w1.bad id',
          'feedback_reason': 'Use position \u2192 action.',
        }),
        _validTask({'task_id': 'w1.bad id'}),
      ],
    });

    expect(result.errors, contains('tasks[0] contains non-ASCII text'));
    expect(
      result.errors,
      contains('tasks[0] invalid task_id format: w1.bad id'),
    );
    expect(result.errors, contains('tasks[1] duplicate task_id: w1.bad id'));
  });

  test('CLI exits non-zero for an invalid fixture path', () async {
    final tempDir = Directory.systemTemp.createTempSync(
      'content_schema_foundation_validator_',
    );
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });
    final file = File('${tempDir.path}/invalid.json')
      ..writeAsStringSync(
        jsonEncode({
          'tasks': [
            _validTask({
              'route_gate_status': 'learner_playable',
              'world_id': 'world_8',
            }),
          ],
        }),
      );

    final process = await Process.run('dart', [
      'run',
      'tools/content_schema_foundation_validator_v1.dart',
      file.path,
    ]);

    expect(process.exitCode, 2);
    expect(
      '${process.stdout}${process.stderr}',
      contains('world_8 cannot use learner_playable route_gate_status'),
    );
  });
}

Map<String, Object?> _validTask([Map<String, Object?> overrides = const {}]) {
  return <String, Object?>{
    'schema_version': 'content_schema_foundation_v1',
    'world_id': 'world_1',
    'route_world_id': 'world_1',
    'display_world_title': 'Poker from Zero',
    'content_owner_world_id': 'world_1',
    'route_gate_status': 'learner_playable',
    'lesson_id': 'w1.l01',
    'task_id': 'w1.s01.position_action_order.r01',
    'concept_family_id': 'position_action_order',
    'drill_kind': 'action_choice',
    'correct_action': 'raise',
    'acceptable_actions': <String>[],
    'feedback_reason': 'Use position before action.',
    'validation_status': 'draft',
    'preview_only': false,
    'source_truth_status': 'canonical',
    ...overrides,
  };
}
