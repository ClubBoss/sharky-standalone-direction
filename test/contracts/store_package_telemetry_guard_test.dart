import 'dart:io';

import 'package:test/test.dart';
import 'package:poker_analyzer/constants/telemetry_events.dart';

void main() {
  test('release telemetry events are referenced in code', () {
    final releaseEvents = TelemetryEvents.releaseCriticalMap;

    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    final missing = <String, String>{};
    for (final entry in releaseEvents.entries) {
      final found = dartFiles.any((file) {
        final contents = file.readAsStringSync();
        return contents.contains(entry.value) ||
            contents.contains('TelemetryEvents.${entry.key}');
      });
      if (!found) {
        missing[entry.key] = entry.value;
      }
    }

    if (missing.isNotEmpty) {
      final buffer = StringBuffer()
        ..writeln('Telemetry guard failed; missing release-critical events:')
        ..writeln(
          missing.entries
              .map((e) => '- ${e.key} (${e.value}) not referenced')
              .join('\n'),
        )
        ..writeln(
          'Please reference ${missing.length} event(s) before release.',
        );
      fail(buffer.toString());
    }
  });
}
