import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test('catalog truth is exhaustive and new contradictions fail closed', () {
    final rows = auditTableTruth();
    final expected = jsonDecode(
      File(
        'test/ui_v2/fixtures/table_truth_learning_contract_v1.json',
      ).readAsStringSync(),
    );
    final actual = {
      for (final w in Act0ShellStateV1.sample.worlds)
        for (final l in w.lessons)
          for (final t in l.taskList)
            t.taskId: {
              'world': w.worldId,
              'lesson': l.lessonId,
              'options': [
                for (final o in t.runner.options)
                  {
                    'id': o.id,
                    'ok': o.isCorrect,
                    'q': o.quality.name,
                    'seat': o.seatId,
                    'rSeats': o.repairFocusSeatIds,
                    'rCards': o.repairFocusCardIds,
                    'rLabels': o.repairFocusLabels,
                  },
              ],
            },
    };
    final contractOutput = Platform.environment['TABLE_TRUTH_CONTRACT'];
    if (contractOutput != null)
      File(contractOutput).writeAsStringSync(jsonEncode(actual));
    final changes =
        jsonDecode(
              File(
                'test/ui_v2/fixtures/en_v1_truth_contract_corrections_v1.json',
              ).readAsStringSync(),
            )
            as List;
    for (final change in changes.cast<Map>()) {
      final options = expected[change['task']]['options'] as List;
      final option = options.cast<Map>().singleWhere(
        (o) => o['id'] == change['choice'],
      );
      expect(
        option[change['field']],
        change['before'],
        reason: 'Correction must match frozen #337 contract',
      );
      expect(change['reason'], isNotEmpty);
      option[change['field']] = change['after'];
    }
    expect(
      actual,
      expected,
      reason: 'Stable grading, choice/source IDs and repair focus contract',
    );

    final exceptions = File(
      'test/ui_v2/fixtures/table_truth_unresolved_v1.json',
    );
    final records = exceptions.existsSync()
        ? jsonDecode(exceptions.readAsStringSync()) as Map
        : {};
    final admitted = records.keys.toSet();
    final output = Platform.environment['TABLE_TRUTH_LEDGER'];
    if (output != null)
      File(output).writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert([
          for (final row in rows)
            {
              ...row.toJson(),
              if (records.containsKey(row.key))
                'documented_hold': records[row.key],
            },
        ]),
      );
    stdout.writeln(
      'TABLE_TRUTH tasks=${rows.map((r) => r.taskId).toSet().length} rows=${rows.length} documented_failures=${admitted.length}; source context is not a poker PASS',
    );
    final failures = rows
        .where((r) => r.result == 'FAIL')
        .map((r) => r.key)
        .toSet();
    expect(
      failures.difference(admitted),
      isEmpty,
      reason:
          'New catalog contradictions:\n${failures.difference(admitted).join('\n')}',
    );
    expect(
      admitted.difference(failures),
      isEmpty,
      reason: 'Remove resolved/stale exceptions',
    );
    expect(rows.map((r) => r.taskId).toSet().length, greaterThanOrEqualTo(367));
  });
}
