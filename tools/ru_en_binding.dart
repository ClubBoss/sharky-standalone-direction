import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ru_en_binding_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ru_en_binding_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ru_en_binding_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = RuEnBindingService();
  late final RuEnBindingBundle bundle;

  try {
    bundle = await service.run();
  } on RuEnBindingException catch (error) {
    stderr.writeln('ru_en_binding: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('ru_en_binding: unexpected error: $error');
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
    stderr.writeln('ru_en_binding: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'ru_en_binding: skeleton emitted with ${bundle.entries.length} entries.',
  );
  exitCode = 0;
}

String _buildSummary(RuEnBindingBundle bundle) {
  final missingCount = bundle.entries.where((entry) => entry.missing).length;
  final highRiskCount = bundle.entries.where((entry) => entry.highRisk).length;
  final buffer = StringBuffer()
    ..writeln('RU/EN BINDING')
    ..writeln('=============')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Entries: ${bundle.entries.length}')
    ..writeln('Missing: $missingCount')
    ..writeln('High-risk: $highRiskCount');
  return buffer.toString();
}

Future<void> _appendTelemetry(RuEnBindingBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'ru_en_binding_completed',
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
