// flutter test tools/act0_reasoning_map_export_v1.dart --dart-define=OUT=/path/to/reasoning_map_<sha>.json
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';

import '../test/support/act0_catalog_decision_copy_v1.dart';
import '../test/support/act0_catalog_decision_v1.dart';
import '../test/support/act0_catalog_reasoning_audit_v1.dart';
import '../test/support/act0_catalog_snapshot_v1.dart';

void main() {
  test('export Act0 reasoning map', () {
    const path = String.fromEnvironment('OUT');
    expect(
      path,
      isNotEmpty,
      reason: 'Set --dart-define=OUT=/path/to/reasoning_map_<sha>.json',
    );
    final git = Process.runSync('git', ['rev-parse', 'HEAD']);
    expect(git.exitCode, 0);
    final sha = (git.stdout as String).trim();
    expect(path, endsWith('reasoning_map_$sha.json'));
    final status = Process.runSync('git', ['status', '--porcelain']);
    expect(status.exitCode, 0);
    expect(
      status.stdout,
      isEmpty,
      reason: 'Export from a clean source checkout.',
    );
    final tasks = <Object>[];
    final byWorld = <String, Map<String, int>>{};
    for (final row in reasoningCatalogRowsV1) {
      final audit = auditCatalogReasoningV1(row);
      final kind = audit?.kind;
      if (audit == null || kind == null) continue;
      final task = row.task;
      final decision = kind == Act0DecisionKindV1.table
          ? CatalogDecisionLedgerV1(task.runner.table)
          : null;
      final copy = auditDecisionCopyV1(row).toList();
      final summary = byWorld.putIfAbsent(row.world.worldId, () => {});
      void count(String key) =>
          summary.update(key, (value) => value + 1, ifAbsent: () => 1);
      count('decisions');
      count(kind.name);
      if (audit.eligibleShortStack) count('effective_stack_below_50_bb');
      if (audit.stackMatters) count('short_stack_matters');
      for (final rule in audit.findings.keys) {
        count('g1_${rule}_decisions_with_findings');
      }
      for (final item in copy) {
        count('g1_${item.rule}_findings');
      }
      tasks.add({
        'world': row.world.worldNumber,
        'lessonId': row.lesson.lessonId,
        'taskId': task.taskId,
        'kind': kind.name,
        'options': [
          for (final option in task.runner.options)
            {
              'id': option.id,
              'label': option.label,
              'grade': option.quality.name,
            },
        ],
        'principleId': act0DecisionReasoningV1[task.taskId]?.principleId,
        'g1': {
          for (final rule in [28, 29, 30, 32])
            '$rule': switch (rule) {
              28 || 29 when decision == null => 'not_applicable',
              30 when decision?.facingWager != true => 'not_applicable',
              32
                  when act0DecisionReasoningV1[task.taskId]
                          ?.preChoiceAssumption ==
                      null =>
                'not_applicable',
              _ => audit.findings.containsKey(rule) ? 'finding' : 'pass',
            },
        },
        'effectiveStackBb': decision == null
            ? null
            : {
                for (final seat in decision.activeSeatIds)
                  if (seat != decision.table.heroSeat.seatId)
                    decision.seatLabel(seat): decision.effectiveStacks[seat],
              },
        'copyFindings': [
          for (final finding in copy)
            {
              'rule': finding.rule,
              'optionId': finding.optionId,
              'quote': finding.quote,
            },
        ],
      });
    }
    final out = File(path)..createSync(recursive: true);
    final requiredCourse = catalogTasks.where((row) => !row.task.repairOnly);
    out.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert({
        'sourceSha': sha,
        'course': {'tasks': catalogTasks.length, 'mandatoryTasks': requiredCourse.length, 'mandatoryXp': requiredCourse.fold<int>(0, (xp, row) => xp + row.task.rewardXp), 'repairOnlyXp': catalogTasks.where((row) => row.task.repairOnly).fold<int>(0, (xp, row) => xp + row.task.rewardXp)},
        'byWorld': byWorld,
        'decisions': tasks,
      })}\n',
    );
  });
}
