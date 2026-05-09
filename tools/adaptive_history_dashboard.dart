import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final records = <Map<String, dynamic>>[];

  final report = await _readJson('adaptive_report.json');
  if (report != null) {
    records.add(
      _buildRecord(
        source: 'report',
        timestamp: report['timestamp'],
        fps: report['fps_avg'],
        drift: report['drift'],
        stability: report['stability'],
        grade: report['grade'],
        pass: report['pass'],
      ),
    );
  }

  final sim = await _readJson('adaptive_simulation.json');
  if (sim != null) {
    records.add(
      _buildRecord(
        source: 'simulation',
        timestamp: sim['timestamp'],
        fps: sim['avg_fps'],
        drift: sim['drift'],
        stability: sim['stability'],
        grade: sim['pass'] == true ? 'A' : 'C',
        pass: sim['pass'],
      ),
    );
  }

  final recalLog = await _readLog('economy_recalibration_log.jsonl', 50);
  for (final entry in recalLog) {
    records.add(
      _buildRecord(
        source: 'recalibration',
        timestamp: entry['timestamp'],
        fps: null,
        drift: entry['drift'],
        stability:
            1 - (entry['drift'] is num ? (entry['drift'] as num).abs() : 0.0),
        grade: 'N/A',
        pass: true,
      ),
    );
  }

  records.sort((a, b) {
    final ta = DateTime.parse(a['timestamp'] as String);
    final tb = DateTime.parse(b['timestamp'] as String);
    return ta.compareTo(tb);
  });

  final metrics = _computeMetrics(records);

  final trendSign = metrics.trend >= 0 ? '+' : '';
  final gradeTrend = '${metrics.gradeStart}→${metrics.gradeEnd}';
  final status = metrics.pass ? 'PASS' : 'FAIL';
  stdout.writeln(
    'Adaptive History: $status (stability $trendSign${(metrics.trend * 100).toStringAsFixed(1)} %, grade $gradeTrend)',
  );
  stdout.writeln(
    jsonEncode({
      'records': records,
      'trend': double.parse(metrics.trend.toStringAsFixed(4)),
      'grade_start': metrics.gradeStart,
      'grade_end': metrics.gradeEnd,
      'pass_ratio': double.parse(metrics.passRatio.toStringAsFixed(3)),
      'pass': metrics.pass,
    }),
  );

  await File('adaptive_history.json').writeAsString(
    jsonEncode({
      'records': records,
      'trend': metrics.trend,
      'grade_start': metrics.gradeStart,
      'grade_end': metrics.gradeEnd,
      'pass_ratio': metrics.passRatio,
      'pass': metrics.pass,
    }),
  );
}

class _HistoryMetrics {
  final double trend;
  final String gradeStart;
  final String gradeEnd;
  final double passRatio;
  final bool pass;

  _HistoryMetrics({
    required this.trend,
    required this.gradeStart,
    required this.gradeEnd,
    required this.passRatio,
    required this.pass,
  });
}

_HistoryMetrics _computeMetrics(List<Map<String, dynamic>> records) {
  if (records.isEmpty) {
    return _HistoryMetrics(
      trend: 0,
      gradeStart: 'N/A',
      gradeEnd: 'N/A',
      passRatio: 0,
      pass: false,
    );
  }
  final sorted = records
      .where((r) => r['stability'] is num)
      .map(Map<String, dynamic>.from)
      .toList();
  if (sorted.length < 2) {
    final grade = records.first['grade'] as String? ?? 'N/A';
    final passRatio = records.first['pass'] == true ? 1.0 : 0.0;
    return _HistoryMetrics(
      trend: 0,
      gradeStart: grade,
      gradeEnd: grade,
      passRatio: passRatio,
      pass: passRatio >= 0.7,
    );
  }

  sorted.sort(
    (a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String),
  );
  final first = sorted.first;
  final last = sorted.last;
  final stabilityFirst = (first['stability'] as num?)?.toDouble() ?? 0.0;
  final stabilityLast = (last['stability'] as num?)?.toDouble() ?? 0.0;

  final startTime = DateTime.parse(first['timestamp'] as String);
  final endTime = DateTime.parse(last['timestamp'] as String);
  final totalDays = endTime.difference(startTime).inDays.abs();
  final trend = totalDays == 0
      ? stabilityLast - stabilityFirst
      : (stabilityLast - stabilityFirst) / totalDays;

  final gradeStart = first['grade'] as String? ?? 'N/A';
  final gradeEnd = last['grade'] as String? ?? 'N/A';

  final passCount = records.where((r) => r['pass'] == true).length;
  final passRatio = passCount / records.length;

  final pass = trend >= -0.02 && passRatio >= 0.6;

  return _HistoryMetrics(
    trend: trend,
    gradeStart: gradeStart,
    gradeEnd: gradeEnd,
    passRatio: passRatio,
    pass: pass,
  );
}

Map<String, dynamic> _buildRecord({
  required String source,
  Object? timestamp,
  Object? fps,
  Object? drift,
  Object? stability,
  Object? grade,
  Object? pass,
}) {
  final tsString = timestamp is String
      ? timestamp
      : DateTime.now().toIso8601String();
  return {
    'source': source,
    'timestamp': tsString,
    'fps_avg': _asDouble(fps),
    'drift': _asDouble(drift),
    'stability': _asDouble(stability, fallback: 0.0),
    'grade': grade?.toString() ?? 'N/A',
    'pass': pass == true,
  };
}

Future<Map<String, dynamic>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return data;
  } catch (_) {}
  return null;
}

Future<List<Map<String, dynamic>>> _readLog(String path, int limit) async {
  final file = File(path);
  if (!await file.exists()) return const [];
  try {
    final lines = await file.readAsLines();
    final records = <Map<String, dynamic>>[];
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line);
        if (data is Map<String, dynamic>) records.add(data);
        if (records.length >= limit) break;
      } catch (_) {
        continue;
      }
    }
    return records;
  } catch (_) {
    return const [];
  }
}

double _asDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}
