class CohesionQAViewV4 {
  static const List<String> _categories = <String>[
    'surface',
    'card',
    'table',
    'text',
    'radius',
    'shadow',
    'polish',
  ];

  Map<String, Object> buildCohesionView(Map<String, Object?> qaBundle) {
    final normalizedTokens =
        (qaBundle['v4_normalized_tokens'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final snapshot =
        (qaBundle['v4_snapshot'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final delta =
        (qaBundle['v4_delta_report'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final cohesion =
        (qaBundle['v4_cohesion_report'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final cohesionReport =
        (qaBundle['cohesion_report'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final tokenView =
        (qaBundle['token_view'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final polishView =
        (qaBundle['polish_view'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};
    final personaMatView =
        (qaBundle['persona_mat_view'] as Map?)?.cast<String, Object?>() ??
        const <String, Object?>{};

    if (!_asciiMap(normalizedTokens) ||
        !_asciiMap(snapshot) ||
        !_asciiMap(delta) ||
        !_asciiMap(cohesion)) {
      return _fallback();
    }

    final snapshotKeys = snapshot.keys.map((e) => e.toString()).toSet();
    final deltaChanged = <String>{
      ..._asAsciiList(delta['changed']),
      ..._asAsciiList(delta['added']),
    };

    final missingTokens = <String>[];
    final mismatchedCategories = <String>[];
    for (final rawKey in normalizedTokens.keys) {
      final key = rawKey.toString();
      if (!_isAscii(key)) return _fallback();
      final categoryOk = _categories.any(key.startsWith);
      if (!categoryOk) mismatchedCategories.add(key);
      if (!snapshotKeys.contains(key) && !deltaChanged.contains(key)) {
        missingTokens.add(key);
      }
    }

    final surfaceFlags = <String>[];
    for (final added in _asAsciiList(delta['added'])) {
      surfaceFlags.add('delta_added:$added');
    }
    for (final removed in _asAsciiList(delta['removed'])) {
      surfaceFlags.add('delta_removed:$removed');
    }
    for (final miss in _asAsciiList(cohesion['missing_tokens'])) {
      surfaceFlags.add('cohesion_missing:$miss');
    }
    for (final mismatch in _asAsciiList(cohesion['mismatched_tokens'])) {
      surfaceFlags.add('cohesion_mismatch:$mismatch');
    }
    if (normalizedTokens.isEmpty) surfaceFlags.add('tokens_empty');
    if (snapshotKeys.isEmpty) surfaceFlags.add('snapshot_empty');

    final snapshotVsTokens = <String, Object>{
      'snapshot_count': snapshotKeys.length,
      'token_count': normalizedTokens.length,
      'coverage': _clamp01(
        snapshotKeys.isEmpty
            ? 0
            : (snapshotKeys
                      .intersection(
                        normalizedTokens.keys.map((e) => e.toString()).toSet(),
                      )
                      .length /
                  snapshotKeys.length),
      ),
    };
    final deltaVsTokens = <String, Object>{
      'delta_changed': _asAsciiList(delta['changed']),
      'delta_added': _asAsciiList(delta['added']),
      'delta_removed': _asAsciiList(delta['removed']),
      'delta_impact': _clamp01(
        normalizedTokens.isEmpty
            ? 0
            : (_asAsciiList(delta['changed']).length +
                      _asAsciiList(delta['added']).length +
                      _asAsciiList(delta['removed']).length) /
                  normalizedTokens.length,
      ),
    };
    final tokenCategories = <String, Object>{
      'mismatched_categories': List<String>.unmodifiable(
        mismatchedCategories..sort(),
      ),
      'category_coverage': _clamp01(
        normalizedTokens.isEmpty
            ? 0
            : (normalizedTokens.length - mismatchedCategories.length) /
                  normalizedTokens.length,
      ),
    };
    final surfaceRequirements = <String, Object>{
      'surface_flags': List<String>.unmodifiable(surfaceFlags..sort()),
    };
    final polishConsistency = <String, Object>{
      'polish_flags': List<String>.unmodifiable(
        _asAsciiList(polishView['drivers']),
      ),
    };
    final personaMatCrosscheck = <String, Object>{
      'persona_mat_flags': List<String>.unmodifiable(
        _asAsciiList(personaMatView['drivers']),
      ),
    };

    final conflicts = <String>[];
    if (cohesionReport['ok'] == false) conflicts.add('cohesion_report_fail');
    if (tokenView['ok'] == false) conflicts.add('token_view_fail');
    if (polishView['ok'] == false) conflicts.add('polish_view_fail');
    if (personaMatView['ok'] == false) conflicts.add('persona_mat_view_fail');
    if (cohesion['ok'] == true &&
        (missingTokens.isNotEmpty || mismatchedCategories.isNotEmpty)) {
      conflicts.add('cohesion_ok_conflict');
    }
    conflicts.sort();

    final drivers = <String>[
      ..._asAsciiList(cohesion['mismatched_tokens']),
      ...conflicts,
    ]..sort();

    final ok =
        missingTokens.isEmpty &&
        mismatchedCategories.isEmpty &&
        surfaceFlags.isEmpty &&
        drivers.isEmpty;

    final cohesionCrosscheckOk = cohesionReport['ok'] == true;
    final personaMatSyncOk = personaMatView['ok'] == true;
    final tokenPolishConsistencyOk =
        tokenView['ok'] == true && polishView['ok'] == true;
    final surfaceBindingOk =
        normalizedTokens.isNotEmpty && snapshotKeys.isNotEmpty;

    final conflictFlags = <String>[];
    if (!cohesionCrosscheckOk) conflictFlags.add('cohesion_report');
    if (!personaMatSyncOk) conflictFlags.add('persona_mat');
    if (!tokenPolishConsistencyOk) conflictFlags.add('token_polish');
    if (!surfaceBindingOk) conflictFlags.add('surface_binding');
    conflictFlags.sort();

    final cohesionSummary = <String, Object>{
      'conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'ok': ok,
    };

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'snapshot_vs_tokens': Map<String, Object>.unmodifiable(snapshotVsTokens),
      'delta_vs_tokens': Map<String, Object>.unmodifiable(deltaVsTokens),
      'token_categories': Map<String, Object>.unmodifiable(tokenCategories),
      'missing_tokens': List<String>.unmodifiable(missingTokens..sort()),
      'surface_requirements': Map<String, Object>.unmodifiable(
        surfaceRequirements,
      ),
      'polish_consistency': Map<String, Object>.unmodifiable(polishConsistency),
      'persona_mat_crosscheck': Map<String, Object>.unmodifiable(
        personaMatCrosscheck,
      ),
      'cohesion_summary': Map<String, Object>.unmodifiable(cohesionSummary),
      'cohesion_crosscheck_ok': cohesionCrosscheckOk,
      'persona_mat_sync_ok': personaMatSyncOk,
      'token_polish_consistency_ok': tokenPolishConsistencyOk,
      'surface_binding_ok': surfaceBindingOk,
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
    });
  }

  Map<String, Object> buildCohesionFinalSweepV1({
    required Map<String, Object?> snapshot,
    required Map<String, Object?> tokens,
    required Map<String, Object?> delta,
    required Map<String, Object> personaMatView,
    required Map<String, Object> polishView,
    required Map<String, Object> coherenceView,
    required Map<String, Object> readinessSurface,
  }) {
    if (!_asciiMap(snapshot) ||
        !_asciiMap(tokens) ||
        !_asciiMap(delta) ||
        !_asciiMap(personaMatView) ||
        !_asciiMap(polishView) ||
        !_asciiMap(coherenceView) ||
        !_asciiMap(readinessSurface)) {
      return _finalSweepFallback();
    }

    final snapshotKeys = snapshot.keys.map((e) => e.toString()).toSet();
    final deltaChanged = <String>{
      ..._asAsciiList(delta['changed']),
      ..._asAsciiList(delta['added']),
    };
    final missingTokens = <String>[];
    final surfaceMismatches = <String>[];
    for (final rawKey in tokens.keys) {
      final key = rawKey.toString();
      final categoryOk = _categories.any(key.startsWith);
      if (!categoryOk) surfaceMismatches.add(key);
      if (!snapshotKeys.contains(key) && !deltaChanged.contains(key)) {
        missingTokens.add(key);
      }
    }
    final extraSnapshot =
        snapshotKeys
            .difference(tokens.keys.map((e) => e.toString()).toSet())
            .toList()
          ..sort();
    surfaceMismatches.addAll(extraSnapshot);
    surfaceMismatches.sort();
    missingTokens.sort();

    final tokenPolishConflicts = <String>[
      ..._asAsciiList(polishView['drivers']),
      ..._asAsciiList(polishView['final_polish_conflict_flags']),
      ..._asAsciiList(polishView['conflicts']),
    ]..sort();
    final personaMatConflicts = <String>[
      ..._asAsciiList(personaMatView['conflict_flags']),
      ..._asAsciiList(personaMatView['drivers']),
    ]..sort();
    final coherenceConflicts = <String>[
      ..._asAsciiList(coherenceView['conflicts']),
      ..._asAsciiList(coherenceView['drivers']),
      ..._asAsciiList(readinessSurface['conflicts']),
    ]..sort();

    final drivers = <String>[
      ...missingTokens,
      ...surfaceMismatches,
      ...tokenPolishConflicts,
      ...personaMatConflicts,
      ...coherenceConflicts,
    ]..sort();

    final ok =
        drivers.isEmpty &&
        polishView['ok'] != false &&
        personaMatView['ok'] != false &&
        coherenceView['ok'] != false &&
        readinessSurface['ok'] != false;

    final orderedSnapshot = _orderMap(<String, Object>{
      'snapshot': snapshot,
      'tokens': tokens,
      'delta': delta,
      'persona_mat_view': personaMatView,
      'polish_view': polishView,
      'coherence_view': coherenceView,
      'readiness_surface': readinessSurface,
    });

    return Map<String, Object>.unmodifiable(<String, Object>{
      'final_sweep_ok': ok,
      'missing_tokens': List<String>.unmodifiable(missingTokens),
      'surface_mismatches': List<String>.unmodifiable(surfaceMismatches),
      'token_polish_conflicts': List<String>.unmodifiable(tokenPolishConflicts),
      'persona_mat_conflicts': List<String>.unmodifiable(personaMatConflicts),
      'coherence_conflicts': List<String>.unmodifiable(coherenceConflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': orderedSnapshot,
    });
  }

  List<String> _asAsciiList(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      if (_isAscii(s)) out.add(s);
    }
    out.sort();
    return out;
  }

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

  double _clamp01(Object? value) {
    if (value is num) {
      final d = value.toDouble();
      return d.clamp(0.0, 1.0);
    }
    return 0.0;
  }

  Map<String, Object> _fallback() => const <String, Object>{
    'ok': false,
    'snapshot_vs_tokens': <String, Object>{},
    'delta_vs_tokens': <String, Object>{},
    'token_categories': <String, Object>{},
    'missing_tokens': <String>[],
    'surface_requirements': <String, Object>{},
    'polish_consistency': <String, Object>{},
    'persona_mat_crosscheck': <String, Object>{},
    'cohesion_summary': <String, Object>{
      'conflicts': <String>[],
      'drivers': <String>[],
      'ok': false,
    },
    'cohesion_crosscheck_ok': false,
    'persona_mat_sync_ok': false,
    'token_polish_consistency_ok': false,
    'surface_binding_ok': false,
    'conflict_flags': <String>[],
  };

  Map<String, Object> buildCohesionQAStageFinalV1({
    required Map<String, Object> cohesionFinalSweep,
    required Map<String, Object> tokenFinalVerification,
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

    const fallbackFinal = <String, Object>{
      'cohesion_qa_stage_final_v1': false,
      'cohesion_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['cohesion_qa_stage_final_safe_fallback'],
      'snapshot': <String, Object>{},
    };

    final inputs = [
      cohesionFinalSweep,
      tokenFinalVerification,
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
    if (inputs.any((i) => i is! Map)) return fallbackFinal;
    if (inputs.any(
      (m) => (m as Map).keys.any((k) => !_isAscii(k.toString())),
    )) {
      return fallbackFinal;
    }
    if (inputs.any((m) => !(m as Map).isEmpty && !_asciiMap(m as Map))) {
      return fallbackFinal;
    }

    int _clamp(int v) => v.clamp(0, 100);

    final conflictFlags = <String>[
      ..._asciiList(cohesionFinalSweep['conflict_flags']),
      ..._asciiList(tokenFinalVerification['conflict_flags']),
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
      ..._asciiList(tokenFinalVerification['drivers']),
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
        _ok(tokenFinalVerification['token_final_ok']) &&
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

    final snapshot = _orderMap(<String, Object>{
      'cohesion_final_sweep': cohesionFinalSweep,
      'token_final_verification': tokenFinalVerification,
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

    return <String, Object>{
      'cohesion_qa_stage_final_v1': ok,
      'cohesion_score': _clamp(100 - (conflictFlags.length * 3)),
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    };
  }

  Map<String, Object> _finalSweepFallback() => const <String, Object>{
    'final_sweep_ok': false,
    'missing_tokens': <String>[],
    'surface_mismatches': <String>[],
    'token_polish_conflicts': <String>[],
    'persona_mat_conflicts': <String>[],
    'coherence_conflicts': <String>[],
    'drivers': <String>[],
    'snapshot': <String, Object>{},
  };

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
          return v as Object;
        }).toList()..sort((a, b) => a.toString().compareTo(b.toString()));
        ordered[entry.key] = list;
      } else if (value is String) {
        ordered[entry.key] = _isAscii(value) ? value : '';
      } else if (value == null) {
        ordered[entry.key] = '';
      } else {
        ordered[entry.key] = value;
      }
    }
    return ordered;
  }
}
