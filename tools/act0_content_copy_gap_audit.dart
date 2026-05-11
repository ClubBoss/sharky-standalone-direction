import 'dart:io';

final _statePath = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
final _copyPath = File('lib/ui_v2/act0_shell/act0_content_copy_v1.dart');

void main() {
  if (!_statePath.existsSync() || !_copyPath.existsSync()) {
    stderr.writeln('Required Act0 state/copy files are missing.');
    exitCode = 1;
    return;
  }

  final stateSource = _statePath.readAsStringSync();
  final copySource = _copyPath.readAsStringSync();

  final stateWorldIds = _extractFieldValues(stateSource, 'worldId');
  final stateLessonIds = _extractFieldValues(stateSource, 'lessonId');
  final stateTaskIds = _extractFieldValues(stateSource, 'taskId');

  final copyWorldIds = _extractCopyMapKeys(copySource, '_ruWorldCopyByIdV1');
  final copyLessonIds = _extractCopyMapKeys(copySource, '_ruLessonCopyByIdV1');
  final copyTaskIds = _extractCopyMapKeys(copySource, '_ruTaskCopyByIdV1');

  final missingWorldIds = stateWorldIds.difference(copyWorldIds).toList()
    ..sort();
  final missingLessonIds = stateLessonIds.difference(copyLessonIds).toList()
    ..sort();
  final missingTaskIds = stateTaskIds.difference(copyTaskIds).toList()..sort();

  stdout.writeln('Act0 content copy gap audit');
  stdout.writeln('World ids in state: ${stateWorldIds.length}');
  stdout.writeln('Lesson ids in state: ${stateLessonIds.length}');
  stdout.writeln('Task ids in state: ${stateTaskIds.length}');
  stdout.writeln('Missing world ids: ${missingWorldIds.length}');
  stdout.writeln('Missing lesson ids: ${missingLessonIds.length}');
  stdout.writeln('Missing task ids: ${missingTaskIds.length}');

  _printSection('Missing world ids', missingWorldIds);
  _printSection('Missing lesson ids', missingLessonIds);
  _printSection('Missing task ids', missingTaskIds);

  stdout.writeln('');
  stdout.writeln('Starter task stub templates');
  for (final taskId in missingTaskIds.take(12)) {
    stdout.writeln(
      "  '$taskId': Act0TaskDisplayCopyV1(title: '', summary: ''),",
    );
  }
}

Set<String> _extractFieldValues(String source, String fieldName) {
  final matches = RegExp("$fieldName:\\s*'([^']+)'").allMatches(source);
  return matches
      .map((m) => m.group(1)!)
      .where((value) => !value.contains(r'${'))
      .toSet();
}

Set<String> _extractCopyMapKeys(String source, String mapName) {
  final mapStart = source.indexOf('$mapName =');
  if (mapStart == -1) {
    return <String>{};
  }
  final mapBodyStart = source.indexOf('{', mapStart);
  if (mapBodyStart == -1) {
    return <String>{};
  }

  var depth = 0;
  var mapBodyEnd = -1;
  for (var i = mapBodyStart; i < source.length; i++) {
    final char = source[i];
    if (char == '{') {
      depth += 1;
    } else if (char == '}') {
      depth -= 1;
      if (depth == 0) {
        mapBodyEnd = i;
        break;
      }
    }
  }

  if (mapBodyEnd == -1) {
    return <String>{};
  }

  final mapBody = source.substring(mapBodyStart, mapBodyEnd);
  final keyMatches = RegExp("'([^']+)':").allMatches(mapBody);
  return keyMatches
      .map((m) => m.group(1)!)
      .where((value) => !value.contains(r'${'))
      .toSet();
}

void _printSection(String title, List<String> values) {
  stdout.writeln('');
  stdout.writeln(title);
  if (values.isEmpty) {
    stdout.writeln('  none');
    return;
  }
  for (final value in values) {
    stdout.writeln('  $value');
  }
}
