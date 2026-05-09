Map<String, Object> buildFinalReleaseAssemblyV1({
  required Map<String, Object> final_beta_export,
  required Map<String, Object> release_guard,
  required Map<String, Object> release_sync_surface,
  required Map<String, Object> release_sync_snapshot,
  required Map<String, Object> v4_final_cohesion_sweep,
  required Map<String, Object> v4_token_final_verification,
  required Map<String, Object> persona_v4_mat_final,
  required Map<String, Object> final_v4_polish,
  required Map<String, Object> final_coherence_pass,
  required Map<String, Object> final_visual_polish,
  required Map<String, Object> final_marketing_readiness,
  required Map<String, Object> final_marketing_onboarding,
  required Map<String, Object> final_marketing_onboarding_coherence,
  required Map<String, Object> smart_pack_surface,
  required Map<String, Object> regression_platform_snapshot,
  required Map<String, Object> final_rpg_stability,
  required Map<String, Object> final_xp_reward,
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
    'release_assembly_ok': false,
    'alignment_score': 0,
    'drivers': <String>['final_release_assembly_safe_fallback'],
    'conflict_flags': <String>[],
    'sections': <String, Object>{},
    'snapshot': <String, Object>{},
  };

  final inputs = [
    final_beta_export,
    release_guard,
    release_sync_surface,
    release_sync_snapshot,
    v4_final_cohesion_sweep,
    v4_token_final_verification,
    persona_v4_mat_final,
    final_v4_polish,
    final_coherence_pass,
    final_visual_polish,
    final_marketing_readiness,
    final_marketing_onboarding,
    final_marketing_onboarding_coherence,
    smart_pack_surface,
    regression_platform_snapshot,
    final_rpg_stability,
    final_xp_reward,
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
    ..._asciiList(final_beta_export['conflict_flags']),
    ..._asciiList(release_guard['conflict_flags']),
    ..._asciiList(release_sync_surface['conflict_flags']),
    ..._asciiList(release_sync_snapshot['conflict_flags']),
    ..._asciiList(regression_platform_snapshot['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(final_beta_export['drivers']),
    ..._asciiList(release_guard['drivers']),
    ..._asciiList(release_sync_surface['drivers']),
    ..._asciiList(release_sync_snapshot['drivers']),
    ..._asciiList(regression_platform_snapshot['drivers']),
    'rpg',
    'xp',
    'coaching',
    'persona',
    'marketing',
    'v4',
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(final_beta_export['beta_ready_ok']) &&
      _ok(release_guard['release_guard_ok']) &&
      _ok(release_sync_surface['release_sync_surface_ok']) &&
      _ok(release_sync_snapshot['release_sync_ok']) &&
      _ok(regression_platform_snapshot['final_regression_platform_ok']);

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

  final sections = _orderMap(<String, Object>{
    'final_beta_export': final_beta_export,
    'release_guard': release_guard,
    'release_sync_surface': release_sync_surface,
    'release_sync_snapshot': release_sync_snapshot,
    'v4_final_cohesion_sweep': v4_final_cohesion_sweep,
    'v4_token_final_verification': v4_token_final_verification,
    'persona_v4_mat_final': persona_v4_mat_final,
    'final_v4_polish': final_v4_polish,
    'final_coherence_pass': final_coherence_pass,
    'final_visual_polish': final_visual_polish,
    'final_marketing_readiness': final_marketing_readiness,
    'final_marketing_onboarding': final_marketing_onboarding,
    'final_marketing_onboarding_coherence':
        final_marketing_onboarding_coherence,
    'smart_pack_surface': smart_pack_surface,
    'regression_platform_snapshot': regression_platform_snapshot,
    'final_rpg_stability': final_rpg_stability,
    'final_xp_reward': final_xp_reward,
  });

  final snapshot = _orderMap(<String, Object>{...sections});

  return <String, Object>{
    'release_assembly_ok': ok,
    'alignment_score': _clamp(100 - (conflictFlags.length * 3)),
    'drivers': List<String>.unmodifiable(drivers),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'sections': sections,
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalReleaseAssemblyStabilityV1({
  required Map<String, Object> releaseAssembly,
  required Map<String, Object> v4Cohesion,
  required Map<String, Object> v4Tokens,
  required Map<String, Object> v4PersonaMat,
  required Map<String, Object> v4Polish,
  required Map<String, Object> v4Coherence,
  required Map<String, Object> marketingReadiness,
  required Map<String, Object> marketingOnboarding,
  required Map<String, Object> marketingCoherence,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> regressionPlatform,
  required Map<String, Object> rpgStability,
  required Map<String, Object> xpRewardFinal,
  required Map<String, Object> releaseSyncSnapshot,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> finalBetaExport,
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
    'release_assembly_stability': false,
    'stability_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_release_assembly_stability_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    releaseAssembly,
    v4Cohesion,
    v4Tokens,
    v4PersonaMat,
    v4Polish,
    v4Coherence,
    marketingReadiness,
    marketingOnboarding,
    marketingCoherence,
    smartPackSurface,
    regressionPlatform,
    rpgStability,
    xpRewardFinal,
    releaseSyncSnapshot,
    releaseSyncSurface,
    finalBetaExport,
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
    ..._asciiList(releaseAssembly['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(releaseSyncSnapshot['conflict_flags']),
    ..._asciiList(regressionPlatform['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(releaseAssembly['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(releaseSyncSnapshot['drivers']),
    ..._asciiList(regressionPlatform['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(releaseAssembly['release_assembly_ok']) &&
      _ok(releaseSyncSurface['release_sync_surface_ok']) &&
      _ok(releaseSyncSnapshot['release_sync_ok']) &&
      _ok(regressionPlatform['final_regression_platform_ok']);

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
    'release_assembly': releaseAssembly,
    'v4_cohesion': v4Cohesion,
    'v4_tokens': v4Tokens,
    'v4_persona_mat': v4PersonaMat,
    'v4_polish': v4Polish,
    'v4_coherence': v4Coherence,
    'marketing_readiness': marketingReadiness,
    'marketing_onboarding': marketingOnboarding,
    'marketing_coherence': marketingCoherence,
    'smart_pack_surface': smartPackSurface,
    'regression_platform': regressionPlatform,
    'rpg_stability': rpgStability,
    'xp_reward_final': xpRewardFinal,
    'release_sync_snapshot': releaseSyncSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'final_beta_export': finalBetaExport,
  });

  return <String, Object>{
    'release_assembly_stability': ok,
    'stability_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalReleaseAssemblyHarmonizationV1({
  required Map<String, Object> releaseAssembly,
  required Map<String, Object> releaseAssemblyStability,
  required Map<String, Object> releaseSyncSnapshot,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> v4CohesionFinal,
  required Map<String, Object> v4TokenFinal,
  required Map<String, Object> v4PersonaMatFinal,
  required Map<String, Object> v4PolishFinal,
  required Map<String, Object> v4CoherenceFinal,
  required Map<String, Object> marketingReadiness,
  required Map<String, Object> marketingOnboarding,
  required Map<String, Object> marketingCoherence,
  required Map<String, Object> xpRewardFinal,
  required Map<String, Object> rpgStability,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> regressionPlatform,
  required Map<String, Object> finalBetaExport,
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
    'release_assembly_harmonization': <String, Object>{},
    'harmonization_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_release_assembly_harmonization_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    releaseAssembly,
    releaseAssemblyStability,
    releaseSyncSnapshot,
    releaseSyncSurface,
    v4CohesionFinal,
    v4TokenFinal,
    v4PersonaMatFinal,
    v4PolishFinal,
    v4CoherenceFinal,
    marketingReadiness,
    marketingOnboarding,
    marketingCoherence,
    xpRewardFinal,
    rpgStability,
    smartPackSurface,
    regressionPlatform,
    finalBetaExport,
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
    ..._asciiList(releaseAssembly['conflict_flags']),
    ..._asciiList(releaseAssemblyStability['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(releaseSyncSnapshot['conflict_flags']),
    ..._asciiList(regressionPlatform['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(releaseAssembly['drivers']),
    ..._asciiList(releaseAssemblyStability['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(releaseSyncSnapshot['drivers']),
    ..._asciiList(regressionPlatform['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(releaseAssembly['release_assembly_ok']) &&
      _ok(releaseAssemblyStability['release_assembly_stability']) &&
      _ok(releaseSyncSurface['release_sync_surface_ok']) &&
      _ok(releaseSyncSnapshot['release_sync_ok']) &&
      _ok(regressionPlatform['final_regression_platform_ok']);

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
    'release_assembly': releaseAssembly,
    'release_assembly_stability': releaseAssemblyStability,
    'release_sync_snapshot': releaseSyncSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'v4_cohesion_final': v4CohesionFinal,
    'v4_token_final': v4TokenFinal,
    'v4_persona_mat_final': v4PersonaMatFinal,
    'v4_polish_final': v4PolishFinal,
    'v4_coherence_final': v4CoherenceFinal,
    'marketing_readiness': marketingReadiness,
    'marketing_onboarding': marketingOnboarding,
    'marketing_coherence': marketingCoherence,
    'xp_reward_final': xpRewardFinal,
    'rpg_stability': rpgStability,
    'smart_pack_surface': smartPackSurface,
    'regression_platform': regressionPlatform,
    'final_beta_export': finalBetaExport,
  });

  return <String, Object>{
    'release_assembly_harmonization': ok,
    'harmonization_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalReleaseAssemblyMergeV1({
  required Map<String, Object> releaseAssemblySurface,
  required Map<String, Object> finalReleaseSyncPass,
  required Map<String, Object> v4CohesionFinalSweep,
  required Map<String, Object> tokenVerificationStageFinal,
  required Map<String, Object> personaV4MatConsistencyStageFinal,
  required Map<String, Object> finalV4PolishStage,
  required Map<String, Object> v4VisualIntegrator,
  required Map<String, Object> readinessSurface,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> marketingOnboardingCoherenceV2,
  required Map<String, Object> marketingOnboardingSync,
  required Map<String, Object> marketingOnboardingSeal,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardSurface,
  required Map<String, Object> rpgStabilitySurface,
  required Map<String, Object> personaSignals,
  required Map<String, Object> coachingSurface,
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
    'final_release_assembly_merge_v1': <String, Object>{
      'merge_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['final_release_assembly_merge_safe_fallback'],
      'snapshot': <String, Object>{},
    },
  };

  final inputs = [
    releaseAssemblySurface,
    finalReleaseSyncPass,
    v4CohesionFinalSweep,
    tokenVerificationStageFinal,
    personaV4MatConsistencyStageFinal,
    finalV4PolishStage,
    v4VisualIntegrator,
    readinessSurface,
    regressionPlatformSnapshot,
    marketingOnboardingCoherenceV2,
    marketingOnboardingSync,
    marketingOnboardingSeal,
    smartPackSurface,
    xpRewardSurface,
    rpgStabilitySurface,
    personaSignals,
    coachingSurface,
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
    ..._asciiList(releaseAssemblySurface['conflict_flags']),
    ..._asciiList(finalReleaseSyncPass['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(marketingOnboardingSync['conflict_flags']),
    ..._asciiList(marketingOnboardingSeal['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(releaseAssemblySurface['drivers']),
    ..._asciiList(finalReleaseSyncPass['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(marketingOnboardingSync['drivers']),
    ..._asciiList(marketingOnboardingSeal['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'coaching_surface': coachingSurface,
    'final_release_sync_pass': finalReleaseSyncPass,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'marketing_onboarding_seal': marketingOnboardingSeal,
    'marketing_onboarding_sync': marketingOnboardingSync,
    'persona_signals': personaSignals,
    'persona_v4_mat_consistency_stage_final': personaV4MatConsistencyStageFinal,
    'readiness_surface': readinessSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'release_assembly_surface': releaseAssemblySurface,
    'rpg_stability_surface': rpgStabilitySurface,
    'smart_pack_surface': smartPackSurface,
    'token_verification_stage_final': tokenVerificationStageFinal,
    'v4_cohesion_final_sweep': v4CohesionFinalSweep,
    'v4_visual_integrator': v4VisualIntegrator,
    'xp_reward_surface': xpRewardSurface,
    'final_v4_polish_stage': finalV4PolishStage,
  });

  final mergeScore = _clamp(100 - (conflictFlags.length * 2));

  return <String, Object>{
    'final_release_assembly_merge_v1': <String, Object>{
      'merge_score': mergeScore,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    },
  };
}

Map<String, Object> buildFinalReleaseAssemblyStabilityPassV1({
  required Map<String, Object> finalReleaseAssemblyMergeV1,
  required Map<String, Object> releaseSyncSurfaceV1,
  required Map<String, Object> finalV4PolishStageV1,
  required Map<String, Object> cohesionQAStageFinalV1,
  required Map<String, Object> tokenVerificationStageFinalV1,
  required Map<String, Object> personaV4MatConsistencyStageFinalV1,
  required Map<String, Object> readinessSurfaceV1,
  required Map<String, Object> regressionPlatformSnapshotV1,
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
    'final_release_assembly_stability_pass_v1': <String, Object>{
      'stability_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['final_release_assembly_stability_safe_fallback'],
      'snapshot': <String, Object>{},
    },
  };

  final inputs = [
    finalReleaseAssemblyMergeV1,
    releaseSyncSurfaceV1,
    finalV4PolishStageV1,
    cohesionQAStageFinalV1,
    tokenVerificationStageFinalV1,
    personaV4MatConsistencyStageFinalV1,
    readinessSurfaceV1,
    regressionPlatformSnapshotV1,
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
    ..._asciiList(finalReleaseAssemblyMergeV1['conflict_flags']),
    ..._asciiList(releaseSyncSurfaceV1['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshotV1['conflict_flags']),
    ..._asciiList(cohesionQAStageFinalV1['conflict_flags']),
    ..._asciiList(tokenVerificationStageFinalV1['conflict_flags']),
    ..._asciiList(personaV4MatConsistencyStageFinalV1['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalReleaseAssemblyMergeV1['drivers']),
    ..._asciiList(releaseSyncSurfaceV1['drivers']),
    ..._asciiList(regressionPlatformSnapshotV1['drivers']),
    ..._asciiList(cohesionQAStageFinalV1['drivers']),
    ..._asciiList(tokenVerificationStageFinalV1['drivers']),
    ..._asciiList(personaV4MatConsistencyStageFinalV1['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'cohesion_qa_stage_final_v1': cohesionQAStageFinalV1,
    'final_release_assembly_merge_v1': finalReleaseAssemblyMergeV1,
    'final_v4_polish_stage_v1': finalV4PolishStageV1,
    'persona_v4_mat_consistency_stage_final_v1':
        personaV4MatConsistencyStageFinalV1,
    'readiness_surface_v1': readinessSurfaceV1,
    'regression_platform_snapshot_v1': regressionPlatformSnapshotV1,
    'release_sync_surface_v1': releaseSyncSurfaceV1,
    'token_verification_stage_final_v1': tokenVerificationStageFinalV1,
  });

  final stabilityScore = _clamp(100 - (conflictFlags.length * 2));

  return <String, Object>{
    'final_release_assembly_stability_pass_v1': <String, Object>{
      'stability_score': stabilityScore,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    },
  };
}

Map<String, Object> buildFinalReleaseAssemblyHarmonizationV2({
  required Map<String, Object> finalMerge,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> finalPolishStage,
  required Map<String, Object> finalPersonaMatStage,
  required Map<String, Object> finalTokenStage,
  required Map<String, Object> finalCohesionStage,
  required Map<String, Object> v4VisualIntegrator,
  required Map<String, Object> finalReadinessSurface,
  required Map<String, Object> finalReleaseAssemblyStabilityPass,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> marketingOnboardingCoherenceV2,
  required Map<String, Object> smartPackSurface,
  required Map<String, Object> xpRewardSurface,
  required Map<String, Object> rpgStabilitySnapshot,
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
    'final_release_assembly_harmonization_v2': <String, Object>{
      'harmonization_ok': false,
      'harmonization_v2_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>[
        'final_release_assembly_harmonization_v2_safe_fallback',
      ],
      'ordered_snapshot': <String, Object>{},
    },
  };

  final inputs = [
    finalMerge,
    releaseSyncSurface,
    finalPolishStage,
    finalPersonaMatStage,
    finalTokenStage,
    finalCohesionStage,
    v4VisualIntegrator,
    finalReadinessSurface,
    finalReleaseAssemblyStabilityPass,
    regressionPlatformSnapshot,
    marketingOnboardingCoherenceV2,
    smartPackSurface,
    xpRewardSurface,
    rpgStabilitySnapshot,
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
    ..._asciiList(finalMerge['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalMerge['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'cohesion_stage_final': finalCohesionStage,
    'final_merge': finalMerge,
    'final_persona_mat_stage': finalPersonaMatStage,
    'final_polish_stage': finalPolishStage,
    'final_readiness_surface': finalReadinessSurface,
    'final_release_assembly_stability_pass': finalReleaseAssemblyStabilityPass,
    'final_token_stage': finalTokenStage,
    'rpg_stability_snapshot': rpgStabilitySnapshot,
    'smart_pack_surface': smartPackSurface,
    'v4_visual_integrator': v4VisualIntegrator,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'release_sync_surface': releaseSyncSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'xp_reward_surface': xpRewardSurface,
  });

  final score = _clamp(100 - (conflictFlags.length * 2));
  final ok = conflictFlags.isEmpty && score >= 70;

  return <String, Object>{
    'final_release_assembly_harmonization_v2': <String, Object>{
      'harmonization_ok': ok,
      'harmonization_v2_score': score,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'ordered_snapshot': snapshot,
    },
  };
}

Map<String, Object> buildFinalReleaseAssemblyStabilityV2({
  required Map<String, Object> finalMergeV2,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> finalV4PolishStage,
  required Map<String, Object> finalCohesionStage,
  required Map<String, Object> finalTokenStage,
  required Map<String, Object> finalPersonaStage,
  required Map<String, Object> readinessSurface,
  required Map<String, Object> regressionPlatformSnapshot,
  required Map<String, Object> marketingOnboardingCoherenceV2,
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
    'release_assembly_stability_v2': false,
    'stability_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_release_assembly_stability_v2_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    finalMergeV2,
    releaseSyncSurface,
    finalV4PolishStage,
    finalCohesionStage,
    finalTokenStage,
    finalPersonaStage,
    readinessSurface,
    regressionPlatformSnapshot,
    marketingOnboardingCoherenceV2,
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
    ..._asciiList(finalMergeV2['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalMergeV2['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'final_merge_v2': finalMergeV2,
    'final_persona_stage': finalPersonaStage,
    'final_v4_cohesion_stage': finalCohesionStage,
    'final_v4_polish_stage': finalV4PolishStage,
    'final_v4_token_stage': finalTokenStage,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'readiness_surface': readinessSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'rpg_stability_surface': rpgStabilitySurface,
    'smart_pack_surface': smartPackSurface,
    'xp_reward_surface': xpRewardSurface,
  });

  final score = _clamp(100 - (conflictFlags.length * 2));
  final ok = conflictFlags.isEmpty && score >= 70;

  return <String, Object>{
    'release_assembly_stability_v2': ok,
    'stability_score': score,
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalReleaseAssemblyCoherenceV2({
  required Map<String, Object> finalMergeV2,
  required Map<String, Object> finalStabilityV2,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> cohesionFinalSweep,
  required Map<String, Object> tokenFinalVerification,
  required Map<String, Object> personaV4MatFinalStage,
  required Map<String, Object> finalVisualPolishStage,
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
    'release_assembly_coherence_v2': false,
    'coherence_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_release_assembly_coherence_v2_safe_fallback'],
    'snapshot': <String, Object>{},
  };

  final inputs = [
    finalMergeV2,
    finalStabilityV2,
    releaseSyncSurface,
    cohesionFinalSweep,
    tokenFinalVerification,
    personaV4MatFinalStage,
    finalVisualPolishStage,
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
    ..._asciiList(finalMergeV2['conflict_flags']),
    ..._asciiList(finalStabilityV2['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(marketingOnboardingSeal['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalMergeV2['drivers']),
    ..._asciiList(finalStabilityV2['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(marketingOnboardingSeal['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'cohesion_final_sweep': cohesionFinalSweep,
    'final_merge_v2': finalMergeV2,
    'final_persona_stage': personaV4MatFinalStage,
    'final_stability_v2': finalStabilityV2,
    'final_visual_polish_stage': finalVisualPolishStage,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'marketing_onboarding_seal': marketingOnboardingSeal,
    'readiness_surface': readinessSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'rpg_stability_surface': rpgStabilitySurface,
    'smart_pack_surface': smartPackSurface,
    'token_final_verification': tokenFinalVerification,
    'xp_reward_surface': xpRewardSurface,
  });

  final score = _clamp(100 - (conflictFlags.length * 2));
  final ok = conflictFlags.isEmpty && score >= 70;

  return <String, Object>{
    'release_assembly_coherence_v2': ok,
    'coherence_score': score,
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'snapshot': snapshot,
  };
}

Map<String, Object> buildFinalReleaseAssemblySummaryV1({
  required Map<String, Object> finalMergeV2,
  required Map<String, Object> finalStabilityV2,
  required Map<String, Object> finalCoherenceV2,
  required Map<String, Object> releaseSyncSurface,
  required Map<String, Object> cohesionFinalSweep,
  required Map<String, Object> tokenFinalVerificationStage,
  required Map<String, Object> personaV4MatConsistencyStage,
  required Map<String, Object> finalVisualPolishStage,
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
    'release_assembly_summary_v1': <String, Object>{
      'summary_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['final_release_assembly_summary_v1_safe_fallback'],
      'snapshot': <String, Object>{},
    },
  };

  final inputs = [
    finalMergeV2,
    finalStabilityV2,
    finalCoherenceV2,
    releaseSyncSurface,
    cohesionFinalSweep,
    tokenFinalVerificationStage,
    personaV4MatConsistencyStage,
    finalVisualPolishStage,
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
    ..._asciiList(finalMergeV2['conflict_flags']),
    ..._asciiList(finalStabilityV2['conflict_flags']),
    ..._asciiList(finalCoherenceV2['conflict_flags']),
    ..._asciiList(releaseSyncSurface['conflict_flags']),
    ..._asciiList(regressionPlatformSnapshot['conflict_flags']),
    ..._asciiList(marketingOnboardingCoherenceV2['conflict_flags']),
    ..._asciiList(marketingOnboardingSeal['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(finalMergeV2['drivers']),
    ..._asciiList(finalStabilityV2['drivers']),
    ..._asciiList(finalCoherenceV2['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
    ..._asciiList(regressionPlatformSnapshot['drivers']),
    ..._asciiList(marketingOnboardingCoherenceV2['drivers']),
    ..._asciiList(marketingOnboardingSeal['drivers']),
  ]..sort();

  final snapshot = _orderMap(<String, Object>{
    'cohesion_final_sweep': cohesionFinalSweep,
    'final_coherence_v2': finalCoherenceV2,
    'final_merge_v2': finalMergeV2,
    'final_persona_stage': personaV4MatConsistencyStage,
    'final_stability_v2': finalStabilityV2,
    'final_visual_polish_stage': finalVisualPolishStage,
    'marketing_onboarding_coherence_v2': marketingOnboardingCoherenceV2,
    'marketing_onboarding_seal': marketingOnboardingSeal,
    'readiness_surface': readinessSurface,
    'regression_platform_snapshot': regressionPlatformSnapshot,
    'release_sync_surface': releaseSyncSurface,
    'rpg_stability_surface': rpgStabilitySurface,
    'smart_pack_surface': smartPackSurface,
    'token_final_verification_stage': tokenFinalVerificationStage,
    'xp_reward_surface': xpRewardSurface,
  });

  final score = _clamp(100 - (conflictFlags.length * 2));

  return <String, Object>{
    'release_assembly_summary_v1': <String, Object>{
      'summary_score': score,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    },
  };
}
