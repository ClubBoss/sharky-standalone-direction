import 'dart:io';

import '_lib/act0_copy_language_paths.dart';
import '_lib/act0_content_copy_coverage.dart';
import '_lib/act0_content_copy_registry_parser.dart';
import '_lib/act0_content_copy_source_parser.dart';

void main(List<String> args) {
  final languageCode = _parseLanguageCode(args);
  final stateFile = File('lib/ui_v2/act0_shell/act0_shell_state_v1.dart');
  final copyFile = File(act0LanguageCopyFilePathV1(languageCode));
  if (!stateFile.existsSync() || !copyFile.existsSync()) {
    stderr.writeln('Required Act0 state/copy files are missing.');
    exitCode = 1;
    return;
  }

  final content = Act0SourceParser(stateFile.readAsStringSync()).parse();
  final registry = Act0CopyRegistryParser(
    copyFile.readAsStringSync(),
    languageCode: languageCode,
  ).parse();
  final snapshot = buildAct0CoverageSnapshot(content, registry);

  stdout.writeln('Act0 ${registry.languageCode.toUpperCase()} coverage report');
  stdout.writeln(
    'Worlds: ${snapshot.localizedWorlds}/${snapshot.totalWorlds} '
    '(${_percent(snapshot.localizedWorlds, snapshot.totalWorlds)})',
  );
  stdout.writeln(
    'Lessons: ${snapshot.localizedLessons}/${snapshot.totalLessons} '
    '(${_percent(snapshot.localizedLessons, snapshot.totalLessons)})',
  );
  stdout.writeln(
    'Tasks: ${snapshot.localizedTasks}/${snapshot.totalTasks} '
    '(${_percent(snapshot.localizedTasks, snapshot.totalTasks)})',
  );
  stdout.writeln(
    'Runner prompts: ${snapshot.localizedRunnerPromptTasks}'
    '/${snapshot.totalRunnerTasks} '
    '(${_percent(snapshot.localizedRunnerPromptTasks, snapshot.totalRunnerTasks)})',
  );
  stdout.writeln(
    'Runner supports: ${snapshot.localizedRunnerSupportTasks}'
    '/${snapshot.totalRunnerTasks} '
    '(${_percent(snapshot.localizedRunnerSupportTasks, snapshot.totalRunnerTasks)})',
  );
  stdout.writeln(
    'Runner questions: ${snapshot.localizedRunnerQuestionTasks}'
    '/${snapshot.totalRunnerTasks} '
    '(${_percent(snapshot.localizedRunnerQuestionTasks, snapshot.totalRunnerTasks)})',
  );
  stdout.writeln('');
  stdout.writeln(
    'worldId | lessons | tasks | runnerPrompt | runnerSupport | runnerQuestion',
  );
  for (final world in snapshot.worlds) {
    stdout.writeln(
      '${world.world.worldId} | '
      '${world.localizedLessons}/${world.totalLessons} | '
      '${world.localizedTasks}/${world.totalTasks} | '
      '${world.localizedRunnerPromptTasks}/${world.totalRunnerTasks} | '
      '${world.localizedRunnerSupportTasks}/${world.totalRunnerTasks} | '
      '${world.localizedRunnerQuestionTasks}/${world.totalRunnerTasks}',
    );
  }
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
  final percent = (value / total) * 100;
  return '${percent.toStringAsFixed(1)}%';
}
