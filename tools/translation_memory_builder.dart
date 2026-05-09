import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/translation_memory_builder_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/translation_memory_builder.txt';
const String _summaryJsonPath = '$_reportsDir/translation_memory_builder.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = TranslationMemoryBuilderService();
  TranslationMemoryBundle bundle;

  try {
    bundle = await service.run();
  } on TranslationMemoryBuilderException catch (error) {
    stderr.writeln('translation_memory_builder: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('translation_memory_builder: unexpected error: $error');
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
    stdout.writeln('translation_memory_builder: TM recorded.');
  } catch (error) {
    stderr.writeln('translation_memory_builder: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(TranslationMemoryBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('TRANSLATION MEMORY BUILDER')
    ..writeln('==========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Entries: ${bundle.entries.length}')
    ..writeln('Domains: ${bundle.domains.join(', ')}');
  return buffer.toString();
}

Future<void> _appendTelemetry(TranslationMemoryBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'translation_memory_builder_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'entry_count': bundle.entries.length,
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
