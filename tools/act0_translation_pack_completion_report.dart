import 'dart:io';

import '_lib/act0_translation_pack_markdown.dart';

final _packsDir = Directory('docs/l10n/act0_world_packs');

void main(List<String> args) {
  final languageCode = _parseLanguageCode(args);
  if (!_packsDir.existsSync()) {
    stderr.writeln('Missing packs directory: ${_packsDir.path}');
    exitCode = 1;
    return;
  }

  final files =
      _packsDir
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('_${languageCode.toUpperCase()}_PACK_v1.md'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  var totalLessons = 0;
  var filledLessonTitles = 0;
  var filledLessonSubtitles = 0;
  var totalTasks = 0;
  var filledTaskTitles = 0;
  var filledTaskSummaries = 0;
  var filledTaskLockedSummaries = 0;
  var filledRunnerPrompts = 0;
  var filledRunnerSupports = 0;
  var filledRunnerQuestions = 0;
  var totalTeachingSteps = 0;
  var filledTeachingStepTitles = 0;
  var filledTeachingStepBodies = 0;

  stdout.writeln(
    'Act0 ${languageCode.toUpperCase()} translation pack completion report',
  );
  stdout.writeln(
    'worldId | lessonTitle | lessonSubtitle | taskTitle | taskSummary | runnerPrompt | runnerSupport | runnerQuestion | stepTitle | stepBody',
  );

  for (final file in files) {
    final pack = Act0TranslationPackParser(
      file.readAsStringSync(),
      sourcePath: file.path,
      languageCode: languageCode,
    ).parse();

    totalLessons += pack.lessons.length;
    final worldLessonTitles = pack.lessons
        .where((lesson) => lesson.titleLocalized.trim().isNotEmpty)
        .length;
    final worldLessonSubtitles = pack.lessons
        .where((lesson) => lesson.subtitleLocalized.trim().isNotEmpty)
        .length;
    filledLessonTitles += worldLessonTitles;
    filledLessonSubtitles += worldLessonSubtitles;

    var worldTasks = 0;
    var worldTaskTitles = 0;
    var worldTaskSummaries = 0;
    var worldRunnerPrompts = 0;
    var worldRunnerSupports = 0;
    var worldRunnerQuestions = 0;
    var worldStepTitles = 0;
    var worldStepBodies = 0;

    for (final lesson in pack.lessons) {
      totalTasks += lesson.tasks.length;
      worldTasks += lesson.tasks.length;
      for (final task in lesson.tasks) {
        if (task.titleLocalized.trim().isNotEmpty) {
          filledTaskTitles += 1;
          worldTaskTitles += 1;
        }
        if (task.summaryLocalized.trim().isNotEmpty) {
          filledTaskSummaries += 1;
          worldTaskSummaries += 1;
        }
        if (task.lockedSummaryLocalized.trim().isNotEmpty) {
          filledTaskLockedSummaries += 1;
        }
        if (task.runnerPromptLocalized.trim().isNotEmpty) {
          filledRunnerPrompts += 1;
          worldRunnerPrompts += 1;
        }
        if (task.runnerSupportLocalized.trim().isNotEmpty) {
          filledRunnerSupports += 1;
          worldRunnerSupports += 1;
        }
        if (task.runnerQuestionLocalized.trim().isNotEmpty) {
          filledRunnerQuestions += 1;
          worldRunnerQuestions += 1;
        }
        totalTeachingSteps += task.teachingSteps.length;
        for (final step in task.teachingSteps) {
          if (step.titleLocalized.trim().isNotEmpty) {
            filledTeachingStepTitles += 1;
            worldStepTitles += 1;
          }
          if (step.bodyLocalized.trim().isNotEmpty) {
            filledTeachingStepBodies += 1;
            worldStepBodies += 1;
          }
        }
      }
    }

    stdout.writeln(
      '${pack.worldId} | '
      '$worldLessonTitles/${pack.lessons.length} | '
      '$worldLessonSubtitles/${pack.lessons.length} | '
      '$worldTaskTitles/$worldTasks | '
      '$worldTaskSummaries/$worldTasks | '
      '$worldRunnerPrompts/$worldTasks | '
      '$worldRunnerSupports/$worldTasks | '
      '$worldRunnerQuestions/$worldTasks | '
      '$worldStepTitles/${_worldTeachingSteps(pack)} | '
      '$worldStepBodies/${_worldTeachingSteps(pack)}',
    );
  }

  stdout.writeln('');
  stdout.writeln('Totals');
  stdout.writeln('  lesson titles: $filledLessonTitles/$totalLessons');
  stdout.writeln('  lesson subtitles: $filledLessonSubtitles/$totalLessons');
  stdout.writeln('  task titles: $filledTaskTitles/$totalTasks');
  stdout.writeln('  task summaries: $filledTaskSummaries/$totalTasks');
  stdout.writeln('  locked summaries: $filledTaskLockedSummaries/$totalTasks');
  stdout.writeln('  runner prompts: $filledRunnerPrompts/$totalTasks');
  stdout.writeln('  runner supports: $filledRunnerSupports/$totalTasks');
  stdout.writeln('  runner questions: $filledRunnerQuestions/$totalTasks');
  stdout.writeln(
    '  teaching step titles: $filledTeachingStepTitles/$totalTeachingSteps',
  );
  stdout.writeln(
    '  teaching step bodies: $filledTeachingStepBodies/$totalTeachingSteps',
  );
}

int _worldTeachingSteps(Act0TranslationPack pack) {
  return pack.lessons.fold<int>(
    0,
    (sum, lesson) =>
        sum +
        lesson.tasks.fold<int>(
          0,
          (taskSum, task) => taskSum + task.teachingSteps.length,
        ),
  );
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
    return args[index + 1].trim().toLowerCase().split(RegExp('[-_]')).first;
  }
  return 'ru';
}
