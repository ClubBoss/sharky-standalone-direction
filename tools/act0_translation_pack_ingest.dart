import 'dart:io';

import '_lib/act0_translation_pack_markdown.dart';

final _packsDir = Directory('docs/l10n/act0_world_packs');

void main(List<String> args) {
  final options = _PackIngestOptions.parse(args);
  if (!_packsDir.existsSync()) {
    stderr.writeln('Missing packs directory: ${_packsDir.path}');
    exitCode = 1;
    return;
  }

  final packFiles = _collectPackFiles(options.packPaths);
  final worlds = <String, String>{};
  final lessons = <String, String>{};
  final tasks = <String, String>{};

  for (final file in packFiles) {
    final pack = Act0TranslationPackParser(
      file.readAsStringSync(),
      sourcePath: file.path,
      languageCode: options.languageCode,
    ).parse();
    if (pack.titleLocalized.trim().isNotEmpty ||
        pack.subtitleLocalized.trim().isNotEmpty) {
      worlds[pack.worldId] = _renderWorldStub(pack, options.languageCode);
    }
    for (final lesson in pack.lessons) {
      if (lesson.titleLocalized.trim().isNotEmpty ||
          lesson.subtitleLocalized.trim().isNotEmpty) {
        lessons[lesson.lessonId] = _renderLessonStub(
          lesson,
          options.languageCode,
        );
      }
      for (final task in lesson.tasks) {
        final taskStub = _renderTaskStub(task, options.languageCode);
        if (taskStub != null) {
          tasks[task.taskId] = taskStub;
        }
      }
    }
  }

  stdout.writeln(
    '// ${options.languageCode.toUpperCase()} translation pack ingest output',
  );
  stdout.writeln('// Paste selected stubs into act0_content_copy_v1.dart');
  stdout.writeln('');
  stdout.writeln('// Worlds: ${worlds.length}');
  for (final key in worlds.keys.toList()..sort()) {
    stdout.writeln(worlds[key]);
  }
  stdout.writeln('');
  stdout.writeln('// Lessons: ${lessons.length}');
  for (final key in lessons.keys.toList()..sort()) {
    stdout.writeln(lessons[key]);
  }
  stdout.writeln('');
  stdout.writeln('// Tasks: ${tasks.length}');
  for (final key in tasks.keys.toList()..sort()) {
    stdout.writeln(tasks[key]);
  }
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

String _renderWorldStub(Act0TranslationPack pack, String languageCode) {
  return "'${pack.worldId}': Act0WorldDisplayCopyV1(\n"
      "  title: ${_quote(pack.titleLocalized)},\n"
      "  subtitle: ${_quote(pack.subtitleLocalized)},\n"
      '),';
}

String _renderLessonStub(Act0TranslationLesson lesson, String languageCode) {
  return "'${lesson.lessonId}': Act0LessonDisplayCopyV1(\n"
      "  title: ${_quote(lesson.titleLocalized)},\n"
      "  subtitle: ${_quote(lesson.subtitleLocalized)},\n"
      '),';
}

String? _renderTaskStub(Act0TranslationTask task, String languageCode) {
  final lines = <String>[];
  void addField(String name, String value) {
    if (value.trim().isEmpty) {
      return;
    }
    lines.add("  $name: ${_quote(value)},");
  }

  addField('title', task.titleLocalized);
  addField('summary', task.summaryLocalized);
  addField('lockedSummary', task.lockedSummaryLocalized);
  addField('runnerPrompt', task.runnerPromptLocalized);
  addField('runnerSupport', task.runnerSupportLocalized);
  addField('runnerQuestion', task.runnerQuestionLocalized);
  if (lines.isEmpty) {
    return null;
  }

  return "'${task.taskId}': Act0TaskDisplayCopyV1(\n"
      '${lines.join('\n')}\n'
      '),';
}

String _quote(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n');
  return "'$escaped'";
}

class _PackIngestOptions {
  const _PackIngestOptions({
    required this.languageCode,
    required this.packPaths,
  });

  final String languageCode;
  final List<String> packPaths;

  static _PackIngestOptions parse(List<String> args) {
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
    return _PackIngestOptions(
      languageCode: _normalizeLanguageCode(languageCode),
      packPaths: packPaths,
    );
  }
}

String _normalizeLanguageCode(String languageCode) =>
    languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;
