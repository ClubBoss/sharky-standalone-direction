import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

class Act0TelemetryEventV1 {
  const Act0TelemetryEventV1({required this.name, required this.fields});

  final String name;
  final Map<String, Object?> fields;
}

abstract class Act0TelemetrySinkV1 {
  void record(Act0TelemetryEventV1 event);
}

class Act0InMemoryTelemetrySinkV1 implements Act0TelemetrySinkV1 {
  final List<Act0TelemetryEventV1> events = <Act0TelemetryEventV1>[];

  @override
  void record(Act0TelemetryEventV1 event) {
    events.add(event);
  }
}

/// Local-only, bounded Human Novice Proof collector.
///
/// It intentionally writes structured rows only to the debug console.  The
/// app never transmits, persists, or identifies a participant; the person
/// running a proof session enables it with `--dart-define=HNP_TELEMETRY=true`
/// and captures the resulting `HNP_TRACE_V1` rows locally.
class Act0HnpTelemetrySinkV1 extends Act0InMemoryTelemetrySinkV1 {
  Act0HnpTelemetrySinkV1({this.maxEvents = 256});

  final int maxEvents;

  @override
  void record(Act0TelemetryEventV1 event) {
    if (events.length == maxEvents) {
      events.removeAt(0);
    }
    super.record(event);
    debugPrint(
      'HNP_TRACE_V1 ${jsonEncode(<String, Object?>{'name': event.name, 'fields': event.fields})}',
    );
  }

  String exportJson() => jsonEncode(<String, Object?>{
    'schema': 'act0_hnp_local_trace_v1',
    'events': events
        .map(
          (event) => <String, Object?>{
            'name': event.name,
            'fields': event.fields,
          },
        )
        .toList(growable: false),
  });
}

/// The one canonical-entry policy: HNP capture is debug-only and opt-in.
Act0TelemetrySinkV1? act0CanonicalTelemetrySinkV1({
  required bool hnpEnabled,
  required bool isReleaseMode,
}) => hnpEnabled && !isReleaseMode ? Act0HnpTelemetrySinkV1() : null;
