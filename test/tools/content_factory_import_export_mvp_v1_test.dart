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

    expect(results, hasLength(2));
    expect(File(sourcePath).readAsStringSync(), before);
  });
}

Map<String, Object?> _singleTask(Map<String, Object?> fixture) {
  final tasks = fixture['tasks']! as List<Object?>;
  expect(tasks, hasLength(1));
  return (tasks.single! as Map).cast<String, Object?>();
}
