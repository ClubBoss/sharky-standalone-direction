import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production-real runner capture resolves direct live task seeds', () {
    final source = File(
      'tools/act0_production_real_runner_capture_v1.dart',
    ).readAsStringSync();
    expect(source, contains('Act0ShellStateV1.sample direct task resolution'));
    expect(source, contains("'positions_early_late'"));
    expect(source, contains("'what_poker_is_table_read_recheck'"));
    expect(source, contains("'content_status': 'LIVE_PRODUCTION'"));
    expect(source, isNot(contains('placementQuickCheckRunnerV1')));
    expect(source, contains("'tall_phone': Size(402, 874)"));
  });
}
