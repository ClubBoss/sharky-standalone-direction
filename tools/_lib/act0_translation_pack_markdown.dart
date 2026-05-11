class Act0TranslationPack {
  const Act0TranslationPack({
    required this.languageCode,
    required this.worldId,
    required this.worldNumber,
    required this.titleLocalized,
    required this.subtitleLocalized,
    required this.lessons,
    required this.sourcePath,
  });

  final String languageCode;
  final String worldId;
  final int? worldNumber;
  final String titleLocalized;
  final String subtitleLocalized;
  final List<Act0TranslationLesson> lessons;
  final String sourcePath;
}

class Act0TranslationLesson {
  const Act0TranslationLesson({
    required this.lessonId,
    required this.titleLocalized,
    required this.subtitleLocalized,
    required this.tasks,
  });

  final String lessonId;
  final String titleLocalized;
  final String subtitleLocalized;
  final List<Act0TranslationTask> tasks;
}

class Act0TranslationTask {
  const Act0TranslationTask({
    required this.taskId,
    required this.titleLocalized,
    required this.summaryLocalized,
    required this.lockedSummaryLocalized,
    required this.runnerPromptLocalized,
    required this.runnerSupportLocalized,
    required this.runnerQuestionLocalized,
  });

  final String taskId;
  final String titleLocalized;
  final String summaryLocalized;
  final String lockedSummaryLocalized;
  final String runnerPromptLocalized;
  final String runnerSupportLocalized;
  final String runnerQuestionLocalized;
}

class Act0TranslationPackParser {
  const Act0TranslationPackParser(
    this.source, {
    required this.sourcePath,
    this.languageCode = 'ru',
  });

  final String source;
  final String sourcePath;
  final String languageCode;

  String get _languageFieldSuffix =>
      languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;

  Act0TranslationPack parse() {
    final lines = source.replaceAll('\r\n', '\n').split('\n');
    final worldId = _extractWorldId(lines);
    final worldNumber = _extractWorldNumber(lines);
    final titleLocalized = _findTopLevelValue(
      lines,
      'title_$_languageFieldSuffix',
    );
    final subtitleLocalized = _findTopLevelValue(
      lines,
      'subtitle_$_languageFieldSuffix',
    );
    final lessons = <Act0TranslationLesson>[];

    String? currentLessonId;
    String currentLessonTitleLocalized = '';
    String currentLessonSubtitleLocalized = '';
    final currentTasks = <Act0TranslationTask>[];

    String? currentTaskId;
    final currentTaskFields = <String, String>{};

    void flushTask() {
      if (currentTaskId == null) {
        return;
      }
      currentTasks.add(
        Act0TranslationTask(
          taskId: currentTaskId!,
          titleLocalized:
              currentTaskFields['title_$_languageFieldSuffix'] ?? '',
          summaryLocalized:
              currentTaskFields['summary_$_languageFieldSuffix'] ?? '',
          lockedSummaryLocalized:
              currentTaskFields['lockedSummary_$_languageFieldSuffix'] ?? '',
          runnerPromptLocalized:
              currentTaskFields['runnerPrompt_$_languageFieldSuffix'] ?? '',
          runnerSupportLocalized:
              currentTaskFields['runnerSupport_$_languageFieldSuffix'] ?? '',
          runnerQuestionLocalized:
              currentTaskFields['runnerQuestion_$_languageFieldSuffix'] ?? '',
        ),
      );
      currentTaskId = null;
      currentTaskFields.clear();
    }

    void flushLesson() {
      flushTask();
      if (currentLessonId == null) {
        return;
      }
      lessons.add(
        Act0TranslationLesson(
          lessonId: currentLessonId!,
          titleLocalized: currentLessonTitleLocalized,
          subtitleLocalized: currentLessonSubtitleLocalized,
          tasks: List<Act0TranslationTask>.unmodifiable(currentTasks),
        ),
      );
      currentLessonId = null;
      currentLessonTitleLocalized = '';
      currentLessonSubtitleLocalized = '';
      currentTasks.clear();
    }

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.startsWith('## lesson ')) {
        flushLesson();
        currentLessonId = line.substring('## lesson '.length).trim();
        continue;
      }
      if (currentLessonId == null) {
        continue;
      }
      if (line.startsWith('- taskId: ')) {
        flushTask();
        currentTaskId = line.substring('- taskId: '.length).trim();
        continue;
      }

      if (currentTaskId != null && rawLine.startsWith('  ')) {
        final field = _parseField(line);
        if (field != null) {
          currentTaskFields[field.$1] = field.$2;
        }
        continue;
      }

      final field = _parseField(line);
      if (field == null) {
        continue;
      }
      if (field.$1 == 'title_$_languageFieldSuffix') {
        currentLessonTitleLocalized = field.$2;
      } else if (field.$1 == 'subtitle_$_languageFieldSuffix') {
        currentLessonSubtitleLocalized = field.$2;
      }
    }

    flushLesson();

    return Act0TranslationPack(
      languageCode: _languageFieldSuffix,
      worldId: worldId,
      worldNumber: worldNumber,
      titleLocalized: titleLocalized,
      subtitleLocalized: subtitleLocalized,
      lessons: List<Act0TranslationLesson>.unmodifiable(lessons),
      sourcePath: sourcePath,
    );
  }

  static (String, String)? _parseField(String line) {
    final index = line.indexOf(':');
    if (index <= 0) {
      return null;
    }
    final key = line.substring(0, index).trim();
    final value = line.substring(index + 1).trim();
    return (key, value);
  }

  String _extractWorldId(List<String> lines) {
    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('# ') ||
          !trimmed.endsWith(
            ' ${_languageFieldSuffix.toUpperCase()} Translation Pack',
          )) {
        continue;
      }
      final title = trimmed.substring(
        2,
        trimmed.length -
            ' ${_languageFieldSuffix.toUpperCase()} Translation Pack'.length,
      );
      return title.trim();
    }
    throw FormatException('Missing world heading in $sourcePath');
  }

  int? _extractWorldNumber(List<String> lines) {
    for (final line in lines) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('World number:')) {
        continue;
      }
      return int.tryParse(trimmed.substring('World number:'.length).trim());
    }
    return null;
  }

  String _findTopLevelValue(List<String> lines, String key) {
    for (final rawLine in lines) {
      if (rawLine.startsWith('  ')) {
        continue;
      }
      final trimmed = rawLine.trim();
      if (trimmed.startsWith('$key:')) {
        return trimmed.substring(key.length + 1).trim();
      }
      if (trimmed.startsWith('## lesson ')) {
        break;
      }
    }
    return '';
  }
}
