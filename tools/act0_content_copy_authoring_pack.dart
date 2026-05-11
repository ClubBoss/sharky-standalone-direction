import 'dart:io';

void main(List<String> args) {
  final options = _CommandOptions.parse(args);
  final sourceFile = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source file: ${sourceFile.path}');
    exitCode = 2;
    return;
  }

  final source = sourceFile.readAsStringSync();
  final parser = _Act0SourceParser(source);
  final bundle = parser.parse();
  final selectedWorlds = _selectWorlds(bundle, options);

  if (selectedWorlds.isEmpty) {
    stderr.writeln('No matching worlds for the requested filters.');
    exitCode = 3;
    return;
  }

  if (options.emitDartStubs) {
    stdout.write(_renderDartStubs(selectedWorlds, options));
    return;
  }

  stdout.write(_renderMarkdownPack(selectedWorlds, options));
}

class _CommandOptions {
  const _CommandOptions({
    this.worldId,
    this.lessonId,
    this.lessonPrefix,
    this.taskPrefix,
    this.maxLessons,
    required this.emitDartStubs,
  });

  final String? worldId;
  final String? lessonId;
  final String? lessonPrefix;
  final String? taskPrefix;
  final int? maxLessons;
  final bool emitDartStubs;

  static _CommandOptions parse(List<String> args) {
    String? worldId;
    String? lessonId;
    String? lessonPrefix;
    String? taskPrefix;
    int? maxLessons;
    var emitDartStubs = false;

    for (var index = 0; index < args.length; index += 1) {
      final arg = args[index];
      switch (arg) {
        case '--world':
          worldId = _readValue(args, ++index, arg);
          break;
        case '--lesson':
          lessonId = _readValue(args, ++index, arg);
          break;
        case '--lesson-prefix':
          lessonPrefix = _readValue(args, ++index, arg);
          break;
        case '--task-prefix':
          taskPrefix = _readValue(args, ++index, arg);
          break;
        case '--max-lessons':
          final raw = _readValue(args, ++index, arg);
          maxLessons = int.tryParse(raw);
          if (maxLessons == null || maxLessons <= 0) {
            stderr.writeln('Invalid value for --max-lessons: $raw');
            exit(64);
          }
          break;
        case '--emit-dart-stubs':
          emitDartStubs = true;
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
        default:
          stderr.writeln('Unrecognized option: $arg');
          _printUsage();
          exit(64);
      }
    }

    return _CommandOptions(
      worldId: worldId,
      lessonId: lessonId,
      lessonPrefix: lessonPrefix,
      taskPrefix: taskPrefix,
      maxLessons: maxLessons,
      emitDartStubs: emitDartStubs,
    );
  }

  static String _readValue(List<String> args, int index, String flag) {
    if (index >= args.length) {
      stderr.writeln('Missing value for $flag');
      exit(64);
    }
    return args[index];
  }
}

void _printUsage() {
  stdout.writeln('Usage: dart run tools/act0_content_copy_authoring_pack.dart');
  stdout.writeln('  [--world <worldId>]');
  stdout.writeln('  [--lesson <lessonId>]');
  stdout.writeln('  [--lesson-prefix <prefix>]');
  stdout.writeln('  [--task-prefix <prefix>]');
  stdout.writeln('  [--max-lessons <count>]');
  stdout.writeln('  [--emit-dart-stubs]');
}

List<_WorldPack> _selectWorlds(
  _Act0ContentBundle bundle,
  _CommandOptions options,
) {
  final selected = <_WorldPack>[];
  for (final world in bundle.worlds) {
    if (options.worldId != null && world.worldId != options.worldId) {
      continue;
    }

    final lessons = <_LessonPack>[];
    for (final lesson in world.lessons) {
      if (options.lessonId != null && lesson.lessonId != options.lessonId) {
        continue;
      }
      if (options.lessonPrefix != null &&
          !lesson.lessonId.startsWith(options.lessonPrefix!)) {
        continue;
      }

      final tasks = lesson.tasks
          .where((task) {
            if (options.taskPrefix == null) {
              return true;
            }
            return task.taskId.startsWith(options.taskPrefix!);
          })
          .toList(growable: false);

      if (tasks.isEmpty) {
        continue;
      }

      lessons.add(
        _LessonPack(
          lessonId: lesson.lessonId,
          title: lesson.title,
          subtitle: lesson.subtitle,
          tasks: tasks,
        ),
      );
    }

    if (lessons.isEmpty) {
      continue;
    }

    final maxLessons = options.maxLessons;
    selected.add(
      _WorldPack(
        worldId: world.worldId,
        title: world.title,
        subtitle: world.subtitle,
        lessons: maxLessons == null
            ? lessons
            : lessons.take(maxLessons).toList(growable: false),
      ),
    );
  }
  return selected;
}

String _renderMarkdownPack(List<_WorldPack> worlds, _CommandOptions options) {
  final buffer = StringBuffer()
    ..writeln('# Act0 RU Authoring Pack')
    ..writeln()
    ..writeln('Source: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`')
    ..writeln('Canon: `docs/l10n/RU_POKER_TERMS_CANON_v1.md`')
    ..writeln()
    ..writeln('## RU Brief')
    ..writeln('- Rewrite naturally. Do not mirror English sentence shape.')
    ..writeln('- Keep one poker idea per line.')
    ..writeln(
      '- Use normal poker borrowings where they sound native: префлоп, рейз, колл, фолд, блайнды, кикер.',
    )
    ..writeln('- Keep product wording calm, compact, and learner-facing.')
    ..writeln('- Prefer stable ids over visible English when authoring copy.')
    ..writeln();

  if (options.emitDartStubs) {
    buffer.writeln('## Dart Stubs');
    buffer.writeln();
  }

  for (final world in worlds) {
    buffer.writeln('## ${world.worldId}');
    buffer.writeln('EN title: ${world.title}');
    buffer.writeln('EN subtitle: ${world.subtitle}');
    buffer.writeln();

    for (final lesson in world.lessons) {
      buffer.writeln('### lesson ${lesson.lessonId}');
      buffer.writeln('EN title: ${lesson.title}');
      buffer.writeln('EN subtitle: ${lesson.subtitle}');
      buffer.writeln();

      for (final task in lesson.tasks) {
        buffer.writeln('- taskId: ${task.taskId}');
        buffer.writeln('  title: ${task.title}');
        if (task.summary?.isNotEmpty ?? false) {
          buffer.writeln('  summary: ${task.summary}');
        }
        if (task.lockedSummary?.isNotEmpty ?? false) {
          buffer.writeln('  lockedSummary: ${task.lockedSummary}');
        }
        buffer.writeln('  phase: ${task.phase}');
        buffer.writeln('  stepKind: ${task.stepKind}');
        if (task.runnerName != null) {
          buffer.writeln('  runner: ${task.runnerName}');
        }
        if (task.caption?.isNotEmpty ?? false) {
          buffer.writeln('  caption: ${task.caption}');
        }
        if (task.hint?.isNotEmpty ?? false) {
          buffer.writeln('  hint: ${task.hint}');
        }
        if (task.question?.isNotEmpty ?? false) {
          buffer.writeln('  question: ${task.question}');
        }
        if (task.feedbackReason?.isNotEmpty ?? false) {
          buffer.writeln('  feedbackReason: ${task.feedbackReason}');
        }
        buffer.writeln();
      }
    }
  }

  return buffer.toString();
}

String _renderDartStubs(List<_WorldPack> worlds, _CommandOptions options) {
  final buffer = StringBuffer()
    ..writeln('// Generated from act0_shell_state_v1.dart stable ids.')
    ..writeln('// Fill RU copy in act0_content_copy_v1.dart.')
    ..writeln();

  for (final world in worlds) {
    buffer.writeln('// ${world.worldId}');
    for (final lesson in world.lessons) {
      buffer.writeln("'${lesson.lessonId}': Act0LessonDisplayCopyV1(");
      buffer.writeln("  title: '',");
      buffer.writeln("  subtitle: '',");
      buffer.writeln('),');
    }
    buffer.writeln();

    for (final lesson in world.lessons) {
      for (final task in lesson.tasks) {
        buffer.writeln("'${task.taskId}': Act0TaskDisplayCopyV1(");
        buffer.writeln("  title: '',");
        buffer.writeln("  summary: '',");
        if (task.lockedSummary?.isNotEmpty ?? false) {
          buffer.writeln("  lockedSummary: '',");
        }
        if (task.question?.isNotEmpty ?? false) {
          buffer.writeln("  runnerPrompt: '',");
          buffer.writeln("  runnerSupport: '',");
        }
        buffer.writeln('),');
      }
    }
    buffer.writeln();
  }

  return buffer.toString();
}

class _Act0SourceParser {
  const _Act0SourceParser(this.source);

  final String source;

  _Act0ContentBundle parse() {
    final runners = _parseRunnerSpecs();
    final lessonLists = _parseLessonLists(runners);
    final worlds = _parseWorlds(lessonLists);
    return _Act0ContentBundle(worlds: worlds);
  }

  List<_WorldPack> _parseWorlds(Map<String, List<_LessonPack>> lessonLists) {
    const pattern = 'final _act0PreviewWorlds = <Act0WorldCardV1>[';
    final start = source.indexOf(pattern);
    if (start == -1) {
      return const <_WorldPack>[];
    }
    final openBracket = source.indexOf('[', start);
    final closeBracket = _findMatchingBracket(source, openBracket);
    final block = source.substring(openBracket + 1, closeBracket);
    final worlds = <_WorldPack>[];

    for (final worldBlock in _extractChildBlocks(block, 'Act0WorldCardV1(')) {
      final worldId = _extractStringField(worldBlock, 'worldId');
      final title = _extractStringField(worldBlock, 'title');
      final subtitle = _extractStringField(worldBlock, 'subtitle');
      final lessonsVar = _extractIdentifierField(worldBlock, 'lessons');
      if (worldId == null || title == null || subtitle == null) {
        continue;
      }

      worlds.add(
        _WorldPack(
          worldId: worldId,
          title: title,
          subtitle: subtitle,
          lessons: lessonLists[lessonsVar] ?? const <_LessonPack>[],
        ),
      );
    }

    return worlds;
  }

  Map<String, List<_LessonPack>> _parseLessonLists(
    Map<String, _RunnerSpec> runners,
  ) {
    final result = <String, List<_LessonPack>>{};
    final listPattern = RegExp(r'final\s+(_\w+)\s*=\s*<Act0LessonCardV1>\[');
    for (final match in listPattern.allMatches(source)) {
      final listName = match.group(1)!;
      final openBracket = source.indexOf('[', match.start);
      final closeBracket = _findMatchingBracket(source, openBracket);
      final block = source.substring(openBracket + 1, closeBracket);
      final lessons = <_LessonPack>[];

      for (final lessonBlock in _extractChildBlocks(
        block,
        'Act0LessonCardV1(',
      )) {
        final lessonId = _extractStringField(lessonBlock, 'lessonId');
        final title = _extractStringField(lessonBlock, 'title');
        final subtitle = _extractStringField(lessonBlock, 'subtitle');
        if (lessonId == null || title == null || subtitle == null) {
          continue;
        }

        final tasks = <_TaskPack>[];
        final tasksStart = lessonBlock.indexOf('tasks: <Act0LessonTaskV1>[');
        if (tasksStart != -1) {
          final openTaskBracket = lessonBlock.indexOf('[', tasksStart);
          final closeTaskBracket = _findMatchingBracket(
            lessonBlock,
            openTaskBracket,
          );
          final tasksBlock = lessonBlock.substring(
            openTaskBracket + 1,
            closeTaskBracket,
          );
          for (final taskBlock in _extractChildBlocks(
            tasksBlock,
            'Act0LessonTaskV1(',
          )) {
            final taskId = _extractStringField(taskBlock, 'taskId');
            final taskTitle = _extractStringField(taskBlock, 'title');
            if (taskId == null || taskTitle == null) {
              continue;
            }

            final runnerName = _extractIdentifierField(taskBlock, 'runner');
            final runnerSpec = runnerName == null ? null : runners[runnerName];
            tasks.add(
              _TaskPack(
                taskId: taskId,
                title: taskTitle,
                summary: _extractStringField(taskBlock, 'summary'),
                lockedSummary: _extractStringField(taskBlock, 'lockedSummary'),
                phase: _extractEnumField(taskBlock, 'phase') ?? 'unknown',
                stepKind: _extractEnumField(taskBlock, 'stepKind') ?? 'unknown',
                runnerName: runnerName,
                caption: runnerSpec?.caption,
                hint: runnerSpec?.hint,
                question: runnerSpec?.question,
                feedbackReason: runnerSpec?.feedbackReason,
              ),
            );
          }
        }

        lessons.add(
          _LessonPack(
            lessonId: lessonId,
            title: title,
            subtitle: subtitle,
            tasks: tasks,
          ),
        );
      }

      result[listName] = lessons;
    }

    return result;
  }

  Map<String, _RunnerSpec> _parseRunnerSpecs() {
    final specs = <String, _RunnerSpec>{};
    final pattern = RegExp(r'(?:const|final)\s+(_\w+)\s*=\s*');

    for (final match in pattern.allMatches(source)) {
      final name = match.group(1)!;
      final assignmentStart = match.end;
      if (source.startsWith('Act0RunnerStateV1(', assignmentStart)) {
        final openParen = source.indexOf('(', assignmentStart);
        final closeParen = _findMatchingParen(source, openParen);
        final block = source.substring(openParen + 1, closeParen);
        specs[name] = _RunnerSpec(
          name: name,
          caption: _extractStringField(block, 'caption'),
          hint: _extractStringField(block, 'hint'),
          question: _extractStringField(block, 'question'),
          lessonId: _extractStringField(block, 'lessonId'),
          lessonTitle: _extractStringField(block, 'lessonTitle'),
          lessonSubtitle: _extractStringField(block, 'lessonSubtitle'),
          feedbackReason: _extractStringField(block, 'feedbackReason'),
        );
      } else {
        final copyWithMatch = RegExp(
          r'(_\w+)\.copyWith\(',
        ).matchAsPrefix(source, assignmentStart);
        if (copyWithMatch == null) {
          continue;
        }
        final baseName = copyWithMatch.group(1)!;
        final openParen = source.indexOf('(', assignmentStart);
        final closeParen = _findMatchingParen(source, openParen);
        final block = source.substring(openParen + 1, closeParen);
        final base = specs[baseName];
        specs[name] = _RunnerSpec(
          name: name,
          caption: _extractStringField(block, 'caption') ?? base?.caption,
          hint: _extractStringField(block, 'hint') ?? base?.hint,
          question: _extractStringField(block, 'question') ?? base?.question,
          lessonId: _extractStringField(block, 'lessonId') ?? base?.lessonId,
          lessonTitle:
              _extractStringField(block, 'lessonTitle') ?? base?.lessonTitle,
          lessonSubtitle:
              _extractStringField(block, 'lessonSubtitle') ??
              base?.lessonSubtitle,
          feedbackReason:
              _extractStringField(block, 'feedbackReason') ??
              base?.feedbackReason,
        );
      }
    }

    return specs;
  }
}

class _Act0ContentBundle {
  const _Act0ContentBundle({required this.worlds});

  final List<_WorldPack> worlds;
}

class _WorldPack {
  const _WorldPack({
    required this.worldId,
    required this.title,
    required this.subtitle,
    required this.lessons,
  });

  final String worldId;
  final String title;
  final String subtitle;
  final List<_LessonPack> lessons;
}

class _LessonPack {
  const _LessonPack({
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.tasks,
  });

  final String lessonId;
  final String title;
  final String subtitle;
  final List<_TaskPack> tasks;
}

class _TaskPack {
  const _TaskPack({
    required this.taskId,
    required this.title,
    required this.summary,
    required this.lockedSummary,
    required this.phase,
    required this.stepKind,
    required this.runnerName,
    required this.caption,
    required this.hint,
    required this.question,
    required this.feedbackReason,
  });

  final String taskId;
  final String title;
  final String? summary;
  final String? lockedSummary;
  final String phase;
  final String stepKind;
  final String? runnerName;
  final String? caption;
  final String? hint;
  final String? question;
  final String? feedbackReason;
}

class _RunnerSpec {
  const _RunnerSpec({
    required this.name,
    required this.caption,
    required this.hint,
    required this.question,
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonSubtitle,
    required this.feedbackReason,
  });

  final String name;
  final String? caption;
  final String? hint;
  final String? question;
  final String? lessonId;
  final String? lessonTitle;
  final String? lessonSubtitle;
  final String? feedbackReason;
}

List<String> _extractChildBlocks(String block, String marker) {
  final result = <String>[];
  var searchStart = 0;
  while (true) {
    final markerIndex = block.indexOf(marker, searchStart);
    if (markerIndex == -1) {
      break;
    }
    final openParen = block.indexOf('(', markerIndex);
    final closeParen = _findMatchingParen(block, openParen);
    result.add(block.substring(openParen + 1, closeParen));
    searchStart = closeParen + 1;
  }
  return result;
}

String? _extractStringField(String block, String fieldName) {
  final match = RegExp(
    "$fieldName:\\s*'((?:\\\\'|[^'])*)'",
    dotAll: true,
  ).firstMatch(block);
  if (match == null) {
    return null;
  }
  return match.group(1)!.replaceAll("\\'", "'");
}

String? _extractIdentifierField(String block, String fieldName) {
  final match = RegExp('$fieldName:\\s*(_\\w+)').firstMatch(block);
  return match?.group(1);
}

String? _extractEnumField(String block, String fieldName) {
  final match = RegExp('$fieldName:\\s*\\w+\\.(\\w+)').firstMatch(block);
  return match?.group(1);
}

int _findMatchingParen(String input, int openIndex) {
  return _findMatchingDelimiter(input, openIndex, '(', ')');
}

int _findMatchingBracket(String input, int openIndex) {
  return _findMatchingDelimiter(input, openIndex, '[', ']');
}

int _findMatchingDelimiter(
  String input,
  int openIndex,
  String open,
  String close,
) {
  var depth = 0;
  var inString = false;
  var escapeNext = false;

  for (var index = openIndex; index < input.length; index += 1) {
    final char = input[index];

    if (inString) {
      if (escapeNext) {
        escapeNext = false;
        continue;
      }
      if (char == r'\') {
        escapeNext = true;
        continue;
      }
      if (char == "'") {
        inString = false;
      }
      continue;
    }

    if (char == "'") {
      inString = true;
      continue;
    }
    if (char == open) {
      depth += 1;
      continue;
    }
    if (char == close) {
      depth -= 1;
      if (depth == 0) {
        return index;
      }
    }
  }

  throw StateError('Unmatched delimiter $open at index $openIndex');
}
