import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/localized_preview_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/localized_preview_summary.txt';
const String _summaryJsonPath = '$_reportsDir/localized_preview_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = LocalizedPreviewService();
  late final LocalizedPreviewBundle bundle;

  try {
    bundle = await service.run();
  } on LocalizedPreviewException catch (error) {
    stderr.writeln('localized_preview: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('localized_preview: unexpected error: $error');
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
    stderr.writeln('localized_preview: report write failed: $error');
    exitCode = 2;
    return;
  }

  stdout.writeln(
    'localized_preview: preview ready with ${bundle.items.length} items.',
  );
  exitCode = 0;
}

String _buildSummary(LocalizedPreviewBundle bundle) {
  final missing = bundle.items.where((item) => item.missing).length;
  final highRisk = bundle.items.where((item) => item.highRisk).length;
  final buffer = StringBuffer()
    ..writeln('LOCALIZED PREVIEW')
    ..writeln('=================')
    ..writeln('Generated: ${bundle.timestamp.toIso8601String()}')
    ..writeln('Items: ${bundle.items.length}')
    ..writeln('Missing keys: $missing')
    ..writeln('High-risk keys: $highRisk')
    ..writeln('')
    ..writeln('Sample preview:')
    ..writeln('Key | Missing | High Risk | Source -> Pseudo');
  for (final item in bundle.items.take(5)) {
    buffer.writeln(
      '${item.key} | ${item.missing ? "Y" : "N"} | ${item.highRisk ? "Y" : "N"} | ${item.sourceEn} -> ${item.pseudo}',
    );
  }
  return buffer.toString();
}

Future<void> _appendTelemetry(LocalizedPreviewBundle bundle) async {
  final payload = <String, Object?>{
    'event': 'localized_preview_completed',
    'timestamp': bundle.timestamp.toIso8601String(),
    'item_count': bundle.items.length,
    'missing_count': bundle.items.where((item) => item.missing).length,
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
