import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Exact source transitions. Each world ships its own frozen prior and reviewed
/// current rows. The older census still runs against its historical inputs.
final wave6ContractsV1 = <String, Map<String, dynamic>>{
  for (final world in [11, 12])
    if (File(
      'test/fixtures/act0_w${world}_wave6_contract_v1.json',
    ).existsSync())
      'world_$world':
          jsonDecode(
                File(
                  'test/fixtures/act0_w${world}_wave6_contract_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>,
};

Map<String, dynamic> wave6RowsV1(String phase) => {
  for (final contract in wave6ContractsV1.values)
    ...(contract[phase] as Map<String, dynamic>),
};

final wave6CurrentRowsV1 = wave6RowsV1('current');
final wave6PreviousRowsV1 = wave6RowsV1('previous');
int get wave6TaskDeltaV1 =>
    wave6CurrentRowsV1.length - wave6PreviousRowsV1.length;

int wave6WorldTaskDeltaV1(int world) {
  final contract = wave6ContractsV1['world_$world'];
  return contract == null
      ? 0
      : (contract['current'] as Map).length -
            (contract['previous'] as Map).length;
}

void verifyWave6AndRestoreIdentityV1(List<List<Object?>> entries) {
  for (final contract in wave6ContractsV1.values) {
    final current = contract['current'] as Map<String, dynamic>;
    final previous = contract['previous'] as Map<String, dynamic>;
    final world = ((current.values.first as Map)['identity'] as List).first;
    expect(
      {for (final row in entries.where((r) => r[0] == world)) row[2]: row},
      {for (final e in current.entries) e.key: (e.value as Map)['identity']},
      reason: 'Wave 6 live task and answer identity for $world',
    );
    entries.removeWhere((r) => r[0] == world);
    entries.addAll([
      for (final row in previous.values)
        (row['identity'] as List).cast<Object?>(),
    ]);
  }
  entries.sort((a, b) => (a[2] as String).compareTo(b[2] as String));
}

void verifyWave6AndRestoreLearningV1(Map<String, Object?> comparison) {
  final current = wave6RowsV1('currentLearning');
  expect(
    {for (final id in current.keys) id: comparison[id]},
    current,
    reason: 'Wave 6 live XP, task family and scored answer contract',
  );
  comparison.removeWhere((id, _) => current.containsKey(id));
  comparison.addAll(wave6RowsV1('previousLearning'));
}
