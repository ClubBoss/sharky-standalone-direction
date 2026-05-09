import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/integration_snapshot_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/integration_snapshot_v2.txt';
const String _summaryJsonPath = '$_reportsDir/integration_snapshot_v2.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';
const List<String> _domainOrder = [
  'stability',
  'system_sanity',
  'consistency',
  'telemetry',
  'cache',
  'file_structure',
  'replayability',
  'ux',
  'schema',
  'assets',
];

Future<void> main(List<String> args) async {
  final service = IntegrationSnapshotService();
  IntegrationSnapshotResult result;

  try {
    result = await service.run();
  } on IntegrationSnapshotException catch (error) {
    stderr.writeln('integration_snapshot: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('integration_snapshot: unexpected error: $error');
    exitCode = 1;
    return;
  }

  final summaryText = _buildSummary(result);
  final summaryJson = result.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(result);
    });
    stdout.writeln('integration_snapshot: snapshot recorded.');
  } catch (error) {
    stderr.writeln('integration_snapshot: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = result.summary.integrationPass ? 0 : 2;
}

String _buildSummary(IntegrationSnapshotResult result) {
  final buffer = StringBuffer()
    ..writeln('INTEGRATION SNAPSHOT V2')
    ..writeln('========================')
    ..writeln('Generated: ${result.summary.timestamp.toIso8601String()}')
    ..writeln('Integration pass: ${result.summary.integrationPass}')
    ..writeln('Domains:');

  for (final domain in _domainOrder) {
    final entry = result.snapshot[domain];
    if (entry is! Map<String, Object?>) {
      buffer.writeln('  - $domain: missing entry');
      continue;
    }
    final status = entry['status'];
    if (status is Map<String, Object?>) {
      buffer.writeln('  - $domain (${status['key']}): ${status['value']}');
    } else {
      buffer.writeln('  - $domain: status unavailable');
    }
  }

  if (result.notes.isNotEmpty) {
    buffer.writeln('Notes: ${result.notes.join(' | ')}');
  }

  return buffer.toString();
}

Future<void> _appendTelemetry(IntegrationSnapshotResult result) async {
  final payload = <String, Object?>{
    'event': 'integration_snapshot_completed',
    'timestamp': result.summary.timestamp.toIso8601String(),
    'integration_pass': result.summary.integrationPass,
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
  await _setPermissions(dir.path, true);
  try {
    await action();
  } finally {
    await _setPermissions(dir.path, false);
  }
}

Future<void> _setPermissions(String path, bool writable) async {
  final mode = writable ? 'u+w' : 'u-w';
  try {
    await Process.run('chmod', ['-R', mode, path]);
  } catch (_) {}
}
