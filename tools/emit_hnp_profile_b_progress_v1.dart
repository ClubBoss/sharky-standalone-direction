import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

const String _fixturePath =
    'tools/contracts/alpha_action_capability_prerequisite_progression_v1.json';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tools/emit_hnp_profile_b_progress_v1.dart <output-json>');
    exitCode = 64;
    return;
  }

  final fixtureFile = File(_fixturePath);
  if (!fixtureFile.existsSync()) {
    stderr.writeln('missing canonical Profile B fixture: $_fixturePath');
    exitCode = 2;
    return;
  }

  final fixture = jsonDecode(fixtureFile.readAsStringSync()) as Map<String, dynamic>;
  if (fixture['schema'] != 'act0_progression_fixture_v1' ||
      fixture['source'] != 'production_equivalent_persisted_progression') {
    stderr.writeln('unexpected Profile B fixture authority');
    exitCode = 3;
    return;
  }

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

  if (lessonIds.length != 4) {
    stderr.writeln('Profile B must materialize exactly 4 prerequisite lessons; found ${lessonIds.length}');
    exitCode = 4;
    return;
  }
  if (completedTaskIds.length != 28) {
    stderr.writeln('Profile B must materialize exactly 28 prerequisite tasks; found ${completedTaskIds.length}');
    exitCode = 5;
    return;
  }
  if (target['lesson_id'] != 'fold_check_call_raise' ||
      target['task_id'] != 'actions_theory') {
    stderr.writeln('Profile B canonical Action target drifted');
    exitCode = 6;
    return;
  }

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

  final output = File(args.single);
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
}
