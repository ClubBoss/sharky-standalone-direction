import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/locale_heatmap_analyzer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/locale_heatmap_analyzer.txt';
const String _summaryJsonPath = '$_reportsDir/locale_heatmap_analyzer.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LocaleHeatmapAnalyzerService();
  late final LocaleHeatmapBundle bundle;

  try {
    bundle = await service.run();
  } on LocaleHeatmapAnalyzerException catch (error) {
    stderr.writeln('locale_heatmap_analyzer: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('locale_heatmap_analyzer: unexpected error: $error');
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
    stdout.writeln('locale_heatmap_analyzer: heatmap recorded.');
  } catch (error) {
    stderr.writeln('locale_heatmap_analyzer: report write failed: $error');
    exitCode = 2;
    return;
  }

  exitCode = 0;
}

String _buildSummary(LocaleHeatmapBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('LOCALE HEATMAP ANALYZER')
    ..writeln('=======================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Average ratio: ${bundle.avgLengthRatio.toStringAsFixed(2)}')
    ..writeln('Max ratio: ${bundle.maxLengthRatio.toStringAsFixed(2)}')
    ..writeln('Risk density: ${bundle.riskDensity.toStringAsFixed(2)}')
    ..writeln('High risk entries: ${bundle.highRiskEntries.length}')
    ..writeln('Safe entries: ${bundle.safeEntries.length}');
  return buffer.toString();
}

Future<void> _appendTelemetry(LocaleHeatmapBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'locale_heatmap_analyzer_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'avg_length_ratio': bundle.avgLengthRatio,
    'risk_density': bundle.riskDensity,
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
