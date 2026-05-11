import 'dart:io';

import 'package:test/test.dart';
import 'package:poker_analyzer/content/release_content_plan.dart';

void main() {
  test('release modules include meaningful content', () {
    final guardEnabled = Platform.environment['RELEASE_CONTENT_GUARD'] == '1';
    if (!guardEnabled) {
      stdout.writeln(
        'SKIP: release content guard disabled; set RELEASE_CONTENT_GUARD=1 to enforce.',
      );
      return;
    }
    const baseDir = 'content';
    const optionalJsonlFiles = ['drills.jsonl', 'demos.jsonl', 'quiz.jsonl'];
    const theoryFile = 'theory.md';

    final failures = <String, String>{};

    for (final module in ReleaseContentPlanV1.manifestEnforcedModules) {
      final moduleDir = Directory('$baseDir/${module.id}/v1');
      if (!moduleDir.existsSync()) {
        failures[module.id] =
            'Directory ${moduleDir.path} missing; run release content generator';
        continue;
      }

      var hasMeaningfulJsonl = false;
      for (final fileName in optionalJsonlFiles) {
        final file = File('${moduleDir.path}/$fileName');
        if (!file.existsSync()) continue;
        final nonEmptyLines = file
            .readAsLinesSync()
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        if (nonEmptyLines.length >= 3) {
          hasMeaningfulJsonl = true;
          break;
        }
      }

      if (hasMeaningfulJsonl) continue;

      final theory = File('${moduleDir.path}/$theoryFile');
      if (theory.existsSync()) {
        final length = theory
            .readAsStringSync()
            .replaceAll(RegExp(r'\s+'), '')
            .length;
        if (length >= 200) continue;
        failures[module.id] =
            'theory.md present but too short ($length chars); add more guidance.';
        continue;
      }

      failures[module.id] =
          'Missing meaningful drills/demos/quiz or sizable theory.md';
    }

    if (failures.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Release content meaningful contract failed:')
        ..writeln(
          failures.entries
              .map((entry) => '- ${entry.key}: ${entry.value}')
              .join('\n'),
        )
        ..writeln(
          'Populate drills/demos/quiz or meaningful theory; keep SSOT in sync.',
        );
      fail(buffer.toString());
    }
  });
}
