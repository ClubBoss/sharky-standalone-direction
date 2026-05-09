import 'dart:convert';
import 'dart:io';

/// Adaptive Behavior Tuner (Stage 19B)
///
/// Reads telemetry/*.jsonl and adaptive_learning_summary.json to derive a
/// deterministic behaviorBias in [-1..+1] and an adjustmentFactor in
/// [0.75..1.25] via: adjustment = clamp(1 + bias * 0.25, 0.75, 1.25).
///
/// Behavioral signals considered:
/// - mistake: explicit event type or correct == false
/// - hint_used: explicit flag or event type containing 'hint'
/// - quick_correct: explicit type or (correct == true && solveMs <= 8000)
///
/// Outputs a compact dashboard block and writes a detailed
/// adaptive_behavior_summary.json for inspection.
Future<Map<String, Object>> runAdaptiveBehaviorTuner() async {
  final events = await _readTelemetryEvents();
  final learning = await _readLearningSummary();

  final stats = _analyzeBehavior(events);
  final bias = _computeBias(stats);
  final adjustment = _computeAdjustment(bias);

  final detail = <String, Object>{
    'counts': {
      'mistake': stats.mistakes,
      'hint_used': stats.hints,
      'quick_correct': stats.quickCorrect,
      'totalEvents': events.length,
    },
    'weights': {'mistake': -1.0, 'hint_used': -0.5, 'quick_correct': 1.0},
    'bias': _round2(bias * 100), // percent for readability
    'adjustmentFactor': _round2(adjustment),
    if (learning.isNotEmpty) 'learning': learning,
    'timestamp': DateTime.now().toIso8601String(),
  };

  await File(
    'adaptive_behavior_summary.json',
  ).writeAsString(jsonEncode(detail));

  final pass = true; // tools-only signal; do not fail CI on absence of data
  return {
    'bias': _round2(bias * 100), // percent
    'adjustment': _round2(adjustment),
    'pass': pass,
  };
}

class _BehaviorStats {
  final int mistakes;
  final int hints;
  final int quickCorrect;
  const _BehaviorStats(this.mistakes, this.hints, this.quickCorrect);
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
        } catch (_) {}
      }
    } catch (_) {}
  }
  return events;
}

Future<Map<String, Object>> _readLearningSummary() async {
  final file = File('adaptive_learning_summary.json');
  if (!await file.exists()) return <String, Object>{};
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) return Map<String, Object>.from(data);
  } catch (_) {}
  return <String, Object>{};
}

_BehaviorStats _analyzeBehavior(List<Map<String, Object?>> events) {
  int mistakes = 0;
  int hints = 0;
  int quick = 0;

  for (final e in events) {
    final type =
        (e['type'] ?? e['event'] ?? e['name'])?.toString().toLowerCase() ?? '';
    final correctFlag = _asBool(e['correct']);
    final resultStr = (e['result'] as String?)?.toLowerCase();
    final outcomeStr = (e['outcome'] as String?)?.toLowerCase();
    final isMistake =
        type.contains('mistake') ||
        (correctFlag == false) ||
        (resultStr == 'fail' || resultStr == 'failure') ||
        (outcomeStr == 'loss' || outcomeStr == 'lose');
    if (isMistake) mistakes++;

    final hintFlag =
        _asBool(e['hint']) == true ||
        _asBool(e['hint_used']) == true ||
        type.contains('hint');
    if (hintFlag) hints++;

    // quick_correct by explicit type or fast successful solve
    final solveMs = _firstNum([
      e['timeMs'],
      e['solveTimeMs'],
      e['durationMs'],
    ])?.toDouble();
    final isCorrect =
        (correctFlag == true) ||
        (resultStr == 'success' || resultStr == 'pass');
    final fast = solveMs != null && solveMs <= 8000.0; // 8s threshold
    final isQuickCorrect =
        type.contains('quick_correct') || (isCorrect && fast);
    if (isQuickCorrect) quick++;
  }

  return _BehaviorStats(mistakes, hints, quick);
}

double _computeBias(_BehaviorStats s) {
  final neg = s.mistakes * 1.0 + s.hints * 0.5;
  final pos = s.quickCorrect * 1.0;
  final den = neg + pos;
  if (den <= 0) return 0.0;
  final raw = (pos - neg) / den; // [-1..+1]
  if (raw < -1) return -1;
  if (raw > 1) return 1;
  return raw;
}

double _computeAdjustment(double bias) {
  double f = 1.0 + bias * 0.25;
  if (f < 0.75) f = 0.75;
  if (f > 1.25) f = 1.25;
  return f;
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

num? _firstNum(List<Object?> values) {
  for (final v in values) {
    if (v is num) return v;
    if (v is String) {
      final p = num.tryParse(v);
      if (p != null) return p;
    }
  }
  return null;
}

double _round2(double v) => double.parse(v.toStringAsFixed(2));
