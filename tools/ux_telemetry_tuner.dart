/// UX Telemetry Tuner CLI Tool (Stage Ω3)
///
/// Orchestrates the UxTelemetryTuner service to collect metrics, compute
/// RetentionIndex, adjust UX parameters, and generate reports.
///
/// Usage:
///   dart run tools/ux_telemetry_tuner.dart [--telemetry-path=PATH]
///
/// Outputs:
///   - ASCII report to release/_reports/ux_telemetry_tuning.txt
///   - Telemetry event to release/_reports/telemetry.jsonl
///
/// DoD:
///   - dart run tools/ux_telemetry_tuner.dart creates report and telemetry
///   - Telemetry guard PASS
///   - Analyzer clean

import 'dart:convert';
import 'dart:io';

// Import the service (no Flutter dependency)
import '../lib/services/ux_telemetry_tuner.dart';

Future<void> main(List<String> args) async {
  stdout.writeln('=== UX TELEMETRY TUNER (Stage Ω3) ===');

  // Parse arguments
  String telemetryPath = 'release/_reports/telemetry.jsonl';
  for (final arg in args) {
    if (arg.startsWith('--telemetry-path=')) {
      telemetryPath = arg.substring('--telemetry-path='.length);
    }
  }

  stdout.writeln('[Init] Telemetry source: $telemetryPath');

  // Initialize services
  final collector = UxTelemetryCollector(telemetryFilePath: telemetryPath);
  final tuner = UxTelemetryTuner(
    baselineRetention: 100.0,
    sessionDurationWeight: 1.0,
    accuracyWeight: 1.5,
    xpWeight: 1.2,
  );

  stdout.writeln('[Collect] Gathering metrics...');

  // Collect metrics
  final metrics = await collector.collectMetrics();
  final avgSessionDuration = metrics['avg_session_duration'] as double;
  final avgAccuracy = metrics['avg_accuracy'] as double;
  final avgDailyXp = metrics['avg_daily_xp'] as double;
  final eventCount = metrics['event_count'] as int;

  stdout.writeln('[Metrics] Collected $eventCount events');
  stdout.writeln(
    '  - avg_session_duration: ${avgSessionDuration.toStringAsFixed(1)}s',
  );
  stdout.writeln(
    '  - avg_accuracy: ${(avgAccuracy * 100).toStringAsFixed(1)}%',
  );
  stdout.writeln('  - avg_daily_xp: ${avgDailyXp.toStringAsFixed(0)}');

  // Compute RetentionIndex
  stdout.writeln('[Compute] Calculating RetentionIndex...');
  final retentionIndex = tuner.computeRetentionIndex(
    avgSessionDuration: avgSessionDuration,
    avgAccuracy: avgAccuracy,
    avgDailyXp: avgDailyXp,
  );

  stdout.writeln(
    '[Index] RetentionIndex: ${retentionIndex.toStringAsFixed(2)}',
  );

  // Adjust parameters
  stdout.writeln('[Adjust] Tuning UX parameters...');
  final adjustments = tuner.adjustParameters(retentionIndex);

  stdout.writeln('[Strategy] ${adjustments['strategy']}');
  stdout.writeln('[Reason] ${adjustments['reason']}');
  stdout.writeln('[Parameters]');
  stdout.writeln('  - reward_intensity: ${adjustments['reward_intensity']}');
  stdout.writeln(
    '  - streak_animation_speed: ${adjustments['streak_animation_speed']}',
  );
  stdout.writeln('  - popup_frequency: ${adjustments['popup_frequency']}');

  // Generate adjustment summary
  final adjustmentSummary = tuner.generateAdjustmentSummary(
    retentionIndex,
    adjustments,
  );

  // Write report
  stdout.writeln(
    '[Report] Writing to release/_reports/ux_telemetry_tuning.txt...',
  );
  final reportPath = 'release/_reports/ux_telemetry_tuning.txt';
  await _writeReport(
    reportPath,
    metrics,
    retentionIndex,
    adjustments,
    adjustmentSummary,
  );

  stdout.writeln('[Report] Written to: $reportPath');

  // Emit telemetry
  stdout.writeln('[Telemetry] Emitting ux_telemetry_tuning_completed event...');
  await _emitTelemetry(
    'release/_reports/telemetry.jsonl',
    retentionIndex,
    adjustmentSummary,
    eventCount,
  );

  stdout.writeln('[Telemetry] Event logged: ux_telemetry_tuning_completed');
  stdout.writeln('=== TUNING COMPLETE ===');
}

/// Writes the ASCII report to the specified path
Future<void> _writeReport(
  String reportPath,
  Map<String, dynamic> metrics,
  double retentionIndex,
  Map<String, dynamic> adjustments,
  String adjustmentSummary,
) async {
  final file = File(reportPath);
  file.parent.createSync(recursive: true);

  final buffer = StringBuffer();
  buffer.writeln('=== UX TELEMETRY TUNING REPORT (Stage Ω3) ===');
  buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
  buffer.writeln('');

  buffer.writeln('COLLECTED METRICS:');
  buffer.writeln('  Event count: ${metrics['event_count']}');
  buffer.writeln('  Avg session duration: ${metrics['avg_session_duration']}s');
  buffer.writeln(
    '  Avg accuracy: ${((metrics['avg_accuracy'] as double) * 100).toStringAsFixed(1)}%',
  );
  buffer.writeln('  Avg daily XP: ${metrics['avg_daily_xp']}');
  buffer.writeln('  Collection timestamp: ${metrics['collection_timestamp']}');
  buffer.writeln('');

  buffer.writeln('RETENTION INDEX:');
  buffer.writeln('  Value: ${retentionIndex.toStringAsFixed(2)}');
  buffer.writeln('  Interpretation:');
  if (retentionIndex < 0.7) {
    buffer.writeln('    Status: LOW - Users are disengaging');
    buffer.writeln('    Action: Reduce UX intensity to avoid overwhelm');
  } else if (retentionIndex > 1.3) {
    buffer.writeln('    Status: HIGH - Users are highly engaged');
    buffer.writeln('    Action: Increase UX intensity to maintain momentum');
  } else {
    buffer.writeln('    Status: NORMAL - Users are moderately engaged');
    buffer.writeln('    Action: Maintain default UX parameters');
  }
  buffer.writeln('');

  buffer.writeln('ADJUSTMENT SUMMARY:');
  buffer.writeln(adjustmentSummary);
  buffer.writeln('');

  buffer.writeln('DETAILED ADJUSTMENTS:');
  buffer.writeln('  Strategy: ${adjustments['strategy']}');
  buffer.writeln('  Reason: ${adjustments['reason']}');
  buffer.writeln('  Parameters:');
  buffer.writeln('    - reward_intensity: ${adjustments['reward_intensity']}');
  buffer.writeln(
    '    - streak_animation_speed: ${adjustments['streak_animation_speed']}',
  );
  buffer.writeln('    - popup_frequency: ${adjustments['popup_frequency']}');
  buffer.writeln('');

  buffer.writeln('RECOMMENDATIONS:');
  if (retentionIndex < 0.7) {
    buffer.writeln('  1. Review onboarding flow for complexity');
    buffer.writeln('  2. Reduce reward popup frequency');
    buffer.writeln('  3. Simplify streak animations');
    buffer.writeln('  4. Consider increasing tutorial hints');
  } else if (retentionIndex > 1.3) {
    buffer.writeln('  1. Introduce advanced challenges');
    buffer.writeln('  2. Increase reward visibility');
    buffer.writeln('  3. Add streak milestones');
    buffer.writeln('  4. Enable social sharing features');
  } else {
    buffer.writeln('  1. Monitor metrics for trend changes');
    buffer.writeln('  2. Maintain current UX balance');
    buffer.writeln('  3. Continue A/B testing new features');
    buffer.writeln('  4. Collect qualitative feedback');
  }
  buffer.writeln('');

  buffer.writeln('=== END OF REPORT ===');

  await file.writeAsString(buffer.toString(), flush: true);
}

/// Emits telemetry event to JSONL file
Future<void> _emitTelemetry(
  String telemetryPath,
  double retentionIndex,
  String adjustmentSummary,
  int eventCount,
) async {
  final file = File(telemetryPath);
  file.parent.createSync(recursive: true);

  final event = {
    'event': 'ux_telemetry_tuning_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'retentionIndex': double.parse(retentionIndex.toStringAsFixed(2)),
    'adjustmentSummary': adjustmentSummary.replaceAll('\n', ' | '),
    'eventCount': eventCount,
    'passStatus': 'PASS',
  };

  final line = '${jsonEncode(event)}\n';
  await file.writeAsString(line, mode: FileMode.append, flush: true);
}
