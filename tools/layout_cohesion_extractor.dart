import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/layout_cohesion_extractor_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/layout_cohesion_summary.txt';
const String _summaryJsonPath = '$_reportsDir/layout_cohesion_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LayoutCohesionExtractorService();
  LayoutCohesionBundle bundle;
  try {
    bundle = await service.extract();
  } catch (error) {
    stderr.writeln('Layout Cohesion Extractor failed: $error');
    exitCode = 2;
    return;
  }
  final text = _buildText(bundle);
  final json = {
    'generated_at': DateTime.now().toIso8601String(),
    'stats': bundle.stats,
    'anomalies': bundle.anomalies,
  };
  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(bundle.anomalies.length);
  });
}

String _buildText(LayoutCohesionBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('LAYOUT COHESION SUMMARY')
    ..writeln('=======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Stats:')
    ..writeln(
      bundle.stats.entries.map((e) => '  ${e.key}: ${e.value}').join('\n'),
    )
    ..writeln('Anomalies: ${bundle.anomalies.join(', ')}');
  return buffer.toString();
}

Future<void> _appendTelemetry(int anomalyCount) async {
  final payload = <String, Object?>{
    'event': 'layout_cohesion_extractor_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'anomaly_count': anomalyCount,
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
