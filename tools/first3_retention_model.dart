import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/first3_retention_model_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/first3_retention_model.txt';
const String _summaryJsonPath = '$_reportsDir/first3_retention_model.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = First3RetentionModelService();
  First3RetentionBundle bundle;

  try {
    bundle = await service.run();
  } on First3RetentionException catch (error) {
    stderr.writeln('first3_retention_model: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('first3_retention_model: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(bundle);
  final summaryJson = bundle.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(bundle);
    });
    stdout.writeln('first3_retention_model: model emitted.');
  } catch (error) {
    stderr.writeln('first3_retention_model: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(First3RetentionBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('FIRST 3 MIN RETENTION MODEL')
    ..writeln('===========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln(
      'Retention confidence: ${bundle.retentionConfidence.toStringAsFixed(2)}',
    )
    ..writeln(
      'Retention clarity: ${bundle.retentionClarity.toStringAsFixed(2)}',
    )
    ..writeln(
      'Retention engagement: ${bundle.retentionEngagement.toStringAsFixed(2)}',
    )
    ..writeln('Retention score: ${bundle.retentionScore.toStringAsFixed(2)}')
    ..writeln('Retention tier: ${bundle.retentionTier}');
  return buffer.toString();
}

Future<void> _appendTelemetry(First3RetentionBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'first3_retention_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'retention_score': bundle.retentionScore,
    'retention_tier': bundle.retentionTier,
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
