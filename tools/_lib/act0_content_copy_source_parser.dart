class Act0ContentBundle {
  const Act0ContentBundle({required this.worlds});

  final List<Act0WorldPack> worlds;
}

class Act0WorldPack {
  const Act0WorldPack({
    required this.worldId,
    required this.worldNumber,
    required this.title,
    required this.subtitle,
    required this.lessons,
  });

  final String worldId;
  final int worldNumber;
  final String title;
  final String subtitle;
  final List<Act0LessonPack> lessons;
}

class Act0LessonPack {
  const Act0LessonPack({
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.tasks,
  });

  final String lessonId;
  final String title;
  final String subtitle;
  final List<Act0TaskPack> tasks;
}

class Act0TaskPack {
  const Act0TaskPack({
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

  bool get hasRunnerCopy =>
      (caption?.trim().isNotEmpty ?? false) ||
      (hint?.trim().isNotEmpty ?? false) ||
      (question?.trim().isNotEmpty ?? false);
}

class Act0SourceParser {
  const Act0SourceParser(this.source);

  final String source;

  Act0ContentBundle parse() {
    final runners = _parseRunnerSpecs();
    final lessonLists = _parseLessonLists(runners);
    final worlds = _parseWorlds(lessonLists);
    return Act0ContentBundle(worlds: worlds);
  }

  List<Act0WorldPack> _parseWorlds(
    Map<String, List<Act0LessonPack>> lessonLists,
  ) {
    const pattern = 'final _act0PreviewWorlds = <Act0WorldCardV1>[';
    final start = source.indexOf(pattern);
    if (start == -1) {
      return const <Act0WorldPack>[];
    }
    final openBracket = source.indexOf('[', start);
    final closeBracket = findMatchingBracket(source, openBracket);
    final block = source.substring(openBracket + 1, closeBracket);
    final worlds = <Act0WorldPack>[];

    for (final worldBlock in extractChildBlocks(block, 'Act0WorldCardV1(')) {
      final worldId = extractStringField(worldBlock, 'worldId');
      final worldNumber = extractIntField(worldBlock, 'worldNumber');
      final title = extractStringField(worldBlock, 'title');
      final subtitle = extractStringField(worldBlock, 'subtitle');
      final lessonsVar = extractIdentifierField(worldBlock, 'lessons');
      if (worldId == null ||
          worldNumber == null ||
          title == null ||
          subtitle == null) {
        continue;
      }

      worlds.add(
        Act0WorldPack(
          worldId: worldId,
          worldNumber: worldNumber,
          title: title,
          subtitle: subtitle,
          lessons: lessonLists[lessonsVar] ?? const <Act0LessonPack>[],
        ),
      );
    }

    return worlds;
  }

  Map<String, List<Act0LessonPack>> _parseLessonLists(
    Map<String, _RunnerSpec> runners,
  ) {
    final result = <String, List<Act0LessonPack>>{};
    final listPattern = RegExp(r'final\s+(_\w+)\s*=\s*<Act0LessonCardV1>\[');
    for (final match in listPattern.allMatches(source)) {
      final listName = match.group(1)!;
      final openBracket = source.indexOf('[', match.start);
      final closeBracket = findMatchingBracket(source, openBracket);
      final block = source.substring(openBracket + 1, closeBracket);
      final lessons = <Act0LessonPack>[];

      for (final lessonBlock in extractChildBlocks(
        block,
        'Act0LessonCardV1(',
      )) {
        final lessonId = extractStringField(lessonBlock, 'lessonId');
        final title = extractStringField(lessonBlock, 'title');
        final subtitle = extractStringField(lessonBlock, 'subtitle');
        if (lessonId == null || title == null || subtitle == null) {
          continue;
        }

        final tasks = <Act0TaskPack>[];
        final tasksStart = lessonBlock.indexOf('tasks: <Act0LessonTaskV1>[');
        if (tasksStart != -1) {
          final openTaskBracket = lessonBlock.indexOf('[', tasksStart);
          final closeTaskBracket = findMatchingBracket(
            lessonBlock,
            openTaskBracket,
          );
          final tasksBlock = lessonBlock.substring(
            openTaskBracket + 1,
            closeTaskBracket,
          );
          for (final taskBlock in extractChildBlocks(
            tasksBlock,
            'Act0LessonTaskV1(',
          )) {
            final taskId = extractStringField(taskBlock, 'taskId');
            final taskTitle = extractStringField(taskBlock, 'title');
            if (taskId == null || taskTitle == null) {
              continue;
            }

            final runnerName = extractIdentifierField(taskBlock, 'runner');
            final runnerSpec = runnerName == null ? null : runners[runnerName];
            tasks.add(
              Act0TaskPack(
                taskId: taskId,
                title: taskTitle,
                summary: extractStringField(taskBlock, 'summary'),
                lockedSummary: extractStringField(taskBlock, 'lockedSummary'),
                phase: extractEnumField(taskBlock, 'phase') ?? 'unknown',
                stepKind: extractEnumField(taskBlock, 'stepKind') ?? 'unknown',
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
          Act0LessonPack(
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
        final closeParen = findMatchingParen(source, openParen);
        final block = source.substring(openParen + 1, closeParen);
        specs[name] = _RunnerSpec(
          caption: extractStringField(block, 'caption'),
          hint: extractStringField(block, 'hint'),
          question: extractStringField(block, 'question'),
          feedbackReason: extractStringField(block, 'feedbackReason'),
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
        final closeParen = findMatchingParen(source, openParen);
        final block = source.substring(openParen + 1, closeParen);
        final base = specs[baseName];
        specs[name] = _RunnerSpec(
          caption: extractStringField(block, 'caption') ?? base?.caption,
          hint: extractStringField(block, 'hint') ?? base?.hint,
          question: extractStringField(block, 'question') ?? base?.question,
          feedbackReason:
              extractStringField(block, 'feedbackReason') ??
              base?.feedbackReason,
        );
      }
    }

    return specs;
  }
}

class _RunnerSpec {
  const _RunnerSpec({
    required this.caption,
    required this.hint,
    required this.question,
    required this.feedbackReason,
  });

  final String? caption;
  final String? hint;
  final String? question;
  final String? feedbackReason;
}

List<String> extractChildBlocks(String block, String marker) {
  final result = <String>[];
  var searchStart = 0;
  while (true) {
    final markerIndex = block.indexOf(marker, searchStart);
    if (markerIndex == -1) {
      break;
    }
    final openParen = block.indexOf('(', markerIndex);
    final closeParen = findMatchingParen(block, openParen);
    result.add(block.substring(openParen + 1, closeParen));
    searchStart = closeParen + 1;
  }
  return result;
}

String? extractStringField(String block, String fieldName) {
  final match = RegExp(
    "$fieldName:\\s*'((?:\\\\'|[^'])*)'",
    dotAll: true,
  ).firstMatch(block);
  if (match == null) {
    return null;
  }
  return match.group(1)!.replaceAll("\\'", "'");
}

String? extractIdentifierField(String block, String fieldName) {
  final match = RegExp('$fieldName:\\s*(_\\w+)').firstMatch(block);
  return match?.group(1);
}

String? extractEnumField(String block, String fieldName) {
  final match = RegExp('$fieldName:\\s*\\w+\\.(\\w+)').firstMatch(block);
  return match?.group(1);
}

int? extractIntField(String block, String fieldName) {
  final match = RegExp('$fieldName:\\s*(\\d+)').firstMatch(block);
  return match == null ? null : int.tryParse(match.group(1)!);
}

int findMatchingParen(String input, int openIndex) {
  return findMatchingDelimiter(input, openIndex, '(', ')');
}

int findMatchingBracket(String input, int openIndex) {
  return findMatchingDelimiter(input, openIndex, '[', ']');
}

int findMatchingDelimiter(
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
