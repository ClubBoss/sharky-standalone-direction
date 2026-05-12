import 'dart:io';

import '_lib/act0_copy_language_paths.dart';
import '_lib/act0_content_copy_coverage.dart';
import '_lib/act0_content_copy_registry_parser.dart';
import '_lib/act0_content_copy_source_parser.dart';

final _stateFile = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
final _outputFile = File(
  'docs/l10n/act0_world_packs/ACT0_RU_WORLD_STATUS_REPORT_v1.md',
);

void main(List<String> args) {
  final languageCode = _parseLanguageCode(args);
  final copyFile = File(act0LanguageCopyFilePathV1(languageCode));
  if (!_stateFile.existsSync() || !copyFile.existsSync()) {
    stderr.writeln('Required Act0 state/copy files are missing.');
    exitCode = 1;
    return;
  }

  final content = Act0SourceParser(_stateFile.readAsStringSync()).parse();
  final registry = Act0CopyRegistryParser(
    copyFile.readAsStringSync(),
    languageCode: languageCode,
  ).parse();
  final coverage = buildAct0CoverageSnapshot(content, registry);

  _outputFile.parent.createSync(recursive: true);
  _outputFile.writeAsStringSync(
    _renderReport(coverage, languageCode: languageCode),
  );
  stdout.writeln('Wrote ${_outputFile.path}');
}

String _renderReport(
  Act0CoverageSnapshot coverage, {
  required String languageCode,
}) {
  final buffer = StringBuffer()
    ..writeln('# Act0 ${languageCode.toUpperCase()} World Status Report v1')
    ..writeln()
    ..writeln('Status: GENERATED')
    ..writeln('Scope: `world_1` to `world_12` in canonical Act0 route')
    ..writeln()
    ..writeln('## Quality Scale')
    ..writeln('- `0.0-2.9` Skeleton only')
    ..writeln('- `3.0-4.9` Machine-ready pack only')
    ..writeln('- `5.0-6.4` Partial localized draft')
    ..writeln('- `6.5-7.4` Usable draft')
    ..writeln('- `7.5-8.4` Strong learner-visible slice')
    ..writeln('- `8.5-10.0` Editorially strong')
    ..writeln()
    ..writeln('## Global Snapshot')
    ..writeln(
      '- Worlds: ${coverage.localizedWorlds}/${coverage.totalWorlds} (${_percent(coverage.localizedWorlds, coverage.totalWorlds)})',
    )
    ..writeln(
      '- Lessons: ${coverage.localizedLessons}/${coverage.totalLessons} (${_percent(coverage.localizedLessons, coverage.totalLessons)})',
    )
    ..writeln(
      '- Tasks: ${coverage.localizedTasks}/${coverage.totalTasks} (${_percent(coverage.localizedTasks, coverage.totalTasks)})',
    )
    ..writeln(
      '- Runner prompts: ${coverage.localizedRunnerPromptTasks}/${coverage.totalRunnerTasks} (${_percent(coverage.localizedRunnerPromptTasks, coverage.totalRunnerTasks)})',
    )
    ..writeln(
      '- Runner supports: ${coverage.localizedRunnerSupportTasks}/${coverage.totalRunnerTasks} (${_percent(coverage.localizedRunnerSupportTasks, coverage.totalRunnerTasks)})',
    )
    ..writeln(
      '- Runner questions: ${coverage.localizedRunnerQuestionTasks}/${coverage.totalRunnerTasks} (${_percent(coverage.localizedRunnerQuestionTasks, coverage.totalRunnerTasks)})',
    )
    ..writeln(
      '- Teaching step titles: ${coverage.localizedTeachingStepTitles}/${coverage.totalTeachingSteps} (${_percent(coverage.localizedTeachingStepTitles, coverage.totalTeachingSteps)})',
    )
    ..writeln(
      '- Teaching step bodies: ${coverage.localizedTeachingStepBodies}/${coverage.totalTeachingSteps} (${_percent(coverage.localizedTeachingStepBodies, coverage.totalTeachingSteps)})',
    )
    ..writeln()
    ..writeln('## By World')
    ..writeln(
      '| World | Lessons | Tasks | Prompts | Supports | Questions | Step titles | Step bodies | Score | Grade |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |');

  for (final world in coverage.worlds) {
    final score = _worldQualityScore(world);
    buffer.writeln(
      '| ${world.world.worldId} | '
      '${world.localizedLessons}/${world.totalLessons} | '
      '${world.localizedTasks}/${world.totalTasks} | '
      '${world.localizedRunnerPromptTasks}/${world.totalRunnerTasks} | '
      '${world.localizedRunnerSupportTasks}/${world.totalRunnerTasks} | '
      '${world.localizedRunnerQuestionTasks}/${world.totalRunnerTasks} | '
      '${world.localizedTeachingStepTitles}/${world.totalTeachingSteps} | '
      '${world.localizedTeachingStepBodies}/${world.totalTeachingSteps} | '
      '${score.toStringAsFixed(1)} | ${_grade(score)} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Notes')
    ..writeln(
      '- Score is a structural readiness heuristic, not a prose-quality guarantee.',
    )
    ..writeln(
      '- A world can have a decent score and still sound wooden until editorial rewrite.',
    )
    ..writeln(
      '- Generated world packs remain the editing layer; language file remains the integration target.',
    );

  return buffer.toString();
}

double _worldQualityScore(Act0WorldCoverage world) {
  final score =
      _weighted(world.hasWorldCopy ? 1 : 0, 1, 10) +
      _weighted(world.localizedLessons, world.totalLessons, 15) +
      _weighted(world.localizedTasks, world.totalTasks, 20) +
      _weighted(world.localizedRunnerPromptTasks, world.totalRunnerTasks, 15) +
      _weighted(world.localizedRunnerSupportTasks, world.totalRunnerTasks, 10) +
      _weighted(
        world.localizedRunnerQuestionTasks,
        world.totalRunnerTasks,
        10,
      ) +
      _weighted(
        world.localizedTeachingStepTitles,
        world.totalTeachingSteps,
        10,
      ) +
      _weighted(
        world.localizedTeachingStepBodies,
        world.totalTeachingSteps,
        10,
      );
  return score / 10;
}

double _weighted(int value, int total, int weight) {
  if (total == 0) {
    return 0;
  }
  return (value / total) * weight;
}

String _grade(double score) {
  if (score >= 8.5) {
    return 'Editorially strong';
  }
  if (score >= 7.5) {
    return 'Strong slice';
  }
  if (score >= 6.5) {
    return 'Usable draft';
  }
  if (score >= 5.0) {
    return 'Partial draft';
  }
  if (score >= 3.0) {
    return 'Machine-ready pack';
  }
  return 'Skeleton only';
}

String _parseLanguageCode(List<String> args) {
  for (var index = 0; index < args.length; index += 1) {
    if (args[index] != '--lang') {
      continue;
    }
    if (index + 1 >= args.length) {
      stderr.writeln('Missing value for --lang');
      exit(64);
    }
    return act0NormalizedLanguageCodeForToolsV1(args[index + 1]);
  }
  return 'ru';
}

String _percent(int value, int total) {
  if (total == 0) {
    return '0.0%';
  }
  return '${((value / total) * 100).toStringAsFixed(1)}%';
}
