import 'dart:io';

import '_lib/act0_content_copy_source_parser.dart';

void main(List<String> args) {
  final options = _CommandOptions.parse(args);
  final sourceFile = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
  if (!sourceFile.existsSync()) {
    stderr.writeln('Missing source file: ${sourceFile.path}');
    exitCode = 2;
    return;
  }

  final source = sourceFile.readAsStringSync();
  final bundle = Act0SourceParser(source).parse();
  final selectedWorlds = _selectWorlds(bundle, options);

  if (selectedWorlds.isEmpty) {
    stderr.writeln('No matching worlds for the requested filters.');
    exitCode = 3;
    return;
  }

  if (options.emitDartStubs) {
    stdout.write(_renderDartStubs(selectedWorlds));
    return;
  }

  stdout.write(_renderMarkdownPack(selectedWorlds));
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

List<Act0WorldPack> _selectWorlds(
  Act0ContentBundle bundle,
  _CommandOptions options,
) {
  final selected = <Act0WorldPack>[];
  for (final world in bundle.worlds) {
    if (options.worldId != null && world.worldId != options.worldId) {
      continue;
    }

    final lessons = <Act0LessonPack>[];
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
        Act0LessonPack(
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
      Act0WorldPack(
        worldId: world.worldId,
        worldNumber: world.worldNumber,
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

String _renderMarkdownPack(List<Act0WorldPack> worlds) {
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

String _renderDartStubs(List<Act0WorldPack> worlds) {
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
        if (task.caption?.isNotEmpty ?? false) {
          buffer.writeln("  runnerPrompt: '',");
        }
        if (task.hint?.isNotEmpty ?? false) {
          buffer.writeln("  runnerSupport: '',");
        }
        if (task.question?.isNotEmpty ?? false) {
          buffer.writeln("  runnerQuestion: '',");
        }
        buffer.writeln('),');
      }
    }
    buffer.writeln();
  }

  return buffer.toString();
}
