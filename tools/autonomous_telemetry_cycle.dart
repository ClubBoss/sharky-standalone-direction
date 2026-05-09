// Autonomous Telemetry Cycle (Stage Ψ-1)
// Pure Dart CLI: parses telemetry + UX metrics, computes retention & trends.
// Outputs ASCII report and telemetry event.

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final sw = Stopwatch()..start();
  final telemetryPath = 'telemetry_normalized.jsonl';
  final uxMetricsPath = 'ux_metrics.json';

  final events = await _readJsonl(telemetryPath);
  final ux = await _readJson(uxMetricsPath);

  final byDayUsers = _dailyActiveUsers(events);
  final dailyActives = byDayUsers.map((d, s) => MapEntry(d, s.length));
  final weeklyActives = _weeklyActiveUsers(byDayUsers);
  final retention = _retentionPercent(byDayUsers);
  final avgSession = _averageSessionDuration(events, ux);
  final trendIndex = _uxTrendIndex(ux, events);

  final report = StringBuffer()
    ..writeln('Autonomous Telemetry Summary')
    ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('\nDaily Active Users (DAU)')
    ..writeln(_asciiTableCounts(dailyActives))
    ..writeln('\nWeekly Active Users (WAU)')
    ..writeln(_asciiTableCounts(weeklyActives))
    ..writeln('\nRetention')
    ..writeln('Next-day retention: ${retention.toStringAsFixed(3)}')
    ..writeln('\nAverage Session Duration')
    ..writeln('${avgSession.toStringAsFixed(1)} sec')
    ..writeln('\nUX Trend Index (0-1)')
    ..writeln(trendIndex.toStringAsFixed(3))
    ..writeln('\nGraphs')
    ..writeln(_asciiBarGraph('DAU', dailyActives))
    ..writeln(_asciiBarGraph('WAU', weeklyActives));

  var outPath = 'release/_reports/autonomous_telemetry_summary.txt';
  try {
    await File(outPath).writeAsString(report.toString());
  } catch (_) {
    outPath = 'release/_exports/autonomous_telemetry_summary.txt';
    await File(outPath).writeAsString(report.toString());
  }

  final outTelemetry = {
    'event': 'autonomous_telemetry_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'retention': retention,
    'trend_index': trendIndex,
    'duration_ms': sw.elapsedMilliseconds,
  };
  final tPath = 'release/_exports/autonomous_telemetry_telemetry.jsonl';
  await File(
    tPath,
  ).writeAsString(jsonEncode(outTelemetry) + '\n', mode: FileMode.append);

  stdout.writeln('+-------------------------------+');
  stdout.writeln('| Autonomous Telemetry COMPLETE |');
  stdout.writeln('+-------------------------------+');
  stdout.writeln('Report: ' + outPath);
  stdout.writeln('Retention: ' + retention.toStringAsFixed(3));
  stdout.writeln('Trend Index: ' + trendIndex.toStringAsFixed(3));
  stdout.writeln('Duration ms: ${sw.elapsedMilliseconds}');
}

Future<List<Map<String, dynamic>>> _readJsonl(String path) async {
  final file = File(path);
  if (!file.existsSync()) return <Map<String, dynamic>>[];
  final lines = await file.readAsLines();
  final result = <Map<String, dynamic>>[];
  for (final l in lines) {
    if (l.trim().isEmpty) continue;
    try {
      final m = jsonDecode(l);
      if (m is Map<String, dynamic>) result.add(m);
    } catch (_) {}
  }
  return result;
}

Future<Map<String, dynamic>> _readJson(String path) async {
  final file = File(path);
  if (!file.existsSync()) return <String, dynamic>{};
  try {
    return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  } catch (_) {
    return <String, dynamic>{};
  }
}

Map<String, Set<String>> _dailyActiveUsers(List<Map<String, dynamic>> events) {
  final map = <String, Set<String>>{}; // date -> unique users
  for (final e in events) {
    final ts = (e['timestamp'] ?? e['time'])?.toString();
    final uid = (e['user_id'] ?? e['uid'] ?? e['user'])?.toString();
    if (ts == null || uid == null) continue;
    final day = DateTime.tryParse(ts)?.toUtc();
    if (day == null) continue;
    final key = _ymd(day);
    map.putIfAbsent(key, () => <String>{}).add(uid);
  }
  final sortedKeys = map.keys.toList()..sort();
  final out = <String, Set<String>>{};
  for (final k in sortedKeys) {
    out[k] = map[k]!..toList().sort();
  }
  return out;
}

Map<String, int> _weeklyActiveUsers(Map<String, Set<String>> daily) {
  if (daily.isEmpty) return <String, int>{};
  final keys = daily.keys.toList()..sort();
  final dates = keys.map(_parseYmd).toList();
  final out = <String, int>{};
  for (int i = 0; i < dates.length; i++) {
    final start = dates[i];
    final end = start.add(const Duration(days: 6));
    final users = <String>{};
    for (int j = i; j < dates.length; j++) {
      if (dates[j].isAfter(end)) break;
      users.addAll(daily[_ymd(dates[j])] ?? {});
    }
    out[_ymd(start)] = users.length;
  }
  return out;
}

double _retentionPercent(Map<String, Set<String>> daily) {
  if (daily.length < 2) return 0.0;
  final keys = daily.keys.toList()..sort();
  double sum = 0.0;
  int days = 0;
  for (int i = 0; i < keys.length - 1; i++) {
    final a = daily[keys[i]]!;
    final b = daily[keys[i + 1]]!;
    if (a.isEmpty) continue;
    final retained = a.intersection(b).length / a.length;
    sum += retained;
    days++;
  }
  return days == 0 ? 0.0 : sum / days;
}

double _averageSessionDuration(
  List<Map<String, dynamic>> events,
  Map<String, dynamic> ux,
) {
  // Prefer sessions with explicit duration; fallback to ux['avg_session_seconds']
  final durations = <double>[];
  for (final e in events) {
    if (e.containsKey('session_duration_sec')) {
      final v = (e['session_duration_sec'] as num).toDouble();
      if (v >= 0) durations.add(v);
    }
  }
  if (durations.isEmpty) {
    final n = ux['avg_session_seconds'];
    if (n is num) return n.toDouble();
    return 0.0;
  }
  final total = durations.fold<double>(0.0, (a, b) => a + b);
  return total / durations.length;
}

double _uxTrendIndex(
  Map<String, dynamic> ux,
  List<Map<String, dynamic>> events,
) {
  // Compose an index from normalized signals if present
  final stability = (ux['stability_score'] ?? ux['stability'] ?? 1.0) as num;
  final crashRate = (ux['crash_rate'] ?? 0.0) as num; // lower better
  final fps = (ux['avg_fps'] ?? 60.0) as num; // target 60
  // Normalize ranges to 0..1
  final fpsNorm = (fps.toDouble() / 60.0).clamp(0.0, 1.0);
  final crashNorm = (1.0 - crashRate.toDouble()).clamp(0.0, 1.0);
  final stabilityNorm = stability.toDouble().clamp(0.0, 1.0);
  final index = 0.5 * stabilityNorm + 0.3 * fpsNorm + 0.2 * crashNorm;
  return index;
}

String _asciiTableCounts(Map<String, int> data) {
  if (data.isEmpty) return '(no data)';
  final sb = StringBuffer()
    ..writeln('+------------+-------+')
    ..writeln('| Date       | Count |')
    ..writeln('+------------+-------+');
  for (final k in (data.keys.toList()..sort())) {
    final v = data[k] ?? 0;
    sb.writeln('| ${k.padRight(10)} | ${v.toString().padLeft(5)} |');
  }
  sb.writeln('+------------+-------+');
  return sb.toString();
}

String _asciiBarGraph(String title, Map<String, int> data) {
  if (data.isEmpty) return '$title: (no data)';
  final keys = data.keys.toList()..sort();
  final values = keys.map((k) => data[k] ?? 0).toList();
  final maxVal = values.fold<int>(0, (a, b) => a > b ? a : b);
  final scale = maxVal == 0 ? 1.0 : 40.0 / maxVal;
  final sb = StringBuffer()..writeln('[$title]');
  for (int i = 0; i < keys.length; i++) {
    final bar = '#' * (values[i] * scale).round();
    sb.writeln('${keys[i]} | $bar (${values[i]})');
  }
  return sb.toString();
}

String _ymd(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime _parseYmd(String s) {
  final parts = s.split('-');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
