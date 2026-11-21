// Offline 2-template practice generator harness (not in CI lane; verified via act0_catalog_truth_guards_v1_test).
// Usage:
//   flutter test tools/generate_act0_practice_v1_test.dart
//   GEN_TEMPLATE=open_fold GEN_COUNT=8 GEN_SEED=3 GEN_FORMAT=dart flutter test tools/generate_act0_practice_v1_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../test/support/act0_catalog_quality_audit_v1.dart';
import '../test/support/act0_catalog_truth_audit_v1.dart';
import '../test/support/act0_practice_generator_v1.dart';
import '../test/support/act0_table_truth_v1.dart';

void main() {
  test('generate and validate offline Act0 practice batch', () {
    final env = Platform.environment;
    final template = env['GEN_TEMPLATE'] ?? 'both';
    final count = int.tryParse(env['GEN_COUNT'] ?? '') ?? 4;
    final seed = int.tryParse(env['GEN_SEED'] ?? '') ?? 1;
    final format = env['GEN_FORMAT'] ?? 'summary';

    final generated = <GeneratedPracticeTaskV1>[
      if (template == 'open_fold' || template == 'both')
        ...generateOpenFoldByChartTasksV1(count: count, seed: seed),
      if (template == 'call_price' || template == 'both')
        ...generateTurnCallPriceWithOutsTasksV1(count: count, seed: seed),
    ];

    expect(generated, isNotEmpty);
    final rows = [for (final item in generated) item.toCatalogRow()];
    final truthAudit = runCatalogAudit(rows: rows);
    final nonRepairFindings = truthAudit.findings.keys
        .where((key) => !key.startsWith('10.'))
        .toList();
    expect(nonRepairFindings, isEmpty, reason: nonRepairFindings.join('\n'));

    for (final item in generated) {
      final table = item.task.runner.table;
      expect(actorFlagsConsistent(table), isTrue, reason: item.task.taskId);
      final contrib = auditTableContributionsV1(
        item.task.taskId,
        'generated',
        table,
      );
      expect(
        contrib.where((row) => row.result != 'PASS'),
        isEmpty,
        reason: item.task.taskId,
      );
    }

    final quality = runCatalogQualityAudit(rows: rows);
    expect(quality.btnShareByWorld, isEmpty);
    expect(
      quality.findings.where(
        (key) =>
            !key.startsWith('17.') &&
            !key.startsWith('18.') &&
            !key.startsWith('19.'),
      ),
      isEmpty,
    );

    final output = format == 'dart'
        ? renderGeneratedDay7DartV1(generated)
        : renderGeneratedSummaryMarkdownV1(generated);
    // ignore: avoid_print
    print(output);
  });
}
