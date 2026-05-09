class V4PersonaMatConsistencyFinalViewV4 {
  Map<String, Object> buildPersonaV4MatFinalQA({
    required Map<String, Object?> personaUx,
    required Map<String, Object?> v4Snapshot,
    required Map<String, Object?> v4Delta,
    required Map<String, Object> matSnapshot,
    required Map<String, Object> cohesionFinalSweep,
    required Map<String, Object> tokenFinalVerification,
    required Map<String, Object> finalPolishView,
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

    if (!_asciiMap(personaUx) ||
        !_asciiMap(v4Snapshot) ||
        !_asciiMap(v4Delta) ||
        !_asciiMap(matSnapshot) ||
        !_asciiMap(cohesionFinalSweep) ||
        !_asciiMap(tokenFinalVerification) ||
        !_asciiMap(finalPolishView)) {
      return _fallback();
    }

    final missingKeys = <String>[];
    for (final key in ['title', 'short']) {
      if (!personaUx.containsKey(key)) missingKeys.add('persona_$key');
    }
    for (final key in ['primary', 'secondary']) {
      if (!v4Snapshot.containsKey(key)) missingKeys.add('v4_$key');
    }
    for (final key in ['color', 'radius', 'spacing']) {
      if (!matSnapshot.containsKey(key)) missingKeys.add('mat_$key');
    }

    final snapshotConflicts = <String>[];
    final personaMatConflicts = <String>[
      ..._asciiList(cohesionFinalSweep['persona_mat_conflicts']),
      ..._asciiList(cohesionFinalSweep['surface_mismatches']),
    ];
    final tokenConflicts = _asciiList(
      tokenFinalVerification['cohesion_conflicts'],
    );
    final polishConflicts = _asciiList(
      finalPolishView['final_polish_conflict_flags'],
    );
    final cohesionConflicts = _asciiList(
      cohesionFinalSweep['coherence_conflicts'],
    );

    if (cohesionFinalSweep['final_sweep_ok'] == false) {
      snapshotConflicts.add('cohesion_final_not_ok');
    }
    if (tokenFinalVerification['token_final_ok'] == false) {
      tokenConflicts.add('token_final_not_ok');
    }
    if (finalPolishView['visual_polish_ok'] == false &&
        finalPolishView['ok'] != true) {
      polishConflicts.add('final_polish_not_ok');
    }

    final drivers = <String>[
      ...missingKeys,
      ...snapshotConflicts,
      ...personaMatConflicts,
      ...cohesionConflicts,
      ...tokenConflicts,
      ...polishConflicts,
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
            if (v is String && !_isAscii(v)) return '';
            if (v is num) return v.toDouble().clamp(0, 100);
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

    final snapshotOrdered = _orderMap(<String, Object>{
      'persona': personaUx,
      'v4_snapshot': v4Snapshot,
      'v4_delta': v4Delta,
      'mat_snapshot': matSnapshot,
      'cohesion_final_sweep': cohesionFinalSweep,
      'token_final_verification': tokenFinalVerification,
      'final_polish_view': finalPolishView,
    });

    final ok =
        missingKeys.isEmpty &&
        personaMatConflicts.isEmpty &&
        tokenConflicts.isEmpty &&
        polishConflicts.isEmpty &&
        cohesionConflicts.isEmpty &&
        snapshotConflicts.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'persona_v4_mat_final_ok': ok,
      'missing_keys': List<String>.unmodifiable(missingKeys..sort()),
      'snapshot_conflicts': List<String>.unmodifiable(
        snapshotConflicts..sort(),
      ),
      'persona_mat_conflicts': List<String>.unmodifiable(
        personaMatConflicts..sort(),
      ),
      'cohesion_conflicts': List<String>.unmodifiable(
        cohesionConflicts..sort(),
      ),
      'token_conflicts': List<String>.unmodifiable(tokenConflicts..sort()),
      'polish_conflicts': List<String>.unmodifiable(polishConflicts..sort()),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshotOrdered,
    });
  }

  Map<String, Object> _fallback() => const <String, Object>{
    'persona_v4_mat_final_ok': false,
    'missing_keys': <String>[],
    'snapshot_conflicts': <String>[],
    'persona_mat_conflicts': <String>[],
    'cohesion_conflicts': <String>[],
    'token_conflicts': <String>[],
    'polish_conflicts': <String>[],
    'drivers': <String>[],
    'snapshot': <String, Object>{},
  };

  Map<String, Object> buildPersonaV4MatConsistencyStageFinalV1({
    required Map<String, Object> cohesionFinalSweep,
    required Map<String, Object> tokenVerificationStageFinal,
    required Map<String, Object> personaV4MatFinalQA,
    required Map<String, Object> finalV4Polish,
    required Map<String, Object> visualCohesionIntegrator,
    required Map<String, Object> releaseReadinessSurface,
    required Map<String, Object> releaseSyncSnapshot,
    required Map<String, Object> releaseSyncSurface,
    required Map<String, Object> finalReleaseAssembly,
    required Map<String, Object> finalReleaseAssemblyStability,
    required Map<String, Object> finalReleaseAssemblyHarmonization,
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

    const fallback = <String, Object>{
      'persona_v4_mat_consistency_stage_final_v1': false,
      'consistency_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['persona_v4_mat_final_stage_safe_fallback'],
      'snapshot': <String, Object>{},
    };

    final inputs = [
      cohesionFinalSweep,
      tokenVerificationStageFinal,
      personaV4MatFinalQA,
      finalV4Polish,
      visualCohesionIntegrator,
      releaseReadinessSurface,
      releaseSyncSnapshot,
      releaseSyncSurface,
      finalReleaseAssembly,
      finalReleaseAssemblyStability,
      finalReleaseAssemblyHarmonization,
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
      ..._asciiList(personaV4MatFinalQA['persona_mat_conflicts']),
      ..._asciiList(finalV4Polish['polish_conflicts']),
      ..._asciiList(visualCohesionIntegrator['conflict_flags']),
      ..._asciiList(releaseSyncSurface['conflict_flags']),
      ..._asciiList(releaseSyncSnapshot['conflict_flags']),
      ..._asciiList(finalReleaseAssembly['conflict_flags']),
      ..._asciiList(finalReleaseAssemblyStability['conflict_flags']),
      ..._asciiList(finalReleaseAssemblyHarmonization['conflict_flags']),
    ]..sort();

    final drivers = <String>[
      ..._asciiList(cohesionFinalSweep['drivers']),
      ..._asciiList(tokenVerificationStageFinal['drivers']),
      ..._asciiList(personaV4MatFinalQA['drivers']),
      ..._asciiList(finalV4Polish['drivers']),
      ..._asciiList(visualCohesionIntegrator['drivers']),
      ..._asciiList(releaseReadinessSurface['drivers'] ?? const []),
      ..._asciiList(releaseSyncSurface['drivers']),
      ..._asciiList(releaseSyncSnapshot['drivers']),
      ..._asciiList(finalReleaseAssembly['drivers'] ?? const []),
      ..._asciiList(finalReleaseAssemblyStability['drivers'] ?? const []),
      ..._asciiList(finalReleaseAssemblyHarmonization['drivers'] ?? const []),
    ]..sort();

    bool _ok(Object? v) => v == true;
    final ok =
        conflictFlags.isEmpty &&
        _ok(cohesionFinalSweep['final_sweep_ok'] ?? cohesionFinalSweep['ok']) &&
        _ok(tokenVerificationStageFinal['token_verification_stage_final_v1']) &&
        _ok(personaV4MatFinalQA['persona_v4_mat_final_ok']) &&
        _ok(finalV4Polish['final_v4_polish_ok']) &&
        _ok(visualCohesionIntegrator['visual_cohesion_ok']) &&
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

    final snapshotOrdered = _orderMap(<String, Object>{
      'cohesion_final_sweep': cohesionFinalSweep,
      'token_verification_stage_final': tokenVerificationStageFinal,
      'persona_v4_mat_final': personaV4MatFinalQA,
      'final_v4_polish': finalV4Polish,
      'visual_cohesion_integrator': visualCohesionIntegrator,
      'release_readiness_surface': releaseReadinessSurface,
      'release_sync_snapshot': releaseSyncSnapshot,
      'release_sync_surface': releaseSyncSurface,
      'final_release_assembly': finalReleaseAssembly,
      'final_release_assembly_stability': finalReleaseAssemblyStability,
      'final_release_assembly_harmonization': finalReleaseAssemblyHarmonization,
    });

    return Map<String, Object>.unmodifiable(<String, Object>{
      'persona_v4_mat_consistency_stage_final_v1': ok,
      'consistency_score': _clamp(100 - (conflictFlags.length * 3)),
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshotOrdered,
    });
  }
}
