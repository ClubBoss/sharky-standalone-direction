class V4TokenVerificationViewV4 {
  Map<String, Object> buildTokenVerificationView(
    Map<String, Object?> verificationStatus,
  ) {
    bool asciiOk = true;
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    List<String> _toAsciiList(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s)) {
          out.add(s);
        } else {
          asciiOk = false;
        }
      }
      out.sort();
      return out;
    }

    final missingCategories = _toAsciiList(
      verificationStatus['missing_categories'],
    );
    final missingTokens = _toAsciiList(verificationStatus['missing_tokens']);
    final invalidTokens = _toAsciiList(verificationStatus['invalid_tokens']);
    final drivers = _toAsciiList(verificationStatus['drivers']);
    final anomalies = _toAsciiList(verificationStatus['anomalies']);

    if (!asciiOk) return _fallback();

    final ok =
        verificationStatus['ok'] == true &&
        missingCategories.isEmpty &&
        missingTokens.isEmpty &&
        invalidTokens.isEmpty &&
        drivers.isEmpty &&
        anomalies.isEmpty;

    final tokenStructureOk =
        verificationStatus['token_structure_ok'] == true && asciiOk;
    final crosscheckPolishTokens = _toAsciiList(
      verificationStatus['crosscheck_polish_tokens'],
    );
    final invalidShapes = _toAsciiList(verificationStatus['invalid_shapes']);
    final tokenValueAnomalies = _toAsciiList(
      verificationStatus['token_value_anomalies'],
    );

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'missing_categories': List<String>.unmodifiable(
        List<String>.from(missingCategories),
      ),
      'missing_tokens': List<String>.unmodifiable(
        List<String>.from(missingTokens),
      ),
      'invalid_tokens': List<String>.unmodifiable(
        List<String>.from(invalidTokens),
      ),
      'drivers': List<String>.unmodifiable(List<String>.from(drivers)),
      'token_structure_ok': tokenStructureOk,
      'missing_required_categories': List<String>.unmodifiable(
        List<String>.from(missingCategories),
      ),
      'invalid_token_shapes': List<String>.unmodifiable(
        List<String>.from(invalidShapes),
      ),
      'token_value_anomalies': List<String>.unmodifiable(
        List<String>.from(tokenValueAnomalies),
      ),
      'crosscheck_polish_tokens': List<String>.unmodifiable(
        List<String>.from(crosscheckPolishTokens),
      ),
    });
  }

  Map<String, Object> _fallback() => const <String, Object>{
    'ok': false,
    'missing_categories': <String>[],
    'missing_tokens': <String>[],
    'invalid_tokens': <String>[],
    'drivers': <String>['token_verification_view_safe_fallback'],
    'token_structure_ok': false,
    'missing_required_categories': <String>[],
    'invalid_token_shapes': <String>[],
    'token_value_anomalies': <String>[],
    'crosscheck_polish_tokens': <String>[],
  };

  Map<String, Object> buildTokenVerificationStageFinalV1({
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
      'token_verification_stage_final_v1': false,
      'token_verification_score': 0,
      'conflict_flags': <String>[],
      'drivers': <String>['token_verification_stage_final_safe_fallback'],
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
      ..._asciiList(tokenFinalVerification['conflict_flags']),
      ..._asciiList(personaV4MatFinalQA['conflict_flags'] ?? const []),
      ..._asciiList(finalV4Polish['polish_conflicts'] ?? const []),
      ..._asciiList(visualCohesionIntegrator['conflict_flags'] ?? const []),
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
      ..._asciiList(tokenFinalVerification['drivers']),
      ..._asciiList(personaV4MatFinalQA['drivers'] ?? const []),
      ..._asciiList(finalV4Polish['drivers'] ?? const []),
      ..._asciiList(visualCohesionIntegrator['drivers'] ?? const []),
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
      'token_verification_stage_final_v1': ok,
      'token_verification_score': _clamp(100 - (conflictFlags.length * 3)),
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    };
  }

  Map<String, Object> buildTokenFinalVerificationV1({
    required Map<String, Object?> normalizedTokens,
    required Map<String, Object> tokenVerificationView,
    required Map<String, Object> polishView,
    required Map<String, Object> cohesionFinalSweep,
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

    List<String> _toAsciiList(Object? value) {
      if (value is! Iterable) return const <String>[];
      final out = <String>[];
      for (final v in value) {
        final s = v.toString();
        if (_isAscii(s)) out.add(s);
      }
      out.sort();
      return out;
    }

    if (!_asciiMap(normalizedTokens) ||
        !_asciiMap(tokenVerificationView) ||
        !_asciiMap(polishView) ||
        !_asciiMap(cohesionFinalSweep) ||
        !_asciiMap(readinessSurface)) {
      return _finalTokenFallback();
    }

    const requiredCategories = <String>{
      'color',
      'surface',
      'spacing',
      'radius',
      'shadow',
      'accent',
    };
    final presentCategories = <String>{};
    for (final raw in normalizedTokens.keys) {
      final key = raw.toString();
      for (final cat in requiredCategories) {
        if (key.startsWith(cat)) presentCategories.add(cat);
      }
    }
    final missingCategories =
        (requiredCategories.difference(presentCategories).toList()..sort());

    final invalidShapes = _toAsciiList(
      tokenVerificationView['invalid_token_shapes'],
    );
    final missingTokens = _toAsciiList(tokenVerificationView['missing_tokens']);
    final tokenPolishConflicts = <String>[
      ..._toAsciiList(tokenVerificationView['crosscheck_polish_tokens']),
      ..._toAsciiList(polishView['drivers']),
      ..._toAsciiList(polishView['final_polish_conflict_flags']),
      ..._toAsciiList(polishView['conflicts']),
    ]..sort();
    final cohesionConflicts = <String>[
      ..._toAsciiList(cohesionFinalSweep['surface_mismatches']),
      ..._toAsciiList(cohesionFinalSweep['token_polish_conflicts']),
      ..._toAsciiList(cohesionFinalSweep['coherence_conflicts']),
    ]..sort();

    final drivers = <String>[
      ...missingCategories,
      ...missingTokens,
      ...invalidShapes,
      ...tokenPolishConflicts,
      ...cohesionConflicts,
    ]..sort();

    final ok =
        tokenVerificationView['ok'] == true &&
        tokenVerificationView['token_structure_ok'] == true &&
        missingCategories.isEmpty &&
        missingTokens.isEmpty &&
        invalidShapes.isEmpty &&
        tokenPolishConflicts.isEmpty &&
        cohesionFinalSweep['final_sweep_ok'] != false &&
        readinessSurface['ok'] != false;

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
      'tokens': normalizedTokens,
      'token_view': tokenVerificationView,
      'polish_view': polishView,
      'cohesion_final_sweep': cohesionFinalSweep,
      'readiness_surface': readinessSurface,
    });

    return Map<String, Object>.unmodifiable(<String, Object>{
      'token_final_ok': ok,
      'missing_categories': List<String>.unmodifiable(missingCategories),
      'invalid_shapes': List<String>.unmodifiable(invalidShapes),
      'token_polish_conflicts': List<String>.unmodifiable(tokenPolishConflicts),
      'cohesion_conflicts': List<String>.unmodifiable(cohesionConflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'snapshot': snapshot,
    });
  }

  Map<String, Object> _finalTokenFallback() => const <String, Object>{
    'token_final_ok': false,
    'missing_categories': <String>[],
    'invalid_shapes': <String>[],
    'token_polish_conflicts': <String>[],
    'cohesion_conflicts': <String>[],
    'drivers': <String>[],
    'snapshot': <String, Object>{},
  };
}
