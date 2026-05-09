import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('worlds 0-4 telemetry audit scans the live runner emission owner', () {
    final audit = File(
      'tools/audit_worlds_0_4_telemetry_v1.dart',
    ).readAsStringSync();

    expect(
      audit,
      contains(
        "lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart",
      ),
    );
    expect(
      audit,
      isNot(
        contains(
          "lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart",
        ),
      ),
    );
  });

  test('worlds 0-4 telemetry audit passes on current main', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/audit_worlds_0_4_telemetry_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';

    expect(result.exitCode, 0, reason: combined);
    expect(combined, contains('TELEMETRY_OK'), reason: combined);
    expect(combined, isNot(contains('MISSING_TELEMETRY')), reason: combined);
  });
}
