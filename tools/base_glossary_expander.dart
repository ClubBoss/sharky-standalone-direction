import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/base_glossary_expander_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/base_glossary_expander.txt';
const String _summaryJsonPath = '$_reportsDir/base_glossary_expander.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = BaseGlossaryExpanderService();
  BaseGlossaryExpanderBundle bundle;

  try {
    bundle = await service.run();
  } on BaseGlossaryExpanderException catch (error) {
    stderr.writeln('base_glossary_expander: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('base_glossary_expander: unexpected error: $error');
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
    stdout.writeln('base_glossary_expander: glossary emitted.');
  } catch (error) {
    stderr.writeln('base_glossary_expander: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(BaseGlossaryExpanderBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('BASE GLOSSARY EXPANDER')
    ..writeln('=======================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Glossary entries: ${bundle.entryCount}')
    ..writeln('Domains: ${bundle.domainList.join(', ')}');
  return buffer.toString();
}

Future<void> _appendTelemetry(BaseGlossaryExpanderBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'base_glossary_expander_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'entry_count': bundle.entryCount,
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
