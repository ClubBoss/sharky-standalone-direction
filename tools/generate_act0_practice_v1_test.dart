// Offline practice generator harness (not in CI lane; verified via act0_catalog_truth_guards_v1_test).
// Usage:
//   flutter test tools/generate_act0_practice_v1_test.dart
//   GEN_TEMPLATE=open_fold GEN_COUNT=8 GEN_SEED=3 GEN_FORMAT=dart flutter test tools/generate_act0_practice_v1_test.dart
//   GEN_TEMPLATE=postflop GEN_COUNT=200 GEN_OUTPUT=/tmp/postflop.txt flutter test tools/generate_act0_practice_v1_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../test/support/act0_catalog_quality_audit_v1.dart';
import '../test/support/act0_catalog_rubric_guards_v1.dart';
import '../test/support/act0_catalog_truth_audit_v1.dart';
import '../test/support/act0_practice_generator_v1.dart';
import '../test/support/act0_table_truth_v1.dart';

void main() {
  test(
    'generate and validate offline Act0 practice batch',
    () {
      final env = Platform.environment;
      final template = env['GEN_TEMPLATE'] ?? 'both';
      final count = int.tryParse(env['GEN_COUNT'] ?? '') ?? 4;
      final seed = int.tryParse(env['GEN_SEED'] ?? '') ?? 1;
      final format = env['GEN_FORMAT'] ?? 'summary';

      final postflop = [
        for (final skill in PostflopPracticeSkillV1.values)
          if (template == 'postflop' || template == skill.name)
            ...generatePostflopPracticeV1(skill, count: count, seed: seed),
      ];
      final generated = <GeneratedPracticeTaskV1>[
        if (template == 'open_fold' || template == 'both')
          ...generateOpenFoldByChartTasksV1(count: count, seed: seed),
        if (template == 'call_price' || template == 'both')
          ...generateTurnCallPriceWithOutsTasksV1(count: count, seed: seed),
        ...postflop,
      ];

      expect(generated, isNotEmpty);
      final rows = [for (final item in generated) item.toCatalogRow()];
      // Samples are independent practice reps. Catalog repeat policy applies
      // when candidates are selected for a single fixed course route.
      final truthFindings = postflop.isEmpty
          ? runCatalogAudit(rows: rows).findings.keys
          : rows.expand((row) => runCatalogAudit(rows: [row]).findings.keys);
      final nonRepairFindings = truthFindings
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
          contrib.map((row) => row.invariant),
          containsAll(['D2.pot_feasibility', 'D3.to_call_completeness']),
          reason: item.task.taskId,
        );
        expect(
          contrib.where((row) => row.result != 'PASS'),
          isEmpty,
          reason: item.task.taskId,
        );
      }

      for (final item in postflop) {
        expect(
          catalogRubricFindingsV1(item.task),
          isEmpty,
          reason: item.task.taskId,
        );
      }
      final quality = runCatalogQualityAudit(rows: rows);
      expect(quality.btnShareByWorld, isEmpty);
      expect(quality.correctFeedbackOverLimit, isEmpty);
      expect(
        quality.findings.where(
          (key) =>
              !key.startsWith('17.') &&
              !key.startsWith('18.') &&
              !key.startsWith('19.'),
        ),
        isEmpty,
      );

      for (final skill in PostflopPracticeSkillV1.values) {
        final batch = postflop.where((item) => item.templateId == skill.name);
        if (batch.isEmpty) continue;
        expect(batch, hasLength(count));
        final signatures = batch
            .map((item) => (item.metadata['hero'], item.metadata['board']))
            .toSet();
        expect(signatures, hasLength(count));
        final correct = <String, int>{};
        for (final item in batch) {
          final answer = item.task.runner.options.singleWhere(
            (o) => o.isCorrect,
          );
          correct.update(answer.id, (n) => n + 1, ifAbsent: () => 1);
          expect(item.metadata['runouts'], isNotEmpty);
        }
        if (count >= 10) {
          expect(
            correct.values.every((n) => n * 5 <= count * 3),
            isTrue,
            reason: '${skill.name}: $correct',
          );
        }
      }
      final output = format == 'dart'
          ? renderGeneratedDay7DartV1(generated)
          : renderGeneratedSummaryMarkdownV1(generated);
      if (env['GEN_OUTPUT'] case final path?) {
        File(path).writeAsStringSync(output);
      } else {
        // ignore: avoid_print
        print(output);
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
