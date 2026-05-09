import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/pseudo_localization_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/pseudo_localization.txt';
const String _summaryJsonPath = '$_reportsDir/pseudo_localization.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = PseudoLocalizationService();
  late final PseudoLocalizationBundle bundle;

  try {
    bundle = await service.run();
  } on PseudoLocalizationException catch (error) {
    stderr.writeln('pseudo_localization_generator: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('pseudo_localization_generator: unexpected error: $error');
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
    stdout.writeln(
      'pseudo_localization_generator: pseudo-local entries recorded.',
    );
  } catch (error) {
    stderr.writeln(
      'pseudo_localization_generator: report write failed: $error',
    );
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(PseudoLocalizationBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('PSEUDO LOCALIZATION GENERATOR')
    ..writeln('=============================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Entries: ${bundle.entryCount}');
  return buffer.toString();
}

Future<void> _appendTelemetry(PseudoLocalizationBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'pseudo_localization_completed',
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
