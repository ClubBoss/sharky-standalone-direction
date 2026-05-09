import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localization_core_bootstrap_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/localization_core_bootstrap.txt';
const String _summaryJsonPath = '$_reportsDir/localization_core_bootstrap.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LocalizationCoreBootstrapService();
  LocalizationCoreBundle bundle;

  try {
    bundle = await service.run();
  } on LocalizationCoreBootstrapException catch (error) {
    stderr.writeln('localization_core_bootstrap: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('localization_core_bootstrap: unexpected error: $error');
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
    stdout.writeln('localization_core_bootstrap: bundle emitted.');
  } catch (error) {
    stderr.writeln('localization_core_bootstrap: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(LocalizationCoreBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('LOCALIZATION CORE BOOTSTRAP')
    ..writeln('===========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Base locale: ${bundle.baseLocale}')
    ..writeln('Supported locales: ${bundle.supportedLocales.join(', ')}')
    ..writeln(
      'Translation memory entries: ${bundle.translationMemorySeed.length}',
    )
    ..writeln('Glossary entries: ${bundle.glossarySeed.length}');
  return buffer.toString();
}

Future<void> _appendTelemetry(LocalizationCoreBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'localization_core_bootstrap_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'locale_count': bundle.supportedLocales.length,
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
