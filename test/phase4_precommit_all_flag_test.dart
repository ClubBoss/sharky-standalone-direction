import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Future<String> _emitLogAndGetPath() async {
  final emit = await Process.run('dart', [
    'run',
    'tools/phase4_emit_sample_logs.dart',
  ], runInShell: true);
  expect(emit.exitCode, 0, reason: emit.stderr);
  final output = emit.stdout is String ? emit.stdout as String : '';
  final decoded = jsonDecode(output) as Map<String, dynamic>;
  final path = decoded['output'] as String?;
  expect(path, isNotNull);
  expect(File(path!).existsSync(), isTrue);
  return path;
}

Future<ProcessResult> _runPrecommit(Map<String, String> env) async {
  final mergedEnv = <String, String>{...Platform.environment, ...env};
  return await Process.run(
    'bash',
    ['tool/dev/precommit_sanity.sh'],
    runInShell: true,
    environment: mergedEnv,
  );
}

Map<String, dynamic>? _parseSummary(String stdoutText) {
  for (final line in stdoutText.split('\n')) {
    if (line.contains('REGRESSION_PHASE4_SUMMARY')) {
      return jsonDecode(line) as Map<String, dynamic>;
    }
  }
  return null;
}

void main() {
  test(
    'RUN_PHASE4_ALL emits summary and respects explicit skips',
    () async {
      final logPath = await _emitLogAndGetPath();

      final resultAll = await _runPrecommit({
        'RUN_PHASE4_ALL': '1',
        'PHASE4_LOG_INPUT': logPath,
      });
      expect(resultAll.exitCode, 0, reason: resultAll.stderr);
      final summaryAll = _parseSummary(resultAll.stdout as String);
      expect(summaryAll, isNotNull);
      _assertSummaryStatuses(summaryAll!);

      final resultSkip = await _runPrecommit({
        'RUN_PHASE4_ALL': '1',
        'RUN_PHASE4_REGRESSION_LOGS': '0',
        'PHASE4_LOG_INPUT': logPath,
      });
      expect(resultSkip.exitCode, 0, reason: resultSkip.stderr);
      final summarySkip = _parseSummary(resultSkip.stdout as String);
      expect(summarySkip, isNotNull);
      _assertSummaryStatuses(summarySkip!);
      expect(summarySkip['logs'], 'skip');
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

void _assertSummaryStatuses(Map<String, dynamic> summary) {
  const allowedStatuses = {'pass', 'skip', 'fail'};
  const keys = [
    'stub',
    'logs',
    'log_tests',
    'inset_guard',
    'inset_guard_tests',
  ];
  for (final key in keys) {
    expect(summary.containsKey(key), isTrue, reason: 'Missing $key');
    final value = summary[key];
    expect(value, isA<String>());
    expect(
      allowedStatuses,
      contains(value),
      reason: 'Unexpected value for $key: $value',
    );
  }
}
