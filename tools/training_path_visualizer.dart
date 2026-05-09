import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/training_path_visualizer_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath = '$_reportsDir/training_path_visualization.txt';
const String _summaryJsonPath = '$_reportsDir/training_path_visualization.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = TrainingPathVisualizerService();
  TrainingPathVisualization visualization;

  try {
    visualization = await service.build();
  } on TrainingPathVisualizerException catch (error) {
    stderr.writeln('training_path_visualizer: ${error.message}');
    exitCode = 2;
    return;
  } catch (error) {
    stderr.writeln('training_path_visualizer: unexpected error: $error');
    exitCode = 2;
    return;
  }

  final summaryText = _buildSummary(visualization);
  final summaryJson = visualization.toJson();

  try {
    await _withReportsWritable(() async {
      await File(_summaryTextPath).writeAsString(summaryText);
      await File(
        _summaryJsonPath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(summaryJson));
      await _appendTelemetry(visualization);
    });
    stdout.writeln('training_path_visualizer: bundle emitted.');
  } catch (error) {
    stderr.writeln('training_path_visualizer: report write failed: $error');
    exitCode = 2;
  }
}

String _buildSummary(TrainingPathVisualization visualization) {
  final buffer = StringBuffer()
    ..writeln('TRAINING PATH VISUALIZATION')
    ..writeln('===========================')
    ..writeln('Generated: ${visualization.timestamp.toIso8601String()}')
    ..writeln('Path nodes: ${visualization.pathNodes.length}')
    ..writeln('Grouped paths: ${visualization.groupedPaths}')
    ..writeln('Path graph edges: ${visualization.pathGraph.length}')
    ..writeln('Summary: ${visualization.summary}');
  return buffer.toString();
}

Future<void> _appendTelemetry(TrainingPathVisualization visualization) async {
  final payload = <String, Object?>{
    'event': 'training_path_visualization_completed',
    'timestamp': visualization.timestamp.toIso8601String(),
    'module_count': visualization.summary['module_count'],
    'priority_count': visualization.summary['priority_count'],
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
