import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final telemetryText = await _readFileIfExists(
    'release/_reports/telemetry_dashboard.txt',
  );
  final postlaunchJson = await _readJsonIfExists(
    'release/_reports/postlaunch_monitor.json',
  );
  final adaptivePatch =
      await _readJsonIfExists('release/_reports/ai_adaptive_patch.json') ??
      <String, dynamic>{};

  final crashRate =
      _extractPercent(telemetryText, ['crash_rate', 'crash_free']) ?? 0.01;
  final aiErrorRate = postlaunchJson?['ai_errors']?.toDouble() ?? 0.0;
  final retentionIndex = postlaunchJson?['retention_14d']?.toDouble() ?? 0.5;

  final rawScore = (1 - crashRate) * (1 - aiErrorRate) * retentionIndex * 100;
  final double stabilityScore = rawScore < 0
      ? 0.0
      : rawScore > 100.0
      ? 100.0
      : rawScore;

  final telemetryVolume = _extractNumber(telemetryText, [
    'event_volume',
    'events_per_day',
  ]);
  final growthTrend =
      _extractPercent(telemetryText, ['growth_trend', 'event_growth']) ?? 0.02;
  final scalingCapacity = (telemetryVolume * (1 + growthTrend)).toStringAsFixed(
    0,
  );

  final recommendations = _generateRecommendations(
    stabilityScore,
    growthTrend,
    adaptivePatch,
  );

  await _writePlan(
    stabilityScore,
    growthTrend,
    scalingCapacity,
    recommendations,
  );
  _emitTelemetry(stabilityScore, growthTrend, recommendations);
}

Future<String> _readFileIfExists(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
}

Future<Map<String, dynamic>?> _readJsonIfExists(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return null;
  }
  try {
    final content = await file.readAsString();
    final decoded = jsonDecode(content);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    return null;
  }
  return null;
}

double? _extractPercent(String content, List<String> keys) {
  final value = _extractNumber(content, keys);
  if (value == 0) return null;
  return value > 1 ? value / 100 : value;
}

double _extractNumber(String content, List<String> keys) {
  if (content.isEmpty) return 0;
  for (final key in keys) {
    final regex = RegExp(
      '$key\\s*[:=]\\s*([0-9]+\\.?[0-9]*)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(content);
    if (match != null) {
      final value = double.tryParse(match.group(1)!);
      if (value != null) {
        return value;
      }
    }
  }
  return 0;
}

Map<String, String> _generateRecommendations(
  num stabilityScore,
  double growthTrend,
  Map<String, dynamic> adaptivePatch,
) {
  final backupFrequency = stabilityScore >= 85
      ? 'Weekly differential'
      : 'Daily incremental';
  final dataRotation = growthTrend >= 0.05
      ? 'Rotate telemetry logs every 30 days'
      : 'Rotate telemetry logs every 60 days';
  final ciInterval = adaptivePatch.isEmpty
      ? 'CI re-validation every 72h'
      : 'CI re-validation every 48h (active tuning)';
  final storageGrowth = (growthTrend * 90).clamp(0.05, 0.3);
  final expectedGrowth =
      'Projected telemetry/storage growth ~${(storageGrowth * 100).toStringAsFixed(1)}% next 90 days';

  return <String, String>{
    'backup_frequency': backupFrequency,
    'data_rotation': dataRotation,
    'ci_interval': ciInterval,
    'storage_outlook': expectedGrowth,
  };
}

Future<void> _writePlan(
  num stabilityScore,
  double growthTrend,
  String scalingCapacity,
  Map<String, String> recommendations,
) async {
  final file = File('release/_reports/stability_scaling_plan.txt');
  await file.parent.create(recursive: true);
  final buffer = StringBuffer()
    ..writeln('Stability & Scaling Plan')
    ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Stability Score: ${stabilityScore.toStringAsFixed(2)}')
    ..writeln('Growth Trend: ${(growthTrend * 100).toStringAsFixed(2)}%')
    ..writeln('Scaling Capacity (events/day): $scalingCapacity')
    ..writeln('')
    ..writeln('Recommendations:')
    ..writeln('- Backup frequency: ${recommendations['backup_frequency']}')
    ..writeln('- Data rotation: ${recommendations['data_rotation']}')
    ..writeln('- CI re-validation: ${recommendations['ci_interval']}')
    ..writeln('- Storage outlook: ${recommendations['storage_outlook']}');
  await file.writeAsString(buffer.toString());
}

void _emitTelemetry(
  num stabilityScore,
  double growthTrend,
  Map<String, String> recommendations,
) {
  final payload = <String, Object>{
    'event': 'stability_scaling_plan_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'score': stabilityScore,
    'growthRate': growthTrend,
    'recommendations': recommendations,
  };
  stdout.writeln(jsonEncode(payload));
}
