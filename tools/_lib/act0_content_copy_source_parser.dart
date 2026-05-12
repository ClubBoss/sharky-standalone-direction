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
    required this.teachingSteps,
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
  final List<Act0TeachingStepPack> teachingSteps;

  bool get hasRunnerCopy =>
      (caption?.trim().isNotEmpty ?? false) ||
      (hint?.trim().isNotEmpty ?? false) ||
      (question?.trim().isNotEmpty ?? false);
}

class Act0TeachingStepPack {
  const Act0TeachingStepPack({required this.title, required this.body});

  final String title;
  final String body;
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
      var searchStart = 0;
      while (true) {
        final directIndex = block.indexOf('Act0LessonCardV1(', searchStart);
        final helperIndex = block.indexOf('_lessonFromTasksV1(', searchStart);
        final hasDirect = directIndex != -1;
        final hasHelper = helperIndex != -1;
        if (!hasDirect && !hasHelper) {
          break;
        }

        final isDirect = hasDirect && (!hasHelper || directIndex < helperIndex);
        final markerIndex = isDirect ? directIndex : helperIndex;
        final openParen = block.indexOf('(', markerIndex);
        final closeParen = findMatchingParen(block, openParen);
        final lessonBlock = block.substring(openParen + 1, closeParen);

        final lesson = isDirect
            ? _parseDirectLessonBlock(lessonBlock, runners)
            : _parseHelperLessonBlock(lessonBlock, runners, result);
        if (lesson != null) {
          lessons.add(lesson);
        }
        searchStart = closeParen + 1;
      }

      result[listName] = lessons;
    }

    return result;
  }

  Act0LessonPack? _parseDirectLessonBlock(
    String lessonBlock,
    Map<String, _RunnerSpec> runners,
  ) {
    final lessonId = extractStringField(lessonBlock, 'lessonId');
    final title = extractStringField(lessonBlock, 'title');
    final subtitle = extractStringField(lessonBlock, 'subtitle');
    if (lessonId == null || title == null || subtitle == null) {
      return null;
    }

    return Act0LessonPack(
      lessonId: lessonId,
      title: title,
      subtitle: subtitle,
      tasks: _extractTasksField(lessonBlock, 'tasks', runners),
    );
  }

  Act0LessonPack? _parseHelperLessonBlock(
    String lessonBlock,
    Map<String, _RunnerSpec> runners,
    Map<String, List<Act0LessonPack>> lessonLists,
  ) {
    final lessonId = extractStringField(lessonBlock, 'lessonId');
    final title = extractStringField(lessonBlock, 'title');
    final subtitle = extractStringField(lessonBlock, 'subtitle');
    if (lessonId == null || title == null || subtitle == null) {
      return null;
    }

    final sourceTasks = _extractSourceTasks(lessonBlock, runners, lessonLists);
    final extraDrills = _extractTasksField(lessonBlock, 'extraDrills', runners);
    final tasks = _mergeHelperTasks(sourceTasks, extraDrills);

    return Act0LessonPack(
      lessonId: lessonId,
      title: title,
      subtitle: subtitle,
      tasks: tasks,
    );
  }

  List<Act0TaskPack> _extractSourceTasks(
    String lessonBlock,
    Map<String, _RunnerSpec> runners,
    Map<String, List<Act0LessonPack>> lessonLists,
  ) {
    final inlineTasks = _extractTasksField(lessonBlock, 'sourceTasks', runners);
    if (inlineTasks.isNotEmpty) {
      return inlineTasks;
    }

    final refMatch = RegExp(
      r'sourceTasks:\s*(_\w+)\[(\d+)\]\.taskList',
    ).firstMatch(lessonBlock);
    if (refMatch == null) {
      return const <Act0TaskPack>[];
    }
    final listName = refMatch.group(1)!;
    final lessonIndex = int.tryParse(refMatch.group(2)!);
    final sourceLessons = lessonLists[listName];
    if (lessonIndex == null ||
        sourceLessons == null ||
        lessonIndex < 0 ||
        lessonIndex >= sourceLessons.length) {
      return const <Act0TaskPack>[];
    }
    return List<Act0TaskPack>.unmodifiable(sourceLessons[lessonIndex].tasks);
  }

  List<Act0TaskPack> _mergeHelperTasks(
    List<Act0TaskPack> sourceTasks,
    List<Act0TaskPack> extraDrills,
  ) {
    if (extraDrills.isEmpty) {
      return sourceTasks;
    }
    final recapStartIndex = sourceTasks.lastIndexWhere(
      (task) => task.phase == 'review',
    );
    final insertIndex = recapStartIndex == -1
        ? sourceTasks.length
        : recapStartIndex;
    return List<Act0TaskPack>.unmodifiable(<Act0TaskPack>[
      ...sourceTasks.take(insertIndex),
      ...extraDrills,
      ...sourceTasks.skip(insertIndex),
    ]);
  }

  List<Act0TaskPack> _extractTasksField(
    String block,
    String fieldName,
    Map<String, _RunnerSpec> runners,
  ) {
    final tasksStart = block.indexOf('$fieldName:');
    if (tasksStart == -1) {
      return const <Act0TaskPack>[];
    }
    final openTaskBracket = block.indexOf('[', tasksStart);
    if (openTaskBracket == -1) {
      return const <Act0TaskPack>[];
    }
    final closeTaskBracket = findMatchingBracket(block, openTaskBracket);
    final tasksBlock = block.substring(openTaskBracket + 1, closeTaskBracket);
    return _parseTaskBlocks(tasksBlock, runners);
  }

  List<Act0TaskPack> _parseTaskBlocks(
    String tasksBlock,
    Map<String, _RunnerSpec> runners,
  ) {
    final tasks = <Act0TaskPack>[];
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
          teachingSteps:
              runnerSpec?.teachingSteps ?? const <Act0TeachingStepPack>[],
        ),
      );
    }
    return List<Act0TaskPack>.unmodifiable(tasks);
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
          teachingSteps: _extractTeachingSteps(block),
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
          teachingSteps: _extractTeachingSteps(block) ?? base?.teachingSteps,
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
    required this.teachingSteps,
  });

  final String? caption;
  final String? hint;
  final String? question;
  final String? feedbackReason;
  final List<Act0TeachingStepPack>? teachingSteps;
}

List<Act0TeachingStepPack>? _extractTeachingSteps(String block) {
  final marker = 'teachingSteps:';
  final start = block.indexOf(marker);
  if (start == -1) {
    return null;
  }
  final openBracket = block.indexOf('[', start);
  if (openBracket == -1) {
    return null;
  }
  final closeBracket = findMatchingBracket(block, openBracket);
  final teachingBlock = block.substring(openBracket + 1, closeBracket);
  final steps = <Act0TeachingStepPack>[];
  for (final stepBlock in extractChildBlocks(
    teachingBlock,
    'Act0TeachingStepV1(',
  )) {
    final title = extractStringField(stepBlock, 'title');
    final body = extractStringField(stepBlock, 'body');
    if (title == null || body == null) {
      continue;
    }
    steps.add(Act0TeachingStepPack(title: title, body: body));
  }
  return List<Act0TeachingStepPack>.unmodifiable(steps);
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
