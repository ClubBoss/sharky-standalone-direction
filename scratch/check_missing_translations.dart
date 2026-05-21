import 'dart:io';
import '../tools/_lib/act0_translation_pack_markdown.dart';

void main() {
  final packs = [
    'docs/l10n/act0_world_packs/W03_world_3_RU_PACK_v1.md',
    'docs/l10n/act0_world_packs/W05_world_5_RU_PACK_v1.md',
  ];

  for (final path in packs) {
    print('Checking pack: $path');
    final file = File(path);
    if (!file.existsSync()) {
      print('File not found: $path');
      continue;
    }

    final pack = Act0TranslationPackParser(
      file.readAsStringSync(),
      sourcePath: file.path,
      languageCode: 'ru',
    ).parse();

    print(
      'World: ${pack.worldId} (RU title: "${pack.titleLocalized}", RU subtitle: "${pack.subtitleLocalized}")',
    );

    for (final lesson in pack.lessons) {
      print(
        '  Lesson: ${lesson.lessonId} (RU title: "${lesson.titleLocalized}", RU subtitle: "${lesson.subtitleLocalized}")',
      );
      if (lesson.titleLocalized.trim().isEmpty) {
        print('    [MISSING] Lesson title for ${lesson.lessonId}');
      }
      if (lesson.subtitleLocalized.trim().isEmpty) {
        print('    [MISSING] Lesson subtitle for ${lesson.lessonId}');
      }

      for (final task in lesson.tasks) {
        final missing = <String>[];
        if (task.titleLocalized.trim().isEmpty) missing.add('title');
        if (task.runnerPromptLocalized.trim().isEmpty)
          missing.add('runnerPrompt');
        if (task.runnerSupportLocalized.trim().isEmpty)
          missing.add('runnerSupport');
        if (task.runnerQuestionLocalized.trim().isEmpty)
          missing.add('runnerQuestion');
        // Summary is optional but let's check
        // LockedSummary is also optional

        for (final step in task.teachingSteps) {
          if (step.titleLocalized.trim().isEmpty) {
            missing.add('teachingStep${step.stepIndex}_title');
          }
          if (step.bodyLocalized.trim().isEmpty) {
            missing.add('teachingStep${step.stepIndex}_body');
          }
        }

        if (missing.isNotEmpty) {
          print('    Task: ${task.taskId} - Missing RU: ${missing.join(", ")}');
        }
      }
    }
  }
}
