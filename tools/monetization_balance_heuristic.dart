import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

const List<double> _multiplierBins = <double>[0.8, 1.0, 1.2, 1.4];
const double _elasticity = 0.3;
const double _defaultRetention = 60.0; // percent
const double _defaultSessions = 5.0;
const double _chipValuePerThousand = 1.0; // 1000 chips -> $1
const double _xpValuePerThousand = 1.0; // treat XP similarly for heuristic
const double _costPerUser = 0.45;

void main(List<String> arguments) {
  final heuristic = MonetizationBalanceHeuristic();
  heuristic.run();
}

class MonetizationBalanceHeuristic {
  void run() {
    final rewardCache = _readRewardCache();
    final difficulty = _readDifficultyCache();
    final telemetry = _readTelemetrySummary();

    final baseRetention = (telemetry.retentionScore ?? _defaultRetention).clamp(
      10.0,
      95.0,
    );
    final confidence = telemetry.avgConfidence ?? 60.0;
    final arpuCoeff = double.parse(
      (confidence / 100.0).clamp(0.8, 1.2).toStringAsFixed(2),
    );

    final sessions = difficulty.historyLength > 0
        ? difficulty.historyLength.toDouble()
        : rewardCache.totalEntries > 0
        ? rewardCache.totalEntries.toDouble()
        : _defaultSessions;

    final overallXp = rewardCache.averageBaseXp ?? 100.0;
    final overallChips = rewardCache.averageBaseChips ?? 40.0;

    final rows = <ProjectionRow>[];

    for (final multiplier in _multiplierBins) {
      final binStats = rewardCache.forMultiplier(multiplier);
      final avgXp = binStats.averageBaseXp ?? overallXp;
      final avgChips = binStats.averageBaseChips ?? overallChips;
      final binSessions = max(binStats.entryCount.toDouble(), sessions);

      final retentionPercent = _computeRetention(
        base: baseRetention,
        multiplier: multiplier,
      ).clamp(5.0, 98.0);
      final retentionRate = retentionPercent / 100.0;

      final multiplierAdjustedXp = avgXp * multiplier.clamp(0.5, 1.6);
      final xpFlow = multiplierAdjustedXp * retentionRate * binSessions;

      final dropFrequency = _chipDropFrequency(multiplier);
      final chipFlow = avgChips * dropFrequency * retentionRate * binSessions;

      final ltvBase =
          (xpFlow / 1000.0 * _xpValuePerThousand) +
          (chipFlow / 1000.0 * _chipValuePerThousand);
      final ltv = ltvBase * arpuCoeff * retentionRate;

      final roiRaw = _computeRoi(ltv);
      final flag = _computeFlag(
        multiplier: multiplier,
        chipFlow: chipFlow,
        xpFlow: xpFlow,
      );

      rows.add(
        ProjectionRow(
          multiplier: multiplier,
          retentionPercent: retentionPercent,
          xpFlow: xpFlow,
          chipFlow: chipFlow,
          ltv: ltv,
          roiPercent: roiRaw * 100.0,
          dropFrequency: dropFrequency,
          flag: flag,
        ),
      );
    }

    _printTable(rows);
    _writeReport(rows, arpuCoeff, baseRetention);
    _emitTelemetry(rows, arpuCoeff, baseRetention);
  }

  void _printTable(List<ProjectionRow> rows) {
    const headers = <String>[
      'Mult',
      'Retention %',
      'XP Flow',
      'Chip Flow',
      'LTV (\$)',
      'ROI %',
      'Flag',
    ];

    final data = <List<String>>[
      headers,
      ...rows.map(
        (row) => <String>[
          row.multiplier.toStringAsFixed(1),
          row.retentionPercent.toStringAsFixed(2),
          row.xpFlow.toStringAsFixed(1),
          row.chipFlow.toStringAsFixed(1),
          row.ltv.toStringAsFixed(3),
          row.roiPercent.toStringAsFixed(2),
          row.flag,
        ],
      ),
    ];

    final widths = List<int>.filled(headers.length, 0);
    for (final row in data) {
      for (var i = 0; i < row.length; i++) {
        widths[i] = max(widths[i], row[i].length);
      }
    }

    String border() => '+' + widths.map((w) => '-' * (w + 2)).join('+') + '+';

    print(border());
    for (var idx = 0; idx < data.length; idx++) {
      final row = data[idx];
      final cells = <String>[];
      for (var i = 0; i < row.length; i++) {
        final value = row[i];
        cells.add(value.padRight(widths[i]));
      }
      print('| ${cells.join(' | ')} |');
      if (idx == 0 || idx == data.length - 1) {
        print(border());
      }
    }
  }

  void _writeReport(
    List<ProjectionRow> rows,
    double arpuCoeff,
    double baseRetention,
  ) {
    final file = File('tools/_reports/monetization_projection.json');
    final payload = <String, Object?>{
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'base_retention_percent': baseRetention,
      'arpu_coeff': arpuCoeff,
      'cost_per_user': _costPerUser,
      'rows': rows
          .map(
            (row) => <String, Object>{
              'multiplier': row.multiplier,
              'retention_percent': row.retentionPercent,
              'xp_flow': row.xpFlow,
              'chip_flow': row.chipFlow,
              'drop_frequency': row.dropFrequency,
              'ltv': row.ltv,
              'roi_percent': row.roiPercent,
              'flag': row.flag,
            },
          )
          .toList(),
      'summary': <String, Object>{
        'best_multiplier': _selectBest(rows),
        'risk_bins': rows.where((row) => row.flag != 'SAFE').length,
      },
    };

    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  }

  void _emitTelemetry(
    List<ProjectionRow> rows,
    double arpuCoeff,
    double baseRetention,
  ) {
    final best = _selectBest(rows);
    final averageRoi =
        rows.map((row) => row.roiPercent).fold<double>(0.0, (a, b) => a + b) /
        rows.length;

    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'monetization_projection_generated',
        params: <String, Object>{
          'best_multiplier': best,
          'avg_roi_percent': double.parse(averageRoi.toStringAsFixed(2)),
          'risk_bins': rows.where((row) => row.flag != 'SAFE').length,
          'arpu_coeff': arpuCoeff,
          'base_retention_percent': double.parse(
            baseRetention.toStringAsFixed(2),
          ),
        },
      ),
    );
  }

  String _selectBest(List<ProjectionRow> rows) {
    final safeRows = rows.where((row) => row.flag == 'SAFE').toList();
    final candidates = safeRows.isEmpty ? rows : safeRows;
    candidates.sort((a, b) => b.roiPercent.compareTo(a.roiPercent));
    return candidates.first.multiplier.toStringAsFixed(1);
  }

  double _computeRetention({required double base, required double multiplier}) {
    final delta = (multiplier - 1.0) * _elasticity * 5.0 * 100.0 / 100.0;
    return base + delta;
  }

  double _chipDropFrequency(double multiplier) {
    final freq = 0.25 - (multiplier / 6.0);
    return max(0.05, freq);
  }

  double _computeRoi(double ltv) {
    return (ltv - _costPerUser) / _costPerUser;
  }

  String _computeFlag({
    required double multiplier,
    required double chipFlow,
    required double xpFlow,
  }) {
    final total = chipFlow + xpFlow;
    final chipShare = total <= 0 ? 0.0 : chipFlow / total;
    final highChip = chipShare > 0.15;
    final highMultiplier = multiplier > 1.3;
    if (highChip && highMultiplier) {
      return 'RISK_HIGH';
    }
    if (highChip) {
      return 'RISK_CHIP';
    }
    if (highMultiplier) {
      return 'RISK_MULT';
    }
    return 'SAFE';
  }

  RewardCacheSnapshot _readRewardCache() {
    final file = File('tools/_reports/adaptive_reward_cache.json');
    if (!file.existsSync()) {
      return RewardCacheSnapshot.empty();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final history =
            decoded['history'] as List<dynamic>? ?? const <dynamic>[];
        final entries = <RewardEntry>[];
        for (final entry in history) {
          if (entry is Map<String, dynamic>) {
            entries.add(RewardEntry.fromJson(entry));
          }
        }
        return RewardCacheSnapshot(entries: entries);
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] monetization heuristic failed to read reward cache: $error',
      );
    }
    return RewardCacheSnapshot.empty();
  }

  DifficultySnapshot _readDifficultyCache() {
    final file = File('tools/_reports/.adaptive_difficulty_cache.json');
    if (!file.existsSync()) {
      return DifficultySnapshot.empty();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final history = decoded['history'];
        if (history is List) {
          return DifficultySnapshot(historyLength: history.length);
        }
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] monetization heuristic failed to read difficulty cache: $error',
      );
    }
    return DifficultySnapshot.empty();
  }

  TelemetrySnapshot _readTelemetrySummary() {
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
          );
        }
      } catch (error) {
        stderr.writeln(
          '[WARN] monetization heuristic telemetry read error: $error',
        );
      }
    }
    return TelemetrySnapshot.empty();
  }
}

class ProjectionRow {
  ProjectionRow({
    required this.multiplier,
    required this.retentionPercent,
    required this.xpFlow,
    required this.chipFlow,
    required this.ltv,
    required this.roiPercent,
    required this.dropFrequency,
    required this.flag,
  });

  final double multiplier;
  final double retentionPercent;
  final double xpFlow;
  final double chipFlow;
  final double ltv;
  final double roiPercent;
  final double dropFrequency;
  final String flag;
}

class RewardCacheSnapshot {
  RewardCacheSnapshot({required this.entries});

  factory RewardCacheSnapshot.empty() =>
      RewardCacheSnapshot(entries: const <RewardEntry>[]);

  final List<RewardEntry> entries;

  int get totalEntries => entries.length;

  double? get averageBaseXp {
    if (entries.isEmpty) return null;
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.baseXp);
    return total / entries.length;
  }

  double? get averageBaseChips {
    if (entries.isEmpty) return null;
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.baseChips);
    return total / entries.length;
  }

  RewardBinStats forMultiplier(double multiplier) {
    if (entries.isEmpty) {
      return RewardBinStats.empty();
    }

    RewardEntry? closest;
    double closestDistance = double.infinity;
    final binEntries = <RewardEntry>[];

    for (final entry in entries) {
      final distance = (entry.multiplier - multiplier).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closest = entry;
      }
      if (distance <= 0.11) {
        binEntries.add(entry);
      }
    }

    final selected = binEntries.isNotEmpty
        ? binEntries
        : closest != null
        ? <RewardEntry>[closest]
        : const <RewardEntry>[];

    if (selected.isEmpty) {
      return RewardBinStats.empty();
    }

    final avgXp =
        selected.fold<int>(0, (sum, entry) => sum + entry.baseXp) /
        selected.length;
    final avgChips =
        selected.fold<int>(0, (sum, entry) => sum + entry.baseChips) /
        selected.length;

    return RewardBinStats(
      averageBaseXp: avgXp.toDouble(),
      averageBaseChips: avgChips.toDouble(),
      entryCount: selected.length,
    );
  }
}

class RewardBinStats {
  RewardBinStats({
    required this.averageBaseXp,
    required this.averageBaseChips,
    required this.entryCount,
  });

  factory RewardBinStats.empty() => RewardBinStats(
    averageBaseXp: null,
    averageBaseChips: null,
    entryCount: 0,
  );

  final double? averageBaseXp;
  final double? averageBaseChips;
  final int entryCount;
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
  DifficultySnapshot({required this.historyLength});

  factory DifficultySnapshot.empty() => DifficultySnapshot(historyLength: 0);

  final int historyLength;
}

class TelemetrySnapshot {
  TelemetrySnapshot({
    required this.retentionScore,
    required this.avgConfidence,
  });

  factory TelemetrySnapshot.empty() =>
      TelemetrySnapshot(retentionScore: null, avgConfidence: null);

  final double? retentionScore;
  final double? avgConfidence;
}
