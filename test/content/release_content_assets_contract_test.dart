import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:poker_analyzer/content/release_content_plan.dart';

void main() {
  const assetDir = 'content';
  const requiredFiles = ['manifest.json'];
  const optionalJsonFiles = ['theory.md'];
  const optionalJsonlFiles = ['drills.jsonl', 'quiz.jsonl', 'demos.jsonl'];

  test('release modules expose required assets', () {
    final missingDirs = <String>[];
    final missingFiles = <String, List<String>>{};
    final emptyFiles = <String, List<String>>{};
    final manifestErrors = <String, String>{};
    final jsonlEmpty = <String, List<String>>{};

    for (final module in ReleaseContentPlanV1.modules) {
      final moduleDir = Directory('$assetDir/${module.id}/v1');
      if (!moduleDir.existsSync()) {
        missingDirs.add(module.id);
        continue;
      }

      for (final fileName in requiredFiles) {
        final file = File('${moduleDir.path}/$fileName');
        if (!file.existsSync()) {
          missingFiles.putIfAbsent(module.id, () => []).add(fileName);
          continue;
        }
        final content = file.readAsStringSync();
        if (content.trim().isEmpty) {
          emptyFiles.putIfAbsent(module.id, () => []).add(fileName);
          continue;
        }

        try {
          jsonDecode(content);
        } catch (error) {
          manifestErrors[module.id] = error.toString();
        }
      }

      for (final fileName in optionalJsonFiles) {
        final file = File('${moduleDir.path}/$fileName');
        if (!file.existsSync()) continue;
        final content = file.readAsStringSync();
        if (content.trim().isEmpty) {
          emptyFiles.putIfAbsent(module.id, () => []).add(fileName);
        }
      }

      for (final fileName in optionalJsonlFiles) {
        final file = File('${moduleDir.path}/$fileName');
        if (!file.existsSync()) continue;
        final content = file.readAsStringSync();
        if (content.trim().isEmpty) {
          emptyFiles.putIfAbsent(module.id, () => []).add(fileName);
          continue;
        }
        final validLine = content
            .split('\n')
            .map((line) => line.trim())
            .firstWhere((line) => line.isNotEmpty, orElse: () => '');
        if (validLine.isEmpty) {
          jsonlEmpty.putIfAbsent(module.id, () => []).add(fileName);
          continue;
        }
        try {
          jsonDecode(validLine);
        } catch (error) {
          manifestErrors['$module.id/$fileName'] = error.toString();
        }
      }
    }

    expect(
      missingDirs,
      isEmpty,
      reason: missingDirs.isEmpty
          ? null
          : 'Missing module directories at content/<id>/v1: $missingDirs',
    );
    expect(
      missingFiles,
      isEmpty,
      reason: missingFiles.isEmpty
          ? null
          : 'Missing required files for modules: $missingFiles',
    );
    expect(
      emptyFiles,
      isEmpty,
      reason: emptyFiles.isEmpty
          ? null
          : 'Empty required files detected: $emptyFiles',
    );
    expect(
      manifestErrors,
      isEmpty,
      reason: manifestErrors.isEmpty
          ? null
          : 'Manifest/JSON parsing issues: $manifestErrors',
    );
    expect(
      jsonlEmpty,
      isEmpty,
      reason: jsonlEmpty.isEmpty
          ? null
          : 'JSONL files must contain at least one valid line: $jsonlEmpty',
    );
  });
}
