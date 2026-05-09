import 'dart:convert';
import 'dart:io';

/// Adaptive Learning Core (Stage 19A)
///
/// Reads telemetry/*.jsonl, ui_metrics.json, and adaptive_loop_report.json to
/// compute a deterministic summary of the learner's current state:
/// - performanceFactor: combined correctness/winrate/speed score in [0..1]
/// - learningMomentum: stabilized momentum indicator in [0..1]
/// - fatiguePenalty: percent in [0..100]
///
/// Writes a detailed report to adaptive_learning_summary.json and returns a
/// compact map suitable for the Health Dashboard JSON block.
Future<Map<String, Object>> runAdaptiveLearningCore() async {
  final telemetry = await _readTelemetryEvents();
  final uiMetrics = await _readUiMetrics();
  final loopReport = await _readAdaptiveLoopReport();

  final perf = _computePerformance(telemetry);
  final momentum = _computeMomentum(perf, uiMetrics);
  final fatigue = _computeFatigue(telemetry, perf);

  final pass = momentum >= 0.5 && fatigue <= 40;

  final detail = <String, Object>{
    'performanceFactor': _round2(perf.performanceFactor),
    'correctRate': _round2(perf.correctRate),
    'winrate': _round2(perf.winrate),
    'avgSolveSec': _round2(perf.avgSolveSec),
    'events': perf.events.toInt(),
    'learningMomentum': _round2(momentum),
    'fatiguePenalty': fatigue,
    'ui_drift_history_len': (uiMetrics['adaptive_drift_history'] is List)
        ? (uiMetrics['adaptive_drift_history'] as List).length
        : 0,
    if (loopReport.isNotEmpty) 'loop': loopReport,
    'timestamp': DateTime.now().toIso8601String(),
  };

  // Persist detailed summary for CI/Dev inspection.
  await File(
    'adaptive_learning_summary.json',
  ).writeAsString(jsonEncode(detail));

  // Minimal block for dashboard consumption.
  return <String, Object>{
    'momentum': _round2(momentum),
    'fatigue': fatigue,
    'pass': pass,
  };
}

class _Perf {
  final double performanceFactor; // [0..1]
  final double correctRate; // [0..1]
  final double winrate; // [0..1]
  final double avgSolveSec; // >=0
  final int events; // count
  const _Perf({
    required this.performanceFactor,
    required this.correctRate,
    required this.winrate,
    required this.avgSolveSec,
    required this.events,
  });
}

Future<List<Map<String, Object?>>> _readTelemetryEvents() async {
  final dir = Directory('telemetry');
  if (!await dir.exists()) return const <Map<String, Object?>>[];
  final files =
      dir
          .listSync(followLinks: false)
          .whereType<File>()
          .where((f) => f.path.endsWith('.jsonl'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final events = <Map<String, Object?>>[];
  for (final f in files) {
    try {
      final lines = await f.readAsLines();
      for (final ln in lines) {
        final t = ln.trim();
        if (t.isEmpty) continue;
        try {
          final obj = jsonDecode(t);
          if (obj is Map<String, dynamic>) {
            events.add(Map<String, Object?>.from(obj));
          }
        } catch (_) {
          // skip malformed lines
        }
      }
    } catch (_) {
      // skip unreadable files
    }
  }
  return events;
}

Future<Map<String, Object>> _readUiMetrics() async {
  final file = File('ui_metrics.json');
  if (!await file.exists()) return <String, Object>{};
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return Map<String, Object>.from(data);
  } catch (_) {}
  return <String, Object>{};
}

Future<Map<String, Object>> _readAdaptiveLoopReport() async {
  // Prefer root-level report; fallback to build/adaptive_content
  final primary = File('adaptive_loop_report.json');
  if (await primary.exists()) {
    try {
      final raw = await primary.readAsString();
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        return Map<String, Object>.from(data);
      }
    } catch (_) {}
  }
  final alt = File('build/adaptive_content/adaptive_loop_report.json');
  if (await alt.exists()) {
    try {
      final raw = await alt.readAsString();
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        return Map<String, Object>.from(data);
      }
    } catch (_) {}
  }
  return <String, Object>{};
}

_Perf _computePerformance(List<Map<String, Object?>> events) {
  int correct = 0;
  int incorrect = 0;
  int wins = 0;
  int losses = 0;
  double totalSolveMs = 0.0;
  int solveCount = 0;

  for (final e in events) {
    final correctFlag =
        _asBool(e['correct']) ??
        (e['result'] is String
            ? (e['result'] as String).toLowerCase() == 'success' ||
                  (e['result'] as String).toLowerCase() == 'pass'
            : null);
    if (correctFlag == true) correct++;
    if (correctFlag == false) incorrect++;

    final winFlag =
        _asBool(e['win']) ??
        (e['outcome'] is String
            ? (e['outcome'] as String).toLowerCase() == 'win'
            : null);
    if (winFlag == true) wins++;
    if (winFlag == false) losses++;

    final solveMs = _firstNum([e['timeMs'], e['solveTimeMs'], e['durationMs']]);
    if (solveMs != null && solveMs >= 0) {
      totalSolveMs += solveMs.toDouble();
      solveCount++;
    }
  }

  final attempts = correct + incorrect;
  final correctRate = attempts > 0 ? correct / attempts : 0.5;
  final wrDen = wins + losses;
  final winrate = wrDen > 0 ? wins / wrDen : 0.5;
  final avgSolveSec = solveCount > 0
      ? (totalSolveMs / solveCount) / 1000.0
      : 15.0;

  // Speed score: 1.0 at 15s, ~0.2 at 60s, capped [0..1]
  double speedScore = 1.0 - ((avgSolveSec - 15.0) / 45.0);
  if (speedScore < 0) speedScore = 0;
  if (speedScore > 1) speedScore = 1;

  // Base skill: average of winrate and correctness
  final baseSkill = (winrate + correctRate) * 0.5;
  // Performance factor blends baseSkill with speed
  final performanceFactor = _clamp01(baseSkill * 0.7 + speedScore * 0.3);

  return _Perf(
    performanceFactor: performanceFactor,
    correctRate: correctRate,
    winrate: winrate,
    avgSolveSec: avgSolveSec,
    events: attempts > 0 ? attempts : (wrDen > 0 ? wrDen : solveCount),
  );
}

double _computeMomentum(_Perf perf, Map<String, Object> uiMetrics) {
  // Drift trend influence from ui_metrics.adaptive_drift_history
  double driftSlope = 0.0; // percentage points across history
  final hist = uiMetrics['adaptive_drift_history'];
  if (hist is List && hist.length >= 2) {
    final first = _asNum(hist.first)?.toDouble();
    final last = _asNum(hist.last)?.toDouble();
    if (first != null && last != null) {
      driftSlope = last - first; // e.g., -4.8 -> -2.3 delta = +2.5
    }
  }
  // Normalize slope into [-1..1] using a 25pp scale and invert sign so that
  // decreasing drift (more negative) lifts momentum slightly.
  double driftBoost = (-driftSlope) / 25.0;
  if (driftBoost < -1) driftBoost = -1;
  if (driftBoost > 1) driftBoost = 1;

  // Momentum is performance centered, stabilized by small drift effect.
  final m = perf.performanceFactor * 0.9 + (0.1 * ((driftBoost + 1) / 2));
  return _clamp01(m);
}

int _computeFatigue(List<Map<String, Object?>> events, _Perf perf) {
  final eCount = events.length;
  // Volume penalty grows with event volume; ~0% at 0, ~25% at 500, capped.
  double volumePenalty = (eCount / 500.0) * 25.0;
  if (volumePenalty > 30) volumePenalty = 30; // hard cap

  // Speed penalty if avg solve time > 20s; bonus (negative penalty) if < 12s.
  double speedPenalty = (perf.avgSolveSec - 20.0) * 1.5; // 10s over -> 15%
  if (speedPenalty < -10) speedPenalty = -10; // at fast speeds, reduce fatigue
  if (speedPenalty > 50) speedPenalty = 50;

  // Lower performance slightly increases perceived fatigue.
  final perfPenalty = (1.0 - perf.performanceFactor) * 20.0; // up to +20%

  double total = volumePenalty + speedPenalty + perfPenalty;
  if (total < 0) total = 0;
  if (total > 100) total = 100;
  return total.round();
}

bool? _asBool(Object? v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final t = v.toLowerCase().trim();
    if (t == 'true' || t == '1' || t == 'yes') return true;
    if (t == 'false' || t == '0' || t == 'no') return false;
  }
  return null;
}

num? _asNum(Object? v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

num? _firstNum(List<Object?> values) {
  for (final v in values) {
    final n = _asNum(v);
    if (n != null) return n;
  }
  return null;
}

double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

double _round2(double v) => double.parse(v.toStringAsFixed(2));
