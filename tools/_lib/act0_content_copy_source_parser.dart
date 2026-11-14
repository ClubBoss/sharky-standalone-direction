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

  Act0TaskPack withTaskId(String value) => Act0TaskPack(
    taskId: value,
    title: title,
    summary: summary,
    lockedSummary: lockedSummary,
    phase: phase,
    stepKind: stepKind,
    runnerName: runnerName,
    caption: caption,
    hint: hint,
    question: question,
    feedbackReason: feedbackReason,
    teachingSteps: teachingSteps,
  );

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
    // Match State's _lessonFromTasksV1 -> _retitledTasksV1. These are
    // canonical route task IDs, not the source lesson's unprefixed IDs.
    final tasks = _mergeHelperTasks(sourceTasks, extraDrills)
        .map((task) => task.withTaskId('${lessonId}_${task.taskId}'))
        .toList(growable: false);

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
      r'^(_\w+)\[(\d+)\]\.taskList$',
    ).firstMatch(extractFieldExpression(lessonBlock, 'sourceTasks') ?? '');
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
    final expression = extractFieldExpression(block, fieldName);
    if (expression == null ||
        !RegExp(r'^(?:const\s+)?(?:<[^>]+>\s*)?\[').hasMatch(expression)) {
      return const <Act0TaskPack>[];
    }
    final openTaskBracket = expression.indexOf('[');
    final closeTaskBracket = findMatchingBracket(expression, openTaskBracket);
    final tasksBlock = expression.substring(
      openTaskBracket + 1,
      closeTaskBracket,
    );
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
      var runnerSpec = runnerName == null ? null : runners[runnerName];
      final rawRunnerExpression = extractFieldExpression(taskBlock, 'runner');
      final runnerExpression = rawRunnerExpression == null
          ? null
          : _compactExpression(rawRunnerExpression);
      if (runnerName != null &&
          runnerExpression != null &&
          runnerExpression.contains('.copyWith(')) {
        final open = runnerExpression.indexOf('(');
        runnerSpec = _copyRunnerSpec(
          runnerExpression.substring(
            open + 1,
            findMatchingParen(runnerExpression, open),
          ),
          runnerSpec,
        );
      }
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
        specs[name] = _copyRunnerSpec(block, specs[baseName]);
      }
    }

    return specs;
  }
}

// Absence inherits; a present expression we cannot resolve remains unknown.
// Use this for both named and inline runner.copyWith expressions.
_RunnerSpec _copyRunnerSpec(String block, _RunnerSpec? base) {
  String? value(String name, String? inherited) =>
      extractFieldExpression(block, name) == null
      ? inherited
      : extractStringField(block, name);
  return _RunnerSpec(
    caption: value('caption', base?.caption),
    hint: value('hint', base?.hint),
    question: value('question', base?.question),
    feedbackReason: value('feedbackReason', base?.feedbackReason),
    teachingSteps: extractFieldExpression(block, 'teachingSteps') == null
        ? base?.teachingSteps
        : _extractTeachingSteps(block),
  );
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
  final expression = extractFieldExpression(block, 'teachingSteps');
  if (expression == null ||
      !RegExp(r'^(?:const\s+)?(?:<[^>]+>\s*)?\[').hasMatch(expression)) {
    return null;
  }
  final openBracket = expression.indexOf('[');
  final closeBracket = findMatchingBracket(expression, openBracket);
  final teachingBlock = expression.substring(openBracket + 1, closeBracket);
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
  final value = extractFieldExpression(block, fieldName);
  if (value == null) return null;
  final parts = <String>[];
  var index = 0;
  while ((index = _skipTrivia(value, index)) < value.length) {
    final raw = value[index] == 'r';
    final quoteIndex = index + (raw ? 1 : 0);
    if (quoteIndex >= value.length ||
        (value[quoteIndex] != "'" && value[quoteIndex] != '"')) {
      return null; // An expression is not a source-owned literal.
    }
    final quote = value[quoteIndex];
    final triple = value.startsWith(quote * 3, quoteIndex);
    final width = triple ? 3 : 1;
    final end = _skipString(value, index);
    final text = value.substring(quoteIndex + width, end - width);
    if (!raw && _hasInterpolation(text)) return null;
    parts.add(raw ? text : _decodeLiteral(text));
    index = end;
  }
  return parts.isEmpty ? null : parts.join();
}

String? extractIdentifierField(String block, String fieldName) {
  final match = RegExp(r'^(_\w+)(?:\.copyWith\([\s\S]*\))?$').firstMatch(
    _compactExpression(extractFieldExpression(block, fieldName) ?? ''),
  );
  return match?.group(1);
}

String? extractEnumField(String block, String fieldName) {
  final match = RegExp(r'^\w+\.(\w+)$').firstMatch(
    _compactExpression(extractFieldExpression(block, fieldName) ?? ''),
  );
  return match?.group(1);
}

int? extractIntField(String block, String fieldName) {
  final match = RegExp(r'^(\d+)$').firstMatch(
    _compactExpression(extractFieldExpression(block, fieldName) ?? ''),
  );
  return match == null ? null : int.tryParse(match.group(1)!);
}

/// Reads a named argument belonging to this block, never a nested object's.
/// This is source inventory, not a Dart evaluator: unsupported values stay null
/// in the typed readers rather than borrowing a nested field or partial value.
String? extractFieldExpression(String block, String fieldName) {
  var index = 0;
  while ((index = _skipTrivia(block, index)) < block.length) {
    final name = RegExp(r'[A-Za-z_$][\w$]*').matchAsPrefix(block, index);
    if (name == null)
      throw FormatException('Expected named source field', block, index);
    index = _skipTrivia(block, name.end);
    if (index >= block.length || block[index] != ':') {
      throw FormatException('Expected source field colon', block, index);
    }
    final start = _skipTrivia(block, index + 1);
    index = start;
    final stack = <String>[];
    while (index < block.length) {
      final afterTrivia = _skipTrivia(block, index);
      if (afterTrivia != index) {
        index = afterTrivia;
        continue;
      }
      final char = block[index];
      // A type-argument comma is not an argument separator, e.g.
      // const <String, int>{...}. Only skip syntactic type-argument forms.
      if (char == '<') {
        final type = RegExp(
          r'<[\w.$?,<>\s]+>\s*(?=[\[({.])',
        ).matchAsPrefix(block, index);
        if (type != null) {
          index = type.end;
          continue;
        }
      }
      if (char == "'" ||
          char == '"' ||
          (char == 'r' &&
              index + 1 < block.length &&
              (block[index + 1] == "'" || block[index + 1] == '"'))) {
        index = _skipString(block, index);
        continue;
      }
      if (char == ',' && stack.isEmpty) break;
      if ('([{'.contains(char)) stack.add(char);
      if (')]}'.contains(char)) {
        final expected = {'(': ')', '[': ']', '{': '}'};
        if (stack.isEmpty || expected[stack.removeLast()] != char) {
          throw FormatException('Unbalanced source field', block, index);
        }
      }
      index += 1;
    }
    if (stack.isNotEmpty)
      throw FormatException('Unclosed source field', block, start);
    if (name.group(0) == fieldName) return block.substring(start, index).trim();
    index += index < block.length ? 1 : 0;
  }
  return null;
}

int _skipTrivia(String source, int index) {
  while (index < source.length) {
    if (RegExp(r'\s').hasMatch(source[index])) {
      index += 1;
    } else if (source.startsWith('//', index)) {
      final end = source.indexOf('\n', index + 2);
      index = end == -1 ? source.length : end + 1;
    } else if (source.startsWith('/*', index)) {
      var depth = 1;
      index += 2;
      while (index < source.length && depth > 0) {
        if (source.startsWith('/*', index)) {
          depth += 1;
          index += 2;
        } else if (source.startsWith('*/', index)) {
          depth -= 1;
          index += 2;
        } else {
          index += 1;
        }
      }
      if (depth != 0) throw FormatException('Unclosed source comment');
    } else {
      break;
    }
  }
  return index;
}

int _skipString(String source, int index) {
  final raw = source[index] == 'r';
  final quoteIndex = index + (raw ? 1 : 0);
  final quote = source[quoteIndex];
  final marker = source.startsWith(quote * 3, quoteIndex) ? quote * 3 : quote;
  index = quoteIndex + marker.length;
  while (index < source.length) {
    if (!raw && source[index] == r'\') {
      index += 2;
      continue;
    }
    if (source.startsWith(marker, index)) return index + marker.length;
    index += 1;
  }
  throw FormatException('Unclosed source string');
}

String _decodeLiteral(String value) => value.replaceAllMapped(
  RegExp(r'''\\(?:u\{[0-9a-fA-F]+\}|u[0-9a-fA-F]{4}|x[0-9a-fA-F]{2}|.)'''),
  (match) {
    final escape = match.group(0)!.substring(1);
    if (escape.startsWith('u{'))
      return String.fromCharCode(
        int.parse(escape.substring(2, escape.length - 1), radix: 16),
      );
    if (escape.startsWith('u') || escape.startsWith('x'))
      return String.fromCharCode(int.parse(escape.substring(1), radix: 16));
    return {
          'n': '\n',
          'r': '\r',
          't': '\t',
          'b': '\b',
          'f': '\f',
          'v': '\v',
        }[escape] ??
        escape;
  },
);

bool _hasInterpolation(String value) {
  for (var index = 0; index < value.length; index += 1) {
    if (value[index] == r'\') {
      index += 1;
      continue;
    }
    if (value[index] == r'$') return true;
  }
  return false;
}

String _compactExpression(String value) {
  final result = StringBuffer();
  var index = 0;
  while ((index = _skipTrivia(value, index)) < value.length) {
    if (value[index] == "'" ||
        value[index] == '"' ||
        (value[index] == 'r' &&
            index + 1 < value.length &&
            (value[index + 1] == "'" || value[index + 1] == '"'))) {
      final end = _skipString(value, index);
      result.write(value.substring(index, end));
      index = end;
    } else {
      result.write(value[index]);
      index += 1;
    }
  }
  return result.toString();
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
  for (var index = openIndex; index < input.length; index += 1) {
    final afterTrivia = _skipTrivia(input, index);
    if (afterTrivia != index) {
      index = afterTrivia - 1;
      continue;
    }
    final char = input[index];
    if (char == "'" ||
        char == '"' ||
        (char == 'r' &&
            index + 1 < input.length &&
            (input[index + 1] == "'" || input[index + 1] == '"'))) {
      index = _skipString(input, index) - 1;
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
