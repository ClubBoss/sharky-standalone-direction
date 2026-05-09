import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Future<_CompareResult> _runComparator(String content) async {
  final temp = File('${Directory.systemTemp.path}/phase1_compare_passes.log');
  temp.writeAsStringSync(content);
  final result = await Process.run('dart', [
    'run',
    'tools/phase1_compare_passes.dart',
    '--input',
    temp.path,
  ], runInShell: true);
  final stdoutStr = result.stdout is String ? result.stdout as String : '';
  final trimmed = stdoutStr.trim();
  return _CompareResult(result.exitCode, trimmed, result.stderr);
}

class _CompareResult {
  final int exitCode;
  final String stdout;
  final dynamic stderr;

  _CompareResult(this.exitCode, this.stdout, this.stderr);
}

void main() {
  test('valid passes produce expected deltas', () async {
    final content = '''
flutter: PHASE1_PASS {"run_id":"run1","pass":"A","timestamp":"2025-01-01T00:00:00Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run1","result":"correct","decision_time_ms":100,"timestamp":"2025-01-01T00:00:01Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run1","result":"wrong_action","timestamp":"2025-01-01T00:00:02Z"}
flutter: PHASE1_PASS {"run_id":"run1","pass":"B","timestamp":"2025-01-01T00:00:03Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run1","result":"correct","decision_time_ms":200,"timestamp":"2025-01-01T00:00:04Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run1","result":"correct","decision_time_ms":250,"timestamp":"2025-01-01T00:00:05Z"}
flutter: PHASE1_FLOW_END {"run_id":"run1","result":"completed","timestamp":"2025-01-01T00:00:06Z"}
''';
    final result = await _runComparator(content);
    expect(result.exitCode, 0);
    final summary = jsonDecode(result.stdout) as Map<String, dynamic>;
    expect(summary['schema'], 'phase1_pass_compare_v1');
    final passes = summary['passes'] as Map<String, dynamic>;
    final passA = passes['A'] as Map<String, dynamic>;
    final passB = passes['B'] as Map<String, dynamic>;
    expect(passA['attempts_total'], 2);
    expect(passA['correct_count'], 1);
    expect(passA['incorrect_count'], 1);
    expect((passA['accuracy'] as num).toDouble(), closeTo(0.5, 1e-9));
    expect(passB['attempts_total'], 2);
    expect(passB['correct_count'], 2);
    expect(passB['incorrect_count'], 0);
    expect((passB['accuracy'] as num).toDouble(), closeTo(1.0, 1e-9));
    expect(passB['decision_time_ms_min'], 200);
    expect(passB['decision_time_ms_max'], 250);
    expect(passB['decision_time_ms_p50'], 225);
    expect(passB['decision_time_ms_p90'], 245);
    expect(passB['decision_time_ms_mean'], 225);
    expect((summary['accuracy_delta'] as num).toDouble(), closeTo(0.5, 1e-9));
    expect(
      (summary['decision_time_mean_delta_ms'] as num).toDouble(),
      closeTo(125, 1e-9),
    );
  });

  test('missing pass B triggers exit 2', () async {
    final content = '''
flutter: PHASE1_PASS {"run_id":"run2","pass":"A","timestamp":"2025-01-01T00:01:00Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run2","result":"correct","decision_time_ms":120,"timestamp":"2025-01-01T00:01:01Z"}
flutter: PHASE1_FLOW_END {"run_id":"run2","result":"completed","timestamp":"2025-01-01T00:01:02Z"}
''';
    final result = await _runComparator(content);
    expect(result.exitCode, 2);
  });

  test('pass with zero correct samples emits null stats', () async {
    final content = '''
flutter: PHASE1_PASS {"run_id":"run3","pass":"A","timestamp":"2025-01-01T00:02:00Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run3","result":"correct","decision_time_ms":150,"timestamp":"2025-01-01T00:02:01Z"}
flutter: PHASE1_PASS {"run_id":"run3","pass":"B","timestamp":"2025-01-01T00:02:02Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"run3","result":"wrong_action","timestamp":"2025-01-01T00:02:03Z"}
flutter: PHASE1_FLOW_END {"run_id":"run3","result":"completed","timestamp":"2025-01-01T00:02:04Z"}
''';
    final result = await _runComparator(content);
    expect(result.exitCode, 0);
    final summary = jsonDecode(result.stdout) as Map<String, dynamic>;
    final passes = summary['passes'] as Map<String, dynamic>;
    final passB = passes['B'] as Map<String, dynamic>;
    expect(passB['correct_count'], 0);
    expect(passB['decision_time_ms_min'], isNull);
    expect(passB['decision_time_ms_p50'], isNull);
    expect(passB['decision_time_ms_p90'], isNull);
    expect(passB['decision_time_ms_mean'], isNull);
  });
}
