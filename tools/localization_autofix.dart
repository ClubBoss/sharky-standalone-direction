import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localization_autofix_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/localization_autofix_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/localization_autofix_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LocalizationAutofixService();
  late final LocalizationAutofixBundle bundle;

  try {
    bundle = await service.run();
  } on LocalizationAutofixException catch (error) {
    stderr.writeln('localization_autofix: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('localization_autofix: unexpected error: $error');
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
  } catch (error) {
    stderr.writeln('localization_autofix: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'localization_autofix: suggestions ready (priority ${bundle.priority}).',
  );
  exitCode = 0;
}

String _buildSummary(LocalizationAutofixBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('LOCALIZATION AUTOFIX')
    ..writeln('====================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Priority: ${bundle.priority}')
    ..writeln('Missing glossary keys: ${bundle.missingKeys.length}')
    ..writeln('Inconsistent sources: ${bundle.inconsistentSources.length}')
    ..writeln('High-risk strings: ${bundle.highRiskStrings.length}');
  return buffer.toString();
}

Future<void> _appendTelemetry(LocalizationAutofixBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'localization_autofix_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'priority': bundle.priority,
    'missing_keys': bundle.missingKeys.length,
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
