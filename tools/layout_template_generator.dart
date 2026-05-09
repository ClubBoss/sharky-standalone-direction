import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/layout_template_generator_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/layout_template_bundle.txt';
const String _summaryJsonPath = '$_reportsDir/layout_template_bundle.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LayoutTemplateGeneratorService();
  LayoutTemplateBundle bundle;

  try {
    bundle = await service.build();
  } on LayoutTemplateGeneratorException catch (error) {
    stderr.writeln('layout_template_generator: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('layout_template_generator: unexpected error: $error');
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
    stdout.writeln('layout_template_generator: bundle ready.');
  } catch (error) {
    stderr.writeln('layout_template_generator: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(LayoutTemplateBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('LAYOUT TEMPLATE BUNDLE')
    ..writeln('======================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Screen templates: ${bundle.screenTemplates}')
    ..writeln('Card templates: ${bundle.cardTemplates}')
    ..writeln('List templates: ${bundle.listTemplates}')
    ..writeln('Row/column templates: ${bundle.rowColumnTemplates}')
    ..writeln('Spacing templates: ${bundle.spacingTemplates}')
    ..writeln('Component placement: ${bundle.componentPlacementTemplates}');
  return buffer.toString();
}

Future<void> _appendTelemetry(LayoutTemplateBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'layout_template_generator_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
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
