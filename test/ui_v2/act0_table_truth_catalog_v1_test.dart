import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test('enumerates the live source and final runtime projections', () {
    final rows = auditTableTruth();
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons).expand((l) => l.taskList).toList();
    expect(tasks.map((t) => t.taskId).toSet().length, tasks.length);
    expect(rows.map((r) => r.taskId).toSet(), tasks.map((t) => t.taskId).toSet());
    final out = Directory(Platform.environment['TABLE_TRUTH_OUTPUT'] ?? 'output/table_truth');
    out.createSync(recursive: true);
    out.uri.resolve('ledger.json').toFilePath();
    File('${out.path}/ledger.json').writeAsStringSync(jsonEncode(rows.map((r) => r.toJson()).toList()));
    final contract = {for (final t in tasks) t.taskId: {
      'rewardXp': t.rewardXp,
      'family': t.resolvedTaskFamily.name,
      'options': [for (final o in t.runner.options) {
        'id': o.id, 'correct': o.isCorrect, 'quality': o.quality.name,
        'seat': o.seatId, 'repairSeats': o.repairFocusSeatIds,
        'repairCards': o.repairFocusCardIds, 'repairLabels': o.repairFocusLabels,
      }],
    }};
    File('${out.path}/learning-contract.json').writeAsStringSync(jsonEncode(contract));
    final failures = rows.where((r) => r.result == 'FAIL').toList();
    final byInvariant = <String, Set<String>>{};
    for (final r in failures) {
      byInvariant.putIfAbsent(r.invariant, () => <String>{}).add(r.taskId);
    }
    stdout.writeln('TABLE_TRUTH tasks=${tasks.length} variants=${rows.map((r) => '${r.taskId}|${r.variant}').toSet().length} rows=${rows.length}');
    stdout.writeln(jsonEncode({for (final e in byInvariant.entries) e.key: e.value.toList()..sort()}));
    if (Platform.environment['TABLE_TRUTH_CENSUS_ONLY'] != '1') {
      expect(failures.map((r) => r.key), isEmpty, reason: 'Confirmed invariants must have exact disposition');
    }
  });
}
