import 'dart:convert';

import 'package:test/test.dart';
// ignore: unused_import
import 'package:poker_analyzer/ui/flutter_stub_test.dart'
    if (dart.library.ui) 'package:flutter/material.dart';
import 'package:poker_analyzer/infra/telemetry_builder.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart'
    if (dart.library.ui) 'package:poker_analyzer/ui/telemetry_test_harness_flutter.dart';

void main() {
  group('Telemetry consistency', () {
    test('captures telemetry suite and remains JSON friendly', () async {
      final telemetry = TelemetryTestHarness();
      await telemetry.logEvent('session_start', {'sessionId': 's-1'});
      await telemetry.logEvent('session_end', {'sessionId': 's-1'});
      await telemetry.logEvent('session_abort', {
        'sessionId': 's-1',
        'reason': 'network',
      });

      for (final name in ['session_start', 'session_end', 'session_abort']) {
        final events = telemetry.eventsByName(name);
        expect(events, isNotEmpty, reason: '$name should be logged');
        expect(
          events.first.payload,
          isNotEmpty,
          reason: '$name should have payload',
        );
      }
      await telemetry.logEvent('export_l3_errors_file', {
        'status': 'ok',
        'count': 3,
      });
      await telemetry.logEvent('export_l3_errors_failed', {
        'status': 'error',
        'message': 'network',
      });
      await telemetry.logEvent('import_confirm_result', {
        'status': 'success',
        'imported': 12,
      });

      final expectations = {
        'export_l3_errors_file': ['status', 'count'],
        'export_l3_errors_failed': ['status', 'message'],
        'import_confirm_result': ['status', 'imported'],
      };

      expectations.forEach((event, keys) {
        final logged = telemetry.eventsByName(event);
        expect(logged, isNotEmpty, reason: '$event should be logged');
        final payload = logged.first.payload;
        for (final key in keys) {
          expect(
            payload.containsKey(key),
            isTrue,
            reason: '$event missing $key',
          );
        }
      });
      final map = buildTelemetry(
        sessionId: 's-42',
        packId: 'pack-1',
        data: {'accuracy': 0.82, 'notes': 'ok'},
      );

      expect(map['sessionId'], equals('s-42'));
      expect(map['packId'], equals('pack-1'));
      expect(
        () => jsonEncode(map),
        returnsNormally,
        reason: 'Map must be JSON serializable',
      );
    });
  });
}
