class V4FinalPolishViewV4 {
  Map<String, Object> buildFinalPolishView({
    required Map<String, Object?> v4Snapshot,
    required Map<String, Object?> tokenVerificationView,
    required Map<String, Object?> cohesionView,
    required Map<String, Object?> personaMatView,
    required Map<String, Object?> polishBundle,
  }) {
    bool asciiOk = true;
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    List<String> _list(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s))
          out.add(s);
        else
          asciiOk = false;
      }
      out.sort();
      return out;
    }

    Map<String, Object> _map(Map<String, Object?>? input) {
      if (input == null) return const <String, Object>{};
      final entries = input.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final out = <String, Object>{};
      for (final entry in entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) {
          asciiOk = false;
          continue;
        }
        final v = entry.value;
        if (v is String && !_isAscii(v)) {
          asciiOk = false;
          continue;
        }
        out[key] = v is String || v is num || v is bool ? v as Object : v ?? '';
      }
      return Map<String, Object>.unmodifiable(out);
    }

    final polishKeys =
        polishBundle.keys.map((k) => k.toString()).where(_isAscii).toList()
          ..sort();
    final snapshotKeys =
        v4Snapshot.keys.map((k) => k.toString()).where(_isAscii).toList()
          ..sort();
    final missingPolishTokens = <String>[];
    for (final key in snapshotKeys) {
      if (key.startsWith('polish') && !polishKeys.contains(key)) {
        missingPolishTokens.add(key);
      }
    }

    final surfacePolishStatus = _map(polishBundle);

    final personaAlignmentOk =
        personaMatView['persona_v4_mat_crosscheck_ok'] == true;
    final tokenSyncOk =
        tokenVerificationView['token_structure_ok'] == true &&
        tokenVerificationView['ok'] == true;
    final matPolishOk =
        cohesionView['cohesion_crosscheck_ok'] == true && tokenSyncOk;

    final conflictFlags = <String>[];
    if (!personaAlignmentOk) conflictFlags.add('persona_alignment');
    if (!tokenSyncOk) conflictFlags.add('token_sync');
    if (!matPolishOk) conflictFlags.add('mat_polish');
    if (missingPolishTokens.isNotEmpty) conflictFlags.add('missing_polish');
    conflictFlags.sort();

    if (!asciiOk) return _fallback();

    final drivers = <String>[
      ..._list(tokenVerificationView['drivers']),
      ..._list(cohesionView['conflict_flags']),
      ..._list(personaMatView['conflict_flags']),
      ...conflictFlags,
    ]..sort();

    final visualPolishOk = conflictFlags.isEmpty && drivers.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'visual_polish_ok': visualPolishOk,
      'missing_polish_tokens': List<String>.unmodifiable(missingPolishTokens),
      'surface_polish_status': surfacePolishStatus,
      'persona_visual_alignment_ok': personaAlignmentOk,
      'token_polish_sync_ok': tokenSyncOk,
      'mat_polish_alignment_ok': matPolishOk,
      'final_polish_conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
    });
  }

  Map<String, Object> _fallback() => const <String, Object>{
    'visual_polish_ok': false,
    'missing_polish_tokens': <String>[],
    'surface_polish_status': <String, Object>{},
    'persona_visual_alignment_ok': false,
    'token_polish_sync_ok': false,
    'mat_polish_alignment_ok': false,
    'final_polish_conflict_flags': <String>[],
    'drivers': <String>['v4_final_polish_view_safe_fallback'],
  };

  Map<String, Object> buildFinalV4PolishV1({
    required Map<String, Object?> v4Snapshot,
    required Map<String, Object?> tokenNormalized,
    required Map<String, Object> cohesionFinalSweep,
    required Map<String, Object> tokenFinalVerification,
    required Map<String, Object> personaV4MatFinal,
    required Map<String, Object?> polishBundle,
    required Map<String, Object> finalCoherencePass,
    required Map<String, Object> readinessSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    bool _asciiMap(Map<dynamic, dynamic> m) {
      for (final entry in m.entries) {
        final k = entry.key.toString();
        if (!_isAscii(k)) return false;
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

    if (!_asciiMap(v4Snapshot) ||
        !_asciiMap(tokenNormalized) ||
        !_asciiMap(cohesionFinalSweep) ||
        !_asciiMap(tokenFinalVerification) ||
        !_asciiMap(personaV4MatFinal) ||
        !_asciiMap(polishBundle) ||
        !_asciiMap(finalCoherencePass) ||
        !_asciiMap(readinessSurface)) {
      return _finalPolishFallback();
    }

    final missingKeys = <String>[];
    for (final key in ['primary', 'secondary']) {
      if (!v4Snapshot.containsKey(key)) missingKeys.add('v4_$key');
    }
    if (tokenNormalized.isEmpty) missingKeys.add('token_normalized');
    if (polishBundle.isEmpty) missingKeys.add('polish_bundle');

    final visualConflicts = <String>[
      ..._asciiList(cohesionFinalSweep['surface_mismatches']),
      ..._asciiList(cohesionFinalSweep['token_polish_conflicts']),
    ];
    final personaConflicts = _asciiList(
      personaV4MatFinal['persona_mat_conflicts'],
    );
    final tokenConflicts = _asciiList(
      tokenFinalVerification['cohesion_conflicts'],
    );
    final polishConflicts = _asciiList(
      polishBundle['final_polish_conflict_flags'],
    );
    final coherenceConflicts =
        _asciiList(finalCoherencePass['conflicts']) +
        _asciiList(readinessSurface['conflicts']);

    final drivers = <String>[
      ...missingKeys,
      ...visualConflicts,
      ...personaConflicts,
      ...tokenConflicts,
      ...polishConflicts,
      ...coherenceConflicts,
    ]..sort();

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
      'v4_snapshot': v4Snapshot,
      'token_normalized': tokenNormalized,
      'cohesion_final_sweep': cohesionFinalSweep,
      'token_final_verification': tokenFinalVerification,
      'persona_v4_mat_final': personaV4MatFinal,
      'polish_bundle': polishBundle,
      'final_coherence_pass': finalCoherencePass,
      'readiness_surface': readinessSurface,
    });

    final ok =
        missingKeys.isEmpty &&
        visualConflicts.isEmpty &&
        personaConflicts.isEmpty &&
        tokenConflicts.isEmpty &&
        polishConflicts.isEmpty &&
        coherenceConflicts.isEmpty &&
        readinessSurface['ok'] != false &&
        finalCoherencePass['ok'] != false;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'final_v4_polish_ok': ok,
      'missing_keys': List<String>.unmodifiable(missingKeys..sort()),
      'visual_conflicts': List<String>.unmodifiable(visualConflicts..sort()),
      'persona_conflicts': List<String>.unmodifiable(personaConflicts..sort()),
      'token_conflicts': List<String>.unmodifiable(tokenConflicts..sort()),
      'polish_conflicts': List<String>.unmodifiable(polishConflicts..sort()),
      'coherence_conflicts': List<String>.unmodifiable(
        coherenceConflicts..sort(),
      ),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    });
  }

  Map<String, Object> _finalPolishFallback() => const <String, Object>{
    'final_v4_polish_ok': false,
    'missing_keys': <String>[],
    'visual_conflicts': <String>[],
    'persona_conflicts': <String>[],
    'token_conflicts': <String>[],
    'polish_conflicts': <String>[],
    'coherence_conflicts': <String>[],
    'drivers': <String>[],
    'snapshot': <String, Object>{},
  };

  Map<String, Object> buildFinalVisualPolishStageV1({
    required Map<String, Object> cohesionFinalSweep,
    required Map<String, Object> tokenVerificationStageFinal,
    required Map<String, Object> personaV4MatConsistencyStageFinal,
    required Map<String, Object> finalV4PolishBundle,
    required Map<String, Object> visualCohesionIntegrator,
    required Map<String, Object> finalV4CoherencePass,
    required Map<String, Object> releaseReadinessSurface,
    required Map<String, Object> releaseSyncSnapshot,
    required Map<String, Object> releaseSyncSurface,
    required Map<String, Object> finalReleaseAssembly,
    required Map<String, Object> finalReleaseAssemblyStability,
    required Map<String, Object> finalReleaseAssemblyHarmonization,
    required Map<String, Object> v4Tokens,
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
      'final_visual_polish_stage_v1': false,
      'polish_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['final_visual_polish_stage_safe_fallback'],
      'snapshot': <String, Object>{},
    };

    final inputs = [
      cohesionFinalSweep,
      tokenVerificationStageFinal,
      personaV4MatConsistencyStageFinal,
      finalV4PolishBundle,
      visualCohesionIntegrator,
      finalV4CoherencePass,
      releaseReadinessSurface,
      releaseSyncSnapshot,
      releaseSyncSurface,
      finalReleaseAssembly,
      finalReleaseAssemblyStability,
      finalReleaseAssemblyHarmonization,
      v4Tokens,
    ];
    if (inputs.any((i) => i is! Map)) return fallback;
    if (inputs.any(
      (m) => (m as Map).keys.any((k) => !_isAscii(k.toString())),
    )) {
      return fallback;
    }
    if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
      return fallback;
    }

    int _clamp(int v) => v.clamp(0, 100);

    final conflictFlags = <String>[
      ..._asciiList(cohesionFinalSweep['conflict_flags']),
      ..._asciiList(tokenVerificationStageFinal['conflict_flags']),
      ..._asciiList(
        personaV4MatConsistencyStageFinal['conflict_flags'] ?? const [],
      ),
      ..._asciiList(
        finalV4PolishBundle['final_polish_conflict_flags'] ?? const [],
      ),
      ..._asciiList(visualCohesionIntegrator['conflict_flags'] ?? const []),
      ..._asciiList(finalV4CoherencePass['conflicts'] ?? const []),
      ..._asciiList(releaseSyncSurface['conflict_flags'] ?? const []),
      ..._asciiList(releaseSyncSnapshot['conflict_flags'] ?? const []),
      ..._asciiList(finalReleaseAssembly['conflict_flags'] ?? const []),
      ..._asciiList(
        finalReleaseAssemblyStability['conflict_flags'] ?? const [],
      ),
      ..._asciiList(
        finalReleaseAssemblyHarmonization['conflict_flags'] ?? const [],
      ),
    ]..sort();

    final drivers = <String>[
      ..._asciiList(cohesionFinalSweep['drivers']),
      ..._asciiList(tokenVerificationStageFinal['drivers']),
      ..._asciiList(personaV4MatConsistencyStageFinal['drivers'] ?? const []),
      ..._asciiList(finalV4PolishBundle['drivers'] ?? const []),
      ..._asciiList(visualCohesionIntegrator['drivers'] ?? const []),
      ..._asciiList(finalV4CoherencePass['drivers'] ?? const []),
      ..._asciiList(releaseReadinessSurface['drivers'] ?? const []),
      ..._asciiList(releaseSyncSurface['drivers'] ?? const []),
      ..._asciiList(releaseSyncSnapshot['drivers'] ?? const []),
      ..._asciiList(finalReleaseAssembly['drivers'] ?? const []),
      ..._asciiList(finalReleaseAssemblyStability['drivers'] ?? const []),
      ..._asciiList(finalReleaseAssemblyHarmonization['drivers'] ?? const []),
    ]..sort();

    bool _ok(Object? v) => v == true;
    final ok =
        conflictFlags.isEmpty &&
        _ok(cohesionFinalSweep['final_sweep_ok'] ?? cohesionFinalSweep['ok']) &&
        _ok(tokenVerificationStageFinal['token_verification_stage_final_v1']) &&
        _ok(
          personaV4MatConsistencyStageFinal['persona_v4_mat_consistency_stage_final_v1'],
        ) &&
        _ok(
          finalV4PolishBundle['visual_polish_ok'] ??
              finalV4PolishBundle['final_v4_polish_ok'],
        ) &&
        _ok(visualCohesionIntegrator['visual_cohesion_ok']) &&
        _ok(finalV4CoherencePass['ok']) &&
        _ok(releaseReadinessSurface['ok']) &&
        _ok(releaseSyncSurface['release_sync_surface_ok']) &&
        _ok(releaseSyncSnapshot['release_sync_ok']) &&
        _ok(finalReleaseAssembly['release_assembly_ok']) &&
        _ok(finalReleaseAssemblyStability['release_assembly_stability']) &&
        _ok(
          finalReleaseAssemblyHarmonization['release_assembly_harmonization'],
        );

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
      'cohesion_final_sweep': cohesionFinalSweep,
      'token_verification_stage_final': tokenVerificationStageFinal,
      'persona_v4_mat_consistency_stage_final':
          personaV4MatConsistencyStageFinal,
      'final_v4_polish_bundle': finalV4PolishBundle,
      'visual_cohesion_integrator': visualCohesionIntegrator,
      'final_v4_coherence_pass': finalV4CoherencePass,
      'release_readiness_surface': releaseReadinessSurface,
      'release_sync_snapshot': releaseSyncSnapshot,
      'release_sync_surface': releaseSyncSurface,
      'final_release_assembly': finalReleaseAssembly,
      'final_release_assembly_stability': finalReleaseAssemblyStability,
      'final_release_assembly_harmonization': finalReleaseAssemblyHarmonization,
      'v4_tokens': v4Tokens,
    });

    return <String, Object>{
      'final_visual_polish_stage_v1': ok,
      'polish_score': _clamp(100 - (conflictFlags.length * 3)),
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    };
  }
}
