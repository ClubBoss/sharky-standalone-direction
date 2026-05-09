import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/design_readiness_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/design_readiness_summary.txt';
const String _summaryJsonPath = '$_reportsDir/design_readiness_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = DesignReadinessBridgeService();
  DesignReadinessSummary summary;
  try {
    summary = await service.evaluate();
  } catch (error) {
    stderr.writeln('Design Readiness Bridge failed: $error');
    exitCode = 2;
    return;
  }
  final text = _buildText(summary);
  final json = summary.toJson();
  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(
      summary.failCount,
      summary.riskScore,
      summary.designPriority,
    );
  });
}

String _buildText(DesignReadinessSummary summary) {
  final buffer = StringBuffer()
    ..writeln('DESIGN READINESS SUMMARY')
    ..writeln('========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Design priority: ${summary.designPriority}')
    ..writeln(
      'Visual risk score: ${(summary.riskScore * 100).toStringAsFixed(1)}%',
    )
    ..writeln('Fail count: ${summary.failCount}');
  summary.domains.forEach((name, pass) {
    buffer.writeln('  $name: ${pass ? 'PASS' : 'FAIL'}');
  });
  if (summary.stale.isNotEmpty) {
    buffer.writeln('Stale files: ${summary.stale.join(', ')}');
  }
  if (summary.missing.isNotEmpty) {
    buffer.writeln('Missing files: ${summary.missing.join(', ')}');
  }
  return buffer.toString();
}

Future<void> _appendTelemetry(
  int failCount,
  double riskScore,
  String priority,
) async {
  final payload = <String, Object?>{
    'event': 'design_readiness_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'fail_count': failCount,
    'risk_score': riskScore,
    'design_priority': priority,
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
