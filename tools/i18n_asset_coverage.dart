import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/i18n_asset_coverage_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/i18n_asset_coverage.txt';
const String _summaryJsonPath = '$_reportsDir/i18n_asset_coverage.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = I18nAssetCoverageService();
  late final I18nAssetCoverageBundle bundle;

  try {
    bundle = await service.run();
  } on I18nAssetCoverageException catch (error) {
    stderr.writeln('i18n_asset_coverage: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('i18n_asset_coverage: unexpected error: $error');
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
    stderr.writeln('i18n_asset_coverage: report write failed: $error');
    exitCode = 2;
    return;
  }

  if (bundle.coverageRatio < 1.0) {
    stderr.writeln(
      'i18n_asset_coverage: coverage incomplete (${bundle.coverageRatio.toStringAsFixed(2)})',
    );
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'i18n_asset_coverage: coverage verified (${bundle.coverageRatio.toStringAsFixed(2)}).',
  );
  exitCode = 0;
}

String _buildSummary(I18nAssetCoverageBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('I18N ASSET COVERAGE')
    ..writeln('===================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Total keys: ${bundle.totalKeys}')
    ..writeln('Covered keys: ${bundle.covered}')
    ..writeln('Coverage ratio: ${bundle.coverageRatio.toStringAsFixed(2)}')
    ..writeln('Missing glossary entries: ${bundle.missingInGlossary.length}')
    ..writeln('Missing pseudo entries: ${bundle.missingInPseudo.length}')
    ..writeln('External keys not in TM: ${bundle.missingInTm.length}');
  return buffer.toString();
}

Future<void> _appendTelemetry(I18nAssetCoverageBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'i18n_asset_coverage_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'total_keys': bundle.totalKeys,
    'coverage_ratio': bundle.coverageRatio,
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
