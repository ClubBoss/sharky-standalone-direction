import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/cross_locale_consistency_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/cross_locale_consistency.txt';
const String _summaryJsonPath = '$_reportsDir/cross_locale_consistency.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = CrossLocaleConsistencyService();
  CrossLocaleConsistencyResult result;

  try {
    result = await service.run();
  } on CrossLocaleConsistencyException catch (error) {
    stderr.writeln('cross_locale_consistency: ${error.message}');
    result = CrossLocaleConsistencyResult(
      missingKeys: const [],
      inconsistentEn: const [],
      unexpectedRuPopulated: const [],
      orphanTmEntries: const [],
      consistencyPass: false,
      timestamp: DateTime.now().toUtc(),
    );
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('cross_locale_consistency: unexpected error: $error');
    exitCode = 2;
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
    stdout.writeln('cross_locale_consistency: check recorded.');
  } catch (error) {
    stderr.writeln('cross_locale_consistency: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = result.consistencyPass ? 0 : 2;
}

String _buildSummary(CrossLocaleConsistencyResult result) {
  final buffer = StringBuffer()
    ..writeln('CROSS-LOCALE CONSISTENCY')
    ..writeln('========================')
    ..writeln('Generated: ${result.timestamp.toIso8601String()}')
    ..writeln('Missing keys: ${result.missingKeys}')
    ..writeln('Inconsistent en: ${result.inconsistentEn}')
    ..writeln('Unexpected RU: ${result.unexpectedRuPopulated}')
    ..writeln('Orphan TM entries: ${result.orphanTmEntries}')
    ..writeln('Consistency pass: ${result.consistencyPass}');
  return buffer.toString();
}

Future<void> _appendTelemetry(CrossLocaleConsistencyResult result) async {
  final payload = <String, Object?>{
    'event': 'cross_locale_consistency_completed',
    'timestamp': result.timestamp.toIso8601String(),
    'consistency_pass': result.consistencyPass,
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
