import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/constants/telemetry_schema.dart';

Future<void> main(List<String> args) async {
  final validator = _TelemetrySchemaValidator();
  final report = validator.run();
  report.printReport();
  if (report.isPass) {
    _emitTelemetry(report);
    return;
  }
  exitCode = 1;
}

void _emitTelemetry(_ValidationReport report) {
  final payload = <String, Object>{
    'event': TelemetryEvents.marketingPrepCompleted,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'total_events': report.totalEvents,
    'unknown_events': report.unknownEvents.length,
    'success': true,
  };
  stdout.writeln(jsonEncode(payload));
}

class _TelemetrySchemaValidator {
  _ValidationReport run() {
    final telemetryFile = File('release/_reports/telemetry.json');
    if (!telemetryFile.existsSync()) {
      return _ValidationReport(
        totalEvents: 0,
        unknownEvents: const ['missing release/_reports/telemetry.json'],
      );
    }

    Map<String, dynamic> events = const {};
    try {
      final decoded = jsonDecode(telemetryFile.readAsStringSync());
      final rawEvents = decoded is Map<String, dynamic>
          ? decoded['events']
          : {};
      if (rawEvents is Map<String, dynamic>) {
        events = rawEvents;
      }
    } catch (error) {
      return _ValidationReport(
        totalEvents: 0,
        unknownEvents: ['telemetry.json parse error: $error'],
      );
    }

    final schema = TelemetrySchema.byId;
    final unknown = <String>[];
    events.forEach((eventName, rawValue) {
      final declared =
          rawValue is Map<String, dynamic> && rawValue['declared'] == true;
      if (!declared) {
        return;
      }
      if (!schema.containsKey(eventName)) {
        unknown.add(eventName);
      }
    });

    return _ValidationReport(
      totalEvents: events.length,
      unknownEvents: unknown..sort(),
    );
  }
}

class _ValidationReport {
  _ValidationReport({required this.totalEvents, required this.unknownEvents});

  final int totalEvents;
  final List<String> unknownEvents;

  bool get isPass => unknownEvents.isEmpty;

  void printReport() {
    const border = '+----------------------+--------+';
    stdout.writeln(border);
    stdout.writeln('| Metric               | Value  |');
    stdout.writeln(border);
    stdout.writeln('| Total events         | ${_pad(totalEvents)} |');
    stdout.writeln(
      '| Schema definitions   | ${_pad(TelemetrySchema.events.length)} |',
    );
    stdout.writeln('| Undocumented events  | ${_pad(unknownEvents.length)} |');
    stdout.writeln(border);

    if (!isPass) {
      stdout.writeln('Undocumented events:');
      for (final name in unknownEvents) {
        stdout.writeln('- $name');
      }
    } else {
      stdout.writeln('Telemetry schema validation PASSED.');
    }
  }

  String _pad(int value) => value.toString().padLeft(6);
}
