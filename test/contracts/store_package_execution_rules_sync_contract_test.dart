import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('execution rules mention Store Package guard', () {
    final rules = File('docs/EXECUTION_RULES.md');
    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }

    final content = rules.readAsStringSync();
    final containsGuard = content.contains('STORE_PACKAGE_GUARD=1');
    final containsCommand = content.contains(
      'STORE_PACKAGE_GUARD=1 dart test test/contracts/store_package_assets_contract_test.dart',
    );
    final mentionsSkipEnforce =
        content.contains('store_package_assets_contract_test.dart') ||
        (content.contains('out/modern_table_screenshots_v1.zip') &&
            content.contains('skip') &&
            content.contains('enforce'));

    if (!containsGuard || !containsCommand || !mentionsSkipEnforce) {
      final buffer = StringBuffer()
        ..writeln('Execution rules contract failed:')
        ..writeln(
          'Update EXECUTION_RULES.md: add Store Package guard command + off-by-default note.',
        );
      if (!containsGuard)
        buffer.writeln('- Missing STORE_PACKAGE_GUARD=1 mention.');
      if (!containsCommand) {
        buffer.writeln(
          '- Missing example command with STORE_PACKAGE_GUARD=1 + dart test + store_package_assets_contract_test.dart.',
        );
      }
      if (!mentionsSkipEnforce) {
        buffer.writeln(
          '- Missing skip/enforce wording around out/modern_table_screenshots_v1.zip.',
        );
      }
      fail(buffer.toString());
    }
  });
}
