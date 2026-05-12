import 'dart:io';

import '_lib/act0_copy_language_paths.dart';
import '_lib/act0_content_copy_coverage.dart';
import '_lib/act0_content_copy_registry_parser.dart';
import '_lib/act0_content_copy_source_parser.dart';
import '_lib/act0_translation_pack_markdown.dart';

final _statePath = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
final _outputDir = Directory('docs/l10n/act0_world_packs');

void main(List<String> args) {
  final options = _SyncOptions.parse(args);
  final copyPath = File(act0LanguageCopyFilePathV1(options.languageCode));
  if (!_statePath.existsSync() || !copyPath.existsSync()) {
    stderr.writeln('Required Act0 state/copy files are missing.');
    exitCode = 1;
    return;
  }

  final content = Act0SourceParser(_statePath.readAsStringSync()).parse();
  final registry = Act0CopyRegistryParser(
    copyPath.readAsStringSync(),
    languageCode: options.languageCode,
  ).parse();
  final coverage = buildAct0CoverageSnapshot(content, registry);

  _outputDir.createSync(recursive: true);
  for (final world in coverage.worlds) {
    final filePath =
        '${_outputDir.path}/${_worldFileName(world.world.worldNumber, world.world.worldId, options.languageCode)}';
    final file = File(filePath);
    final existingPack = file.existsSync()
        ? Act0TranslationPackParser(
            file.readAsStringSync(),
            sourcePath: filePath,
            languageCode: options.languageCode,
          ).parse()
        : null;
    file.writeAsStringSync(
      _renderWorldPack(
        world,
        registry,
        existingPack,
        languageCode: options.languageCode,
      ),
    );
  }

  final masterFile = File(
    '${_outputDir.path}/ACT0_${options.languageCode.toUpperCase()}_TRANSLATION_MASTER_v1.md',
  );
  masterFile.writeAsStringSync(
    _renderMasterWorkbook(coverage, languageCode: options.languageCode),
  );
  stdout.writeln(
    'Generated ${coverage.worlds.length} world packs and ${masterFile.path}.',
  );
}

String _renderMasterWorkbook(
  Act0CoverageSnapshot coverage, {
  required String languageCode,
}) {
  final languageTag = languageCode.toUpperCase();
  final buffer = StringBuffer()
    ..writeln('# Act0 $languageTag Translation Master Workbook v1')
    ..writeln()
    ..writeln('Status: GENERATED')
    ..writeln(
      'Scope: `Act0` canonical route in `/Users/elmarsalimzade/Sharky_1.0`',
    )
    ..writeln()
    ..writeln('This is the master handoff index for all current Act0 worlds.')
    ..writeln(
      'Use the per-world pack files in this folder for actual translation work.',
    )
    ..writeln()
    ..writeln('## Workflow')
    ..writeln(
      '1. Pick a world pack from the table below, starting with the highest visible-value gaps.',
    )
    ..writeln(
      '2. Translate or improve only the `*_$languageCode` fields inside that world pack.',
    )
    ..writeln('3. Keep ids unchanged and return the edited Markdown.')
    ..writeln(
      '4. Integrate the returned copy into `${act0LanguageCopyFilePathV1(languageCode)}`.',
    )
    ..writeln('5. Re-run gap, coverage, and copy-fit audits.')
    ..writeln(
      '6. If landed copy sounds wooden, rewrite it in the world pack first. Editorial polish uses the same pipeline as missing translations.',
    )
    ..writeln()
    ..writeln('## Commands')
    ..writeln(
      '- `dart run tools/act0_translation_workbook_sync.dart --lang $languageCode`',
    )
    ..writeln(
      '- `dart run tools/act0_content_copy_coverage_report.dart --lang $languageCode`',
    )
    ..writeln(
      '- `dart run tools/act0_translation_quality_report.dart --lang $languageCode`',
    )
    ..writeln(
      '- `dart run tools/act0_translation_pack_audit.dart --lang $languageCode`',
    )
    ..writeln(
      '- `dart run tools/act0_translation_pack_ingest.dart --lang $languageCode <pack files>`',
    )
    ..writeln('- `dart run tools/act0_content_copy_priority_audit.dart`')
    ..writeln('- `dart run tools/act0_content_copy_gap_audit.dart`')
    ..writeln('- `dart run tools/act0_copy_fit_audit.dart`')
    ..writeln()
    ..writeln('## Coverage Snapshot')
    ..writeln(
      '- Worlds localized: ${coverage.localizedWorlds}/${coverage.totalWorlds} (${_percent(coverage.localizedWorlds, coverage.totalWorlds)})',
    )
    ..writeln(
      '- Lessons localized: ${coverage.localizedLessons}/${coverage.totalLessons} (${_percent(coverage.localizedLessons, coverage.totalLessons)})',
    )
    ..writeln(
      '- Tasks localized: ${coverage.localizedTasks}/${coverage.totalTasks} (${_percent(coverage.localizedTasks, coverage.totalTasks)})',
    )
    ..writeln(
      '- Runner prompts localized: ${coverage.localizedRunnerPromptTasks}/${coverage.totalRunnerTasks} (${_percent(coverage.localizedRunnerPromptTasks, coverage.totalRunnerTasks)})',
    )
    ..writeln(
      '- Runner supports localized: ${coverage.localizedRunnerSupportTasks}/${coverage.totalRunnerTasks} (${_percent(coverage.localizedRunnerSupportTasks, coverage.totalRunnerTasks)})',
    )
    ..writeln(
      '- Runner questions localized: ${coverage.localizedRunnerQuestionTasks}/${coverage.totalRunnerTasks} (${_percent(coverage.localizedRunnerQuestionTasks, coverage.totalRunnerTasks)})',
    )
    ..writeln(
      '- Teaching step titles localized: ${coverage.localizedTeachingStepTitles}/${coverage.totalTeachingSteps} (${_percent(coverage.localizedTeachingStepTitles, coverage.totalTeachingSteps)})',
    )
    ..writeln(
      '- Teaching step bodies localized: ${coverage.localizedTeachingStepBodies}/${coverage.totalTeachingSteps} (${_percent(coverage.localizedTeachingStepBodies, coverage.totalTeachingSteps)})',
    )
    ..writeln()
    ..writeln('## World Packs')
    ..writeln(
      '| World | EN title | Lessons | Tasks | Runner prompts | Runner supports | Runner questions | Step titles | Step bodies | Pack |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');

  for (final world in coverage.worlds) {
    final fileName = _worldFileName(
      world.world.worldNumber,
      world.world.worldId,
      languageCode,
    );
    buffer.writeln(
      '| ${world.world.worldId} | ${_escapePipes(world.world.title)} | '
      '${world.localizedLessons}/${world.totalLessons} | '
      '${world.localizedTasks}/${world.totalTasks} | '
      '${world.localizedRunnerPromptTasks}/${world.totalRunnerTasks} | '
      '${world.localizedRunnerSupportTasks}/${world.totalRunnerTasks} | '
      '${world.localizedRunnerQuestionTasks}/${world.totalRunnerTasks} | '
      '${world.localizedTeachingStepTitles}/${world.totalTeachingSteps} | '
      '${world.localizedTeachingStepBodies}/${world.totalTeachingSteps} | '
      '[$fileName](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/$fileName) |',
    );
  }

  return buffer.toString();
}

String _renderWorldPack(
  Act0WorldCoverage coverage,
  Act0CopyRegistryBundle registry,
  Act0TranslationPack? existingPack, {
  required String languageCode,
}) {
  final world = coverage.world;
  final worldCopy = registry.worlds[world.worldId];
  final existingLessonById = {
    for (final lesson
        in existingPack?.lessons ?? const <Act0TranslationLesson>[])
      lesson.lessonId: lesson,
  };
  final buffer = StringBuffer()
    ..writeln(
      '# ${world.worldId} ${languageCode.toUpperCase()} Translation Pack',
    )
    ..writeln()
    ..writeln('Status: GENERATED')
    ..writeln('World number: ${world.worldNumber}')
    ..writeln('EN title: ${world.title}')
    ..writeln('EN subtitle: ${world.subtitle}')
    ..writeln(
      _markdownField(
        'title_$languageCode',
        _preferExisting(existingPack?.titleLocalized, worldCopy?.title),
      ),
    )
    ..writeln(
      _markdownField(
        'subtitle_$languageCode',
        _preferExisting(existingPack?.subtitleLocalized, worldCopy?.subtitle),
      ),
    )
    ..writeln()
    ..writeln('## Coverage')
    ..writeln(
      '- Lessons: ${coverage.localizedLessons}/${coverage.totalLessons}',
    )
    ..writeln('- Tasks: ${coverage.localizedTasks}/${coverage.totalTasks}')
    ..writeln(
      '- Runner prompts: ${coverage.localizedRunnerPromptTasks}/${coverage.totalRunnerTasks}',
    )
    ..writeln(
      '- Runner supports: ${coverage.localizedRunnerSupportTasks}/${coverage.totalRunnerTasks}',
    )
    ..writeln(
      '- Runner questions: ${coverage.localizedRunnerQuestionTasks}/${coverage.totalRunnerTasks}',
    )
    ..writeln(
      '- Teaching step titles: ${coverage.localizedTeachingStepTitles}/${coverage.totalTeachingSteps}',
    )
    ..writeln(
      '- Teaching step bodies: ${coverage.localizedTeachingStepBodies}/${coverage.totalTeachingSteps}',
    )
    ..writeln()
    ..writeln('## Translator Rules')
    ..writeln('- Keep ids unchanged.')
    ..writeln('- Translate only `*_$languageCode` fields.')
    ..writeln('- Keep tone calm, compact, and table-literate.')
    ..writeln('- Do not mirror English word order mechanically.')
    ..writeln(
      '- Improve stiff landed lines here instead of patching UI-local strings.',
    )
    ..writeln()
    ..writeln('## Return Format')
    ..writeln(
      'Edit this file in place or return the same structure with updated `*_$languageCode` fields.',
    )
    ..writeln();

  for (final lesson in world.lessons) {
    final lessonCopy = registry.lessons[lesson.lessonId];
    final existingLesson = existingLessonById[lesson.lessonId];
    final existingTaskById = {
      for (final task in existingLesson?.tasks ?? const <Act0TranslationTask>[])
        task.taskId: task,
    };
    buffer.writeln('## lesson ${lesson.lessonId}');
    buffer.writeln(
      'status: ${lessonCopy == null ? 'missing' : 'landed_or_partial'}',
    );
    buffer.writeln('title_en: ${lesson.title}');
    buffer.writeln('subtitle_en: ${lesson.subtitle}');
    buffer.writeln(
      _markdownField(
        'title_$languageCode',
        _preferExisting(existingLesson?.titleLocalized, lessonCopy?.title),
      ),
    );
    buffer.writeln(
      _markdownField(
        'subtitle_$languageCode',
        _preferExisting(
          existingLesson?.subtitleLocalized,
          lessonCopy?.subtitle,
        ),
      ),
    );
    buffer.writeln();

    for (final task in lesson.tasks) {
      final taskCopy = registry.tasks[task.taskId];
      final existingTask = existingTaskById[task.taskId];
      buffer.writeln('- taskId: ${task.taskId}');
      buffer.writeln(
        '  status: ${taskCopy == null ? 'missing' : 'landed_or_partial'}',
      );
      buffer.writeln('  title_en: ${task.title}');
      if (task.summary?.isNotEmpty ?? false) {
        buffer.writeln('  summary_en: ${task.summary}');
      }
      if (task.lockedSummary?.isNotEmpty ?? false) {
        buffer.writeln('  lockedSummary_en: ${task.lockedSummary}');
      }
      buffer.writeln('  phase: ${task.phase}');
      buffer.writeln('  stepKind: ${task.stepKind}');
      if (task.runnerName != null) {
        buffer.writeln('  runner: ${task.runnerName}');
      }
      if (task.caption?.isNotEmpty ?? false) {
        buffer.writeln('  runnerPrompt_en: ${task.caption}');
      }
      if (task.hint?.isNotEmpty ?? false) {
        buffer.writeln('  runnerSupport_en: ${task.hint}');
      }
      if (task.question?.isNotEmpty ?? false) {
        buffer.writeln('  runnerQuestion_en: ${task.question}');
      }
      for (var index = 0; index < task.teachingSteps.length; index += 1) {
        final step = task.teachingSteps[index];
        final existingStep = existingTask?.teachingSteps
            .where((candidate) => candidate.stepIndex == index)
            .cast<Act0TranslationTeachingStep?>()
            .firstWhere((candidate) => candidate != null, orElse: () => null);
        final taskCopyStep =
            taskCopy?.teachingSteps != null &&
                index < taskCopy!.teachingSteps!.length
            ? taskCopy.teachingSteps![index]
            : null;
        buffer.writeln(
          _markdownField('  teachingStep${index}_title_en', step.title),
        );
        buffer.writeln(
          _markdownField('  teachingStep${index}_body_en', step.body),
        );
        buffer.writeln(
          _markdownField(
            '  teachingStep${index}_title_$languageCode',
            _preferExisting(existingStep?.titleLocalized, taskCopyStep?.title),
          ),
        );
        buffer.writeln(
          _markdownField(
            '  teachingStep${index}_body_$languageCode',
            _preferExisting(existingStep?.bodyLocalized, taskCopyStep?.body),
          ),
        );
      }
      buffer.writeln(
        _markdownField(
          '  title_$languageCode',
          _preferExisting(existingTask?.titleLocalized, taskCopy?.title),
        ),
      );
      if (task.summary?.isNotEmpty ?? false) {
        buffer.writeln(
          _markdownField(
            '  summary_$languageCode',
            _preferExisting(existingTask?.summaryLocalized, taskCopy?.summary),
          ),
        );
      }
      if (task.lockedSummary?.isNotEmpty ?? false) {
        buffer.writeln(
          _markdownField(
            '  lockedSummary_$languageCode',
            _preferExisting(
              existingTask?.lockedSummaryLocalized,
              taskCopy?.lockedSummary,
            ),
          ),
        );
      }
      if (task.caption?.isNotEmpty ?? false) {
        buffer.writeln(
          _markdownField(
            '  runnerPrompt_$languageCode',
            _preferExisting(
              existingTask?.runnerPromptLocalized,
              taskCopy?.runnerPrompt,
            ),
          ),
        );
      }
      if (task.hint?.isNotEmpty ?? false) {
        buffer.writeln(
          _markdownField(
            '  runnerSupport_$languageCode',
            _preferExisting(
              existingTask?.runnerSupportLocalized,
              taskCopy?.runnerSupport,
            ),
          ),
        );
      }
      if (task.question?.isNotEmpty ?? false) {
        buffer.writeln(
          _markdownField(
            '  runnerQuestion_$languageCode',
            _preferExisting(
              existingTask?.runnerQuestionLocalized,
              taskCopy?.runnerQuestion,
            ),
          ),
        );
      }
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String _worldFileName(int worldNumber, String worldId, String languageCode) {
  final padded = worldNumber.toString().padLeft(2, '0');
  return 'W${padded}_${worldId}_${languageCode.toUpperCase()}_PACK_v1.md';
}

String _escapePipes(String input) => input.replaceAll('|', r'\|');

String _markdownField(String key, String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.trim().isEmpty) {
    return '$key:';
  }
  return '$key: $normalized';
}

String _preferExisting(String? existingValue, String? fallback) {
  if (fallback?.trim().isNotEmpty ?? false) {
    return fallback!;
  }
  if (existingValue?.trim().isNotEmpty ?? false) {
    return existingValue!;
  }
  return '';
}

String _percent(int value, int total) {
  if (total == 0) {
    return '0.0%';
  }
  return '${((value / total) * 100).toStringAsFixed(1)}%';
}

class _SyncOptions {
  const _SyncOptions({required this.languageCode});

  final String languageCode;

  static _SyncOptions parse(List<String> args) {
    var languageCode = 'ru';
    for (var index = 0; index < args.length; index += 1) {
      if (args[index] != '--lang') {
        continue;
      }
      if (index + 1 >= args.length) {
        stderr.writeln('Missing value for --lang');
        exit(64);
      }
      languageCode = args[++index];
    }
    return _SyncOptions(
      languageCode: act0NormalizedLanguageCodeForToolsV1(languageCode),
    );
  }
}
