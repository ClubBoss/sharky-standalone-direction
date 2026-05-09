import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/review_loop_integrator_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/review_loop_integrator_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/review_loop_integrator_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final integrator = ReviewLoopIntegratorService();
  List<ReviewSuggestionBundle> bundles;
  try {
    bundles = await integrator.integrate();
  } catch (error) {
    stderr.writeln('Review Loop Integrator failed: $error');
    exitCode = 2;
    return;
  }

  final avgPriority = bundles.isEmpty
      ? 0.0
      : bundles.map((b) => b.priorityScore).reduce((a, b) => a + b) /
            bundles.length;

  final text = _buildText(bundles, avgPriority);
  final json = _buildJson(bundles, avgPriority);

  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(bundles.length, avgPriority);
  });
}

String _buildText(List<ReviewSuggestionBundle> bundles, double avgPriority) {
  final buffer = StringBuffer()
    ..writeln('REVIEW LOOP INTEGRATOR SUMMARY')
    ..writeln('==============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Modules: ${bundles.length}')
    ..writeln('Average priority: ${(avgPriority * 100).toStringAsFixed(2)}%');
  for (final bundle in bundles) {
    buffer
      ..writeln(
        '- ${bundle.module}: priority ${bundle.priorityScore.toStringAsFixed(3)}',
      )
      ..writeln('  cohesion score: ${bundle.cohesionScore.toStringAsFixed(3)}')
      ..writeln('  gap warnings: ${bundle.gapWarnings.join(', ')}')
      ..writeln('  high-order flags: ${bundle.highOrderFlags.join(', ')}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(
  List<ReviewSuggestionBundle> bundles,
  double avgPriority,
) => {
  'generated_at': DateTime.now().toIso8601String(),
  'module_count': bundles.length,
  'avg_priority_score': avgPriority,
  'bundles': bundles.map((b) => b.toJson()).toList(),
};

Future<void> _appendTelemetry(int moduleCount, double avgPriority) async {
  final payload = <String, Object?>{
    'event': 'review_loop_integrator_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'module_count': moduleCount,
    'avg_priority_score': avgPriority,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  final dir = Directory(_reportsDir);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
