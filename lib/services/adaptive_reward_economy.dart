import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/services/firebase_lite_telemetry_service.dart';

final class AdaptiveRewardEconomy {
  AdaptiveRewardEconomy._();

  static final AdaptiveRewardEconomy instance = AdaptiveRewardEconomy._();

  static const String _difficultyCachePath =
      'tools/_reports/.adaptive_difficulty_cache.json';
  static const String _unifiedTelemetryPath =
      'tools/_reports/unified_telemetry_summary.json';
  static const String _releaseTelemetryPath =
      'release/public_beta_v2/unified_telemetry_summary.json';
  static const String _rewardCachePath =
      'tools/_reports/adaptive_reward_cache.json';
  static const int _historyLimit = 5;

  AdaptiveRewardDecision scaleReward({required int xp, required int chips}) {
    if (xp <= 0 && chips <= 0) {
      return AdaptiveRewardDecision(
        adjustedXp: 0,
        adjustedChips: 0,
        multiplier: 1.0,
        reason: 'no_reward',
      );
    }

    final skillIndex = _readSkillIndex();
    final telemetry = _readUnifiedTelemetry();
    final derived =
        telemetry['derived_metrics'] as Map<String, dynamic>? ?? const {};

    final currentConfidence =
        (derived['avg_confidence'] as num?)?.toDouble() ?? 50.0;
    final lastCache = _readRewardCache();
    final previousConfidence = lastCache.lastConfidence;
    final confidenceDelta = previousConfidence != null
        ? currentConfidence - previousConfidence
        : 0.0;

    var baseMultiplier = 0.9 + skillIndex * 0.3; // 0.9 - 1.2

    if (skillIndex < 0.3) {
      baseMultiplier -= 0.1;
    } else if (skillIndex > 0.7) {
      baseMultiplier += 0.05;
    }

    final double trendAdjustment;
    if (confidenceDelta >= 10) {
      trendAdjustment = 0.15;
    } else if (confidenceDelta >= 5) {
      trendAdjustment = 0.10;
    } else if (confidenceDelta >= 2) {
      trendAdjustment = 0.05;
    } else if (confidenceDelta <= -10) {
      trendAdjustment = -0.15;
    } else if (confidenceDelta <= -5) {
      trendAdjustment = -0.10;
    } else if (confidenceDelta <= -2) {
      trendAdjustment = -0.05;
    } else {
      trendAdjustment = 0.0;
    }

    var multiplier = baseMultiplier + trendAdjustment;
    multiplier = multiplier.clamp(0.8, 1.4);
    multiplier = double.parse(multiplier.toStringAsFixed(2));

    final adjustedXp = multiplier == 1.0
        ? xp
        : (xp * multiplier).round().clamp(0, 1 << 31);
    final adjustedChips = multiplier == 1.0
        ? chips
        : (chips * multiplier).round().clamp(0, 1 << 31);

    final reason = _buildReason(
      skillIndex: skillIndex,
      confidenceDelta: confidenceDelta,
    );

    _writeRewardCache(
      history: lastCache.history,
      entry: _RewardHistoryEntry(
        timestamp: DateTime.now().toUtc().toIso8601String(),
        multiplier: multiplier,
        skillIndex: skillIndex,
        confidence: currentConfidence,
        confidenceDelta: confidenceDelta,
        reason: reason,
        baseXp: xp,
        adjustedXp: adjustedXp,
        baseChips: chips,
        adjustedChips: adjustedChips,
      ),
      confidence: currentConfidence,
    );

    unawaited(
      FirebaseLiteTelemetryService.instance.logEvent(
        'ux_reward_scaled',
        params: <String, Object>{
          'multiplier': multiplier,
          'skill_index': double.parse(skillIndex.toStringAsFixed(4)),
          'confidence': double.parse(currentConfidence.toStringAsFixed(2)),
          'confidence_delta': double.parse(confidenceDelta.toStringAsFixed(2)),
          'reason': reason,
          'base_xp': xp,
          'base_chips': chips,
          'adjusted_xp': adjustedXp,
          'adjusted_chips': adjustedChips,
        },
      ),
    );

    return AdaptiveRewardDecision(
      adjustedXp: adjustedXp,
      adjustedChips: adjustedChips,
      multiplier: multiplier,
      reason: reason,
    );
  }

  double _readSkillIndex() {
    final file = File(_difficultyCachePath);
    if (!file.existsSync()) {
      return 0.5;
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final average = (decoded['average'] as num?)?.toDouble();
        if (average != null && average.isFinite) {
          return average.clamp(0.0, 1.0);
        }
        final history = decoded['history'];
        if (history is List) {
          final values = history.whereType<num>().toList();
          if (values.isNotEmpty) {
            final avg = values.reduce((a, b) => a + b) / values.length;
            return avg.clamp(0.0, 1.0);
          }
        }
      }
    } catch (error) {
      stderr.writeln(
        '[WARN] AdaptiveRewardEconomy skill index read error: $error',
      );
    }
    return 0.5;
  }

  Map<String, dynamic> _readUnifiedTelemetry() {
    const paths = [_unifiedTelemetryPath, _releaseTelemetryPath];
    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      try {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (error) {
        stderr.writeln(
          '[WARN] AdaptiveRewardEconomy telemetry read error: $error',
        );
      }
    }
    return const {};
  }

  _RewardCache _readRewardCache() {
    final file = File(_rewardCachePath);
    if (!file.existsSync()) {
      return const _RewardCache(history: [], lastConfidence: null);
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final historyList = decoded['history'];
        final history = <_RewardHistoryEntry>[];
        if (historyList is List) {
          for (final entry in historyList) {
            if (entry is Map<String, dynamic>) {
              history.add(_RewardHistoryEntry.fromJson(entry));
            }
          }
        }
        final lastConfidence = (decoded['last_confidence'] as num?)?.toDouble();
        return _RewardCache(history: history, lastConfidence: lastConfidence);
      }
    } catch (error) {
      stderr.writeln('[WARN] AdaptiveRewardEconomy cache read error: $error');
    }
    return const _RewardCache(history: [], lastConfidence: null);
  }

  void _writeRewardCache({
    required List<_RewardHistoryEntry> history,
    required _RewardHistoryEntry entry,
    required double confidence,
  }) {
    final updated = <_RewardHistoryEntry>[...history, entry];
    if (updated.length > _historyLimit) {
      updated.removeRange(0, updated.length - _historyLimit);
    }

    final payload = <String, Object>{
      'history': updated.map((e) => e.toJson()).toList(),
      'last_confidence': double.parse(confidence.toStringAsFixed(2)),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final file = File(_rewardCachePath);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (error) {
      stderr.writeln('[WARN] AdaptiveRewardEconomy cache write error: $error');
    }
  }

  String _buildReason({
    required double skillIndex,
    required double confidenceDelta,
  }) {
    String skillLabel;
    if (skillIndex >= 0.7) {
      skillLabel = 'skill_high';
    } else if (skillIndex <= 0.3) {
      skillLabel = 'skill_low';
    } else {
      skillLabel = 'skill_mid';
    }

    String trendLabel;
    if (confidenceDelta >= 5) {
      trendLabel = 'confidence_up';
    } else if (confidenceDelta <= -5) {
      trendLabel = 'confidence_down';
    } else {
      trendLabel = 'confidence_flat';
    }

    return '$skillLabel\_$trendLabel';
  }
}

class AdaptiveRewardDecision {
  const AdaptiveRewardDecision({
    required this.adjustedXp,
    required this.adjustedChips,
    required this.multiplier,
    required this.reason,
  });

  final int adjustedXp;
  final int adjustedChips;
  final double multiplier;
  final String reason;
}

class _RewardCache {
  const _RewardCache({required this.history, required this.lastConfidence});

  final List<_RewardHistoryEntry> history;
  final double? lastConfidence;
}

class _RewardHistoryEntry {
  const _RewardHistoryEntry({
    required this.timestamp,
    required this.multiplier,
    required this.skillIndex,
    required this.confidence,
    required this.confidenceDelta,
    required this.reason,
    required this.baseXp,
    required this.adjustedXp,
    required this.baseChips,
    required this.adjustedChips,
  });

  final String timestamp;
  final double multiplier;
  final double skillIndex;
  final double confidence;
  final double confidenceDelta;
  final String reason;
  final int baseXp;
  final int adjustedXp;
  final int baseChips;
  final int adjustedChips;

  factory _RewardHistoryEntry.fromJson(Map<String, dynamic> json) {
    return _RewardHistoryEntry(
      timestamp:
          json['timestamp']?.toString() ??
          DateTime.now().toUtc().toIso8601String(),
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      skillIndex: (json['skill_index'] as num?)?.toDouble() ?? 0.5,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 50.0,
      confidenceDelta: (json['confidence_delta'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? 'unknown',
      baseXp: (json['base_xp'] as num?)?.toInt() ?? 0,
      adjustedXp: (json['adjusted_xp'] as num?)?.toInt() ?? 0,
      baseChips: (json['base_chips'] as num?)?.toInt() ?? 0,
      adjustedChips: (json['adjusted_chips'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, Object> toJson() {
    return <String, Object>{
      'timestamp': timestamp,
      'multiplier': double.parse(multiplier.toStringAsFixed(2)),
      'skill_index': double.parse(skillIndex.toStringAsFixed(4)),
      'confidence': double.parse(confidence.toStringAsFixed(2)),
      'confidence_delta': double.parse(confidenceDelta.toStringAsFixed(2)),
      'reason': reason,
      'base_xp': baseXp,
      'adjusted_xp': adjustedXp,
      'base_chips': baseChips,
      'adjusted_chips': adjustedChips,
    };
  }
}
