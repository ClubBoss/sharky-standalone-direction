import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('release dry run runner documented', () {
    final rules = File('docs/EXECUTION_RULES.md');
    final script = File('tool/release_dry_run_gate.sh');
    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }

    final content = rules.readAsStringSync();
    final heading = 'Release Dry-Run Gate';
    final runnerPath = 'tool/release_dry_run_gate.sh';
    final preferredNote = 'Preferred tooling';
    final scriptContent = script.existsSync() ? script.readAsStringSync() : '';

    final missing = <String>[];
    if (!content.contains(heading)) missing.add('section header "$heading"');
    if (!content.contains(runnerPath)) missing.add('runner path "$runnerPath"');
    if (!content.contains(preferredNote))
      missing.add('note that the tool is preferred locally');
    if (!script.existsSync()) missing.add('script file "$runnerPath"');
    if (!scriptContent.contains('STORE_PACKAGE_GUARD=1')) {
      missing.add('script must set STORE_PACKAGE_GUARD=1');
    }
    if (!scriptContent.contains('RELEASE_CONTENT_GUARD=1')) {
      missing.add('script must set RELEASE_CONTENT_GUARD=1');
    }
    if (!scriptContent.contains('set -euo pipefail')) {
      missing.add('script must enable "set -euo pipefail"');
    }

    const steps = <String>[
      'store_package_assets_contract_test.dart',
      'store_package_docs_sync_contract_test.dart',
      'store_package_execution_rules_sync_contract_test.dart',
      'store_package_telemetry_guard_test.dart',
      'release_content_meaningful_contract_test.dart',
    ];
    final indices = <int>[];
    for (final step in steps) {
      indices.add(scriptContent.indexOf(step));
      if (!scriptContent.contains(step)) {
        missing.add('script missing step: $step');
      }
    }
    for (var i = 1; i < indices.length; i++) {
      if (indices[i - 1] >= 0 &&
          indices[i] >= 0 &&
          indices[i] <= indices[i - 1]) {
        missing.add(
          'script steps out of order: ${steps[i - 1]} before ${steps[i]}',
        );
      }
    }

    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln(
          'Release dry run runner docs contract failed: update EXECUTION_RULES.md.',
        )
        ..writeln(missing.map((line) => '- $line').join('\n'));
      fail(buffer.toString());
    }
  });
}
