import 'dart:convert';
import 'dart:io';

const String _profilesDir = 'release/_profiles';
const String _uxSummaryPath =
    'release/_reports/ux_emotional_resonance_summary.json';
const String _integrationSummaryPath =
    'release/_reports/player_profile_integration_summary.json';

class PlayerProfileSurfaceResult {
  PlayerProfileSurfaceResult({
    required this.profileConsistency,
    required this.uxResonance,
    required this.masteryCoherence,
  });

  final double profileConsistency;
  final double uxResonance;
  final double masteryCoherence;
}

class PlayerProfileSurfaceEngine {
  const PlayerProfileSurfaceEngine();

  Future<PlayerProfileSurfaceResult?> evaluate() async {
    final profileConsistency = await _extractProfileConsistency();
    final uxResonance = await _extractUxResonance();
    final masteryCoherence = await _extractMasteryCoherence();

    if (profileConsistency == null ||
        uxResonance == null ||
        masteryCoherence == null) {
      return null;
    }

    return PlayerProfileSurfaceResult(
      profileConsistency: profileConsistency,
      uxResonance: uxResonance,
      masteryCoherence: masteryCoherence,
    );
  }

  Future<double?> _extractProfileConsistency() async {
    final dir = Directory(_profilesDir);
    if (!await dir.exists()) return null;
    final files = await dir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .toList();
    if (files.isEmpty) return null;
    final file = files.first as File;
    try {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final xpTotal = (decoded['xp_total'] as num?)?.toDouble() ?? 0.0;
      if (xpTotal <= 0) return 0.0;
      return (xpTotal / 1000).clamp(0.0, 1.0);
    } catch (_) {
      return null;
    }
  }

  Future<double?> _extractUxResonance() async {
    final file = File(_uxSummaryPath);
    if (!await file.exists()) return null;
    try {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final score =
          (decoded['average_resonance'] as num?)?.toDouble() ??
          (decoded['ux_resonance_score'] as num?)?.toDouble();
      if (score == null) return null;
      return _normalize(score);
    } catch (_) {
      return null;
    }
  }

  Future<double?> _extractMasteryCoherence() async {
    final file = File(_integrationSummaryPath);
    if (!await file.exists()) return null;
    try {
      final decoded =
          json.decode(await file.readAsString()) as Map<String, dynamic>;
      final masteryConsistency = (decoded['mastery_consistency'] as num?)
          ?.toDouble();
      final traitAlignment = (decoded['trait_alignment'] as num?)?.toDouble();
      if (masteryConsistency == null || traitAlignment == null) return null;
      return ((masteryConsistency + traitAlignment) / 2).clamp(0.0, 1.0);
    } catch (_) {
      return null;
    }
  }

  double _normalize(double value) {
    if (value <= 1.0) return value.clamp(0.0, 1.0);
    return (value / 100).clamp(0.0, 1.0);
  }
}
