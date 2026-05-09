import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('operational review packet owner and runner stay documented', () {
    final rules = File('docs/EXECUTION_RULES.md');
    final owner = File('docs/release/operational_review_packet_truth_v1.md');
    final runner = File('tools/operational_review_packet_v1.dart');

    if (!rules.existsSync()) {
      fail('Missing docs/EXECUTION_RULES.md');
    }

    final content = rules.readAsStringSync();
    final missing = <String>[];

    if (!content.contains('Operational Review Packet')) {
      missing.add('missing Operational Review Packet section header');
    }
    if (!content.contains(
      'docs/release/operational_review_packet_truth_v1.md',
    )) {
      missing.add('missing operational review packet owner path');
    }
    if (!content.contains('tools/operational_review_packet_v1.dart')) {
      missing.add('missing operational review packet runner path');
    }
    if (!content.contains('bounded local operational review artifact')) {
      missing.add('missing bounded review packet note');
    }
    if (!owner.existsSync()) {
      missing.add('missing docs/release/operational_review_packet_truth_v1.md');
    }
    if (!runner.existsSync()) {
      missing.add('missing tools/operational_review_packet_v1.dart');
    }

    if (missing.isNotEmpty) {
      fail(missing.map((m) => '- $m').join('\n'));
    }
  });
}
