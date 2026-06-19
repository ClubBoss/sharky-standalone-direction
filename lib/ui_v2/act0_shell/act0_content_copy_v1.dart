import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

part 'l10n/act0_copy_ru_v1.dart';

class Act0WorldDisplayCopyV1 {
  const Act0WorldDisplayCopyV1({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class Act0LessonDisplayCopyV1 {
  const Act0LessonDisplayCopyV1({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class Act0TaskDisplayCopyV1 {
  const Act0TaskDisplayCopyV1({
    this.title,
    this.summary,
    this.lockedSummary,
    this.runnerPrompt,
    this.runnerSupport,
    this.runnerQuestion,
    this.teachingSteps,
  });

  final String? title;
  final String? summary;
  final String? lockedSummary;
  final String? runnerPrompt;
  final String? runnerSupport;
  final String? runnerQuestion;
  final List<Act0TeachingStepDisplayCopyV1>? teachingSteps;
}

class Act0TeachingStepDisplayCopyV1 {
  const Act0TeachingStepDisplayCopyV1({this.title, this.body});

  final String? title;
  final String? body;
}

class Act0SurfaceAtomCopyV1 {
  const Act0SurfaceAtomCopyV1({required this.text});

  final String text;
}

class Act0LanguageCopyBundleV1 {
  const Act0LanguageCopyBundleV1({
    required this.worlds,
    required this.lessons,
    required this.tasks,
    required this.surfaceAtoms,
    required this.lessonTitlesByEnglish,
  });

  final Map<String, Act0WorldDisplayCopyV1> worlds;
  final Map<String, Act0LessonDisplayCopyV1> lessons;
  final Map<String, Act0TaskDisplayCopyV1> tasks;
  final Map<String, Act0SurfaceAtomCopyV1> surfaceAtoms;
  final Map<String, String> lessonTitlesByEnglish;
}

bool act0IsRuLocaleV1(BuildContext context) =>
    Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ru');

String act0LanguageCodeV1(BuildContext context) =>
    _act0NormalizedLanguageCodeV1(Localizations.localeOf(context).languageCode);

String act0LocalizedSurfaceAtomV1(
  BuildContext context,
  String atomId, {
  required String fallback,
}) => act0LocalizedSurfaceAtomByIdV1(
  atomId,
  fallback: fallback,
  languageCode: act0LanguageCodeV1(context),
);

String act0LocalizedWorldTitleV1(BuildContext context, Act0WorldCardV1 world) =>
    act0LocalizedWorldTitleAtomV1(
      world.worldId,
      fallback: world.title,
      languageCode: act0LanguageCodeV1(context),
    );

String act0LocalizedWorldSubtitleV1(
  BuildContext context,
  Act0WorldCardV1 world,
) => act0LocalizedWorldSubtitleAtomV1(
  world.worldId,
  fallback: world.subtitle,
  languageCode: act0LanguageCodeV1(context),
);

String act0LocalizedLessonTitleV1(
  BuildContext context,
  Act0LessonCardV1 lesson,
) => act0LocalizedLessonTitleAtomByIdV1(
  lesson.lessonId,
  fallback: lesson.title,
  languageCode: act0LanguageCodeV1(context),
);

String act0LocalizedLessonSubtitleV1(
  BuildContext context,
  Act0LessonCardV1 lesson,
) => act0LocalizedLessonSubtitleAtomByIdV1(
  lesson.lessonId,
  fallback: lesson.subtitle,
  languageCode: act0LanguageCodeV1(context),
);

String act0LocalizedWorldTitleAtomV1(
  String worldId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedWorldTitleAtomByLanguageV1(
    worldId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedWorldSubtitleAtomV1(
  String worldId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedWorldSubtitleAtomByLanguageV1(
    worldId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedLessonTitleAtomByIdV1(
  String lessonId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedLessonTitleAtomByLanguageV1(
    lessonId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedLessonSubtitleAtomByIdV1(
  String lessonId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedLessonSubtitleAtomByLanguageV1(
    lessonId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedLessonTitleAtomV1(
  String fallback, {
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedLessonTitleByEnglishAtomV1(
    fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedTaskTitleV1(BuildContext context, Act0LessonTaskV1 task) =>
    act0LocalizedTaskTitleAtomByIdV1(
      task.taskId,
      fallback: task.title,
      languageCode: act0LanguageCodeV1(context),
    );

String act0LocalizedTaskSummaryV1(
  BuildContext context,
  Act0LessonTaskV1 task, {
  String? fallback,
}) => act0LocalizedTaskSummaryAtomByIdV1(
  task.taskId,
  fallback: fallback ?? task.summary ?? '',
  languageCode: act0LanguageCodeV1(context),
);

String act0LocalizedTaskLockedSummaryV1(
  BuildContext context,
  Act0LessonTaskV1 task, {
  String? fallback,
}) => act0LocalizedTaskLockedSummaryAtomByIdV1(
  task.taskId,
  fallback: fallback ?? task.lockedSummary ?? '',
  languageCode: act0LanguageCodeV1(context),
);

String act0LocalizedTaskTitleAtomByIdV1(
  String taskId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedTaskTitleAtomByLanguageV1(
    taskId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedTaskSummaryAtomByIdV1(
  String taskId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedTaskSummaryAtomByLanguageV1(
    taskId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedTaskLockedSummaryAtomByIdV1(
  String taskId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedTaskLockedSummaryAtomByLanguageV1(
    taskId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedRunnerPromptAtomByTaskIdV1(
  String? taskId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedRunnerPromptAtomByLanguageV1(
    taskId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedRunnerSupportAtomByTaskIdV1(
  String? taskId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedRunnerSupportAtomByLanguageV1(
    taskId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedRunnerQuestionAtomByTaskIdV1(
  String? taskId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedRunnerQuestionAtomByLanguageV1(
    taskId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedTeachingStepTitleAtomByTaskIdV1(
  String? taskId,
  int? teachingStepIndex, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedTeachingStepTitleAtomByLanguageV1(
    taskId,
    teachingStepIndex,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedTeachingStepBodyAtomByTaskIdV1(
  String? taskId,
  int? teachingStepIndex, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedTeachingStepBodyAtomByLanguageV1(
    taskId,
    teachingStepIndex,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedSurfaceAtomByIdV1(
  String atomId, {
  required String fallback,
  String? languageCode,
  bool? isRu,
}) {
  return act0LocalizedSurfaceAtomByLanguageV1(
    atomId,
    fallback: fallback,
    languageCode: languageCode ?? ((isRu ?? false) ? 'ru' : ''),
  );
}

String act0LocalizedWorldTitleAtomByLanguageV1(
  String worldId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.worlds[worldId]?.title ?? fallback;
}

String act0LocalizedWorldSubtitleAtomByLanguageV1(
  String worldId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.worlds[worldId]?.subtitle ?? fallback;
}

String act0LocalizedLessonTitleAtomByLanguageV1(
  String lessonId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.lessons[lessonId]?.title ?? fallback;
}

String act0LocalizedLessonSubtitleAtomByLanguageV1(
  String lessonId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.lessons[lessonId]?.subtitle ?? fallback;
}

String act0LocalizedLessonTitleByEnglishAtomV1(
  String fallback, {
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.lessonTitlesByEnglish[fallback] ?? fallback;
}

String act0LocalizedTaskTitleAtomByLanguageV1(
  String taskId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.tasks[taskId]?.title ?? fallback;
}

String act0LocalizedTaskSummaryAtomByLanguageV1(
  String taskId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.tasks[taskId]?.summary ?? fallback;
}

String act0LocalizedTaskLockedSummaryAtomByLanguageV1(
  String taskId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.tasks[taskId]?.lockedSummary ?? fallback;
}

String act0LocalizedRunnerPromptAtomByLanguageV1(
  String? taskId, {
  required String fallback,
  required String languageCode,
}) {
  if (taskId == null) {
    return fallback;
  }
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.tasks[taskId]?.runnerPrompt ?? fallback;
}

String act0LocalizedRunnerSupportAtomByLanguageV1(
  String? taskId, {
  required String fallback,
  required String languageCode,
}) {
  if (taskId == null) {
    return fallback;
  }
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.tasks[taskId]?.runnerSupport ?? fallback;
}

String act0LocalizedRunnerQuestionAtomByLanguageV1(
  String? taskId, {
  required String fallback,
  required String languageCode,
}) {
  if (taskId == null) {
    return fallback;
  }
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.tasks[taskId]?.runnerQuestion ?? fallback;
}

String act0LocalizedTeachingStepTitleAtomByLanguageV1(
  String? taskId,
  int? teachingStepIndex, {
  required String fallback,
  required String languageCode,
}) {
  final step = _act0LocalizedTeachingStepByLanguageV1(
    taskId,
    teachingStepIndex,
    languageCode: languageCode,
  );
  return step?.title ?? fallback;
}

String act0LocalizedTeachingStepBodyAtomByLanguageV1(
  String? taskId,
  int? teachingStepIndex, {
  required String fallback,
  required String languageCode,
}) {
  final step = _act0LocalizedTeachingStepByLanguageV1(
    taskId,
    teachingStepIndex,
    languageCode: languageCode,
  );
  return step?.body ?? fallback;
}

String act0LocalizedSurfaceAtomByLanguageV1(
  String atomId, {
  required String fallback,
  required String languageCode,
}) {
  final bundle = act0CopyBundleForLanguageCodeV1(languageCode);
  return bundle?.surfaceAtoms[atomId]?.text ?? fallback;
}

Act0LanguageCopyBundleV1? act0CopyBundleForLanguageCodeV1(String languageCode) {
  final normalized = _act0NormalizedLanguageCodeV1(languageCode);
  return _act0CopyByLanguageCodeV1[normalized];
}

String _act0NormalizedLanguageCodeV1(String languageCode) =>
    languageCode.trim().toLowerCase().split(RegExp('[-_]')).first;

Act0TeachingStepDisplayCopyV1? _act0LocalizedTeachingStepByLanguageV1(
  String? taskId,
  int? teachingStepIndex, {
  required String languageCode,
}) {
  if (taskId == null || teachingStepIndex == null || teachingStepIndex < 0) {
    return null;
  }
  final teachingSteps = act0CopyBundleForLanguageCodeV1(
    languageCode,
  )?.tasks[taskId]?.teachingSteps;
  if (teachingSteps == null || teachingStepIndex >= teachingSteps.length) {
    return null;
  }
  return teachingSteps[teachingStepIndex];
}

String act0RussianPluralV1(
  int count,
  String form1,
  String form2,
  String form5,
) {
  final rem10 = count % 10;
  final rem100 = count % 100;
  if (rem100 >= 11 && rem100 <= 19) {
    return form5;
  }
  if (rem10 == 1) {
    return form1;
  }
  if (rem10 >= 2 && rem10 <= 4) {
    return form2;
  }
  return form5;
}
