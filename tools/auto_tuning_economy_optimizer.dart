import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

void main(List<String> args) {
  final cli = _OptimizerCli.parse(args);
  AutoTuningEconomyOptimizer(cli: cli).run();
}

class _OptimizerCli {
  _OptimizerCli({required this.applyChanges, required this.summaryOnly});

  final bool applyChanges;
  final bool summaryOnly;

  static _OptimizerCli parse(List<String> args) {
    var applyChanges = false;
    var summaryOnly = false;

    for (final arg in args) {
      switch (arg) {
        case '--apply':
          applyChanges = true;
          break;
        case '--dry-run':
          applyChanges = false;
          break;
        case '--summary':
          summaryOnly = true;
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
        default:
          stderr.writeln('Unknown option: $arg');
          _printUsage();
          exit(64);
      }
    }

    return _OptimizerCli(applyChanges: applyChanges, summaryOnly: summaryOnly);
  }

  static void _printUsage() {
    stdout
      ..writeln(
        'Usage: dart run tools/auto_tuning_economy_optimizer.dart [options]',
      )
      ..writeln('Options:')
      ..writeln('  --apply     Apply tuned economy factors (default dry run)')
      ..writeln('  --dry-run   Do not modify economy_tuning.json (default)')
      ..writeln('  --summary   Print summary only')
      ..writeln('  --help      Show this message');
  }
}

class AutoTuningEconomyOptimizer {
  AutoTuningEconomyOptimizer({required this.cli});

  final _OptimizerCli cli;

  void run() {
    final abReport = _readAbReport();
    final economy = _readEconomy();
    if (abReport == null || abReport.rows.isEmpty) {
      stdout.writeln(
        'economy_auto_tune: missing monetization_ab_test.json or no strategies.',
      );
      return;
    }

    final best = _pickBest(abReport.rows);
    if (best == null) {
      stdout.writeln(
        'economy_auto_tune: unable to determine winning strategy.',
      );
      return;
    }

    final strategyFactors = _strategyFactors(best.id);
    final blended = _blendWeights(
      current: economy,
      target: strategyFactors,
      weight: 0.30,
    );

    final summary = _buildSummary(
      best: best,
      current: economy,
      blended: blended,
      applied: cli.applyChanges,
    );

    if (cli.summaryOnly || !cli.applyChanges) {
      stdout.writeln(summary.asAscii(applied: cli.applyChanges));
    }

    _writeSummary(summary);

    if (cli.applyChanges) {
      _writeEconomy(blended);
      stdout.writeln(summary.asAscii(applied: true));
    }

    _emitTelemetry(summary);
  }

  MonetizationAbReport? _readAbReport() {
    final file = File('tools/_reports/monetization_ab_test.json');
    if (!file.existsSync()) return null;
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final rows = decoded['strategies'];
        if (rows is List) {
          final entries = rows
              .whereType<Map<String, dynamic>>()
              .map(MonetizationStrategyRow.fromJson)
              .toList();
          return MonetizationAbReport(rows: entries);
        }
      }
    } catch (error) {
      stderr.writeln(
        'auto_tuning: failed to read monetization_ab_test.json: $error',
      );
    }
    return null;
  }

  EconomyTuning _readEconomy() {
    final file = File('tools/_reports/economy_tuning.json');
    if (!file.existsSync()) {
      return EconomyTuning(xpFactor: 1.0, chipFactor: 1.0);
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
      stderr.writeln('auto_tuning: failed to read economy_tuning.json: $error');
    }
    return EconomyTuning(xpFactor: 1.0, chipFactor: 1.0);
  }

  MonetizationStrategyRow? _pickBest(List<MonetizationStrategyRow> rows) {
    if (rows.isEmpty) return null;
    rows.sort((a, b) => b.profitIndex.compareTo(a.profitIndex));
    return rows.first;
  }

  StrategyFactors _strategyFactors(String id) {
    switch (id.toUpperCase()) {
      case 'B':
        return StrategyFactors(xpFactor: 1.2, chipFactor: 1.1);
      case 'C':
        return StrategyFactors(xpFactor: 0.9, chipFactor: 0.8);
      case 'A':
      default:
        return StrategyFactors(xpFactor: 1.0, chipFactor: 1.0);
    }
  }

  EconomyTuning _blendWeights({
    required EconomyTuning current,
    required StrategyFactors target,
    required double weight,
  }) {
    double blend(double currentValue, double targetValue) {
      return (currentValue * (1 - weight)) + (targetValue * weight);
    }

    return EconomyTuning(
      xpFactor: double.parse(
        blend(current.xpFactor, target.xpFactor).toStringAsFixed(4),
      ),
      chipFactor: double.parse(
        blend(current.chipFactor, target.chipFactor).toStringAsFixed(4),
      ),
    );
  }

  AutoTuneSummary _buildSummary({
    required MonetizationStrategyRow best,
    required EconomyTuning current,
    required EconomyTuning blended,
    required bool applied,
  }) {
    return AutoTuneSummary(
      bestStrategyId: best.id,
      bestProfitIndex: best.profitIndex,
      currentXp: current.xpFactor,
      currentChips: current.chipFactor,
      tunedXp: blended.xpFactor,
      tunedChips: blended.chipFactor,
      applyChanges: applied,
    );
  }

  void _writeSummary(AutoTuneSummary summary) {
    final file = File('tools/_reports/economy_auto_tune_summary.json');
    final payload = <String, Object>{
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'best_strategy': summary.bestStrategyId,
      'profit_index': summary.bestProfitIndex,
      'xp_before': summary.currentXp,
      'xp_after': summary.tunedXp,
      'chip_before': summary.currentChips,
      'chip_after': summary.tunedChips,
      'delta_xp': summary.deltaXp,
      'delta_chip': summary.deltaChip,
      'applied': summary.applyChanges,
    };
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  }

  void _writeEconomy(EconomyTuning tuning) {
    final file = File('tools/_reports/economy_tuning.json');
    final payload = <String, Object>{
      'xp_factor': tuning.xpFactor,
      'chip_factor': tuning.chipFactor,
    };
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  }

  void _emitTelemetry(AutoTuneSummary summary) {
    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'economy_auto_tuned',
        params: <String, Object>{
          'best_strategy': summary.bestStrategyId,
          'xp_before': summary.currentXp,
          'xp_after': summary.tunedXp,
          'chip_before': summary.currentChips,
          'chip_after': summary.tunedChips,
          'delta_xp': summary.deltaXp,
          'delta_chip': summary.deltaChip,
        },
      ),
    );
  }
}

class MonetizationAbReport {
  MonetizationAbReport({required this.rows});

  final List<MonetizationStrategyRow> rows;
}

class MonetizationStrategyRow {
  MonetizationStrategyRow({
    required this.id,
    required this.label,
    required this.profitIndex,
  });

  factory MonetizationStrategyRow.fromJson(Map<String, dynamic> json) {
    return MonetizationStrategyRow(
      id: (json['id'] ?? '').toString().toUpperCase(),
      label: json['label']?.toString() ?? '',
      profitIndex: (json['profit_index'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String id;
  final String label;
  final double profitIndex;
}

class StrategyFactors {
  const StrategyFactors({required this.xpFactor, required this.chipFactor});

  final double xpFactor;
  final double chipFactor;
}

class EconomyTuning {
  EconomyTuning({required this.xpFactor, required this.chipFactor});

  final double xpFactor;
  final double chipFactor;
}

class AutoTuneSummary {
  AutoTuneSummary({
    required this.bestStrategyId,
    required this.bestProfitIndex,
    required this.currentXp,
    required this.currentChips,
    required this.tunedXp,
    required this.tunedChips,
    required this.applyChanges,
  });

  final String bestStrategyId;
  final double bestProfitIndex;
  final double currentXp;
  final double currentChips;
  final double tunedXp;
  final double tunedChips;
  final bool applyChanges;

  double get deltaXp => double.parse((tunedXp - currentXp).toStringAsFixed(4));
  double get deltaChip =>
      double.parse((tunedChips - currentChips).toStringAsFixed(4));

  String asAscii({required bool applied}) {
    return [
      'Economy Auto-Tune Summary',
      '--------------------------',
      'Best Strategy : $bestStrategyId',
      'Profit Index  : ${bestProfitIndex.toStringAsFixed(3)}',
      'XP Factor     : ${currentXp.toStringAsFixed(4)} -> ${tunedXp.toStringAsFixed(4)} (Δ ${deltaXp.toStringAsFixed(4)})',
      'Chip Factor   : ${currentChips.toStringAsFixed(4)} -> ${tunedChips.toStringAsFixed(4)} (Δ ${deltaChip.toStringAsFixed(4)})',
      'Applied       : ${applied ? 'YES' : 'NO'}',
    ].join('\n');
  }
}
