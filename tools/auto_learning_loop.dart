import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final steps = <Map<String, dynamic>>[];

  final simulation = await _runTool([
    'run',
    'tools/adaptive_simulation_loop.dart',
  ], name: 'simulation');
  steps.add({
    'name': 'simulation',
    'result': simulation.json,
    'pass': simulation.pass,
  });

  final analyzer = await _runTool([
    'run',
    'tools/economy_telemetry_analyzer.dart',
  ], name: 'analyzer');
  steps.add({
    'name': 'analyzer',
    'result': analyzer.json,
    'pass': analyzer.pass,
  });

  final recalibration = await _runTool([
    'run',
    'tools/economy_recalibration_engine.dart',
    '--apply',
  ], name: 'recalibration');
  steps.add({
    'name': 'recalibration',
    'result': recalibration.json,
    'pass': recalibration.pass,
  });

  final forecast = await _runTool([
    'run',
    'tools/adaptive_forecast_engine.dart',
  ], name: 'forecast');
  steps.add({
    'name': 'forecast',
    'result': forecast.json,
    'pass': forecast.pass,
  });

  final optimizer = await _runTool([
    'run',
    'tools/economy_auto_optimizer.dart',
  ], name: 'optimizer');
  steps.add({
    'name': 'optimizer',
    'result': optimizer.json,
    'pass': optimizer.pass,
  });

  final stabilityTrend = _asDouble(forecast.json?['trend_stability']);
  final riskLevel = forecast.json?['risk_level']?.toString() ?? 'unknown';
  final grade = riskLevel == 'Low'
      ? 'A+'
      : riskLevel == 'Medium'
      ? 'B'
      : 'C';

  final pass =
      steps.every((s) => s['pass'] == true) &&
      riskLevel != 'High' &&
      stabilityTrend >= -0.02;

  final trendPct = stabilityTrend * 100;
  final trendStr =
      '${trendPct >= 0 ? '+' : ''}${trendPct.toStringAsFixed(1)} %';
  stdout.writeln(
    'Auto-Learning Loop: ${pass ? 'PASS' : 'FAIL'} '
    '($grade, stability $trendStr)',
  );

  final payload = {
    'steps': steps,
    'stability_trend': double.parse(stabilityTrend.toStringAsFixed(4)),
    'risk_level': riskLevel,
    'grade': grade,
    'pass': pass,
    'timestamp': DateTime.now().toIso8601String(),
  };
  stdout.writeln(jsonEncode(payload));

  await File('auto_learning_loop.json').writeAsString(jsonEncode(payload));
  await _appendLog(payload);
}

class _ToolResult {
  final Map<String, dynamic>? json;
  final bool pass;

  _ToolResult({required this.json, required this.pass});
}

Future<_ToolResult> _runTool(List<String> args, {required String name}) async {
  try {
    final proc = await Process.run('dart', args);
    final json = _parseLastJson(proc.stdout);
    final pass = json?['pass'] == true || proc.exitCode == 0;
    return _ToolResult(json: json, pass: pass);
  } catch (_) {
    return _ToolResult(json: null, pass: false);
  }
}

Map<String, dynamic>? _parseLastJson(Object? stdout) {
  if (stdout is! String) return null;
  final lines = const LineSplitter().convert(stdout).reversed;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final data = jsonDecode(trimmed);
        if (data is Map<String, dynamic>) return data;
      } catch (_) {
        continue;
      }
    }
  }
  return null;
}

Future<void> _appendLog(Map<String, dynamic> entry) async {
  final file = File('auto_learning_log.jsonl');
  await file.writeAsString('${jsonEncode(entry)}\n', mode: FileMode.append);
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return 0.0;
}
