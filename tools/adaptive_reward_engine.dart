import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

/// Computes adaptive reward drift across content spots given a player level.
///
/// Formula:
///   adjXp = xp * (1 + errorRate * 0.25 - level * 0.05)
///   factor clamped to [0.75, 1.25] (i.e., +/-25%)
///
/// errorRate source (deterministic, no randomness):
///   - If error_stats.json exists with { "<spot_id>": <0..1> }, use it.
///   - Else, derive from difficulty_score via a log mapping to avoid extremes:
///       errorRate = ln(1 + (d-1)) / ln(1 + 4), mapping d in [1..5] -> [0..1].
///
/// Returns a JSON-like map with average percent drift across all spots.
Future<Map<String, Object>> computeAdaptiveRewardDrift({
  required int playerLevel,
}) async {
  final contentDir = Directory('content');
  if (!await contentDir.exists()) {
    return {
      'avgPercent': 0.0,
      'count': 0,
      'pass': true,
      'errors': ['content/ directory not found'],
    };
  }

  // Optional explicit error stats file
  final errorStats = await _readErrorStats();

  int count = 0;
  double percentSum = 0.0;

  await for (final entity in contentDir.list(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path;
    if (!path.endsWith('.jsonl')) continue;

    final raw = await entity.readAsString();
    final lines = const LineSplitter().convert(raw);
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      dynamic obj;
      try {
        obj = jsonDecode(trimmed);
      } catch (_) {
        // skip invalid JSON lines (validator will handle)
        continue;
      }
      if (obj is! Map) continue;
      final xp = obj['xp_reward'];
      final d = obj['difficulty_score'];
      final id = obj['id']?.toString();
      if (xp is! num || xp <= 0 || d is! num) continue;

      final double baseXp = xp.toDouble();
      final double diff = d.toDouble();

      // Determine error rate
      final double errorRate = _deriveErrorRate(id, diff, errorStats);

      // Compute adaptation factor
      final rawFactor =
          1.0 + errorRate * 0.25 - (playerLevel.clamp(0, 10) * 0.05);
      // Clamp to +/- 25%
      final factor = rawFactor.clamp(0.75, 1.25);
      final adjXp = baseXp * factor;

      // Drift percent relative to base
      final driftPct = ((adjXp - baseXp) / baseXp) * 100.0;
      percentSum += driftPct;
      count++;
    }
  }

  final avg = count > 0
      ? double.parse((percentSum / count).toStringAsFixed(2))
      : 0.0;
  return {
    'avgPercent': avg,
    'count': count,
    'pass': true, // informational only; not a CI gate
  };
}

Future<Map<String, double>> _readErrorStats() async {
  final file = File('error_stats.json');
  if (!await file.exists()) return const {};
  try {
    final raw = await file.readAsString();
    final data = jsonDecode(raw);
    if (data is Map<String, dynamic>) {
      final out = <String, double>{};
      data.forEach((k, v) {
        final d = (v is num) ? v.toDouble() : double.tryParse(v.toString());
        if (d != null) {
          // clamp to [0,1]
          out[k] = d.clamp(0.0, 1.0);
        }
      });
      return out;
    }
  } catch (_) {}
  return const {};
}

double _deriveErrorRate(
  String? id,
  double difficulty,
  Map<String, double> stats,
) {
  if (id != null && stats.containsKey(id)) {
    return stats[id]!.clamp(0.0, 1.0);
  }
  // Log-scaled mapping: d in [1..5] -> [0..1]
  final x = (difficulty - 1.0).clamp(0.0, 4.0);
  final num = math.log(1.0 + x);
  final den = math.log(1.0 + 4.0);
  if (den == 0) return 0.0;
  final rate = (num / den);
  // Safety clamp
  return rate.clamp(0.0, 1.0);
}
