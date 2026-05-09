import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('phase4 inset guard exits cleanly', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/phase4_regression_inset_guard.dart',
    ], runInShell: true);

    expect(result.exitCode, 0, reason: result.stderr);
    final stdoutText = result.stdout is String ? result.stdout as String : '';
    expect(
      stdoutText.contains('REGRESSION_INSET_GUARD'),
      isTrue,
      reason: stdoutText,
    );
    expect(stdoutText.contains('"result":"pass"'), isTrue, reason: stdoutText);
  });
}
