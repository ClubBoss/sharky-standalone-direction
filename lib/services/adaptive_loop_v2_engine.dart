import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// Adaptive Loop V2 Engine
///
/// Consumes telemetry, semantic audit quality, and user performance snapshots
/// to recalibrate training difficulty weights for SmartTrainingPlanner.
Future<Map<String, Object>> runAdaptiveLoopV2({
  String telemetryPath = 'session_analytics.json',
  String semanticAuditPath = 'tools/_reports/content_semantic_audit.json',
  String performancePath = 'user_performance.json',
  String plannerSummaryPath = 'adaptive_learning_summary.json',
  String telemetryLogPath = 'telemetry/adaptive_loop_recalibrated.log',
  String reportPath = 'adaptive_loop_v2_report.json',
}) async {
  final telemetry = await _loadTelemetry(telemetryPath);
  final performance = await _loadPerformance(performancePath);
  final semantic = await _loadSemanticAudit(semanticAuditPath);

  final loopStats = _computeLoopStats(telemetry);
  final perfStats = _computePerformanceStats(performance);
  final semanticStats = _computeSemanticStats(semantic);

  final difficultyMultiplier = _computeDifficultyMultiplier(
    perfStats,
    semanticStats,
    loopStats,
  );
  final repetitionRate = _computeRepetitionRate(
    loopStats,
    semanticStats,
    perfStats,
  );
  final plannerWeights = _computePlannerWeights(
    perfStats,
    semanticStats,
    loopStats,
  );

  final recalibration = {
    'timestamp': DateTime.now().toIso8601String(),
    'difficultyMultiplier': _round2(difficultyMultiplier),
    'topicRepetitionRate': _round2(repetitionRate),
    'plannerWeights': plannerWeights,
    'telemetrySummary': loopStats.toJson(),
    'performanceSummary': perfStats.toJson(),
    'semanticSummary': semanticStats.toJson(),
    'pass': true,
  };

  await _updatePlannerSummary(plannerSummaryPath, recalibration);

  await _appendTelemetryLog(telemetryLogPath, recalibration);
  await File(reportPath).writeAsString(jsonEncode(recalibration));

  return recalibration;
}

Future<List<_TelemetryEvent>> _loadTelemetry(String path) async {
  final file = File(path);
  if (!await file.exists()) return const [];

  try {
    final raw = await file.readAsString();
    if (raw.trim().startsWith('[')) {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .whereType<Map>()
            .map(_TelemetryEvent.fromMap)
            .whereType<_TelemetryEvent>()
            .toList();
      }
    }
    final events = <_TelemetryEvent>[];
    for (final line in raw.split('\n')) {
      if (line.trim().isEmpty) continue;
      try {
        final data = jsonDecode(line);
        if (data is Map) {
          final event = _TelemetryEvent.fromMap(data);
          if (event != null) events.add(event);
        }
      } catch (_) {
        continue;
      }
    }
    return events;
  } catch (_) {
    return const [];
  }
}

Future<Map<String, dynamic>> _loadPerformance(String path) async {
  final file = File(path);
  if (!await file.exists()) return const {};
  try {
    final data = jsonDecode(await file.readAsString());
    return data is Map<String, dynamic> ? data : const {};
  } catch (_) {
    return const {};
  }
}

Future<Map<String, dynamic>> _loadSemanticAudit(String path) async {
  final file = File(path);
  if (!await file.exists()) return const {};
  try {
    final data = jsonDecode(await file.readAsString());
    return data is Map<String, dynamic> ? data : const {};
  } catch (_) {
    return const {};
  }
}

_LoopStats _computeLoopStats(List<_TelemetryEvent> events) {
  if (events.isEmpty) return const _LoopStats();

  int sessions = 0;
  int loopsCompleted = 0;
  final sessionDurations = <double>[];
  DateTime? currentSessionStart;

  for (final event in events) {
    switch (event.type) {
      case 'session_start':
        currentSessionStart = event.timestamp;
        sessions++;
        break;
      case 'session_end':
        if (currentSessionStart != null &&
            !event.timestamp.isBefore(currentSessionStart)) {
          final duration = event.timestamp
              .difference(currentSessionStart)
              .inMinutes;
          if (duration > 0) {
            sessionDurations.add(duration.toDouble());
          }
        }
        currentSessionStart = null;
        break;
      case 'loop_progress_completed':
        loopsCompleted++;
        break;
      default:
        break;
    }
  }

  final avgSessionLength = sessionDurations.isEmpty
      ? 0.0
      : sessionDurations.reduce((a, b) => a + b) / sessionDurations.length;
  return _LoopStats(
    sessions: sessions,
    loopsCompleted: loopsCompleted,
    averageSessionMinutes: avgSessionLength,
  );
}

_PerformanceStats _computePerformanceStats(Map<String, dynamic> data) {
  final xp =
      (data['xp'] as num?)?.toDouble() ??
      (data['xp_total'] as num?)?.toDouble() ??
      0.0;
  final errorRate =
      (data['error_rate'] as num?)?.toDouble() ??
      (data['mistake_rate'] as num?)?.toDouble() ??
      0.2;
  final streaks = data['streaks'];
  final currentStreak = (streaks is Map ? streaks['current'] : null) as num?;
  final fatigue =
      (data['fatigue_index'] as num?)?.toDouble() ??
      max(0.0, (data['average_session_minutes'] as num?)?.toDouble() ?? 0.0) /
          90.0;

  return _PerformanceStats(
    errorRate: errorRate.clamp(0.0, 1.0),
    xp: xp,
    currentStreak: (currentStreak ?? 0).toDouble(),
    fatigueIndex: fatigue.clamp(0.0, 1.0),
  );
}

_SemanticStats _computeSemanticStats(Map<String, dynamic> data) {
  if (data.isEmpty) {
    return const _SemanticStats(alignedRatio: 1.0, weakCount: 0, totalPacks: 0);
  }
  final aligned = (data['aligned_packs'] as num?)?.toDouble() ?? 0.0;
  final total = (data['packs'] as num?)?.toDouble() ?? 0.0;
  final weak = (data['weak_packs'] as num?)?.toInt() ?? 0;
  final ratio = total > 0 ? (aligned / total).clamp(0.0, 1.0) : 1.0;

  double coverageBalance = 1.0;
  final coverage = data['coverage'];
  if (coverage is Map<String, dynamic> && coverage.isNotEmpty) {
    final values = coverage.values
        .whereType<num>()
        .map((v) => v.toDouble())
        .toList();
    if (values.isNotEmpty) {
      final mean = values.reduce((a, b) => a + b) / values.length;
      final variance =
          values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
          values.length;
      final stdDev = sqrt(variance);
      coverageBalance = (1.0 - (stdDev / 100.0)).clamp(0.4, 1.0);
    }
  }

  return _SemanticStats(
    alignedRatio: ratio,
    weakCount: weak,
    totalPacks: total.toInt(),
    coverageBalance: coverageBalance,
  );
}

double _computeDifficultyMultiplier(
  _PerformanceStats perf,
  _SemanticStats semantic,
  _LoopStats loop,
) {
  final baseline = 1.0;
  final errorImpact = (perf.errorRate - 0.2) * 0.6;
  final streakRelief = perf.currentStreak * 0.015;
  final semanticPressure = (1.0 - semantic.alignedRatio) * 0.5;
  final fatigueGuard = -perf.fatigueIndex * 0.3;
  final loopMomentum = loop.sessions > 0
      ? min(0.2, loop.loopsCompleted / (loop.sessions * 10.0))
      : 0.0;

  final result =
      baseline +
      errorImpact -
      streakRelief +
      semanticPressure +
      fatigueGuard +
      loopMomentum;
  return result.clamp(0.7, 1.4);
}

double _computeRepetitionRate(
  _LoopStats loop,
  _SemanticStats semantic,
  _PerformanceStats perf,
) {
  final base = 0.25;
  final weakPenalty = (semantic.weakCount / max(1, semantic.totalPacks)) * 0.6;
  final fatigueRelief = perf.fatigueIndex * -0.1;
  final loopDrive = loop.sessions == 0
      ? 0.0
      : min(0.3, loop.loopsCompleted / (loop.sessions * 5.0));

  final result = base + weakPenalty + fatigueRelief + loopDrive;
  return result.clamp(0.1, 0.8);
}

Map<String, double> _computePlannerWeights(
  _PerformanceStats perf,
  _SemanticStats semantic,
  _LoopStats loop,
) {
  final retry = 0.25 + perf.errorRate * 0.35;
  final checkpoint = 0.2 + (1.0 - semantic.alignedRatio) * 0.5;
  final weekly = 0.15 + perf.fatigueIndex * 0.2;
  final nextTopic =
      0.2 + semantic.coverageBalance * 0.3 + loop.loopsCompleted * 0.02;

  final rawWeights = {
    'retry': retry,
    'checkpoint': checkpoint,
    'weekly': weekly,
    'next_topic': nextTopic,
  };
  final sum = rawWeights.values.reduce((a, b) => a + b);
  final normalized = sum == 0
      ? rawWeights.map((key, value) => MapEntry(key, 0.25))
      : rawWeights.map(
          (key, value) =>
              MapEntry(key, _round2((value / sum).clamp(0.05, 0.6))),
        );

  final adjustmentSum = normalized.values.reduce((a, b) => a + b);
  final diff = adjustmentSum - 1.0;
  if (diff.abs() > 0.001) {
    final correction = diff / normalized.length;
    return normalized.map(
      (key, value) =>
          MapEntry(key, _round2((value - correction).clamp(0.05, 0.6))),
    );
  }
  return normalized;
}

Future<void> _updatePlannerSummary(
  String path,
  Map<String, Object> recalibration,
) async {
  final file = File(path);
  Map<String, dynamic> existing = const {};
  if (await file.exists()) {
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is Map<String, dynamic>) {
        existing = data;
      }
    } catch (_) {
      existing = const {};
    }
  }

  final updated = Map<String, dynamic>.from(existing)
    ..['loop_v2'] = recalibration
    ..['timestamp_v2'] = DateTime.now().toIso8601String();

  await file.writeAsString(jsonEncode(updated));
}

Future<void> _appendTelemetryLog(
  String path,
  Map<String, Object> recalibration,
) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    '${jsonEncode(recalibration)}\n',
    mode: FileMode.append,
  );
}

double _round2(double value) => double.parse(value.toStringAsFixed(2));

class _TelemetryEvent {
  const _TelemetryEvent({required this.type, required this.timestamp});

  final String type;
  final DateTime timestamp;

  static _TelemetryEvent? fromMap(Map<dynamic, dynamic> map) {
    final type = map['type']?.toString();
    final ts = map['timestamp']?.toString();
    if (type == null || ts == null) return null;
    DateTime? parsed;
    try {
      parsed = DateTime.parse(ts).toUtc();
    } catch (_) {
      return null;
    }
    return _TelemetryEvent(type: type, timestamp: parsed);
  }
}

class _LoopStats {
  const _LoopStats({
    this.sessions = 0,
    this.loopsCompleted = 0,
    this.averageSessionMinutes = 0.0,
  });

  final int sessions;
  final int loopsCompleted;
  final double averageSessionMinutes;

  Map<String, Object> toJson() => {
    'sessions': sessions,
    'loopsCompleted': loopsCompleted,
    'averageSessionMinutes': _round2(averageSessionMinutes),
  };
}

class _PerformanceStats {
  const _PerformanceStats({
    required this.errorRate,
    required this.xp,
    required this.currentStreak,
    required this.fatigueIndex,
  });

  final double errorRate;
  final double xp;
  final double currentStreak;
  final double fatigueIndex;

  Map<String, Object> toJson() => {
    'errorRate': _round2(errorRate),
    'xp': _round2(xp),
    'currentStreak': _round2(currentStreak),
    'fatigueIndex': _round2(fatigueIndex),
  };
}

class _SemanticStats {
  const _SemanticStats({
    required this.alignedRatio,
    required this.weakCount,
    required this.totalPacks,
    this.coverageBalance = 1.0,
  });

  final double alignedRatio;
  final int weakCount;
  final int totalPacks;
  final double coverageBalance;

  Map<String, Object> toJson() => {
    'alignedRatio': _round2(alignedRatio),
    'weakCount': weakCount,
    'totalPacks': totalPacks,
    'coverageBalance': _round2(coverageBalance),
  };
}
