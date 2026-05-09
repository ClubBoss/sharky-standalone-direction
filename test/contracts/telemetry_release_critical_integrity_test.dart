import 'package:test/test.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';

void main() {
  test('release-critical telemetry events are registered in SSOT', () {
    final registered = Set<String>.from(TelemetryEvents.all);
    final missing = <String>[];
    for (final entry in TelemetryEvents.releaseCriticalMap.entries) {
      if (!registered.contains(entry.value)) {
        missing.add('${entry.key} (${entry.value})');
      }
    }
    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Telemetry release-critical integrity failed:')
        ..writeln(missing.map((e) => '- $e').join('\n'))
        ..writeln('Register these names in TelemetryEvents SSOT.');
      fail(buffer.toString());
    }
  });
}
