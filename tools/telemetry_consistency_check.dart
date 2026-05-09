import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

const int _expectedEventCount = 79;

Future<void> main(List<String> args) async {
  final file = File('release/_reports/telemetry.json');
  if (!await file.exists()) {
    stdout.writeln('Missing release/_reports/telemetry.json');
    exit(1);
  }

  Map<String, dynamic> events;
  try {
    final decoded = jsonDecode(await file.readAsString());
    final rawEvents = decoded['events'];
    if (decoded is! Map || rawEvents is! Map) {
      stdout.writeln('Telemetry report malformed.');
      exit(1);
    }
    events = Map<String, dynamic>.from(rawEvents);
  } catch (error) {
    stdout.writeln('Failed to parse telemetry report: $error');
    exit(1);
  }

  final missingDeclarations = <String>[];
  events.forEach((name, value) {
    final entry = value is Map<String, dynamic>
        ? value
        : const <String, dynamic>{};
    final declared = entry['declared'] == true;
    if (!declared) {
      missingDeclarations.add(name);
    }
  });

  stdout.writeln('Telemetry Consistency Report');
  stdout.writeln('============================');
  stdout.writeln('Events observed  : ${events.length}');
  stdout.writeln('Expected events  : $_expectedEventCount');
  stdout.writeln('Undeclared events: ${missingDeclarations.length}');

  if (missingDeclarations.isNotEmpty) {
    stdout.writeln('\nUndeclared events:');
    for (final name in missingDeclarations..sort()) {
      stdout.writeln('- $name');
    }
  }

  final success = events.length == _expectedEventCount;
  _emitTelemetry(
    total: events.length,
    missing: missingDeclarations.length,
    success: success,
  );

  if (!success) {
    exit(1);
  }
}

void _emitTelemetry({
  required int total,
  required int missing,
  required bool success,
}) {
  final payload = <String, Object>{
    'event': TelemetryEvents.telemetryConsistencyCompleted,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'total_events': total,
    'missing_declarations': missing,
    'success': success,
  };
  stdout.writeln(jsonEncode(payload));
}
