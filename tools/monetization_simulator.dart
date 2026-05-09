import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

void main(List<String> args) {
  final cli = _MonetizationSimulatorCli.parse(args);
  final simulator = MonetizationSimulator(cli: cli);
  simulator.run();
}

class _MonetizationSimulatorCli {
  _MonetizationSimulatorCli({
    required this.runs,
    required this.strategies,
    required this.seed,
    required this.emitJson,
    required this.emitAscii,
  });

  final int runs;
  final List<String> strategies;
  final int seed;
  final bool emitJson;
  final bool emitAscii;

  static _MonetizationSimulatorCli parse(List<String> args) {
    var runs = 1000;
    var seed = 1337;
    var emitJson = false;
    var emitAscii = true;
    final selectedStrategies = <String>{};

    for (final arg in args) {
      if (arg.startsWith('--runs=')) {
        final value = int.tryParse(arg.substring(7));
        if (value != null && value > 0) runs = value;
      } else if (arg.startsWith('--seed=')) {
        final value = int.tryParse(arg.substring(7));
        if (value != null) seed = value;
      } else if (arg.startsWith('--strategy=')) {
        final value = arg.substring(11).trim();
        if (value.isNotEmpty) {
          value
              .split(',')
              .map((s) => s.trim().toUpperCase())
              .where((s) => s.isNotEmpty)
              .forEach(selectedStrategies.add);
        }
      } else if (arg == '--json') {
        emitJson = true;
      } else if (arg == '--ascii') {
        emitAscii = true;
      } else if (arg == '--no-ascii') {
        emitAscii = false;
      } else if (arg == '--help' || arg == '-h') {
        _printUsage();
        exit(0);
      }
    }

    final strategies = selectedStrategies.isEmpty
        ? <String>['A', 'B', 'C']
        : selectedStrategies.toList();

    return _MonetizationSimulatorCli(
      runs: runs,
      strategies: strategies,
      seed: seed,
      emitJson: emitJson,
      emitAscii: emitAscii,
    );
  }

  static void _printUsage() {
    stdout
      ..writeln('Usage: dart run tools/monetization_simulator.dart [options]')
      ..writeln('Options:')
      ..writeln(
        '  --runs=<int>        Number of simulated sessions per strategy (default 1000)',
      )
      ..writeln(
        '  --strategy=A,B,C    Comma-separated strategies to evaluate (default A,B,C)',
      )
      ..writeln('  --seed=<int>        RNG seed (default 1337)')
      ..writeln(
        '  --json              Emit JSON report to tools/_reports/monetization_ab_test.json',
      )
      ..writeln('  --ascii             Print ASCII table (default on)')
      ..writeln('  --no-ascii          Disable ASCII table output')
      ..writeln('  --help, -h          Show this message');
  }
}

class MonetizationSimulator {
  MonetizationSimulator({required this.cli});

  final _MonetizationSimulatorCli cli;

  final Map<String, StrategyPreset> _presets = <String, StrategyPreset>{
    'A': StrategyPreset(
      id: 'A',
      name: 'Balanced',
      xpFactor: 1.0,
      chipFactor: 1.0,
      retentionDelta: 0.0,
    ),
    'B': StrategyPreset(
      id: 'B',
      name: 'Aggressive',
      xpFactor: 1.2,
      chipFactor: 1.1,
      retentionDelta: -3.0,
    ),
    'C': StrategyPreset(
      id: 'C',
      name: 'Conservative',
      xpFactor: 0.9,
      chipFactor: 0.8,
      retentionDelta: 4.0,
    ),
  };

  void run() {
    final telemetry = _readTelemetry();
    final economy = _readEconomyTuning();
    final rewardHistory = _readRewardHistory();
    final difficulty = _readDifficultyHistory();
    final projection = _readProjection();

    final random = Random(cli.seed);

    final strategies = cli.strategies
        .map((key) => _presets[key])
        .whereType<StrategyPreset>()
        .toList();

    if (strategies.isEmpty) {
      stderr.writeln('[ERROR] No valid strategies selected.');
      exitCode = 64;
      return;
    }

    final results = <StrategyResult>[];
    final baselineId = strategies.any((s) => s.id == 'A')
        ? 'A'
        : strategies.first.id;

    StrategyAggregate? baselineAggregate;

    for (final strategy in strategies) {
      final aggregate = _simulateStrategy(
        strategy: strategy,
        runs: cli.runs,
        random: random,
        telemetry: telemetry,
        economy: economy,
        rewardHistory: rewardHistory,
        difficulty: difficulty,
        projection: projection,
      );
      final StrategyDelta delta;
      if (baselineAggregate == null) {
        delta = StrategyDelta.zero();
      } else {
        delta = _computeDelta(baseline: baselineAggregate, current: aggregate);
      }
      results.add(
        StrategyResult(strategy: strategy, aggregate: aggregate, delta: delta),
      );
      baselineAggregate ??= aggregate;
    }

    final best = results.reduce(
      (a, b) => a.aggregate.profitIndex >= b.aggregate.profitIndex ? a : b,
    );

    if (cli.emitAscii) {
      _printAscii(results, baselineId);
    }
    if (cli.emitJson) {
      _writeJson(results, best);
    }

    _emitTelemetry(results, best);
  }

  StrategyAggregate _simulateStrategy({
    required StrategyPreset strategy,
    required int runs,
    required Random random,
    required TelemetrySnapshot telemetry,
    required EconomyTuning economy,
    required RewardCacheSnapshot rewardHistory,
    required DifficultySnapshot difficulty,
    required ProjectionSnapshot projection,
  }) {
    final baseRetention = telemetry.retentionScore ?? 60.0;
    final baseConfidence = telemetry.avgConfidence ?? 60.0;
    final baseSkillIndex = difficulty.averageSkillIndex ?? 0.5;
    final baseLatency = telemetry.avgLatency ?? 320.0;

    final baseXp =
        rewardHistory.averageBaseXp ?? projection.averageXpFlow ?? 120.0;
    final baseChips =
        rewardHistory.averageBaseChips ?? projection.averageChipFlow ?? 45.0;

    var previousConfidence = baseConfidence;

    double totalXp = 0.0;
    double totalChips = 0.0;
    double totalRetention = 0.0;
    double totalRevenue = 0.0;

    for (var i = 0; i < runs; i++) {
      final sessionBaseXp = _sampleBaseValue(
        random,
        entries: rewardHistory.entries,
        extractor: (entry) => entry.baseXp.toDouble(),
        fallback: baseXp,
      );

      final sessionBaseChips = _sampleBaseValue(
        random,
        entries: rewardHistory.entries,
        extractor: (entry) => entry.baseChips.toDouble(),
        fallback: baseChips,
      );

      final skillNoise = (random.nextDouble() - 0.5) * 0.2;
      final sessionSkillIndex = (baseSkillIndex + skillNoise).clamp(0.0, 1.0);

      final confidenceNoise = (random.nextDouble() - 0.5) * 12.0;
      final sessionConfidence = (baseConfidence + confidenceNoise).clamp(
        30.0,
        95.0,
      );

      final latencyNoise = (random.nextDouble() - 0.5) * 120.0;
      final sessionLatency = (baseLatency + latencyNoise).clamp(120.0, 820.0);

      final multiplier = _computeAdaptiveMultiplier(
        skillIndex: sessionSkillIndex,
        confidence: sessionConfidence,
        previousConfidence: previousConfidence,
        latencyMs: sessionLatency,
      );
      previousConfidence = sessionConfidence;

      final adjustedXp =
          sessionBaseXp * multiplier * strategy.xpFactor * economy.xpFactor;
      final dropFrequency = _chipDropFrequency(multiplier);
      final adjustedChips =
          sessionBaseChips *
          multiplier *
          strategy.chipFactor *
          economy.chipFactor *
          dropFrequency;

      final retentionPercent = _computeRetentionMultiplier(
        baseRetention: baseRetention,
        multiplier: multiplier,
        strategyDelta: strategy.retentionDelta,
      );
      final retentionRate = retentionPercent.clamp(5.0, 98.0) / 100.0;

      final revenue = adjustedChips * 0.01;

      totalXp += adjustedXp;
      totalChips += adjustedChips;
      totalRetention += retentionRate;
      totalRevenue += revenue;
    }

    final avgXp = totalXp / runs;
    final avgChips = totalChips / runs;
    final avgRetention = totalRetention / runs;
    final avgRevenue = totalRevenue / runs;
    final profitIndex = avgRevenue * avgRetention;

    return StrategyAggregate(
      runs: runs,
      averageXp: avgXp,
      averageChips: avgChips,
      averageRetention: avgRetention,
      averageRevenue: avgRevenue,
      profitIndex: profitIndex,
    );
  }

  double _computeAdaptiveMultiplier({
    required double skillIndex,
    required double confidence,
    required double previousConfidence,
    required double latencyMs,
  }) {
    var multiplier = 0.9 + skillIndex * 0.3;

    if (skillIndex < 0.3) {
      multiplier -= 0.1;
    } else if (skillIndex > 0.7) {
      multiplier += 0.05;
    }

    if (confidence >= 80) {
      multiplier += 0.08;
    } else if (confidence <= 40) {
      multiplier -= 0.08;
    }

    if (latencyMs <= 240) {
      multiplier += 0.05;
    } else if (latencyMs >= 600) {
      multiplier -= 0.07;
    }

    final delta = confidence - previousConfidence;
    if (delta >= 6) {
      multiplier += 0.06;
    } else if (delta >= 3) {
      multiplier += 0.03;
    } else if (delta <= -6) {
      multiplier -= 0.06;
    } else if (delta <= -3) {
      multiplier -= 0.03;
    }

    return multiplier.clamp(0.6, 1.4);
  }

  double _computeRetentionMultiplier({
    required double baseRetention,
    required double multiplier,
    required double strategyDelta,
  }) {
    final elasticity = 0.3;
    final retentionShift =
        (multiplier - 1.0) * elasticity * 5.0 * 100.0 / 100.0;
    return baseRetention + retentionShift + strategyDelta;
  }

  StrategyDelta _computeDelta({
    required StrategyAggregate baseline,
    required StrategyAggregate current,
  }) {
    double percentDelta(double baselineValue, double currentValue) {
      if (baselineValue == 0) return 0;
      return ((currentValue - baselineValue) / baselineValue) * 100.0;
    }

    return StrategyDelta(
      xpPercent: percentDelta(baseline.averageXp, current.averageXp),
      chipsPercent: percentDelta(baseline.averageChips, current.averageChips),
      retentionPercent: percentDelta(
        baseline.averageRetention,
        current.averageRetention,
      ),
    );
  }

  void _printAscii(List<StrategyResult> results, String baselineId) {
    const headers = <String>[
      'Strategy',
      'Avg XP',
      'Avg Chips',
      'Retention %',
      'Revenue (\$)',
      'ProfitIdx',
      'ΔXP',
      'ΔChips',
      'ΔRetention',
    ];

    final rows = <List<String>>[
      headers,
      ...results.map(
        (result) => <String>[
          result.strategy.label,
          result.aggregate.averageXp.toStringAsFixed(2),
          result.aggregate.averageChips.toStringAsFixed(2),
          (result.aggregate.averageRetention * 100.0).toStringAsFixed(2),
          result.aggregate.averageRevenue.toStringAsFixed(3),
          result.aggregate.profitIndex.toStringAsFixed(3),
          _formatDelta(result.delta.xpPercent),
          _formatDelta(result.delta.chipsPercent),
          _formatDelta(result.delta.retentionPercent),
        ],
      ),
    ];

    final widths = List<int>.filled(headers.length, 0);
    for (final row in rows) {
      for (var col = 0; col < row.length; col++) {
        widths[col] = max(widths[col], row[col].length);
      }
    }

    String border() => '+' + widths.map((w) => '-' * (w + 2)).join('+') + '+';

    stdout.writeln('Monetization Strategy Simulation (baseline: $baselineId)');
    stdout.writeln(border());
    for (var idx = 0; idx < rows.length; idx++) {
      final row = rows[idx];
      final padded = <String>[];
      for (var i = 0; i < row.length; i++) {
        padded.add(row[i].padRight(widths[i]));
      }
      stdout.writeln('| ${padded.join(' | ')} |');
      if (idx == 0 || idx == rows.length - 1) {
        stdout.writeln(border());
      }
    }
  }

  void _writeJson(List<StrategyResult> results, StrategyResult best) {
    final file = File('tools/_reports/monetization_ab_test.json');
    final payload = <String, Object>{
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'runs_per_strategy': cli.runs,
      'strategies': results
          .map(
            (result) => <String, Object>{
              'id': result.strategy.id,
              'label': result.strategy.label,
              'average_xp': result.aggregate.averageXp,
              'average_chips': result.aggregate.averageChips,
              'average_retention': result.aggregate.averageRetention,
              'average_revenue': result.aggregate.averageRevenue,
              'profit_index': result.aggregate.profitIndex,
              'delta_xp_percent': result.delta.xpPercent,
              'delta_chips_percent': result.delta.chipsPercent,
              'delta_retention_percent': result.delta.retentionPercent,
            },
          )
          .toList(),
      'best_strategy': <String, Object>{
        'id': best.strategy.id,
        'label': best.strategy.label,
        'profit_index': best.aggregate.profitIndex,
      },
    };
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  }

  void _emitTelemetry(List<StrategyResult> results, StrategyResult best) {
    final baseline = results.first.aggregate;
    final bestDelta = _computeDelta(
      baseline: baseline,
      current: best.aggregate,
    );

    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'monetization_ab_test_completed',
        params: <String, Object>{
          'run_count': cli.runs * results.length,
          'best_strategy': best.strategy.id,
          'delta_xp_percent': double.parse(
            bestDelta.xpPercent.toStringAsFixed(2),
          ),
          'delta_chips_percent': double.parse(
            bestDelta.chipsPercent.toStringAsFixed(2),
          ),
          'delta_retention_percent': double.parse(
            bestDelta.retentionPercent.toStringAsFixed(2),
          ),
        },
      ),
    );
  }

  double _sampleBaseValue(
    Random random, {
    required List<RewardEntry> entries,
    required double Function(RewardEntry) extractor,
    required double fallback,
  }) {
    if (entries.isEmpty) {
      return fallback;
    }
    final entry = entries[random.nextInt(entries.length)];
    return extractor(entry);
  }

  TelemetrySnapshot _readTelemetry() {
    const paths = <String>[
      'tools/_reports/unified_telemetry_summary.json',
      'release/public_beta_v2/unified_telemetry_summary.json',
    ];
    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          final derived =
              decoded['derived_metrics'] as Map<String, dynamic>? ?? const {};
          return TelemetrySnapshot(
            retentionScore: (derived['retention_score'] as num?)?.toDouble(),
            avgConfidence: (derived['avg_confidence'] as num?)?.toDouble(),
            avgLatency: (derived['avg_latency_ms'] as num?)?.toDouble(),
          );
        }
      } catch (error) {
        stderr.writeln(
          '[WARN] monetization simulator telemetry read error: $error',
        );
      }
    }
    return TelemetrySnapshot.empty();
  }

  EconomyTuning _readEconomyTuning() {
    final file = File('tools/_reports/economy_tuning.json');
    if (!file.existsSync()) {
      return EconomyTuning.defaultValues();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        return EconomyTuning(
          xpFactor: (decoded['xp_factor'] as num?)?.toDouble() ?? 1.0,
          chipFactor: (decoded['chip_factor'] as num?)?.toDouble() ?? 1.0,
        );
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] monetization simulator economy read error: $error',
      );
    }
    return EconomyTuning.defaultValues();
  }

  RewardCacheSnapshot _readRewardHistory() {
    final file = File('tools/_reports/adaptive_reward_cache.json');
    if (!file.existsSync()) {
      return RewardCacheSnapshot.empty();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final history = decoded['history'];
        if (history is List) {
          final entries = history
              .whereType<Map<String, dynamic>>()
              .map(RewardEntry.fromJson)
              .toList();
          return RewardCacheSnapshot(entries: entries);
        }
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] monetization simulator reward cache read error: $error',
      );
    }
    return RewardCacheSnapshot.empty();
  }

  DifficultySnapshot _readDifficultyHistory() {
    final file = File('tools/_reports/.adaptive_difficulty_cache.json');
    if (!file.existsSync()) {
      return DifficultySnapshot.empty();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final history = decoded['history'];
        if (history is List && history.isNotEmpty) {
          final values = history
              .whereType<num>()
              .map((value) => value.toDouble())
              .toList();
          final average = values.reduce((a, b) => a + b) / values.length;
          return DifficultySnapshot(
            averageSkillIndex: average,
            historyLength: values.length,
          );
        }
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] monetization simulator difficulty read error: $error',
      );
    }
    return DifficultySnapshot.empty();
  }

  ProjectionSnapshot _readProjection() {
    final file = File('tools/_reports/monetization_projection.json');
    if (!file.existsSync()) {
      return ProjectionSnapshot.empty();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final rows = decoded['rows'];
        if (rows is List && rows.isNotEmpty) {
          final first = rows.first;
          if (first is Map<String, dynamic>) {
            return ProjectionSnapshot(
              averageXpFlow: (first['xp_flow'] as num?)?.toDouble(),
              averageChipFlow: (first['chip_flow'] as num?)?.toDouble(),
            );
          }
        }
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] monetization simulator projection read error: $error',
      );
    }
    return ProjectionSnapshot.empty();
  }

  String _formatDelta(double value) {
    if (value.abs() < 0.01) {
      return 'FLAT 0.00%';
    }
    final label = value > 0 ? 'UP' : 'DOWN';
    return '$label ${value.abs().toStringAsFixed(2)}%';
  }

  double _chipDropFrequency(double multiplier) {
    final freq = 0.25 - (multiplier / 6.0);
    return max(0.05, freq);
  }
}

class StrategyPreset {
  StrategyPreset({
    required this.id,
    required this.name,
    required this.xpFactor,
    required this.chipFactor,
    required this.retentionDelta,
  });

  final String id;
  final String name;
  final double xpFactor;
  final double chipFactor;
  final double retentionDelta;

  String get label => '$id ($name)';
}

class StrategyAggregate {
  StrategyAggregate({
    required this.runs,
    required this.averageXp,
    required this.averageChips,
    required this.averageRetention,
    required this.averageRevenue,
    required this.profitIndex,
  });

  final int runs;
  final double averageXp;
  final double averageChips;
  final double averageRetention;
  final double averageRevenue;
  final double profitIndex;
}

class StrategyDelta {
  StrategyDelta({
    required this.xpPercent,
    required this.chipsPercent,
    required this.retentionPercent,
  });

  final double xpPercent;
  final double chipsPercent;
  final double retentionPercent;

  factory StrategyDelta.zero() =>
      StrategyDelta(xpPercent: 0, chipsPercent: 0, retentionPercent: 0);
}

class StrategyResult {
  StrategyResult({
    required this.strategy,
    required this.aggregate,
    required this.delta,
  });

  final StrategyPreset strategy;
  final StrategyAggregate aggregate;
  final StrategyDelta delta;
}

class TelemetrySnapshot {
  TelemetrySnapshot({
    required this.retentionScore,
    required this.avgConfidence,
    required this.avgLatency,
  });

  factory TelemetrySnapshot.empty() => TelemetrySnapshot(
    retentionScore: null,
    avgConfidence: null,
    avgLatency: null,
  );

  final double? retentionScore;
  final double? avgConfidence;
  final double? avgLatency;
}

class EconomyTuning {
  EconomyTuning({required this.xpFactor, required this.chipFactor});

  factory EconomyTuning.defaultValues() =>
      EconomyTuning(xpFactor: 1.0, chipFactor: 1.0);

  final double xpFactor;
  final double chipFactor;
}

class RewardCacheSnapshot {
  RewardCacheSnapshot({required this.entries});

  factory RewardCacheSnapshot.empty() =>
      RewardCacheSnapshot(entries: const <RewardEntry>[]);

  final List<RewardEntry> entries;

  double? get averageBaseXp {
    if (entries.isEmpty) return null;
    return entries.fold<int>(0, (sum, entry) => sum + entry.baseXp) /
        entries.length;
  }

  double? get averageBaseChips {
    if (entries.isEmpty) return null;
    return entries.fold<int>(0, (sum, entry) => sum + entry.baseChips) /
        entries.length;
  }
}

class RewardEntry {
  RewardEntry({
    required this.multiplier,
    required this.baseXp,
    required this.adjustedXp,
    required this.baseChips,
    required this.adjustedChips,
  });

  factory RewardEntry.fromJson(Map<String, dynamic> json) {
    return RewardEntry(
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      baseXp: (json['base_xp'] as num?)?.toInt() ?? 0,
      adjustedXp: (json['adjusted_xp'] as num?)?.toInt() ?? 0,
      baseChips: (json['base_chips'] as num?)?.toInt() ?? 0,
      adjustedChips: (json['adjusted_chips'] as num?)?.toInt() ?? 0,
    );
  }

  final double multiplier;
  final int baseXp;
  final int adjustedXp;
  final int baseChips;
  final int adjustedChips;
}

class DifficultySnapshot {
  DifficultySnapshot({
    required this.averageSkillIndex,
    required this.historyLength,
  });

  factory DifficultySnapshot.empty() =>
      DifficultySnapshot(averageSkillIndex: null, historyLength: 0);

  final double? averageSkillIndex;
  final int historyLength;
}

class ProjectionSnapshot {
  ProjectionSnapshot({
    required this.averageXpFlow,
    required this.averageChipFlow,
  });

  factory ProjectionSnapshot.empty() =>
      ProjectionSnapshot(averageXpFlow: null, averageChipFlow: null);

  final double? averageXpFlow;
  final double? averageChipFlow;
}
