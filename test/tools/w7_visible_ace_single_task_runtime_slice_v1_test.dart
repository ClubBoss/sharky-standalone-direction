import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tools/content_schema_foundation_validator_v1.dart';
import '../../tools/content_schema_l2_l3_validator_v1.dart';

void main() {
  const fixturePath =
      'test/fixtures/content_factory_mvp/'
      'w7_visible_ace_combo_reduction_intro_v1.json';

  Map<String, Object?> loadTask() {
    final decoded = jsonDecode(File(fixturePath).readAsStringSync());
    final fixture = (decoded as Map).cast<String, Object?>();
    final tasks = (fixture['tasks']! as List).cast<Map<String, Object?>>();
    return tasks.single;
  }

  test('visible ace task fixture is schema valid and route locked', () {
    final foundation = validateContentSchemaFoundationFixtureV1(
      File(fixturePath),
    );
    expect(foundation.errors, isEmpty);
    expect(foundation.tasksChecked, 1);

    final l2l3 = validateContentSchemaL2L3FixturePathsV1([fixturePath]);
    expect(l2l3.errors, isEmpty);
    expect(l2l3.routeAdmissionErrors, isEmpty);
    expect(
      l2l3.worldReports['world_7']?.routeAdmissionStatus,
      'not_route_ready',
    );

    final task = loadTask();
    expect(task['world_id'], 'world_7');
    expect(task['route_gate_status'], 'authored_but_not_routed');
    expect(task['task_id'], 'visible_ace_combo_reduction_intro');
    expect(task['source_task_id'], 'visible_ace_combo_reduction_intro');
    expect(task['concept_family_id'], 'w7_combo_density_visible_card_removal');
    expect(task['repair_focus_id'], 'w7_visible_card_combo_reduction');
    expect(task['skill_atom_id'], 'w7_combo_density_card_removal');
    expect(task['error_type'], 'missed_visible_card_combo_reduction');
    expect(task['correct_action'], 'ace_combos_reduced');
    expect(task['expected_choice'], 'ace_combos_reduced');
    expect(
      task['mapper_no_target_reason'],
      'w7_route_locked_no_safe_practice_target_v1',
    );
    expect(task['practice_cta_allowed'], isFalse);
  });

  test('visible ace choices and copy stay claim safe', () {
    final task = loadTask();
    final choices = (task['choices']! as List)
        .cast<Map<String, Object?>>()
        .map((choice) => choice['id'])
        .toList();
    expect(choices, <String>[
      'ace_combos_reduced',
      'ace_combos_unchanged',
      'ace_combos_guaranteed',
      'ace_combos_impossible',
    ]);

    final encodedTask = jsonEncode(task).toLowerCase();
    for (final forbidden in <String>[
      'gto',
      'solver',
      'optimal',
      'perfect',
      'mastered',
      'fixed',
      'guaranteed improvement',
      'ai leak',
    ]) {
      expect(encodedTask, isNot(contains(forbidden)));
    }
  });
}
