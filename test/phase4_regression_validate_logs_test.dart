import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('phase4 regression log validator accepts sample fixture', () {
    final fixture = File('test/fixtures/phase_logs/phase123_sample.txt');
    expect(fixture.existsSync(), isTrue, reason: 'fixture exists');

    final result = Process.runSync('dart', [
      'run',
      'tools/phase4_regression_validate_logs.dart',
      '--input',
      fixture.path,
    ]);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    final stdout = result.stdout.toString();
    expect(stdout, contains('REGRESSION_PHASE4_LOG_CONTRACT'));
    expect(stdout, contains('"result":"pass"'));
  });
}
