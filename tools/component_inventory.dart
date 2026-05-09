import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/component_inventory_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/component_inventory_summary.txt';
const String _summaryJsonPath = '$_reportsDir/component_inventory_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

const List<String> _categoryOrder = [
  'buttons',
  'inputs',
  'display',
  'chips',
  'navigation',
  'lists',
  'surfaces',
  'wrappers',
];

const Map<String, String> _categoryLabels = {
  'buttons': 'Buttons',
  'inputs': 'Inputs',
  'display': 'Display',
  'chips': 'Chips / Tags',
  'navigation': 'Navigation',
  'lists': 'Lists & Collections',
  'surfaces': 'Cards & Surfaces',
  'wrappers': 'Structural Wrappers',
};

Future<void> main(List<String> args) async {
  final service = ComponentInventoryService();
  ComponentInventoryBundle bundle;

  try {
    bundle = await service.collect();
  } on ComponentInventoryException catch (error) {
    stderr.writeln('component_inventory: ${error.message}');
    exitCode = 2;
    return;
  } on FileSystemException catch (error) {
    stderr.writeln('component_inventory: file system error: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('component_inventory: unexpected error: $error');
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
      'component_inventory: summary written (groups=${bundle.componentGroupCount}).',
    );
  } catch (error) {
    stderr.writeln('component_inventory: report generation failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(ComponentInventoryBundle bundle) {
  final buffer = StringBuffer()
    ..writeln('COMPONENT INVENTORY SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln(
      'Component groups with usage: '
      '${bundle.componentGroupCount}/${_categoryOrder.length}',
    )
    ..writeln();

  for (final category in _categoryOrder) {
    final label = _categoryLabels[category] ?? category;
    final usageCount = bundle.counts[category] ?? 0;
    final componentList = bundle.components[category] ?? const <String>[];
    final typeCount = componentList.length;
    final typeSummary = typeCount > 0 ? ', $typeCount types' : '';
    final typeText = typeCount > 0 ? componentList.join(', ') : 'None';
    buffer.writeln('$label ($usageCount uses$typeSummary): $typeText');
  }

  return buffer.toString();
}

Future<void> _appendTelemetry(ComponentInventoryBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'component_inventory_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'component_group_count': bundle.componentGroupCount,
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
