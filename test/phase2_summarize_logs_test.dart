import 'dart:io';

import 'package:test/test.dart';

Future<int> _runSummarizer(
  String content, {
  required bool failOnMissing,
  required int minRuns,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'phase2_summarizer_test_',
  );
  final temp = File('${tempDir.path}/phase2_summary.log');
  temp.writeAsStringSync(content);
  final result = await Process.run('dart', [
    'tools/phase2_summarize_logs.dart',
    '--input',
    temp.path,
    if (failOnMissing) '--fail_on_missing',
    '--min_runs',
    '$minRuns',
  ]);
  await tempDir.delete(recursive: true);
  final stdoutStr = result.stdout is String ? result.stdout as String : '';
  expect(stdoutStr.contains('"schema":"phase2_summary_v1"'), isTrue);
  expect(stdoutStr.contains('"event":"PHASE2_LOG_SUMMARY"'), isTrue);
  return result.exitCode;
}

void main() {
  test('valid run passes', () async {
    final content = '''
PHASE2_AHA_HINT_SHOWN {"run_id":"A","timestamp":"2025-12-31T00:00:00Z"}
PHASE2_AHA_HINT_DISMISSED {"run_id":"A","timestamp":"2025-12-31T00:00:01Z"}
PHASE2_FLOW_END {"run_id":"A","result":"signaled","timestamp":"2025-12-31T00:00:02Z"}
''';
    final exitCode = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(exitCode, 0);
  });

  test('missing dismissal fails when strict', () async {
    final content = '''
PHASE2_AHA_HINT_SHOWN {"run_id":"B","timestamp":"2025-12-31T00:01:00Z"}
PHASE2_FLOW_END {"run_id":"B","result":"signaled","timestamp":"2025-12-31T00:01:02Z"}
''';
    final exitCode = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(exitCode, 2);
  });

  test('min_runs enforces multiple sessions', () async {
    final content = '''
PHASE2_AHA_HINT_SHOWN {"run_id":"C","timestamp":"2025-12-31T00:02:00Z"}
PHASE2_AHA_HINT_DISMISSED {"run_id":"C","timestamp":"2025-12-31T00:02:01Z"}
PHASE2_FLOW_END {"run_id":"C","result":"signaled","timestamp":"2025-12-31T00:02:02Z"}
''';
    final exitCode = await _runSummarizer(
      content,
      failOnMissing: false,
      minRuns: 2,
    );
    expect(exitCode, 3);
  });
}
