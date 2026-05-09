import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localized_asset_builder_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/localized_asset_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/localized_asset_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LocalizedAssetBuilderService();
  late final LocalizedAssetBundle bundle;

  try {
    bundle = await service.run();
  } on LocalizedAssetBuilderException catch (error) {
    stderr.writeln('localized_asset_builder: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('localized_asset_builder: unexpected error: $error');
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
    stderr.writeln('localized_asset_builder: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'localized_asset_builder: bundle ready (coverage ${bundle.coverage.toStringAsFixed(2)}).',
  );
  exitCode = 0;
}

String _buildSummary(LocalizedAssetBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('LOCALIZED ASSET BUNDLE')
    ..writeln('======================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Entries: ${bundle.entries.length}')
    ..writeln('Coverage: ${bundle.coverage.toStringAsFixed(2)}');
  return buffer.toString();
}

Future<void> _appendTelemetry(LocalizedAssetBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'localized_asset_builder_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'entry_count': bundle.entries.length,
    'coverage': bundle.coverage,
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
