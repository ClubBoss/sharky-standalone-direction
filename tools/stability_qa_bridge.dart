import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/stability_qa_bridge_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/stability_snapshot_summary.txt';
const String _summaryJsonPath = '$_reportsDir/stability_snapshot_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = StabilityQaBridgeService();
  StabilitySnapshot snapshot;
  try {
    snapshot = await service.snapshot();
  } catch (error) {
    stderr.writeln('Stability QA Bridge failed: $error');
    exitCode = 2;
    return;
  }
  final pass =
      snapshot.domains.values.every((value) => value) &&
      snapshot.stale.isEmpty &&
      snapshot.missing.isEmpty;
  final text = _buildText(snapshot, pass);
  final json = _buildJson(snapshot, pass);
  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(
      snapshot.domains.length,
      snapshot.stale.length,
      snapshot.missing.length,
    );
  });
  if (!pass) exitCode = 2;
}

String _buildText(StabilitySnapshot snapshot, bool pass) {
  final buffer = StringBuffer()
    ..writeln('STABILITY SNAPSHOT SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Overall verdict: ${pass ? 'PASS' : 'FAIL'}')
    ..writeln('Domains:');
  snapshot.domains.forEach((domain, status) {
    buffer.writeln('  $domain: ${status ? 'PASS' : 'FAIL'}');
  });
  if (snapshot.stale.isNotEmpty) {
    buffer.writeln('Stale files: ${snapshot.stale.join(', ')}');
  }
  if (snapshot.missing.isNotEmpty) {
    buffer.writeln('Missing files: ${snapshot.missing.join(', ')}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(StabilitySnapshot snapshot, bool pass) => {
  'generated_at': DateTime.now().toIso8601String(),
  'verdict': pass ? 'PASS' : 'FAIL',
  'domains': snapshot.domains,
  'stale': snapshot.stale,
  'missing': snapshot.missing,
};

Future<void> _appendTelemetry(
  int domainCount,
  int staleCount,
  int missingCount,
) async {
  final payload = <String, Object?>{
    'event': 'stability_snapshot_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'domain_count': domainCount,
    'stale_count': staleCount,
    'missing_count': missingCount,
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
