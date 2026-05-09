class TelemetryEvent {
  TelemetryEvent(this.name, Map<String, dynamic> payload)
    : payload = Map<String, dynamic>.from(payload);

  final String name;
  final Map<String, dynamic> payload;
}

class TelemetryTestHarness {
  final List<TelemetryEvent> _events = [];

  Future<void> logEvent(String name, [Map<String, dynamic>? payload]) async {
    _events.add(TelemetryEvent(name, payload == null ? {} : Map.of(payload)));
  }

  List<TelemetryEvent> eventsByName(String name) =>
      _events.where((e) => e.name == name).toList(growable: false);

  bool hasEvent(String name) => eventsByName(name).isNotEmpty;

  Map<String, int> counts() {
    final map = <String, int>{};
    for (final event in _events) {
      map.update(event.name, (value) => value + 1, ifAbsent: () => 1);
    }
    return map;
  }
}
