import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:poker_analyzer/services/ux_emotional_resonance_service.dart';

const String _reportsDir = 'release/_reports';
const String _profileSurfacePath = '$_reportsDir/player_profile_summary.txt';
const String _masteryStatsPath = '$_reportsDir/player_stats_profile.json';
const String _traitsPath = '$_reportsDir/player_traits_profile.json';

class PlayerProfileIntegrationService {
  PlayerProfileIntegrationService({
    UxEmotionalResonanceService? resonanceService,
  }) : _resonanceService = resonanceService ?? UxEmotionalResonanceService();

  final UxEmotionalResonanceService _resonanceService;

  Future<PlayerProfileIntegrationResult?> computeIntegration() async {
    final surface = await _readSurfaceMeta();
    final masteryProgress = await _readMasteryProgress();
    final traits = await _readTraits();
    if (surface == null || masteryProgress.isEmpty || traits.isEmpty) {
      return null;
    }

    final masteryConsistency = _computeMasteryConsistency(masteryProgress);
    final traitAlignment = _computeTraitAlignment(traits);
    final resonance = await _computeUxResonance();
    if (resonance == null) {
      return null;
    }

    final integrationIndex =
        ((masteryConsistency * 0.5) +
                (traitAlignment * 0.3) +
                (resonance * 0.2))
            .clamp(0, 1)
            .toDouble();

    return PlayerProfileIntegrationResult(
      masteryConsistency: masteryConsistency,
      traitAlignment: traitAlignment,
      uxResonance: resonance,
      integrationIndex: integrationIndex,
      masterySamples: masteryProgress.length,
      traitCount: traits.length,
      surfaceStatsTracked: surface.statsTracked,
      surfaceTraitsActive: surface.traitsActive,
    );
  }

  Future<_ProfileSurfaceMeta?> _readSurfaceMeta() async {
    final file = File(_profileSurfacePath);
    if (!await file.exists()) return null;
    try {
      final contents = await file.readAsString();
      final statsMatch = RegExp(r'Stats tracked:\s*(\d+)').firstMatch(contents);
      final traitsMatch = RegExp(
        r'Traits active:\s*(\d+)',
      ).firstMatch(contents);
      if (statsMatch == null || traitsMatch == null) return null;
      return _ProfileSurfaceMeta(
        statsTracked: int.parse(statsMatch.group(1)!),
        traitsActive: int.parse(traitsMatch.group(1)!),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<double>> _readMasteryProgress() async {
    final file = File(_masteryStatsPath);
    if (!await file.exists()) return const [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return const [];
      final progresses = <double>[];
      for (final entry in decoded.values) {
        if (entry is Map<String, dynamic>) {
          final progress =
              (entry['progress_0_1'] as num?)?.toDouble() ??
              ((entry['xp'] as num?)?.toDouble() ?? 0) / 1000;
          progresses.add(progress.clamp(0, 1));
        }
      }
      return progresses;
    } catch (_) {
      return const [];
    }
  }

  Future<List<_TraitInfo>> _readTraits() async {
    final file = File(_traitsPath);
    if (!await file.exists()) return const [];
    try {
      final decoded = json.decode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) return const [];
      final rawTraits = decoded['traits'];
      if (rawTraits is! List) return const [];
      return rawTraits
          .whereType<Map<String, dynamic>>()
          .map(
            (map) => _TraitInfo(
              name: map['name']?.toString() ?? 'unknown',
              rarity: map['rarity']?.toString() ?? 'Common',
              temporary: map['temporary'] == true,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  double _computeMasteryConsistency(List<double> progress) {
    if (progress.isEmpty) return 0;
    if (progress.length == 1) return 1.0;
    final mean = progress.reduce((a, b) => a + b) / progress.length;
    final variance =
        progress
            .map((value) => pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        progress.length;
    final stdDev = sqrt(variance);
    return (1 - stdDev).clamp(0, 1).toDouble();
  }

  double _computeTraitAlignment(List<_TraitInfo> traits) {
    if (traits.isEmpty) return 0;
    double total = 0;
    for (final trait in traits) {
      final base = _rarityWeight(trait.rarity);
      total += trait.temporary ? base - 0.05 : base + 0.05;
    }
    return (total / traits.length).clamp(0, 1).toDouble();
  }

  Future<double?> _computeUxResonance() async {
    try {
      final result = await _resonanceService.calculate();
      return (result.globalScore / 100).clamp(0, 1).toDouble();
    } catch (_) {
      return null;
    }
  }

  double _rarityWeight(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 0.98;
      case 'epic':
        return 0.92;
      case 'rare':
        return 0.88;
      case 'uncommon':
        return 0.8;
      default:
        return 0.75;
    }
  }
}

class PlayerProfileIntegrationResult {
  const PlayerProfileIntegrationResult({
    required this.masteryConsistency,
    required this.traitAlignment,
    required this.uxResonance,
    required this.integrationIndex,
    required this.masterySamples,
    required this.traitCount,
    required this.surfaceStatsTracked,
    required this.surfaceTraitsActive,
  });

  final double masteryConsistency;
  final double traitAlignment;
  final double uxResonance;
  final double integrationIndex;
  final int masterySamples;
  final int traitCount;
  final int surfaceStatsTracked;
  final int surfaceTraitsActive;
}

class _ProfileSurfaceMeta {
  const _ProfileSurfaceMeta({
    required this.statsTracked,
    required this.traitsActive,
  });

  final int statsTracked;
  final int traitsActive;
}

class _TraitInfo {
  const _TraitInfo({
    required this.name,
    required this.rarity,
    required this.temporary,
  });

  final String name;
  final String rarity;
  final bool temporary;
}
