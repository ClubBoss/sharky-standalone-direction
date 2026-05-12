import 'dart:io';

import '_lib/act0_content_copy_source_parser.dart';
import '_lib/act0_translation_pack_markdown.dart';

final _statePath = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
final _packsDir = Directory('docs/l10n/act0_world_packs');

void main(List<String> args) {
  final options = _PackAuditOptions.parse(args);
  if (!_statePath.existsSync() || !_packsDir.existsSync()) {
    stderr.writeln('Required Act0 state or packs directory is missing.');
    exitCode = 1;
    return;
  }

  final content = Act0SourceParser(_statePath.readAsStringSync()).parse();
  final worldById = {for (final world in content.worlds) world.worldId: world};
  final packFiles = _collectPackFiles(options.packPaths);
  final findings = <String>[];

  stdout.writeln(
    'Act0 ${options.languageCode.toUpperCase()} translation pack audit',
  );
  for (final file in packFiles) {
    final pack = Act0TranslationPackParser(
      file.readAsStringSync(),
      sourcePath: file.path,
      languageCode: options.languageCode,
    ).parse();
    final world = worldById[pack.worldId];
    if (world == null) {
      findings.add('${file.path}: unknown worldId ${pack.worldId}');
      continue;
    }
    final lessonById = {
      for (final lesson in world.lessons) lesson.lessonId: lesson,
    };
    final seenLessons = <String>{};
    final seenTasks = <String>{};

    for (final lesson in pack.lessons) {
      if (!seenLessons.add(lesson.lessonId)) {
        findings.add('${file.path}: duplicate lessonId ${lesson.lessonId}');
      }
      final sourceLesson = lessonById[lesson.lessonId];
      if (sourceLesson == null) {
        findings.add('${file.path}: unknown lessonId ${lesson.lessonId}');
        continue;
      }
      final taskById = {
        for (final task in sourceLesson.tasks) task.taskId: task,
      };
      for (final task in lesson.tasks) {
        if (!seenTasks.add(task.taskId)) {
          findings.add('${file.path}: duplicate taskId ${task.taskId}');
        }
        final sourceTask = taskById[task.taskId];
        if (sourceTask == null) {
          findings.add(
            '${file.path}: taskId ${task.taskId} does not belong to lesson ${lesson.lessonId}',
          );
          continue;
        }
        _checkUnexpectedFilledField(
          findings,
          file.path,
          task.taskId,
          'summary_${options.languageCode}',
          task.summaryLocalized,
          sourceTask.summary,
        );
        _checkUnexpectedFilledField(
          findings,
          file.path,
          task.taskId,
          'lockedSummary_${options.languageCode}',
          task.lockedSummaryLocalized,
          sourceTask.lockedSummary,
        );
        _checkUnexpectedFilledField(
          findings,
          file.path,
          task.taskId,
          'runnerPrompt_${options.languageCode}',
          task.runnerPromptLocalized,
          sourceTask.caption,
        );
        _checkUnexpectedFilledField(
          findings,
          file.path,
          task.taskId,
          'runnerSupport_${options.languageCode}',
          task.runnerSupportLocalized,
          sourceTask.hint,
        );
        _checkUnexpectedFilledField(
          findings,
          file.path,
          task.taskId,
          'runnerQuestion_${options.languageCode}',
          task.runnerQuestionLocalized,
          sourceTask.question,
        );
        for (final teachingStep in task.teachingSteps) {
          final sourceStep =
              teachingStep.stepIndex < sourceTask.teachingSteps.length
              ? sourceTask.teachingSteps[teachingStep.stepIndex]
              : null;
          _checkUnexpectedFilledField(
            findings,
            file.path,
            task.taskId,
            'teachingStep${teachingStep.stepIndex}_title_${options.languageCode}',
            teachingStep.titleLocalized,
            sourceStep?.title,
          );
          _checkUnexpectedFilledField(
            findings,
            file.path,
            task.taskId,
            'teachingStep${teachingStep.stepIndex}_body_${options.languageCode}',
            teachingStep.bodyLocalized,
            sourceStep?.body,
          );
        }
      }
    }

    final lessonCount = pack.lessons.length;
    final taskCount = pack.lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.tasks.length,
    );
    final filledTitles = pack.lessons.fold<int>(
      0,
      (sum, lesson) =>
          sum +
          lesson.tasks
              .where((task) => task.titleLocalized.trim().isNotEmpty)
              .length,
    );
    stdout.writeln(
      '${pack.worldId}: lessons=$lessonCount tasks=$taskCount title_ru_filled=$filledTitles',
    );
  }

  if (findings.isEmpty) {
    stdout.writeln('Audit findings: 0');
    return;
  }

  stdout.writeln('Audit findings: ${findings.length}');
  for (final finding in findings) {
    stdout.writeln('  $finding');
  }
  exitCode = 2;
}

List<File> _collectPackFiles(List<String> packPaths) {
  if (packPaths.isEmpty) {
    return _packsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('_PACK_v1.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }
  return packPaths.map(File.new).toList();
}

void _checkUnexpectedFilledField(
  List<String> findings,
  String path,
  String taskId,
  String fieldName,
  String ruValue,
  String? sourceValue,
) {
  if (ruValue.trim().isEmpty) {
    return;
  }
  if (sourceValue?.trim().isNotEmpty ?? false) {
    return;
  }
  findings.add('$path: $taskId fills $fieldName but source field is absent');
}

class _PackAuditOptions {
  const _PackAuditOptions({
    required this.languageCode,
    required this.packPaths,
  });

  final String languageCode;
  final List<String> packPaths;

  static _PackAuditOptions parse(List<String> args) {
    var languageCode = 'ru';
    final packPaths = <String>[];
    for (var index = 0; index < args.length; index += 1) {
      final arg = args[index];
      if (arg == '--lang') {
        if (index + 1 >= args.length) {
          stderr.writeln('Missing value for --lang');
          exit(64);
        }
        languageCode = args[++index];
        continue;
      }
      packPaths.add(arg);
    }
    return _PackAuditOptions(
      languageCode: _normalizeLanguageCode(languageCode),
      packPaths: packPaths,
    );
  }
}

String _normalizeLanguageCode(String languageCode) =>
    languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
