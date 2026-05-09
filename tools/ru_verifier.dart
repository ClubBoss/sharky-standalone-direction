import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/ru_verifier_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/ru_verifier_summary.txt';
const String _summaryJsonPath = '$_reportsDir/ru_verifier_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = RuVerifierService();
  late final RuVerifierBundle bundle;

  try {
    bundle = await service.run();
  } on RuVerifierException catch (error) {
    stderr.writeln('ru_verifier: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('ru_verifier: unexpected error: $error');
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
    stderr.writeln('ru_verifier: report write failed: $error');
    exitCode = 2;
    return;
  }

  if (!bundle.verified) {
    stderr.writeln('ru_verifier: validation failed.');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'ru_verifier: binding verified at ${bundle.timestamp.toIso8601String()}.',
  );
  exitCode = 0;
}

String _buildSummary(RuVerifierBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('RU VERIFIER')
    ..writeln('===========')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Verified: ${bundle.verified}')
    ..writeln('Invalid keys: ${bundle.invalidKeys.length}')
    ..writeln('Inconsistent sources: ${bundle.inconsistentSources.length}')
    ..writeln('Non-ASCII RU entries: ${bundle.nonAsciiRuEntries.length}');
  return buffer.toString();
}

Future<void> _appendTelemetry(RuVerifierBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'ru_verifier_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'verified': bundle.verified,
    'invalid_keys': bundle.invalidKeys.length,
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
