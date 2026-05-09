import 'dart:io';
import 'dart:convert';

import 'package:test/test.dart';

Future<_SummarizerResult> _runSummarizer(
  String content, {
  required bool failOnMissing,
  required int minRuns,
  bool export = false,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'phase1_summarizer_test_',
  );
  final temp = File('${tempDir.path}/phase1_summarizer.log');
  temp.writeAsStringSync(content);
  final result = await Process.run('dart', [
    'tools/phase1_summarize_logs.dart',
    '--input',
    temp.path,
    if (failOnMissing) '--fail_on_missing',
    '--min_runs',
    '$minRuns',
    if (export) '--export',
  ]);
  await tempDir.delete(recursive: true);
  final stdoutStr = result.stdout is String ? result.stdout as String : '';
  final lines = stdoutStr
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  final summary = jsonDecode(lines.first) as Map<String, dynamic>;
  return _SummarizerResult(result.exitCode, summary, lines);
}

class _SummarizerResult {
  final int exitCode;
  final Map<String, dynamic> summary;
  final List<String> lines;

  _SummarizerResult(this.exitCode, this.summary, this.lines);
}

void main() {
  test('valid run satisfies gate', () async {
    final content = '''
flutter: PHASE1_SESSION_START {"run_id":"runA","timestamp":"2025-01-01T00:00:00Z"}
flutter: PHASE1_ATTEMPT_START {"run_id":"runA","attempt":1,"timestamp":"2025-01-01T00:00:01Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runA","attempt":1,"result":"correct","decision_time_ms":100,"timestamp":"2025-01-01T00:00:02Z"}
flutter: PHASE1_FLOW_END {"run_id":"runA","result":"completed","timestamp":"2025-01-01T00:00:03Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 0);
    expect(result.summary['total_runs'], 1);
    expect(result.summary['flow_end_count'], 1);
    expect(result.summary['attempt_start_count'], 1);
    expect(result.summary['attempt_result_count'], 1);
    expect(result.summary['correct_count'], 1);
    expect(result.summary['incorrect_count'], 0);
    expect(result.summary['decision_time_samples_count'], 1);
    expect(result.summary['ok'], true);
  });

  test('missing flow end triggers failure', () async {
    final content = '''
flutter: PHASE1_SESSION_START {"run_id":"runB","timestamp":"2025-01-01T00:01:00Z"}
flutter: PHASE1_ATTEMPT_START {"run_id":"runB","attempt":1,"timestamp":"2025-01-01T00:01:01Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runB","attempt":1,"result":"wrong_action","timestamp":"2025-01-01T00:01:02Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 2);
    expect(result.summary['total_runs'], 0);
    expect((result.summary['missing_runs'] as List).contains('runB'), isTrue);
    expect(result.summary['ok'], false);
  });

  test('min runs enforcement', () async {
    final content = '''
flutter: PHASE1_SESSION_START {"run_id":"runC","timestamp":"2025-01-01T00:02:00Z"}
flutter: PHASE1_ATTEMPT_START {"run_id":"runC","attempt":1,"timestamp":"2025-01-01T00:02:01Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runC","attempt":1,"result":"correct","decision_time_ms":120,"timestamp":"2025-01-01T00:02:02Z"}
flutter: PHASE1_FLOW_END {"run_id":"runC","result":"completed","timestamp":"2025-01-01T00:02:03Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: false,
      minRuns: 2,
    );
    expect(result.exitCode, 3);
    expect(result.summary['flow_end_count'], 1);
    expect(result.summary['ok'], false);
  });

  test('export flag emits run objects', () async {
    final content = '''
flutter: PHASE1_SESSION_START {"run_id":"runE","timestamp":"2025-01-01T00:03:00Z"}
flutter: PHASE1_ATTEMPT_START {"run_id":"runE","attempt":1,"timestamp":"2025-01-01T00:03:01Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runE","attempt":1,"result":"correct","decision_time_ms":110,"timestamp":"2025-01-01T00:03:02Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runE","attempt":2,"result":"correct","decision_time_ms":130,"timestamp":"2025-01-01T00:03:03Z"}
flutter: PHASE1_FLOW_END {"run_id":"runE","result":"completed","timestamp":"2025-01-01T00:03:04Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: false,
      minRuns: 1,
      export: true,
    );
    expect(result.lines.length, 2);
    final exportLine = jsonDecode(result.lines[1]) as Map<String, dynamic>;
    expect(exportLine['event'], 'PHASE1_EXPORT');
    final runs = exportLine['runs'] as List;
    expect(runs.length, 1);
    final run = runs.first as Map<String, dynamic>;
    expect(run['run_id'], 'runE');
    expect(run['total_attempts'], 2);
    expect(run['correct_count'], 2);
    expect(run['incorrect_count'], 0);
    expect(run['decision_time_ms_min'], 110);
    expect(run['decision_time_ms_mean'], 120);
    expect(run['decision_time_ms_p50'], 120);
    expect(run['decision_time_ms_p90'], 128);
  });

  test('export line emitted even with zero correct samples', () async {
    final content = '''
flutter: PHASE1_SESSION_START {"run_id":"runF","timestamp":"2025-01-01T00:04:00Z"}
flutter: PHASE1_ATTEMPT_START {"run_id":"runF","attempt":1,"timestamp":"2025-01-01T00:04:01Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runF","attempt":1,"result":"wrong_action","timestamp":"2025-01-01T00:04:02Z"}
flutter: PHASE1_ATTEMPT_RESULT {"run_id":"runF","attempt":2,"result":"wrong_action","timestamp":"2025-01-01T00:04:03Z"}
flutter: PHASE1_FLOW_END {"run_id":"runF","result":"completed","timestamp":"2025-01-01T00:04:04Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: false,
      minRuns: 1,
      export: true,
    );
    expect(result.lines.length, 2);
    final exportLine = jsonDecode(result.lines[1]) as Map<String, dynamic>;
    expect(exportLine['event'], 'PHASE1_EXPORT');
    final runs = exportLine['runs'] as List;
    expect(runs.length, 1);
    final run = runs.first as Map<String, dynamic>;
    expect(run['correct_count'], 0);
    expect(run['incorrect_count'], 2);
    expect(run['decision_time_ms_min'], isNull);
    expect(run['decision_time_ms_p50'], isNull);
    expect(run['decision_time_ms_p90'], isNull);
    expect(run['decision_time_ms_mean'], isNull);
  });
}
