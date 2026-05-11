import 'act0_content_copy_source_parser.dart';

class Act0CopyRegistryBundle {
  const Act0CopyRegistryBundle({
    required this.languageCode,
    required this.worlds,
    required this.lessons,
    required this.tasks,
    required this.surfaceAtoms,
  });

  final String languageCode;
  final Map<String, Act0WorldCopyRecord> worlds;
  final Map<String, Act0LessonCopyRecord> lessons;
  final Map<String, Act0TaskCopyRecord> tasks;
  final Map<String, Act0SurfaceAtomCopyRecord> surfaceAtoms;
}

class Act0WorldCopyRecord {
  const Act0WorldCopyRecord({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class Act0LessonCopyRecord {
  const Act0LessonCopyRecord({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class Act0TaskCopyRecord {
  const Act0TaskCopyRecord({
    this.title,
    this.summary,
    this.lockedSummary,
    this.runnerPrompt,
    this.runnerSupport,
    this.runnerQuestion,
  });

  final String? title;
  final String? summary;
  final String? lockedSummary;
  final String? runnerPrompt;
  final String? runnerSupport;
  final String? runnerQuestion;
}

class Act0SurfaceAtomCopyRecord {
  const Act0SurfaceAtomCopyRecord({required this.text});

  final String text;
}

class Act0CopyRegistryParser {
  const Act0CopyRegistryParser(this.source, {this.languageCode = 'ru'});

  final String source;
  final String languageCode;

  Act0CopyRegistryBundle parse() {
    return Act0CopyRegistryBundle(
      languageCode: normalizedLanguageCode,
      worlds: _parseWorlds(),
      lessons: _parseLessons(),
      tasks: _parseTasks(),
      surfaceAtoms: _parseSurfaceAtoms(),
    );
  }

  String get normalizedLanguageCode =>
      languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;

  Map<String, Act0WorldCopyRecord> _parseWorlds() {
    return _parseMapEntries(
      mapName: '_${normalizedLanguageCode}WorldCopyByIdV1',
      constructorName: 'Act0WorldDisplayCopyV1',
      builder: (block) {
        final title = extractStringField(block, 'title');
        final subtitle = extractStringField(block, 'subtitle');
        if (title == null || subtitle == null) {
          return null;
        }
        return Act0WorldCopyRecord(title: title, subtitle: subtitle);
      },
    );
  }

  Map<String, Act0LessonCopyRecord> _parseLessons() {
    return _parseMapEntries(
      mapName: '_${normalizedLanguageCode}LessonCopyByIdV1',
      constructorName: 'Act0LessonDisplayCopyV1',
      builder: (block) {
        final title = extractStringField(block, 'title');
        final subtitle = extractStringField(block, 'subtitle');
        if (title == null || subtitle == null) {
          return null;
        }
        return Act0LessonCopyRecord(title: title, subtitle: subtitle);
      },
    );
  }

  Map<String, Act0TaskCopyRecord> _parseTasks() {
    return _parseMapEntries(
      mapName: '_${normalizedLanguageCode}TaskCopyByIdV1',
      constructorName: 'Act0TaskDisplayCopyV1',
      builder: (block) {
        return Act0TaskCopyRecord(
          title: extractStringField(block, 'title'),
          summary: extractStringField(block, 'summary'),
          lockedSummary: extractStringField(block, 'lockedSummary'),
          runnerPrompt: extractStringField(block, 'runnerPrompt'),
          runnerSupport: extractStringField(block, 'runnerSupport'),
          runnerQuestion: extractStringField(block, 'runnerQuestion'),
        );
      },
    );
  }

  Map<String, Act0SurfaceAtomCopyRecord> _parseSurfaceAtoms() {
    return _parseMapEntries(
      mapName: '_${normalizedLanguageCode}SurfaceAtomCopyByIdV1',
      constructorName: 'Act0SurfaceAtomCopyV1',
      builder: (block) {
        final text = extractStringField(block, 'text');
        if (text == null) {
          return null;
        }
        return Act0SurfaceAtomCopyRecord(text: text);
      },
    );
  }

  Map<String, T> _parseMapEntries<T>({
    required String mapName,
    required String constructorName,
    required T? Function(String block) builder,
  }) {
    final mapStart = source.indexOf('$mapName =');
    if (mapStart == -1) {
      return <String, T>{};
    }
    final bodyStart = source.indexOf('{', mapStart);
    if (bodyStart == -1) {
      return <String, T>{};
    }
    final bodyEnd = findMatchingDelimiter(source, bodyStart, '{', '}');
    final body = source.substring(bodyStart + 1, bodyEnd);
    final pattern = RegExp("'([^']+)':\\s*$constructorName\\(");
    final result = <String, T>{};

    for (final match in pattern.allMatches(body)) {
      final key = match.group(1)!;
      final ctorStart = bodyStart + 1 + match.start;
      final openParen = source.indexOf('(', ctorStart);
      final closeParen = findMatchingParen(source, openParen);
      final block = source.substring(openParen + 1, closeParen);
      final record = builder(block);
      if (record != null) {
        result[key] = record;
      }
    }
    return result;
  }
}
