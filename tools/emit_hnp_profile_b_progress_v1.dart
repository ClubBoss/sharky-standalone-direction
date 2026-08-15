import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const String _fixturePath =
    'tools/contracts/alpha_action_capability_prerequisite_progression_v1.json';

void main() {
  test('emits canonical production-equivalent Profile B progress', () {
    final outputPath = Platform.environment['HNP_PROFILE_B_OUTPUT'];
    expect(
      outputPath,
      isNotNull,
      reason: 'HNP_PROFILE_B_OUTPUT must identify the operator evidence file',
    );

    final fixtureFile = File(_fixturePath);
    expect(
      fixtureFile.existsSync(),
      isTrue,
      reason: 'missing canonical Profile B fixture: $_fixturePath',
    );

    final fixture =
        jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
    expect(fixture['schema'], 'act0_progression_fixture_v1');
    expect(fixture['source'], 'production_equivalent_persisted_progression');

    final lessonIds = (fixture['completed_lesson_ids'] as List<dynamic>)
        .map((value) => value.toString())
        .toList(growable: false);
    final target = fixture['target'] as Map<String, dynamic>;
    final state = Act0ShellStateV1.sample;
    final world = state.worldById(fixture['world_id'] as String);
    final completedTaskIds = <String>[
      for (final lessonId in lessonIds)
        ...world.lessons
            .firstWhere((lesson) => lesson.lessonId == lessonId)
            .taskList
            .map((task) => task.taskId),
    ];

    expect(lessonIds, hasLength(4));
    expect(completedTaskIds, hasLength(28));
    expect(target['lesson_id'], 'fold_check_call_raise');
    expect(target['task_id'], 'actions_theory');

    final progress = <String, Object>{
      'schemaVersion': 16,
      'completedTaskIds': completedTaskIds,
      'skippedTaskIds': <String>[],
      'completedLessonIds': lessonIds,
      'selectedWorldId': world.worldId,
      'selectedLessonId': target['lesson_id'] as String,
      'selectedTaskId': target['task_id'] as String,
      'earnedXp': 0,
    };

    final output = File(outputPath!);
    output.parent.createSync(recursive: true);
    output.writeAsStringSync('${jsonEncode(progress)}\n');
    stdout.writeln(jsonEncode(<String, Object>{
      'profile': 'B',
      'source': _fixturePath,
      'completedLessonCount': lessonIds.length,
      'completedTaskCount': completedTaskIds.length,
      'targetLessonId': target['lesson_id'] as String,
      'targetTaskId': target['task_id'] as String,
      'output': output.path,
    }));
  });
}
