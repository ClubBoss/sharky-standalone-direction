Map<String, Object> buildReleaseSyncSnapshotV1({
  required Map<String, Object> v4Readiness,
  required Map<String, Object> v4FinalCohesion,
  required Map<String, Object> v4TokenFinalVerification,
  required Map<String, Object> personaFinal,
  required Map<String, Object> coachingFinal,
  required Map<String, Object> marketingFinal,
  required Map<String, Object> onboardingFinal,
  required Map<String, Object> xpRewardFinal,
  required Map<String, Object> rpgFinal,
  required Map<String, Object> smartPackSurface,
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
    'release_sync_ok': false,
    'alignment_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['release_sync_snapshot_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    v4Readiness,
    v4FinalCohesion,
    v4TokenFinalVerification,
    personaFinal,
    coachingFinal,
    marketingFinal,
    onboardingFinal,
    xpRewardFinal,
    rpgFinal,
    smartPackSurface,
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

  final conflictFlags = <String>[
    ..._asciiList(v4Readiness['conflicts']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(v4Readiness['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(v4Readiness['ok']) &&
      _ok(regressionPlatformSnapshot['final_regression_platform_ok']);

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

  final snapshot = _orderMap(<String, Object>{
    'v4_readiness': v4Readiness,
    'v4_final_cohesion': v4FinalCohesion,
    'v4_token_final_verification': v4TokenFinalVerification,
    'persona_final': personaFinal,
    'coaching_final': coachingFinal,
    'marketing_final': marketingFinal,
    'onboarding_final': onboardingFinal,
    'xp_reward_final': xpRewardFinal,
    'rpg_final': rpgFinal,
    'smart_pack_surface': smartPackSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
  });

  return <String, Object>{
    'release_sync_ok': ok,
    'alignment_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildReleaseMasterSnapshotV1({
  required Map<String, Object> finalReleaseAssemblySummaryV1,
  required Map<String, Object> finalReleaseAssemblyMergeV2,
  required Map<String, Object> finalReleaseAssemblyStabilityV2,
  required Map<String, Object> finalReleaseAssemblyCoherenceV2,
  required Map<String, Object> cohesionFinalSweep,
  required Map<String, Object> tokenVerificationFinalStage,
  required Map<String, Object> personaV4MatConsistencyFinalStage,
  required Map<String, Object> finalVisualPolishStage,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> readinessSurface,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> marketingOnboardingCoherenceV2,
  required Map<String, Object> marketingOnboardingSeal,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardSurface,
  required Map<String, Object> rpgStabilitySurface,
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
    'release_master_snapshot_v1': <String, Object>{
      'master_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['release_master_snapshot_safe_fallback'],
      'snapshot': <String, Object>{},
    },
  };

  final inputs = [
    finalReleaseAssemblySummaryV1,
    finalReleaseAssemblyMergeV2,
    finalReleaseAssemblyStabilityV2,
    finalReleaseAssemblyCoherenceV2,
    cohesionFinalSweep,
    tokenVerificationFinalStage,
    personaV4MatConsistencyFinalStage,
    finalVisualPolishStage,
    releaseSyncSurface,
    readinessSurface,
    regressionPlatformSnapshot,
    marketingOnboardingCoherenceV2,
    marketingOnboardingSeal,
    smartPackSurface,
    xpRewardSurface,
    rpgStabilitySurface,
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
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(marketingOnboardingSeal['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalReleaseAssemblySummaryV1['drivers']),
    ..._asciiList(finalReleaseAssemblyMergeV2['drivers']),
    ..._asciiList(finalReleaseAssemblyStabilityV2['drivers']),
    ..._asciiList(finalReleaseAssemblyCoherenceV2['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(marketingOnboardingSeal['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'cohesion_final_sweep': cohesionFinalSweep,
    'final_coherence_v2': finalReleaseAssemblyCoherenceV2,
    'final_merge_v2': finalReleaseAssemblyMergeV2,
    'final_persona_stage': personaV4MatConsistencyFinalStage,
    'final_release_assembly_stability_v2': finalReleaseAssemblyStabilityV2,
    'final_visual_polish_stage': finalVisualPolishStage,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'marketing_onboarding_seal': marketingOnboardingSeal,
    'readiness_surface': readinessSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'rpg_stability_surface': rpgStabilitySurface,
    'smart_pack_surface': smartPackSurface,
    'token_final_verification_stage': tokenVerificationFinalStage,
    'xp_reward_surface': xpRewardSurface,
    'release_assembly_summary_v1': finalReleaseAssemblySummaryV1,
  });

  final score = _clamp(100 - (conflictFlags.length * 2));

  return <String, Object>{
    'release_master_snapshot_v1': <String, Object>{
      'master_score': score,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    },
  };
}
