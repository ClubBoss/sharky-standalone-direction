import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('release dry run gate script has portable header', () {
    final script = File('tool/release_dry_run_gate.sh');
    if (!script.existsSync()) {
      fail(
        'Missing release dry run gate script at tool/release_dry_run_gate.sh',
      );
    }
    final lines = script.readAsLinesSync();
    if (lines.isEmpty) {
      fail('Release gate script is empty; expected shebang and flags.');
    }
    final shebang = '#!/usr/bin/env bash';
    if (lines.first.trim() != shebang) {
      fail('Shebang mismatch: expected "$shebang" but found "${lines.first}".');
    }
    final body = script.readAsStringSync();
    if (!body.contains('set -euo pipefail')) {
      fail('Script must include "set -euo pipefail" for portability.');
    }
  });
}
