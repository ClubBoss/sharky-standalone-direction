import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/visual_cohesion_probe_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/visual_cohesion_probe_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/visual_cohesion_probe_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = VisualCohesionProbeService();
  VisualCohesionSummary summary;
  try {
    summary = await service.analyze();
  } catch (error) {
    stderr.writeln('Visual Cohesion Probe failed: $error');
    exitCode = 2;
    return;
  }
  final text = _buildText(summary);
  final json = _buildJson(summary);
  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(
      summary.domains.length,
      summary.failDomainCount,
      summary.visualRiskScore,
    );
  });
}

String _buildText(VisualCohesionSummary summary) {
  final buffer = StringBuffer()
    ..writeln('VISUAL COHESION PROBE')
    ..writeln('=====================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln(
      'Visual risk score: ${(summary.visualRiskScore * 100).toStringAsFixed(1)}%',
    )
    ..writeln('Failing domains: ${summary.failDomainCount}');
  summary.domains.forEach((domain, pass) {
    buffer.writeln('  $domain: ${pass ? 'PASS' : 'FAIL'}');
  });
  if (summary.stale.isNotEmpty) {
    buffer.writeln('Stale files: ${summary.stale.join(', ')}');
  }
  if (summary.missing.isNotEmpty) {
    buffer.writeln('Missing files: ${summary.missing.join(', ')}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(VisualCohesionSummary summary) => {
  'generated_at': DateTime.now().toIso8601String(),
  'domains': summary.domains,
  'stale': summary.stale,
  'missing': summary.missing,
  'fail_domain_count': summary.failDomainCount,
  'visual_risk_score': summary.visualRiskScore,
  'timestamp': DateTime.now().toIso8601String(),
};

Future<void> _appendTelemetry(
  int domainCount,
  int failDomainCount,
  double riskScore,
) async {
  final payload = <String, Object?>{
    'event': 'visual_cohesion_probe_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'domain_count': domainCount,
    'fail_domain_count': failDomainCount,
    'visual_risk_score': riskScore,
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
