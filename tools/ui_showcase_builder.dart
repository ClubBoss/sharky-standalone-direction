import 'dart:convert';
import 'dart:io';

/// UI Showcase / Demo Build Tool (Stage Ω19)
///
/// Aggregates visual elements from assets and ui_v3/widgets directories,
/// generates ui_showcase_manifest.md with component inventory, and emits telemetry.
///
/// Usage:
///   dart run tools/ui_showcase_builder.dart
void main() async {
  final stopwatch = Stopwatch()..start();

  print('=== UI Showcase Builder (Stage Ω19) ===\n');

  final exportDir = Directory('release/_exports');
  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }

  // Scan assets
  final mascotAssets = await _scanMascotAssets();

  // Scan widgets
  final widgets = await _scanWidgets();

  // Generate showcase manifest
  final manifestPath = '${exportDir.path}/ui_showcase_manifest.md';
  await _generateShowcaseManifest(manifestPath, widgets, mascotAssets);

  stopwatch.stop();

  // Print ASCII summary
  _printSummary(widgets, mascotAssets, manifestPath);

  // Emit telemetry
  await _emitTelemetry(
    widgets.length,
    mascotAssets.length,
    stopwatch.elapsedMilliseconds,
  );

  print('\n✓ UI showcase build complete.');
}

/// Scan assets/mascot directory for SVG files
Future<List<Map<String, dynamic>>> _scanMascotAssets() async {
  final assets = <Map<String, dynamic>>[];
  final mascotDir = Directory('assets/mascot');

  if (!await mascotDir.exists()) {
    print('Warning: assets/mascot directory not found');
    return assets;
  }

  await for (final entity in mascotDir.list(recursive: false)) {
    if (entity is File && entity.path.endsWith('.svg')) {
      final stat = await entity.stat();
      final name = entity.path.split('/').last;

      assets.add({
        'name': name,
        'path': entity.path,
        'size_kb': (stat.size / 1024).toStringAsFixed(2),
        'type': 'svg',
      });
    }
  }

  return assets;
}

/// Scan ui_v3/widgets directory for Dart widget files
Future<List<Map<String, dynamic>>> _scanWidgets() async {
  final widgets = <Map<String, dynamic>>[];
  final widgetsDir = Directory('lib/ui_v3/widgets');

  if (!await widgetsDir.exists()) {
    print('Warning: lib/ui_v3/widgets directory not found');
    return widgets;
  }

  await for (final entity in widgetsDir.list(recursive: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final name = entity.path.split('/').last.replaceAll('.dart', '');
      final content = await entity.readAsString();

      // Detect widget type
      final isStateful = content.contains('extends StatefulWidget');
      final isStateless = content.contains('extends StatelessWidget');
      final widgetType = isStateful
          ? 'StatefulWidget'
          : isStateless
          ? 'StatelessWidget'
          : 'Unknown';

      // Count lines of code (non-empty, non-comment)
      final lines = content.split('\n');
      var loc = 0;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty &&
            !trimmed.startsWith('//') &&
            !trimmed.startsWith('/*') &&
            !trimmed.startsWith('*')) {
          loc++;
        }
      }

      widgets.add({
        'name': name,
        'path': entity.path,
        'type': widgetType,
        'loc': loc,
        'status': 'Active',
      });
    }
  }

  return widgets;
}

/// Generate ui_showcase_manifest.md
Future<void> _generateShowcaseManifest(
  String path,
  List<Map<String, dynamic>> widgets,
  List<Map<String, dynamic>> assets,
) async {
  final buffer = StringBuffer();
  final timestamp = DateTime.now().toUtc().toIso8601String();

  buffer.writeln('# UI Showcase Manifest');
  buffer.writeln('Generated: $timestamp');
  buffer.writeln();

  // Section 1: Widget Inventory
  buffer.writeln('## Section 1 — Widget Inventory');
  buffer.writeln('| Widget Name | Type | LOC | Status |');
  buffer.writeln('| ----------- | ---- | --- | ------ |');

  for (final widget in widgets) {
    buffer.writeln(
      '| ${widget['name']} | ${widget['type']} | ${widget['loc']} | ${widget['status']} |',
    );
  }

  buffer.writeln();

  // Section 2: Asset Inventory
  buffer.writeln('## Section 2 — Asset Inventory');
  buffer.writeln('| Asset Name | Type | Size (KB) |');
  buffer.writeln('| ---------- | ---- | --------- |');

  for (final asset in assets) {
    buffer.writeln(
      '| ${asset['name']} | ${asset['type']} | ${asset['size_kb']} |',
    );
  }

  buffer.writeln();

  // Section 3: Summary
  buffer.writeln('## Section 3 — Summary');
  buffer.writeln('- Total Widgets: ${widgets.length}');
  buffer.writeln('- Total Assets: ${assets.length}');
  buffer.writeln(
    '- Total LOC: ${widgets.fold<int>(0, (sum, w) => sum + (w['loc'] as int))}',
  );
  buffer.writeln();

  // Section 4: Build Info
  buffer.writeln('## Section 4 — Build Info');
  buffer.writeln('- Timestamp: $timestamp');
  buffer.writeln('- Builder: ui_showcase_builder.dart (Stage Ω19)');

  await File(path).writeAsString(buffer.toString());
}

/// Print ASCII summary
void _printSummary(
  List<Map<String, dynamic>> widgets,
  List<Map<String, dynamic>> assets,
  String manifestPath,
) {
  print('┌───────────────────────────────────────────────────────────┐');
  print('│ UI Showcase Build Summary                                 │');
  print('├───────────────────────────────────────────────────────────┤');
  print(
    '│ Widgets Cataloged:  ${widgets.length.toString().padLeft(3)}                               │',
  );
  print(
    '│ Assets Cataloged:   ${assets.length.toString().padLeft(3)}                               │',
  );
  print('├───────────────────────────────────────────────────────────┤');
  print('│ Manifest:                                                 │');
  print('│   $manifestPath');
  print('└───────────────────────────────────────────────────────────┘');
}

/// Emit telemetry event
Future<void> _emitTelemetry(int widgets, int assets, int durationMs) async {
  final telemetryFile = File('release/_exports/ui_showcase_telemetry.jsonl');
  final event = {
    'event': 'ui_showcase_built',
    'widgets': widgets,
    'assets': assets,
    'duration_ms': durationMs,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
  };

  final eventLine = '${jsonEncode(event)}\n';

  try {
    if (await telemetryFile.exists()) {
      await telemetryFile.writeAsString(eventLine, mode: FileMode.append);
    } else {
      await telemetryFile.writeAsString(eventLine);
    }
  } catch (e) {
    // Gracefully handle telemetry write failures
    print('Note: Could not write telemetry event ($e)');
  }
}
