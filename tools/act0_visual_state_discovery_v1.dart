import 'dart:io';

/// Exports the current Act0 runtime graph through a disposable Flutter test.
///
/// The exported values come from `Act0ShellStateV1.sample` and its typed task
/// objects. This launcher deliberately contains no source parsing: if Flutter
/// cannot load the production graph, the command fails with its test output.
void main(List<String> args) {
  final output = _outputPath(args);
  final root = Directory.current;
  final temporary = File(
    '${root.path}/test/.visual_state_atlas_runtime_export_tmp_test.dart',
  );
  temporary.writeAsStringSync(_testSource(output));
  try {
    final result = Process.runSync('flutter', <String>[
      'test',
      temporary.path,
      '--no-pub',
    ], workingDirectory: root.path);
    if (result.exitCode != 0) {
      stderr.write(result.stdout);
      stderr.write(result.stderr);
      throw ProcessException(
        'flutter test',
        <String>[temporary.path],
        'Typed runtime graph could not be loaded.',
        result.exitCode,
      );
    }
  } finally {
    if (temporary.existsSync()) temporary.deleteSync();
  }
  if (!File(output).existsSync()) {
    throw StateError(
      'Typed runtime exporter completed without producing $output.',
    );
  }
  stdout.writeln('ACT0_TYPED_VISUAL_STATE_DISCOVERY_WRITTEN:$output');
}

String _outputPath(List<String> args) {
  const prefix = '--output=';
  String? supplied;
  for (final arg in args) {
    if (arg.startsWith(prefix)) {
      supplied = arg;
      break;
    }
  }
  return supplied == null
      ? 'output/visual_control_center/current/runtime_discovery.json'
      : supplied.substring(prefix.length);
}

String _testSource(String output) =>
    '''
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('exports typed Act0 visual runtime graph', () {
    final state = Act0ShellStateV1.sample;
    final tasks = <Map<String, Object?>>[];
    final seen = <String>{};
    final lessonWorld = <String, Act0WorldCardV1>{};
    for (final world in state.worlds) {
      for (final lesson in world.lessons) { lessonWorld[lesson.lessonId] = world; }
    }
    final lessons = <Act0LessonCardV1>{...state.lessons, ...state.worlds.expand((world) => world.lessons)};
    for (final lesson in lessons) {
      final world = lessonWorld[lesson.lessonId];
      for (final task in lesson.taskList) {
        if (!seen.add(task.taskId)) continue;
        final runner = task.runner;
        final incorrect = runner.options.where((option) => !option.isCorrect).toList();
        final repair = task.resolvedTaskFamily == Act0TaskFamilyV1.repair || incorrect.any((option) => option.repairFocusSeatIds.isNotEmpty || option.repairFocusCardIds.isNotEmpty || option.repairFocusLabels.isNotEmpty);
        tasks.add(<String, Object?>{
          'state_id': 'runner.\${task.taskId}.\${task.phase.name}',
          'world_id': world?.worldId,
          'world_number': world?.worldNumber,
          'lesson_id': lesson.lessonId,
          'task_id': task.taskId,
          'task_family': task.resolvedTaskFamily.name,
          'renderer_family': task.resolvedCompositionFamily.name,
          'runner_phase': task.phase.name,
          'option_count': runner.options.length,
          'control_type': runner.options.any((option) => option.seatId != null) ? 'seat_selection' : (runner.sizingConfig.isEnabled ? runner.sizingConfig.mode.name : 'answer_choice'),
          'correct_branch_available': runner.options.any((option) => option.isCorrect),
          'incorrect_branch_available': incorrect.isNotEmpty,
          'repair_capable': repair,
          'source_recheck_relationship': repair ? 'UNKNOWN_TYPED_FIELD' : null,
          'completion_capable': runner.nextLessonId != null || runner.returnTarget.isNotEmpty,
          'table_present': runner.table.seats.isNotEmpty || runner.table.heroCards.isNotEmpty || runner.table.boardCards.isNotEmpty,
          'table_presentation_class': task.tablePresentation.name,
          'board_street_class': runner.table.streetLabel.isEmpty ? null : runner.table.streetLabel,
          'selection_mode': runner.selectedOptionId == null ? 'unselected' : 'selected',
          'scroll_content_form': 'UNKNOWN_TYPED_FIELD',
          'feedback_composition_class': incorrect.isEmpty ? 'correct_only' : (repair ? 'repair_capable' : 'standard_feedback'),
          'production_owner': 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
          'route_identity': 'act0.task.\${task.taskId}',
          'text_stress_class': 'normal',
        });
      }
    }
    final document = <String, Object?>{
      'schema': 'act0_visual_state_discovery_v2',
      'method': 'temporary Flutter test importing typed production objects',
      'source': 'Act0ShellStateV1.sample',
      'worlds': state.worlds.map((world) => <String, Object?>{'world_id': world.worldId, 'world_number': world.worldNumber, 'production_owner': 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart'}).toList(),
      'lessons': lessons.map((lesson) => <String, Object?>{'lesson_id': lesson.lessonId, 'production_owner': 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart', 'route_identity': 'act0.lesson.\${lesson.lessonId}'}).toList(),
      'tasks': tasks,
      'runner_phases': Act0LessonPhaseV1.values.map((value) => value.name).toList(),
      'unknown_typed_fields': <String>['scroll_content_form', 'source_recheck_relationship when no typed repair relationship is present'],
    };
    final file = File(r'$output'); file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(document));
  });
}
''';
