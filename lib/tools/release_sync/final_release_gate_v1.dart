Map<String, Object> buildFinalReleaseGateV1({
  required Map<String, Object> releaseMasterSnapshotV1,
  required Map<String, Object> finalReleaseAssemblySummaryV1,
  required Map<String, Object> finalReleaseAssemblyMergeV2,
  required Map<String, Object> finalReleaseAssemblyStabilityV2,
  required Map<String, Object> finalReleaseAssemblyCoherenceV2,
  required Map<String, Object> v4CohesionFinalSweep,
  required Map<String, Object> tokenFinalVerificationStage,
  required Map<String, Object> personaV4MatConsistencyFinalStage,
  required Map<String, Object> finalVisualPolishStage,
  required Map<String, Object> v4VisualIntegrator,
  required Map<String, Object> releaseReadinessSurface,
  required Map<String, Object> releaseSyncSnapshot,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> marketingOnboardingCoherenceV2,
  required Map<String, Object> marketingOnboardingSeal,
  required Map<String, Object> marketingOnboardingReleaseBridge,
  required Map<String, Object> finalMarketingReadiness,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardSurface,
  required Map<String, Object> rpgStabilitySurface,
  required Map<String, Object> regressionPlatformSnapshot,
}) {
  bool _isAscii(String s) {
    for (final code in s.runes) {
      if (code > 127) return false;
    }
    return true;
  }

  bool _asciiMap(Map<dynamic, dynamic> m) {
    for (final entry in m.entries) {
      final key = entry.key.toString();
      if (!_isAscii(key)) return false;
      final v = entry.value;
      if (v is String && !_isAscii(v)) return false;
    }
    return true;
  }

  List<String> _asciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

  const fallback = <String, Object>{
    'final_release_gate_v1': <String, Object>{
      'gate_score': 0,
      'issues': <String>[],
      'conflict_flags': <String>[],
      'drivers': <String>['final_release_gate_safe_fallback'],
      'snapshot': <String, Object>{},
    },
  };

  final inputs = [
    releaseMasterSnapshotV1,
    finalReleaseAssemblySummaryV1,
    finalReleaseAssemblyMergeV2,
    finalReleaseAssemblyStabilityV2,
    finalReleaseAssemblyCoherenceV2,
    v4CohesionFinalSweep,
    tokenFinalVerificationStage,
    personaV4MatConsistencyFinalStage,
    finalVisualPolishStage,
    v4VisualIntegrator,
    releaseReadinessSurface,
    releaseSyncSnapshot,
    releaseSyncSurface,
    marketingOnboardingCoherenceV2,
    marketingOnboardingSeal,
    marketingOnboardingReleaseBridge,
    finalMarketingReadiness,
    smartPackSurface,
    xpRewardSurface,
    rpgStabilitySurface,
    regressionPlatformSnapshot,
  ];
  if (inputs.any((i) => i is! Map)) return fallback;
  if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString())))) {
    return fallback;
  }
  if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
    return fallback;
  }

  int _clamp(int v) => v.clamp(0, 100);

  Map<String, Object> _orderMap(Map<String, Object?> input) {
    final entries =
        input.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final ordered = <String, Object>{};
    for (final entry in entries) {
      final value = entry.value;
      if (value is Map) {
        ordered[entry.key] = _orderMap(value.cast<String, Object?>());
      } else if (value is Iterable) {
        final list = value.map<Object>((v) {
          if (v is Map) return _orderMap(v.cast<String, Object?>());
          if (v is num) return v.toDouble().clamp(0, 100);
          if (v is String && !_isAscii(v)) return '';
          return v as Object? ?? '';
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is num) {
        ordered[entry.key] = value.toDouble().clamp(0, 100);
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else {
        ordered[entry.key] = value ?? '';
      }
    }
    return ordered;
  }

  final conflictFlags = <String>[
    ..._asciiList(finalReleaseAssemblySummaryV1['conflict_flags']),
    ..._asciiList(finalReleaseAssemblyMergeV2['conflict_flags']),
    ..._asciiList(finalReleaseAssemblyStabilityV2['conflict_flags']),
    ..._asciiList(finalReleaseAssemblyCoherenceV2['conflict_flags']),
    ..._asciiList(releaseMasterSnapshotV1['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(marketingOnboardingSeal['conflict_flags']),
    ..._asciiList(marketingOnboardingReleaseBridge['conflict_flags']),
  ]..sort();

  final issues = <String>[
    ..._asciiList(finalReleaseAssemblySummaryV1['issues']),
    ..._asciiList(releaseMasterSnapshotV1['issues']),
    ..._asciiList(releaseSyncSurface['issues']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalReleaseAssemblySummaryV1['drivers']),
    ..._asciiList(finalReleaseAssemblyMergeV2['drivers']),
    ..._asciiList(finalReleaseAssemblyStabilityV2['drivers']),
    ..._asciiList(finalReleaseAssemblyCoherenceV2['drivers']),
    ..._asciiList(releaseMasterSnapshotV1['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(marketingOnboardingSeal['drivers']),
    ..._asciiList(marketingOnboardingReleaseBridge['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'cohesion_final_sweep': v4CohesionFinalSweep,
    'final_release_assembly_coherence_v2': finalReleaseAssemblyCoherenceV2,
    'final_release_assembly_merge_v2': finalReleaseAssemblyMergeV2,
    'final_release_assembly_stability_v2': finalReleaseAssemblyStabilityV2,
    'final_release_assembly_summary_v1': finalReleaseAssemblySummaryV1,
    'final_visual_polish_stage': finalVisualPolishStage,
    'final_visual_tokens_stage': tokenFinalVerificationStage,
    'final_visual_persona_stage': personaV4MatConsistencyFinalStage,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'marketing_onboarding_release_bridge': marketingOnboardingReleaseBridge,
    'marketing_onboarding_seal': marketingOnboardingSeal,
    'final_marketing_readiness': finalMarketingReadiness,
    'release_master_snapshot_v1': releaseMasterSnapshotV1,
    'release_readiness_surface': releaseReadinessSurface,
    'release_sync_snapshot': releaseSyncSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'rpg_stability_surface': rpgStabilitySurface,
    'smart_pack_surface': smartPackSurface,
    'v4_visual_integrator': v4VisualIntegrator,
    'xp_reward_surface': xpRewardSurface,
    'readiness_surface': releaseReadinessSurface,
    'v4_final_polish_stage': finalVisualPolishStage,
  });

  final score = _clamp(100 - (conflictFlags.length * 2) - (issues.length));

  return <String, Object>{
    'final_release_gate_v1': <String, Object>{
      'gate_score': score,
      'issues': List<String>.unmodifiable(issues),
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    },
  };
}
