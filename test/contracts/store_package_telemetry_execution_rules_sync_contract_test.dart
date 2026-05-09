import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('execution rules mention Store Package telemetry guard', () {
    final rules = File('docs/EXECUTION_RULES.md');
    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }

    final content = rules.readAsStringSync();
    final containsHeading = content.contains('Store Package telemetry guard');
    final containsPurpose = content.contains(
      'release-critical telemetry references',
    );
    final containsCommand = content.contains(
      'dart test test/contracts/store_package_telemetry_guard_test.dart -r expanded --concurrency=1 --timeout 2m',
    );

    if (!containsHeading || !containsPurpose || !containsCommand) {
      final buffer = StringBuffer()
        ..writeln(
          'Execution rules contract failed: document the Store Package telemetry guard.',
        )
        ..writeln(
          'Ensure the section mentions telemetry protection and the dart test command.',
        );
      if (!containsHeading) buffer.writeln('- Missing section header.');
      if (!containsPurpose)
        buffer.writeln('- Missing telemetry purpose statement.');
      if (!containsCommand) buffer.writeln('- Missing guard command snippet.');
      fail(buffer.toString());
    }
  });
}
