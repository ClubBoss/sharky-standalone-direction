import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main(List<String> args) async {
  final report = await _buildReport();

  final sign = report.drift >= 0 ? '+' : '';
  final status = report.pass ? 'PASS' : 'FAIL';
  stdout.writeln(
    'Adaptive Report: $status (${report.grade}, drift $sign${(report.drift * 100).toStringAsFixed(1)} %, '
    'fps ${report.fpsAverage.toStringAsFixed(1)} avg, stability ${report.stability.toStringAsFixed(2)})',
  );

  final jsonPayload = {
    'fps_avg': double.parse(report.fpsAverage.toStringAsFixed(2)),
    'xp_avg': double.parse(report.xpAverage.toStringAsFixed(3)),
    'refill_avg': double.parse(report.refillAverage.toStringAsFixed(2)),
    'drift': double.parse(report.drift.toStringAsFixed(4)),
    'risk': double.parse(report.risk.toStringAsFixed(4)),
    'stability': double.parse(report.stability.toStringAsFixed(4)),
    'ux_score': double.parse(report.uxScore.toStringAsFixed(3)),
    'grade': report.grade,
    'pass': report.pass,
    'timestamp': report.generatedAt.toIso8601String(),
  };

  stdout.writeln(jsonEncode(jsonPayload));
  await File('adaptive_report.json').writeAsString(jsonEncode(jsonPayload));
}

Future<_AdaptiveReport> _buildReport() async {
  final tuning = await _readJson('economy_tuning.json');
  final dynamicMetrics = await _readJson('economy_dynamic_metrics.json');
  final analyzer = await _readJson('economy_telemetry_analyzer.json');
  final betaMetrics = await _readJson('beta_metrics.json');
  final uiPerf = await _readJson('ui_perf_metrics.json');
  final health = await _readJson('health_dashboard.json');
  final recalLog = await _readLog('economy_recalibration_log.jsonl', 50);

  // FPS
  final fpsValues = <double>[
    if (_asDouble(dynamicMetrics?['fpsAvg']) > 0)
      _asDouble(dynamicMetrics?['fpsAvg']),
    if (_asDouble(analyzer?['fps_avg']) > 0) _asDouble(analyzer?['fps_avg']),
    if (_asDouble(uiPerf?['fps_avg']) > 0) _asDouble(uiPerf?['fps_avg']),
    if (_asDouble(betaMetrics?['avg_fps']) > 0)
      _asDouble(betaMetrics?['avg_fps']),
  ].where((v) => v > 0).toList();
  final fpsAvg = fpsValues.isEmpty
      ? 0.0
      : fpsValues.reduce((a, b) => a + b) / fpsValues.length;

  // XP factor
  final xpValues = <double>[
    if (_asDouble(tuning?['xpFactor'] ?? tuning?['xp_factor']) > 0)
      _asDouble(tuning?['xpFactor'] ?? tuning?['xp_factor']),
    if (_asDouble(dynamicMetrics?['xpFactor']) > 0)
      _asDouble(dynamicMetrics?['xpFactor']),
    if (_asDouble(analyzer?['xp_avg']) > 0) _asDouble(analyzer?['xp_avg']),
  ].where((v) => v > 0).toList();
  final xpAvg = xpValues.isEmpty
      ? 1.0
      : xpValues.reduce((a, b) => a + b) / xpValues.length;

  // Refill interval
  final refillValues = <double>[
    if (_asDouble(tuning?['refillMinutes'] ?? tuning?['refill']) > 0)
      _asDouble(tuning?['refillMinutes'] ?? tuning?['refill']),
    if (_asDouble(dynamicMetrics?['energyInterval']) > 0)
      _asDouble(dynamicMetrics?['energyInterval']),
    if (_asDouble(analyzer?['refill_avg']) > 0)
      _asDouble(analyzer?['refill_avg']),
  ].where((v) => v > 0).toList();
  final refillAvg = refillValues.isEmpty
      ? 30.0
      : refillValues.reduce((a, b) => a + b) / refillValues.length;

  final drift = _asDouble(analyzer?['drift']);
  final risk = _asDouble(
    analyzer?['risk'],
    fallback: _sigmoid(drift.abs() * 10),
  );

  final stability =
      (1 - drift.abs()).clamp(0.0, 1.0) *
      _safeDiv(xpAvg, refillAvg / 30.0).clamp(0.5, 1.5);

  final uxScore = _computeUxScore(health);

  final recalAverage = recalLog.isEmpty
      ? 0.0
      : recalLog
                .map((e) => _asDouble(e['adjustments']?['xp_adj'] ?? 0.0).abs())
                .fold<double>(0.0, (a, b) => a + b) /
            recalLog.length;

  final gradeScore = _computeGradeScore(
    fps: fpsAvg,
    xp: xpAvg,
    refill: refillAvg,
    drift: drift,
    risk: risk,
    stability: stability,
    ux: uxScore,
    recalibrationAvg: recalAverage,
  );

  final grade = _gradeFromScore(gradeScore);
  final pass = grade != 'D' && risk < 0.8;

  return _AdaptiveReport(
    fpsAverage: fpsAvg,
    xpAverage: xpAvg,
    refillAverage: refillAvg,
    drift: drift,
    risk: risk,
    stability: stability,
    uxScore: uxScore,
    grade: grade,
    pass: pass,
    generatedAt: DateTime.now(),
  );
}

double _computeGradeScore({
  required double fps,
  required double xp,
  required double refill,
  required double drift,
  required double risk,
  required double stability,
  required double ux,
  required double recalibrationAvg,
}) {
  double score = 0;
  score += _normalize(fps, 45, 60) * 25;
  score += (1 - (xp - 1).abs()).clamp(0.0, 1.0) * 15;
  score += (1 - ((refill - 30).abs() / 30)).clamp(0.0, 1.0) * 10;
  score += (1 - drift.abs()).clamp(0.0, 1.0) * 15;
  score += (1 - risk.clamp(0.0, 1.0)) * 20;
  score += stability.clamp(0.0, 1.0) * 10;
  score += ux.clamp(0.0, 1.0) * 10;
  score -=
      recalibrationAvg.clamp(0.0, 0.2) *
      100; // frequent recalibration lowers score
  if (score < 0) score = 0;
  if (score > 100) score = 100;
  return score;
}

String _gradeFromScore(double score) {
  if (score >= 85) return 'A';
  if (score >= 70) return 'B';
  if (score >= 55) return 'C';
  return 'D';
}

double _computeUxScore(Map<String, dynamic>? health) {
  if (health == null) return 0.5;
  final uxScan = health['ux_qa_scan'];
  if (uxScan is Map) {
    final pass = uxScan['pass'] == true;
    final hard = _asDouble(uxScan['hardcoded'], fallback: 0);
    final inline = _asDouble(uxScan['inline_colors'], fallback: 0);
    final penalty = min(1.0, (hard + inline) / 50.0);
    final score = (1 - penalty).clamp(0.0, 1.0);
    return pass ? score : score * 0.6;
  }
  final quality = health['quality'];
  if (quality is Map) {
    final score = _asDouble(quality['score']) / 100.0;
    if (score > 0) return score.clamp(0.0, 1.0);
  }
  return 0.5;
}

double _normalize(double value, double minValue, double maxValue) {
  if (maxValue - minValue == 0) return 0.0;
  final n = (value - minValue) / (maxValue - minValue);
  return n.clamp(0.0, 1.0);
}

double _safeDiv(double a, double b) => b == 0 ? 0.0 : a / b;

double _sigmoid(double x) => 1 / (1 + exp(-x));

double _asDouble(Object? value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

Future<Map<String, dynamic>?> _readJson(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  try {
    final content = await file.readAsString();
    final data = jsonDecode(content);
    if (data is Map<String, dynamic>) return data;
  } catch (_) {}
  return null;
}

Future<List<Map<String, dynamic>>> _readLog(String path, int limit) async {
  final file = File(path);
  if (!await file.exists()) return const [];
  try {
    final lines = await file.readAsLines();
    final entries = <Map<String, dynamic>>[];
    for (final line in lines.reversed) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line);
        if (json is Map<String, dynamic>) entries.add(json);
        if (entries.length >= limit) break;
      } catch (_) {
        continue;
      }
    }
    return entries;
  } catch (_) {
    return const [];
  }
}

class _AdaptiveReport {
  final double fpsAverage;
  final double xpAverage;
  final double refillAverage;
  final double drift;
  final double risk;
  final double stability;
  final double uxScore;
  final String grade;
  final bool pass;
  final DateTime generatedAt;

  _AdaptiveReport({
    required this.fpsAverage,
    required this.xpAverage,
    required this.refillAverage,
    required this.drift,
    required this.risk,
    required this.stability,
    required this.uxScore,
    required this.grade,
    required this.pass,
    required this.generatedAt,
  });
}
