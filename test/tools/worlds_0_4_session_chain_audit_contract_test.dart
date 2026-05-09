import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'worlds 0-4 session-chain audit encodes extended world2/world3 spines',
    () {
      final audit = File(
        'tools/audit_worlds_0_4_session_chain_v1.dart',
      ).readAsStringSync();

      expect(audit, contains('worldId == 2 || worldId == 3'));
      expect(audit, contains('14,'));
      expect(audit, contains('if (step == 14)'));
    },
  );

  test('worlds 0-4 session-chain audit passes on current main', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/audit_worlds_0_4_session_chain_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';

    expect(result.exitCode, 0, reason: combined);
    expect(combined, contains('SESSION_CHAIN_OK'), reason: combined);
    expect(combined, isNot(contains('SESSION_CHAIN_BROKEN')), reason: combined);
  });
}
