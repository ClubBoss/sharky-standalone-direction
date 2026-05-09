import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

class _SummarizerResult {
  final int exitCode;
  final Map<String, dynamic> summary;

  _SummarizerResult(this.exitCode, this.summary);
}

Future<_SummarizerResult> _runSummarizer(
  String content, {
  required bool failOnMissing,
  required int minRuns,
}) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'phase3_summarizer_test_',
  );
  final temp = File('${tempDir.path}/phase3_summarizer.log');
  temp.writeAsStringSync(content);
  final result = await Process.run('dart', [
    'tools/phase3_summarize_logs.dart',
    '--input',
    temp.path,
    if (failOnMissing) '--fail_on_missing',
    '--min_runs',
    '$minRuns',
  ]);
  await tempDir.delete(recursive: true);
  final stdoutStr = result.stdout is String ? result.stdout as String : '';
  expect(stdoutStr.contains('"schema":"phase3_summary_v1"'), isTrue);
  expect(stdoutStr.contains('"event":"PHASE3_LOG_SUMMARY"'), isTrue);
  final trimmed = stdoutStr.trim();
  expect(trimmed.isNotEmpty, isTrue);
  final summary = jsonDecode(trimmed) as Map<String, dynamic>;
  return _SummarizerResult(result.exitCode, summary);
}

void main() {
  test('valid run satisfies strict gate', () async {
    final content = '''
flutter: PHASE3_RETURN_SIGNAL {"run_id":"runA","signal_type":"engagement_return","timestamp":"2025-12-31T00:00:00Z"}
flutter: PHASE3_FLOW_END {"run_id":"runA","result":"signaled","timestamp":"2025-12-31T00:00:05Z"}
flutter: PHASE3_RETURN_CTA_SHOWN
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 0);
    expect(result.summary['cta_shown_count'], 1);
    expect(result.summary['cta_tapped_count'], 0);
    final latency =
        result.summary['cta_tap_latency_ms'] as Map<String, dynamic>;
    expect(latency['min'], null);
    expect(latency['mean'], null);
  });

  test('zero CTA counts appear when no markers emitted', () async {
    final content = '''
flutter: PHASE3_RETURN_SIGNAL {"run_id":"runZero","signal_type":"engagement_return","timestamp":"2025-12-31T00:03:00Z"}
flutter: PHASE3_FLOW_END {"run_id":"runZero","result":"signaled","timestamp":"2025-12-31T00:03:05Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 0);
    expect(result.summary['cta_shown_count'], 0);
    expect(result.summary['cta_tapped_count'], 0);
    final latency =
        result.summary['cta_tap_latency_ms'] as Map<String, dynamic>;
    expect(latency['min'], null);
    expect(latency['max'], null);
    expect(latency['mean'], null);
  });

  test('properly counts tapped marker', () async {
    final content = '''
flutter: PHASE3_RETURN_SIGNAL {"run_id":"runA","signal_type":"engagement_return","timestamp":"2025-12-31T00:00:00Z"}
flutter: PHASE3_FLOW_END {"run_id":"runA","result":"signaled","timestamp":"2025-12-31T00:00:05Z"}
flutter: PHASE3_RETURN_CTA_SHOWN
flutter: PHASE3_RETURN_CTA_TAPPED
flutter: PHASE3_RETURN_CTA_TAP_LATENCY_MS {"run_id":"runA","duration_ms":7,"timestamp":"2025-12-31T00:00:06Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 0);
    expect(result.summary['cta_shown_count'], 1);
    expect(result.summary['cta_tapped_count'], 1);
    final latency =
        result.summary['cta_tap_latency_ms'] as Map<String, dynamic>;
    expect(latency['min'], 7);
    expect(latency['max'], 7);
    expect(latency['p50'], 7);
    expect(latency['p90'], 7);
    expect(latency['mean'], 7);
  });

  test('aggregates latency statistics', () async {
    final content = '''
flutter: PHASE3_RETURN_SIGNAL {"run_id":"runLatency","signal_type":"engagement_return","timestamp":"2025-12-31T00:10:00Z"}
flutter: PHASE3_FLOW_END {"run_id":"runLatency","result":"signaled","timestamp":"2025-12-31T00:10:05Z"}
flutter: PHASE3_RETURN_CTA_SHOWN
flutter: PHASE3_RETURN_CTA_TAP_LATENCY_MS {"run_id":"runLatency","duration_ms":5,"timestamp":"2025-12-31T00:10:06Z"}
flutter: PHASE3_RETURN_CTA_TAP_LATENCY_MS {"run_id":"runLatency","duration_ms":20,"timestamp":"2025-12-31T00:10:07Z"}
flutter: PHASE3_RETURN_CTA_TAP_LATENCY_MS {"run_id":"runLatency","duration_ms":50,"timestamp":"2025-12-31T00:10:08Z"}
flutter: PHASE3_RETURN_CTA_TAPPED
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 0);
    final latency =
        result.summary['cta_tap_latency_ms'] as Map<String, dynamic>;
    expect(latency['min'], 5);
    expect(latency['max'], 50);
    expect(latency['p50'], 20);
    expect(latency['p90'], 50);
    expect(latency['mean'], closeTo(25, 0.001));
  });

  test('missing flow end triggers failure', () async {
    final content = '''
flutter: PHASE3_RETURN_SIGNAL {"run_id":"runB","signal_type":"engagement_return","timestamp":"2025-12-31T00:01:00Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: true,
      minRuns: 1,
    );
    expect(result.exitCode, 2);
  });

  test('enforces higher min_runs', () async {
    final content = '''
flutter: PHASE3_RETURN_SIGNAL {"run_id":"runC","signal_type":"engagement_return","timestamp":"2025-12-31T00:02:00Z"}
flutter: PHASE3_FLOW_END {"run_id":"runC","result":"signaled","timestamp":"2025-12-31T00:02:05Z"}
''';
    final result = await _runSummarizer(
      content,
      failOnMissing: false,
      minRuns: 2,
    );
    expect(result.exitCode, 3);
  });
}
