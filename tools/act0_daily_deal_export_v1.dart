// Local generator audit. Run from a clean checkout with Flutter:
// flutter test tools/act0_daily_deal_export_v1.dart --dart-define=OUT=/absolute/dir
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../test/support/act0_catalog_snapshot_v1.dart';
import '../test/support/act0_catalog_starting_chart_v1.dart';

const _seedsPerTemplate = 40;

void main() {
  test('export the fixed daily deal audit sample', () {
    const out = String.fromEnvironment('OUT');
    expect(out, isNotEmpty, reason: 'Set --dart-define=OUT=/absolute/dir.');
    final head = Process.runSync('git', ['rev-parse', 'HEAD']);
    expect(head.exitCode, 0, reason: '${head.stderr}');
    final sha = (head.stdout as String).trim();
    final status = Process.runSync('git', ['status', '--porcelain']);
    expect(status.exitCode, 0, reason: '${status.stderr}');
    expect(status.stdout, isEmpty, reason: 'Export from a clean checkout.');

    final templates = act0LegacyDailyDealTemplatesV1;
    final sections = [
      for (final template in templates)
        ...renderDailyDealExportSectionV1(template),
    ];
    final contents = [
      'SHARKY POKER · Daily Practice generator · ${templates.length * _seedsPerTemplate} deals',
      'Generator source: $sha',
      'Options tagged +/−. The last part of each task ID is the seed.',
      '',
      ...sections,
      '===== STARTING CHART · FIRST OPEN =====',
      '',
      renderStartingChartOpening(),
    ].join('\n').trimRight();

    final directory = Directory(out)..createSync(recursive: true);
    final file = File.fromUri(
      directory.absolute.uri.resolve(
        'generator_sample_${sha.substring(0, 7)}.txt',
      ),
    );
    file.writeAsStringSync('$contents\n');
    stdout.writeln(file.path);
  });
}

Iterable<String> renderDailyDealExportSectionV1(
  Act0DailyDealTemplateV1 template,
) sync* {
  yield '===== TEMPLATE ${template.name} · seeds 0–${_seedsPerTemplate - 1} =====';
  yield '';
  yield* renderCatalogTaskSectionV1(
    _sample(template),
    showPotBeforeDecision: template == Act0DailyDealTemplateV1.lowSpr,
  );
}

Iterable<CatalogTask> _sample(Act0DailyDealTemplateV1 template) sync* {
  final sourceId = act0DailyDealSourceTasksV1.entries
      .firstWhere((entry) => entry.value == template)
      .key;
  final anchor = catalogTasks.singleWhere((row) => row.task.taskId == sourceId);
  for (var seed = 0; seed < _seedsPerTemplate; seed++) {
    final id = 'generated_${template.name}_$seed';
    final task = act0GenerateDailyDealV1(
      taskId: id,
      lessonId: anchor.lesson.lessonId,
      template: template,
      seed: seed,
    );
    expect(task, isNotNull, reason: 'The generator rejected $id.');
    yield (
      world: anchor.world,
      lesson: anchor.lesson,
      task: task!,
      lessonIndex: anchor.lessonIndex,
    );
  }
}
