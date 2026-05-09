import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/services/ai_autotuner_service.dart';

Future<void> main(List<String> args) async {
  final service = AiAutotunerService();
  final start = DateTime.now();
  final result = await service.runCycle();
  final durationMs = DateTime.now().difference(start).inMilliseconds;
  result.printSummary();
  await _emitTelemetry(result, durationMs);
  if (!result.success) {
    stdout.writeln('WARN: No AI autotune adjustments applied.');
  }
}

Future<void> _emitTelemetry(AutotuneResult result, int durationMs) async {
  final adjustments = <String, double>{};
  result.adjustments.forEach((key, value) {
    adjustments[key] = double.parse(value.toStringAsFixed(6));
  });
  final payload = <String, Object>{
    'event': TelemetryEvents.aiAutotunerCycleCompleted,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'duration_ms': durationMs,
    'sessions': result.sessions,
    'warnings': result.warnings,
    'success': result.success,
    'adjustments_applied': adjustments.length,
    'adjustments': adjustments,
  };
  final log = File('release/_reports/telemetry.jsonl');
  await log.parent.create(recursive: true);
  final line = '${jsonEncode(payload)}\n';
  await log.writeAsString(line, mode: FileMode.append, flush: true);
  stdout.write(line);
}
