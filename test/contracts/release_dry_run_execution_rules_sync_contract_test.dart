import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('release dry run gate documented in execution rules', () {
    final rules = File('docs/EXECUTION_RULES.md');
    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }
    final content = rules.readAsStringSync();
    final section = 'Release Dry-Run Gate';
    final commandLines = [
      'STORE_PACKAGE_GUARD=1 dart test test/contracts/store_package_assets_contract_test.dart',
      'dart test test/contracts/store_package_docs_sync_contract_test.dart',
      'dart test test/contracts/store_package_execution_rules_sync_contract_test.dart',
      'dart test test/contracts/store_package_telemetry_guard_test.dart',
      'RELEASE_CONTENT_GUARD=1 dart test test/contracts/release_content_meaningful_contract_test.dart',
    ];

    final missing = <String>[];
    if (!content.contains(section)) {
      missing.add('section header "$section"');
    }
    if (!content.contains('STORE_PACKAGE_GUARD=1')) {
      missing.add('STORE_PACKAGE_GUARD=1 mention');
    }
    if (!content.contains('RELEASE_CONTENT_GUARD=1')) {
      missing.add('RELEASE_CONTENT_GUARD=1 mention');
    }
    for (final command in commandLines) {
      if (!content.contains(command)) {
        missing.add('command snippet: $command');
      }
    }

    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln(
          'Dry run guard contract failed: update docs/EXECUTION_RULES.md with the dry run gate details.',
        )
        ..writeln(missing.map((line) => '- $line').join('\n'));
      fail(buffer.toString());
    }
  });
}
