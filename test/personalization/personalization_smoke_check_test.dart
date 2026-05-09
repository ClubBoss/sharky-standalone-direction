import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

String _encode(Map<String, Object?> payload) => jsonEncode(payload);

Future<ProcessResult> _run(String jsonPayload) {
  return Process.run('dart', [
    'run',
    'tool/dev/personalization_smoke_check.dart',
    '--json',
    jsonPayload,
  ]);
}

void main() {
  test('routable action returns OK', () async {
    final payload = _encode({
      'schema': 'personalization_next_action_v1',
      'next_action': 'run_phase2',
      'reason': 'test',
    });
    final result = await _run(payload);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('OK: next_action=run_phase2'));
  });

  test('idle action returns NOTE', () async {
    final payload = _encode({
      'schema': 'personalization_next_action_v1',
      'next_action': 'idle',
      'reason': 'chill',
    });
    final result = await _run(payload);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('NOTE: idle action'));
  });

  test('unknown action errors out', () async {
    final payload = _encode({
      'schema': 'personalization_next_action_v1',
      'next_action': 'zap',
      'reason': 'unknown',
    });
    final result = await _run(payload);
    expect(result.exitCode, 2);
    expect(result.stderr, contains('ERROR: next_action=zap is not routable'));
  });

  test('invalid json reports error', () async {
    final result = await _run('not-json');
    expect(result.exitCode, 2);
    expect(result.stderr, contains('invalid JSON payload'));
  });
}
