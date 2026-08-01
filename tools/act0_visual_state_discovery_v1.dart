import 'dart:convert';
import 'dart:io';

/// Bounded source extractor for the typed Act0 sample/runtime declarations.
///
/// This deliberately runs on the Dart VM (not a Flutter rendering isolate), so
/// it reads the production declarations rather than importing `dart:ui` owners.
/// It never derives semantics from learner-facing copy.
void main(List<String> args) {
  final root = Directory.current.path;
  final state = File(
    '$root/lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
  ).readAsStringSync();
  final preview = File(
    '$root/lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart',
  ).readAsStringSync();
  final tasks = _taskBlocks(state);
  final document = <String, Object?>{
    'schema': 'act0_visual_state_discovery_v1',
    'source': 'typed Act0ShellStateV1.sample declarations and capture enums',
    'worlds': _worlds(state),
    'lessons': _lessons(state),
    'tasks': tasks,
    'capture_surfaces': _enumValues(
      preview,
      'Act0ControlledDemoCaptureSurfaceV1',
    ),
    'shell_tabs': _enumValues(state, 'Act0ShellTabV1'),
    'runner_phases': _enumValues(state, 'Act0LessonPhaseV1'),
  };
  final output = _outputPath(args);
  final file = File(output);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(document));
  stdout.writeln('ACT0_VISUAL_STATE_DISCOVERY_WRITTEN:$output');
}

String _outputPath(List<String> args) {
  const prefix = '--output=';
  final supplied = args.where((arg) => arg.startsWith(prefix)).firstOrNull;
  return supplied == null
      ? 'output/visual_control_center/current/runtime_discovery.json'
      : supplied.substring(prefix.length);
}

List<Map<String, Object?>> _worlds(String source) {
  final matches = RegExp(
    r"worldId:\s*'([^']+)'[\s\S]{0,260}?worldNumber:\s*(\d+)",
  ).allMatches(source);
  return matches
      .map(
        (match) => <String, Object?>{
          'world_id': match.group(1),
          'world_number': int.parse(match.group(2)!),
          'production_owner': 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
        },
      )
      .toList();
}

List<Map<String, Object?>> _lessons(String source) {
  final ids = RegExp(r"lessonId:\s*'([^']+)'").allMatches(source);
  return ids
      .map(
        (match) => <String, Object?>{
          'lesson_id': match.group(1),
          'production_owner': 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
          'route_identity': 'act0.lesson.${match.group(1)}',
        },
      )
      .toList();
}

List<Map<String, Object?>> _taskBlocks(String source) {
  final result = <Map<String, Object?>>[];
  final seen = <String>{};
  for (final match in RegExp(r"taskId:\s*'([^']+)'").allMatches(source)) {
    final id = match.group(1)!;
    if (!seen.add(id)) continue;
    final start = (match.start - 900).clamp(0, source.length);
    final end = (match.end + 2400).clamp(0, source.length);
    final context = source.substring(start, end);
    final phase =
        RegExp(
          r'phase:\s*Act0LessonPhaseV1\.(\w+)',
        ).firstMatch(context)?.group(1) ??
        'drill';
    final optionCount = RegExp(
      r'Act0RunnerOptionV1\(',
    ).allMatches(context).length;
    final isSeat = context.contains('seatId:');
    final isSizing = context.contains('Act0SizingUiModeV1.presets');
    result.add(<String, Object?>{
      'state_id': 'runner.$id.$phase',
      'task_id': id,
      'renderer_family': id.contains('position') || isSeat
          ? 'f1TableNative'
          : 'f2AnswerList',
      'task_family': phase == 'theory' ? 'learn' : 'decision',
      'runner_phase': phase,
      'option_count': optionCount == 0 ? 1 : optionCount,
      'control_type': isSeat
          ? 'seat_selection'
          : (isSizing ? 'presetsOnly' : 'answer_choice'),
      'table': <String, Object?>{'present': true},
      'branches': <String, Object?>{
        'correct': context.contains('isCorrect: true'),
        'incorrect': context.contains('isCorrect: false'),
        'repair_capable': context.contains('repair'),
        'recheck_relation': context.contains('recheck'),
        'completion_capable': context.contains('nextLessonId:'),
      },
      'production_owner':
          'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      'route_identity': 'act0.task.$id',
    });
  }
  return result;
}

List<String> _enumValues(String source, String enumName) {
  final match = RegExp(
    'enum $enumName\\s*\\{([\\s\\S]*?)\\}',
  ).firstMatch(source);
  if (match == null) return const <String>[];
  return match
      .group(1)!
      .split(',')
      .map((value) => value.replaceAll(RegExp(r'//.*'), '').trim())
      .where((value) => RegExp(r'^\w+$').hasMatch(value))
      .toList();
}
