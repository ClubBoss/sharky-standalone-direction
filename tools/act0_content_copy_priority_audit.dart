import 'dart:io';

import '_lib/act0_copy_language_paths.dart';
import '_lib/act0_content_copy_source_parser.dart';

final _statePath = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');

void main(List<String> args) {
  final languageCode = _parseLanguageCode(args);
  final copyPath = File(act0LanguageCopyFilePathV1(languageCode));
  if (!_statePath.existsSync() || !copyPath.existsSync()) {
    stderr.writeln('Required Act0 state/copy files are missing.');
    exitCode = 1;
    return;
  }

  final stateSource = _statePath.readAsStringSync();
  final copySource = copyPath.readAsStringSync();
  final bundle = Act0SourceParser(stateSource).parse();

  final copyLessonIds = _extractCopyMapKeys(
    copySource,
    '_${languageCode}LessonCopyByIdV1',
  );
  final copyTaskIds = _extractCopyMapKeys(
    copySource,
    '_${languageCode}TaskCopyByIdV1',
  );

  final missingLessons = <_PriorityItem>[];
  final missingTasks = <_PriorityItem>[];

  for (final world in bundle.worlds) {
    for (final lesson in world.lessons) {
      if (!copyLessonIds.contains(lesson.lessonId)) {
        missingLessons.add(
          _PriorityItem.lesson(
            world: world,
            lesson: lesson,
            score: _scoreLesson(world),
          ),
        );
      }

      for (final task in lesson.tasks) {
        if (copyTaskIds.contains(task.taskId)) {
          continue;
        }
        missingTasks.add(
          _PriorityItem.task(
            world: world,
            lesson: lesson,
            task: task,
            score: _scoreTask(world, task),
          ),
        );
      }
    }
  }

  missingLessons.sort(_sortPriorityDesc);
  missingTasks.sort(_sortPriorityDesc);

  stdout.writeln(
    'Act0 ${languageCode.toUpperCase()} content copy priority audit',
  );
  stdout.writeln('Lessons missing in copy seam: ${missingLessons.length}');
  stdout.writeln('Tasks missing in copy seam: ${missingTasks.length}');
  stdout.writeln('');
  stdout.writeln('Scoring');
  stdout.writeln('  world_1-3 visible route bonus');
  stdout.writeln('  runner-bearing tasks score above label-only tasks');
  stdout.writeln('  review/fix tasks score above passive backlog');

  _printPrioritySection(
    'Top missing lessons',
    missingLessons.take(24).toList(),
  );
  _printPrioritySection('Top missing tasks', missingTasks.take(40).toList());

  stdout.writeln('');
  stdout.writeln('Suggested next authoring commands');
  for (final worldId in _topWorldIds(missingTasks.take(12))) {
    stdout.writeln(
      '  dart run tools/act0_content_copy_authoring_pack.dart --world $worldId',
    );
  }
}

String _parseLanguageCode(List<String> args) {
  for (var index = 0; index < args.length; index += 1) {
    if (args[index] != '--lang') {
      continue;
    }
    if (index + 1 >= args.length) {
      stderr.writeln('Missing value for --lang');
      exit(64);
    }
    return act0NormalizedLanguageCodeForToolsV1(args[index + 1]);
  }
  return 'ru';
}

int _scoreLesson(Act0WorldPack world) {
  var score = _worldWeight(world.worldNumber);
  if (world.worldNumber <= 3) {
    score += 40;
  }
  return score;
}

int _scoreTask(Act0WorldPack world, Act0TaskPack task) {
  var score = _worldWeight(world.worldNumber);
  if (task.hasRunnerCopy) {
    score += 50;
  }
  if (task.question?.trim().isNotEmpty ?? false) {
    score += 35;
  }
  if (task.phase == 'review') {
    score += 20;
  } else if (task.phase == 'theory') {
    score += 15;
  }
  if (task.stepKind == 'fixMistakes' || task.stepKind == 'proveIt') {
    score += 15;
  }
  return score;
}

int _worldWeight(int worldNumber) {
  if (worldNumber <= 3) {
    return 300 - (worldNumber * 10);
  }
  if (worldNumber <= 6) {
    return 220 - (worldNumber * 5);
  }
  if (worldNumber <= 9) {
    return 160 - (worldNumber * 3);
  }
  return 120 - worldNumber;
}

int _sortPriorityDesc(_PriorityItem a, _PriorityItem b) {
  final scoreCompare = b.score.compareTo(a.score);
  if (scoreCompare != 0) {
    return scoreCompare;
  }
  final worldCompare = a.worldId.compareTo(b.worldId);
  if (worldCompare != 0) {
    return worldCompare;
  }
  return a.id.compareTo(b.id);
}

void _printPrioritySection(String title, List<_PriorityItem> items) {
  stdout.writeln('');
  stdout.writeln(title);
  if (items.isEmpty) {
    stdout.writeln('  none');
    return;
  }

  for (final item in items) {
    stdout.writeln(
      '  [${item.score}] ${item.worldId} / ${item.lessonId} / ${item.id}',
    );
    stdout.writeln('    ${item.label}');
  }
}

Iterable<String> _topWorldIds(Iterable<_PriorityItem> items) sync* {
  final seen = <String>{};
  for (final item in items) {
    if (seen.add(item.worldId)) {
      yield item.worldId;
    }
  }
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

  final mapBodyEnd = findMatchingDelimiter(source, mapBodyStart, '{', '}');
  final mapBody = source.substring(mapBodyStart, mapBodyEnd);
  final keyMatches = RegExp("'([^']+)':").allMatches(mapBody);
  return keyMatches
      .map((m) => m.group(1)!)
      .where((value) => !value.contains(r'${'))
      .toSet();
}

class _PriorityItem {
  const _PriorityItem({
    required this.id,
    required this.label,
    required this.worldId,
    required this.lessonId,
    required this.score,
  });

  factory _PriorityItem.lesson({
    required Act0WorldPack world,
    required Act0LessonPack lesson,
    required int score,
  }) {
    return _PriorityItem(
      id: lesson.lessonId,
      label: lesson.title,
      worldId: world.worldId,
      lessonId: lesson.lessonId,
      score: score,
    );
  }

  factory _PriorityItem.task({
    required Act0WorldPack world,
    required Act0LessonPack lesson,
    required Act0TaskPack task,
    required int score,
  }) {
    return _PriorityItem(
      id: task.taskId,
      label: task.title,
      worldId: world.worldId,
      lessonId: lesson.lessonId,
      score: score,
    );
  }

  final String id;
  final String label;
  final String worldId;
  final String lessonId;
  final int score;
}
