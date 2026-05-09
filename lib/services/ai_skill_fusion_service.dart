import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _reportsDir = 'release/_reports';
const String _statsProfilePath = '$_reportsDir/player_stats_profile.json';
const String _traitsProfilePath = '$_reportsDir/player_traits_profile.json';
const String _semanticSummaryPath =
    '$_reportsDir/semantic_drill_enhancer_summary.txt';

class AiSkillFusionService {
  Future<AiSkillFusionResult> buildDashboard() async {
    final stats = await _readStatsProfile();
    final traits = await _readTraitsProfile();
    final semanticAggregates = await _readSemanticSummary();

    final traitCount = traits.length;
    final traitSynergy = min(1.3, 1 + traitCount * 0.03);

    final entries = <SkillFusionEntry>[];
    for (final entry in stats.entries) {
      final stat = entry.key;
      final profile = entry.value;
      final aggregate = semanticAggregates[stat];
      final accuracy = aggregate?.avgAccuracy ?? 0.75;
      final uplift = aggregate?.avgUplift ?? 0.05;
      final fusionIndex = _fusionScore(
        progress: profile.progress,
        accuracy: accuracy,
        uplift: uplift,
        traitSynergy: traitSynergy,
      );
      entries.add(
        SkillFusionEntry(
          stat: stat,
          progress: profile.progress,
          accuracy: accuracy,
          uplift: uplift,
          traitSynergy: traitSynergy,
          fusionIndex: fusionIndex,
        ),
      );
    }

    if (entries.isEmpty) {
      throw StateError('No skill entries available for fusion dashboard.');
    }

    final avgFusion =
        entries.map((e) => e.fusionIndex).reduce((a, b) => a + b) /
        entries.length;
    return AiSkillFusionResult(
      entries: entries,
      averageFusion: avgFusion,
      traitCount: traitCount,
    );
  }

  double _fusionScore({
    required double progress,
    required double accuracy,
    required double uplift,
    required double traitSynergy,
  }) {
    final progressScore = progress.clamp(0, 1) * 100;
    final accuracyScore = accuracy.clamp(0, 1) * 100;
    final upliftScore = uplift.clamp(0, 0.3) * 100;
    final traitScore = (traitSynergy / 1.3) * 100;

    final fusion =
        (progressScore * 0.4) +
        (accuracyScore * 0.35) +
        (upliftScore * 0.15) +
        (traitScore * 0.10);
    return fusion.clamp(0, 100);
  }

  Future<Map<String, _StatProfile>> _readStatsProfile() async {
    final file = File(_statsProfilePath);
    if (!await file.exists()) {
      throw StateError('Missing $_statsProfilePath');
    }
    final Map<String, dynamic> decoded =
        json.decode(await file.readAsString()) as Map<String, dynamic>;
    final result = <String, _StatProfile>{};
    decoded.forEach((key, value) {
      final map = value is Map ? value.cast<String, Object?>() : {};
      result[key] = _StatProfile(
        id: key,
        progress: (map['progress_0_1'] as num?)?.toDouble() ?? 0.5,
      );
    });
    return result;
  }

  Future<List<String>> _readTraitsProfile() async {
    final file = File(_traitsProfilePath);
    if (!await file.exists()) return const [];
    try {
      final Map<String, dynamic> decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final traits = decoded['traits'];
      if (traits is List) {
        return traits
            .whereType<Map>()
            .map((entry) => entry['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<Map<String, _SemanticAggregate>> _readSemanticSummary() async {
    final file = File(_semanticSummaryPath);
    if (!await file.exists()) {
      throw StateError('Missing $_semanticSummaryPath');
    }
    final aggregates = <String, _SemanticAggregate>{};
    String? currentStat;
    for (final line in await file.readAsLines()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('- ') && trimmed.contains('[')) {
        final match = RegExp(r'\[(.+?)\]').firstMatch(trimmed);
        if (match != null) {
          currentStat = match.group(1)!.trim().toLowerCase();
        }
      } else if (currentStat != null &&
          trimmed.startsWith('hint density:') &&
          trimmed.contains('accuracy=')) {
        final match = RegExp(r'accuracy=([0-9.]+)').firstMatch(trimmed);
        if (match != null) {
          final accuracy = double.tryParse(match.group(1)!) ?? 0;
          final aggregate = aggregates.putIfAbsent(
            currentStat,
            _SemanticAggregate.new,
          );
          aggregate.accuracySum += accuracy;
          aggregate.accuracyCount++;
        }
      } else if (currentStat != null && trimmed.contains('uplift=')) {
        final match = RegExp(r'uplift=([0-9.]+)%').firstMatch(trimmed);
        if (match != null) {
          final uplift = double.tryParse(match.group(1)!) ?? 0;
          final aggregate = aggregates.putIfAbsent(
            currentStat,
            _SemanticAggregate.new,
          );
          aggregate.upliftSum += uplift / 100;
          aggregate.upliftCount++;
        }
      }
    }
    return aggregates;
  }
}

class AiSkillFusionResult {
  AiSkillFusionResult({
    required this.entries,
    required this.averageFusion,
    required this.traitCount,
  });

  final List<SkillFusionEntry> entries;
  final double averageFusion;
  final int traitCount;
}

class SkillFusionEntry {
  SkillFusionEntry({
    required this.stat,
    required this.progress,
    required this.accuracy,
    required this.uplift,
    required this.traitSynergy,
    required this.fusionIndex,
  });

  final String stat;
  final double progress;
  final double accuracy;
  final double uplift;
  final double traitSynergy;
  final double fusionIndex;
}

class _StatProfile {
  _StatProfile({required this.id, required this.progress});

  final String id;
  final double progress;
}

class _SemanticAggregate {
  double accuracySum = 0;
  int accuracyCount = 0;
  double upliftSum = 0;
  int upliftCount = 0;

  double? get avgAccuracy =>
      accuracyCount == 0 ? null : accuracySum / accuracyCount;
  double? get avgUplift => upliftCount == 0 ? null : upliftSum / upliftCount;
}
