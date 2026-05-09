Map<String, Object> buildV4VisualCohesionIntegratorV1({
  required Map<String, Object> sweep,
  required Map<String, Object> tokenFinal,
  required Map<String, Object> personaMatFinal,
  required Map<String, Object> finalPolish,
  required Map<String, Object> finalCoherence,
  required Map<String, Object> matConsistency,
  required Map<String, Object> visualPolish,
  required Map<String, Object> releaseSyncSurface,
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
    'visual_cohesion_ok': false,
    'alignment_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['v4_visual_cohesion_integrator_safe_fallback'],
    'sections': <String, Object>{},
    'snapshot': <String, Object>{},
  };

  final inputs = [
    sweep,
    tokenFinal,
    personaMatFinal,
    finalPolish,
    finalCoherence,
    matConsistency,
    visualPolish,
    releaseSyncSurface,
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
    ..._asciiList(sweep['surface_mismatches']),
    ..._asciiList(sweep['token_polish_conflicts']),
    ..._asciiList(sweep['coherence_conflicts']),
    ..._asciiList(tokenFinal['cohesion_conflicts']),
    ..._asciiList(personaMatFinal['persona_mat_conflicts']),
    ..._asciiList(finalPolish['polish_conflicts']),
    ..._asciiList(finalCoherence['conflicts']),
    ..._asciiList(matConsistency['conflicts']),
    ..._asciiList(visualPolish['conflicts']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(sweep['drivers']),
    ..._asciiList(tokenFinal['drivers']),
    ..._asciiList(personaMatFinal['drivers']),
    ..._asciiList(finalPolish['drivers']),
    ..._asciiList(finalCoherence['drivers']),
    ..._asciiList(matConsistency['drivers']),
    ..._asciiList(visualPolish['drivers']),
    ..._asciiList(releaseSyncSurface['drivers']),
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(sweep['final_sweep_ok'] ?? sweep['visual_cohesion_ok']) &&
      _ok(tokenFinal['token_final_ok']) &&
      _ok(personaMatFinal['persona_v4_mat_final_ok']) &&
      _ok(finalPolish['final_v4_polish_ok']) &&
      _ok(finalCoherence['ok']) &&
      _ok(matConsistency['ok']) &&
      _ok(visualPolish['ok'] ?? visualPolish['final_visual_polish_ok']) &&
      _ok(releaseSyncSurface['release_sync_surface_ok']);

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
    'sweep': sweep,
    'token_final': tokenFinal,
    'persona_mat_final': personaMatFinal,
    'final_polish': finalPolish,
    'final_coherence': finalCoherence,
    'mat_consistency': matConsistency,
    'visual_polish': visualPolish,
    'release_sync_surface': releaseSyncSurface,
  });

  final snapshot = _orderMap(<String, Object>{...sections});

  return <String, Object>{
    'visual_cohesion_ok': ok,
    'alignment_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'sections': sections,
    'snapshot': snapshot,
  };
}
