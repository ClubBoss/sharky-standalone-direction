import 'dart:convert';
import 'dart:io';

void main() {
  final now = DateTime.now().toUtc();
  final timestamp = now.toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
  final runId = 'sample-$timestamp';
  final scenarioId = 'pf_btn_02';
  final filePath = '/tmp/poker_analyzer_phase_logs_$timestamp.txt';

  final summary = {
    'run_id': runId,
    'scenario_id': scenarioId,
    'seed': 123456,
    'passA': {
      'label': 'Pass A',
      'descriptor': 'Original',
      'attempts': 6,
      'correct': 6,
      'avg_correct_time_ms': 420,
      'error_count': 0,
    },
    'passB': {
      'label': 'Pass B',
      'descriptor': 'Mirror',
      'attempts': 6,
      'correct': 6,
      'avg_correct_time_ms': 415,
      'error_count': 0,
    },
    'error_class_reduction': 0,
  };

  final lines = [
    'flutter: PHASE1_SUMMARY: ${jsonEncode(summary)}',
    'flutter: PHASE1_LOG: ${jsonEncode([
      {"run_id": runId, "event": "session_start"},
      {"run_id": runId, "event": "session_end"},
    ])}',
    'flutter: PHASE2_SESSION_START: ${jsonEncode({"run_id": runId, "timestamp": now.toIso8601String()})}',
    'flutter: PHASE2_AHA: ${jsonEncode({"run_id": runId, "aha_type": "value_realization", "timestamp": now.add(const Duration(seconds: 5)).toIso8601String()})}',
    'flutter: PHASE3_RETURN_SIGNAL: ${jsonEncode({"run_id": runId, "signal_type": "engagement_return", "timestamp": now.add(const Duration(seconds: 15)).toIso8601String()})}',
    'flutter: PHASE3_FLOW_END: ${jsonEncode({"run_id": runId, "result": "signaled", "timestamp": now.add(const Duration(seconds: 20)).toIso8601String()})}',
  ];

  final file = File(filePath);
  file.writeAsStringSync(lines.join('\n'));

  final summaryEvent = {
    'event': 'PHASE4_EMIT_SAMPLE_LOGS',
    'result': 'ok',
    'output': filePath,
  };
  stdout.writeln(jsonEncode(summaryEvent));
}
