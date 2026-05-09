import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

/// Evaluates telemetry for critical crash or stability regressions and
/// regenerates a recovery plan + telemetry marker when thresholds are violated.
class AutoRecoveryService {
  const AutoRecoveryService({
    this.telemetryPath = 'release/_reports/telemetry.jsonl',
    this.recoveryPlanPath = 'release/_reports/health_recovery_plan.txt',
    this.crashRateThreshold = 0.03,
    this.stabilityScoreThreshold = 0.8,
  });

  final String telemetryPath;
  final String recoveryPlanPath;
  final double crashRateThreshold;
  final double stabilityScoreThreshold;

  Future<AutoRecoveryMetrics> collectMetrics() async {
    final file = File(telemetryPath);
    if (!file.existsSync()) {
      return AutoRecoveryMetrics.empty();
    }
    final events = <_TelemetryEvent>[];
    final lines = await file.readAsLines();
    for (final raw in lines) {
      if (raw.trim().isEmpty) continue;
      try {
        final Map<String, dynamic> decoded =
            jsonDecode(raw) as Map<String, dynamic>;
        final name = decoded['event']?.toString() ?? 'unknown';
        final timestampRaw = decoded['timestamp']?.toString();
        final timestamp = timestampRaw != null
            ? DateTime.tryParse(timestampRaw)
            : null;
        events.add(_TelemetryEvent(name, decoded, timestamp));
      } catch (_) {
        // Skip malformed lines without crashing the monitor.
      }
    }
    return _summarize(events);
  }

  bool shouldTrigger(AutoRecoveryMetrics metrics) {
    if (metrics.isTelemetryMissing) {
      return false;
    }
    return metrics.crashRate > crashRateThreshold ||
        metrics.stabilityScore < stabilityScoreThreshold;
  }

  Future<AutoRecoveryResult> recover({
    AutoRecoveryMetrics? metrics,
    bool force = false,
  }) async {
    final summary = metrics ?? await collectMetrics();
    final reasons = <String>[];
    if (summary.crashRate > crashRateThreshold) {
      reasons.add(
        'crash_rate>${(summary.crashRate * 100).toStringAsFixed(2)}%',
      );
    }
    if (summary.stabilityScore < stabilityScoreThreshold) {
      reasons.add(
        'stability_score<${summary.stabilityScore.toStringAsFixed(3)}',
      );
    }
    if (summary.hotfixDetected) {
      reasons.add('hotfix_detected');
    }
    if (force && reasons.isEmpty) {
      reasons.add('forced');
    }
    final shouldRun = force || shouldTrigger(summary);
    if (!shouldRun) {
      return AutoRecoveryResult(
        metrics: summary,
        triggered: false,
        planPath: '',
        reasons: reasons,
      );
    }
    final planPath = await _writeRecoveryPlan(summary, reasons);
    await _emitTelemetry(summary, reasons, planPath);
    return AutoRecoveryResult(
      metrics: summary,
      triggered: true,
      planPath: planPath,
      reasons: reasons,
    );
  }

  AutoRecoveryMetrics _summarize(List<_TelemetryEvent> events) {
    if (events.isEmpty) {
      return AutoRecoveryMetrics.empty();
    }
    double? crashRate;
    double? crashFreeRate;
    double? stabilityScore;
    bool hotfixDetected = false;
    DateTime? lastHotfixAt;
    DateTime? lastAutotuneAt;
    final notes = <String>[];

    for (final event in events) {
      final name = event.name;
      if (name == 'postlaunch_hotfix_required') {
        hotfixDetected = true;
        lastHotfixAt = _newer(lastHotfixAt, event.timestamp);
      }
      if (name == TelemetryEvents.aiAutotunerCycleCompleted) {
        lastAutotuneAt = _newer(lastAutotuneAt, event.timestamp);
      }
      final crashSample = _extractCrashRate(event.payload);
      if (crashSample != null) {
        crashRate = crashSample;
      }
      final crashFreeSample = _extractCrashFreeRate(event.payload);
      if (crashFreeSample != null) {
        crashFreeRate = crashFreeSample;
      }
      final stabilitySample = _extractStabilityScore(event.payload);
      if (stabilitySample != null) {
        stabilityScore = stabilitySample;
      }
    }

    final computedCrashRate =
        crashRate ??
        (crashFreeRate != null ? (1 - crashFreeRate).clamp(0.0, 1.0) : 0.0);
    final computedStability = stabilityScore ?? 1.0;
    if (hotfixDetected && lastHotfixAt != null) {
      notes.add(
        'Hotfix requested at ${lastHotfixAt.toUtc().toIso8601String()}',
      );
    }
    if (lastAutotuneAt != null) {
      notes.add(
        'Last AI autotune cycle at ${lastAutotuneAt.toUtc().toIso8601String()}',
      );
    }
    return AutoRecoveryMetrics(
      crashRate: computedCrashRate,
      stabilityScore: computedStability,
      hotfixDetected: hotfixDetected,
      lastHotfixAt: lastHotfixAt,
      lastAutotuneAt: lastAutotuneAt,
      telemetryEvaluated: true,
      notes: notes,
    );
  }

  Future<String> _writeRecoveryPlan(
    AutoRecoveryMetrics metrics,
    List<String> reasons,
  ) async {
    final file = File(recoveryPlanPath);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Auto Recovery Health Plan')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('Crash Rate: ${(metrics.crashRate * 100).toStringAsFixed(2)}%')
      ..writeln('Stability Score: ${metrics.stabilityScore.toStringAsFixed(3)}')
      ..writeln('Hotfix Detected: ${metrics.hotfixDetected ? 'YES' : 'No'}')
      ..writeln(
        'Last Hotfix: ${metrics.lastHotfixAt?.toUtc().toIso8601String() ?? 'N/A'}',
      )
      ..writeln(
        'Last AI Autotune: ${metrics.lastAutotuneAt?.toUtc().toIso8601String() ?? 'N/A'}',
      )
      ..writeln(
        'Trigger Reasons: ${reasons.isEmpty ? 'n/a' : reasons.join(', ')}',
      )
      ..writeln('')
      ..writeln('Recommended Actions:')
      ..writeln('  1. Freeze deployments until crash telemetry stabilizes.')
      ..writeln(
        '  2. Regenerate stability scaling plan and rerun ai_reliability_audit.',
      )
      ..writeln(
        '  3. Coordinate with postlaunch owners to validate hotfix rollouts.',
      )
      ..writeln(
        '  4. Schedule UX + telemetry sweeps after recovery to confirm fixes.',
      );
    if (metrics.notes.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Context:');
      for (final note in metrics.notes) {
        buffer.writeln('  - $note');
      }
    }
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<void> _emitTelemetry(
    AutoRecoveryMetrics metrics,
    List<String> reasons,
    String planPath,
  ) async {
    final file = File(telemetryPath);
    await file.parent.create(recursive: true);
    final payload = <String, Object>{
      'event': TelemetryEvents.autoRecoveryTriggered,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'crash_rate': double.parse(metrics.crashRate.toStringAsFixed(4)),
      'stability_score': double.parse(
        metrics.stabilityScore.toStringAsFixed(4),
      ),
      'hotfix_detected': metrics.hotfixDetected,
      'plan_path': planPath,
      'reasons': reasons,
    };
    final line = '${jsonEncode(payload)}\n';
    await file.writeAsString(line, mode: FileMode.append, flush: true);
  }

  double? _extractCrashRate(Map<String, dynamic> payload) {
    const keys = <String>[
      'crash_rate',
      'crashRate',
      'crash_rate_percent',
      'crashPercent',
    ];
    for (final key in keys) {
      final value = _readDouble(payload[key]);
      if (value != null) {
        return _normalizePercent(value);
      }
    }
    return null;
  }

  double? _extractCrashFreeRate(Map<String, dynamic> payload) {
    const keys = <String>[
      'crash_free',
      'crashFree',
      'crash_free_percent',
      'crashFreePercent',
    ];
    for (final key in keys) {
      final value = _readDouble(payload[key]);
      if (value != null) {
        return _normalizePercent(value);
      }
    }
    return null;
  }

  double? _extractStabilityScore(Map<String, dynamic> payload) {
    const keys = <String>[
      'stability_score',
      'stabilityScore',
      'stability_index',
    ];
    for (final key in keys) {
      final value = _readDouble(payload[key]);
      if (value != null) {
        return value > 1
            ? (value / 100).clamp(0.0, 1.0)
            : value.clamp(0.0, 1.0);
      }
    }
    return null;
  }

  double? _readDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  double _normalizePercent(double value) =>
      value > 1 ? (value / 100).clamp(0.0, 1.0) : value.clamp(0.0, 1.0);

  DateTime? _newer(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }
}

class AutoRecoveryMetrics {
  AutoRecoveryMetrics({
    required this.crashRate,
    required this.stabilityScore,
    required this.hotfixDetected,
    required this.lastHotfixAt,
    required this.lastAutotuneAt,
    required this.telemetryEvaluated,
    required this.notes,
  });

  factory AutoRecoveryMetrics.empty() => AutoRecoveryMetrics(
    crashRate: 0.0,
    stabilityScore: 1.0,
    hotfixDetected: false,
    lastHotfixAt: null,
    lastAutotuneAt: null,
    telemetryEvaluated: false,
    notes: const <String>[],
  );

  final double crashRate;
  final double stabilityScore;
  final bool hotfixDetected;
  final DateTime? lastHotfixAt;
  final DateTime? lastAutotuneAt;
  final bool telemetryEvaluated;
  final List<String> notes;

  bool get isTelemetryMissing => !telemetryEvaluated;

  double get crashRatePercent => crashRate * 100;

  double get stabilityScorePercent => stabilityScore * 100;
}

class AutoRecoveryResult {
  AutoRecoveryResult({
    required this.metrics,
    required this.triggered,
    required this.planPath,
    required this.reasons,
  });

  final AutoRecoveryMetrics metrics;
  final bool triggered;
  final String planPath;
  final List<String> reasons;
}

class _TelemetryEvent {
  _TelemetryEvent(this.name, this.payload, this.timestamp);

  final String name;
  final Map<String, dynamic> payload;
  final DateTime? timestamp;
}
