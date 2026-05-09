import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/adaptive_content_router_service.dart';

const String _reportsDir = 'release/_reports';
const String _summaryTextPath =
    '$_reportsDir/adaptive_content_router_summary.txt';
const String _summaryJsonPath =
    '$_reportsDir/adaptive_content_router_summary.json';
const String _telemetryPath = '$_reportsDir/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final service = AdaptiveContentRouterService();
  Map<String, List<RoutedModule>> groups;
  try {
    groups = await service.route();
  } catch (error) {
    stderr.writeln('Adaptive Content Router failed: $error');
    exitCode = 2;
    return;
  }

  final ordered = <RoutedModule>[]
    ..addAll(groups['priority'] ?? [])
    ..addAll(groups['mid'] ?? [])
    ..addAll(groups['fallback'] ?? []);
  final avgReinforcement = ordered.isEmpty
      ? 0.0
      : ordered.map((m) => m.reinforcementScore).reduce((a, b) => a + b) /
            ordered.length;

  final text = _buildText(groups, ordered, avgReinforcement);
  final json = _buildJson(groups, ordered, avgReinforcement);

  await _withReportsWritable(() async {
    await File(_summaryTextPath).writeAsString(text);
    await File(
      _summaryJsonPath,
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));
    await _appendTelemetry(
      ordered.length,
      groups['priority']?.length ?? 0,
      avgReinforcement,
    );
  });
}

String _buildText(
  Map<String, List<RoutedModule>> groups,
  List<RoutedModule> ordered,
  double avgReinforcement,
) {
  final buffer = StringBuffer()
    ..writeln('ADAPTIVE CONTENT ROUTER SUMMARY')
    ..writeln('===============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Total modules: ${ordered.length}')
    ..writeln('Priority modules: ${groups['priority']?.length ?? 0}')
    ..writeln(
      'Average reinforcement: ${(avgReinforcement * 100).toStringAsFixed(2)}%',
    );
  for (final module in ordered) {
    buffer
      ..writeln('- ${module.module} (${module.routeGroup})')
      ..writeln(
        '  reinforcement: ${module.reinforcementScore.toStringAsFixed(3)}',
      )
      ..writeln('  severity: ${module.severityFlag}');
  }
  return buffer.toString();
}

Map<String, Object?> _buildJson(
  Map<String, List<RoutedModule>> groups,
  List<RoutedModule> ordered,
  double avgReinforcement,
) => {
  'generated_at': DateTime.now().toIso8601String(),
  'module_count': ordered.length,
  'priority_count': groups['priority']?.length ?? 0,
  'avg_reinforcement_score': avgReinforcement,
  'groups': {
    'priority': groups['priority']?.map((m) => m.toJson()).toList() ?? [],
    'mid': groups['mid']?.map((m) => m.toJson()).toList() ?? [],
    'fallback': groups['fallback']?.map((m) => m.toJson()).toList() ?? [],
    'ordered': ordered.map((m) => m.toJson()).toList(),
  },
};

Future<void> _appendTelemetry(
  int moduleCount,
  int priorityCount,
  double avgReinforcement,
) async {
  final payload = <String, Object?>{
    'event': 'adaptive_content_router_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'module_count': moduleCount,
    'priority_count': priorityCount,
    'avg_reinforcement_score': avgReinforcement,
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
  try {
    await Process.run('chmod', ['-R', 'u+w', dir.path]);
  } catch (_) {}
  try {
    await action();
  } finally {
    try {
      await Process.run('chmod', ['-R', 'u-w', dir.path]);
    } catch (_) {}
  }
}
