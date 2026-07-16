import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

void main() {
  test('canonical HNP policy is opt-in and never active in release mode', () {
    expect(
      act0CanonicalTelemetrySinkV1(hnpEnabled: false, isReleaseMode: false),
      isNull,
    );
    expect(
      act0CanonicalTelemetrySinkV1(hnpEnabled: true, isReleaseMode: true),
      isNull,
    );
    expect(
      act0CanonicalTelemetrySinkV1(hnpEnabled: true, isReleaseMode: false),
      isA<Act0HnpTelemetrySinkV1>(),
    );
  });

  test('local HNP export is ordered, bounded, and structured', () {
    final sink = Act0HnpTelemetrySinkV1(maxEvents: 2);
    sink.record(
      const Act0TelemetryEventV1(
        name: 'task_shown',
        fields: <String, Object?>{},
      ),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'user_choice',
        fields: <String, Object?>{'choiceId': 'fold'},
      ),
    );
    sink.record(
      const Act0TelemetryEventV1(
        name: 'task_result',
        fields: <String, Object?>{'result': 'incorrect'},
      ),
    );

    final trace = jsonDecode(sink.exportJson()) as Map<String, dynamic>;
    expect(trace['schema'], 'act0_hnp_local_trace_v1');
    expect(trace['events'].map((event) => event['name']).toList(), <String>[
      'user_choice',
      'task_result',
    ]);
  });
}
