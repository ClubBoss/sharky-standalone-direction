import 'dart:convert';

void main() {
  final runId = DateTime.now().toUtc().toIso8601String().replaceAll(
    RegExp(r'[:.]'),
    '-',
  );
  final payload = jsonEncode({
    'event': 'REGRESSION_PHASE4_STUB',
    'run_id': runId,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  });
  print(payload);
}
