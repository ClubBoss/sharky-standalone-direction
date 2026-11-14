// Pure owner-reader checks only. These do not exercise the record/cache,
// widget/native path or real elapsed learning/retention.
import 'dart:convert';
import 'dart:io';

import '../lib/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';

class _LooksLikeTime {
  @override
  String toString() => '2026-11-14T12:30:00.000Z';
}

void main() {
  var passed = 0;
  var failed = 0;
  void check(bool condition, String name) {
    if (condition) {
      passed += 1;
    } else {
      failed += 1;
      stderr.writeln('FAIL $name');
    }
  }

  final invalid = <Object?>[
    null,
    true,
    false,
    20261114,
    2026.1114,
    <String, Object?>{},
    <Object?>[],
    _LooksLikeTime(),
    '',
    'not a date',
    '20261114',
    '2026-11-14',
    '2026-11-14T12:30:00',
    '2026-00-01T00:00:00Z',
    '2026-13-01T00:00:00Z',
    '2026-01-00T00:00:00Z',
    '2026-01-32T00:00:00Z',
    '2026-02-29T00:00:00Z',
    '2026-02-31T00:00:00Z',
    '2026-04-31T00:00:00Z',
    '2026-11-14T24:00:00Z',
    '2026-11-14T25:00:00Z',
    '2026-11-14T00:60:00Z',
    '2026-11-14T00:00:60Z',
    '2026-11-14T00:00:00+24:00',
    '2026-11-14T00:00:00+04:60',
    '2026-11-14T00:00:00-99:99',
    '2026-11-14T00:00:00.1234567Z',
    '2026-11-14T00:00:00Z extra',
  ];
  for (var i = 0; i < invalid.length; i += 1) {
    check(act0TryParseUtcV1(invalid[i]) == null, 'invalid input $i');
  }
  final dates = [
    DateTime.utc(2026, 11, 14, 12, 30),
    DateTime.utc(2026, 11, 14, 12, 30, 1, 123, 456),
    DateTime.utc(2024, 2, 29, 23, 59, 59, 999, 999),
    DateTime.utc(2000, 2, 29),
    DateTime.utc(0, 1, 1),
    DateTime.utc(-1, 1, 1),
    DateTime.utc(10000, 1, 1),
    DateTime.fromMicrosecondsSinceEpoch(8640000000000000000, isUtc: true),
    DateTime.fromMicrosecondsSinceEpoch(-8640000000000000000, isUtc: true),
  ];
  for (final date in dates) {
    final parsed = act0TryParseUtcV1(act0UtcStorageStringV1(date));
    check(parsed == date && parsed!.isUtc, 'writer round trip $date');
  }
  final equivalent = <String, DateTime>{
    '2026-11-14T16:30:00+04:00': DateTime.utc(2026, 11, 14, 12, 30),
    '2026-11-14T09:00:00-03:30': DateTime.utc(2026, 11, 14, 12, 30),
    '2026-11-14T16:30:00+0400': DateTime.utc(2026, 11, 14, 12, 30),
    '2026-01-01T00:30:00+01:00': DateTime.utc(2025, 12, 31, 23, 30),
    '2025-12-31T23:30:00-01:00': DateTime.utc(2026, 1, 1, 0, 30),
    '2024-03-01T00:30:00+01:00': DateTime.utc(2024, 2, 29, 23, 30),
    '2026-11-14t12:30:00z': DateTime.utc(2026, 11, 14, 12, 30),
    ' 2026-11-14T12:30:00.1Z ': DateTime.utc(2026, 11, 14, 12, 30, 0, 100),
  };
  for (final entry in equivalent.entries) {
    check(
      act0TryParseUtcV1(entry.key) == entry.value,
      'offset/precision ${entry.key}',
    );
  }
  check(
    Act0DurableLearningTimingV1.recoveryToFirstReview ==
        const Duration(hours: 24),
    '24h threshold unchanged',
  );
  check(
    Act0DurableLearningTimingV1.firstToSecondReview ==
        const Duration(hours: 72),
    '72h threshold unchanged',
  );
  check(
    Act0DurableLearningTimingV1.durableMaintenance == const Duration(days: 7),
    '7d threshold unchanged',
  );
  stdout.writeln(
    jsonEncode({
      'scope': 'pure timestamp reader; no consumer/runtime/Human proof',
      'passed': passed,
      'failed': failed,
      'total': passed + failed,
    }),
  );
  if (failed != 0) exitCode = 1;
}
