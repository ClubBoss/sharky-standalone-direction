import 'dart:convert';
import 'dart:io';

/// Validates Phase 1–3 log contracts from a captured run output.

const logSpecs = {
  'PHASE1_SUMMARY': [
    'run_id',
    'scenario_id',
    'seed',
    'passA',
    'passB',
    'error_class_reduction',
  ],
  'PHASE2_SESSION_START': ['run_id', 'timestamp'],
  'PHASE2_AHA': ['run_id', 'aha_type', 'timestamp'],
  'PHASE3_RETURN_SIGNAL': ['run_id', 'signal_type', 'timestamp'],
  'PHASE3_FLOW_END': ['run_id', 'result', 'timestamp'],
};

const requiredPassFields = [
  'label',
  'descriptor',
  'attempts',
  'correct',
  'avg_correct_time_ms',
  'error_count',
];

void main(List<String> args) {
  final inputIndex = args.indexOf('--input');
  if (inputIndex < 0 || inputIndex + 1 >= args.length) {
    stderr.writeln(
      'Usage: dart run tools/phase4_regression_validate_logs.dart --input <path>',
    );
    exit(1);
  }

  final inputPath = args[inputIndex + 1];
  final file = File(inputPath);
  if (!file.existsSync()) {
    stderr.writeln('Input file not found: $inputPath');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  final parsed = <String, Map<String, dynamic>>{};
  final missing = <String>[];

  for (final line in lines) {
    for (final prefix in logSpecs.keys) {
      if (parsed.containsKey(prefix)) {
        continue;
      }
      final marker = '$prefix:';
      final markerIndex = line.indexOf(marker);
      if (markerIndex < 0) {
        continue;
      }
      final payload = line.substring(markerIndex + marker.length).trim();
      try {
        final data = jsonDecode(payload);
        if (data is Map<String, dynamic>) {
          parsed[prefix] = data;
        } else {
          missing.add('$prefix (invalid JSON structure)');
        }
      } catch (_) {
        missing.add('$prefix (invalid JSON)');
      }
    }
  }

  for (final entry in logSpecs.entries) {
    if (!parsed.containsKey(entry.key)) {
      missing.add('$entry.key (missing)');
      continue;
    }
    final payload = parsed[entry.key]!;
    for (final key in entry.value) {
      if (!payload.containsKey(key)) {
        missing.add('$entry.key.$key');
      }
    }
  }

  final passA = parsed['PHASE1_SUMMARY']?['passA'];
  final passB = parsed['PHASE1_SUMMARY']?['passB'];
  if (passA is Map<String, dynamic>) {
    missing.addAll(_checkPassFields('PHASE1_SUMMARY.passA', passA));
  }
  if (passB is Map<String, dynamic>) {
    missing.addAll(_checkPassFields('PHASE1_SUMMARY.passB', passB));
  }

  final result = missing.isEmpty ? 'pass' : 'fail';
  final eventPayload = jsonEncode({
    'event': 'REGRESSION_PHASE4_LOG_CONTRACT',
    'result': result,
    'missing': missing,
    'input': inputPath,
  });
  print(eventPayload);

  if (missing.isNotEmpty) {
    stderr.writeln('Validation failed: ${missing.join(', ')}');
    exit(1);
  }
}

List<String> _checkPassFields(String label, Map<String, dynamic> data) {
  final issues = <String>[];
  for (final field in requiredPassFields) {
    if (!data.containsKey(field)) {
      issues.add('$label.$field');
    }
  }
  return issues;
}
