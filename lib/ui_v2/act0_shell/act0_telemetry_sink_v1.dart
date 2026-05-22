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
