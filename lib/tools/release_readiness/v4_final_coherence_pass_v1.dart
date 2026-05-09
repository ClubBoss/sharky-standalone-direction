class V4FinalCoherencePassV1 {
  static Map<String, Object> build({
    required Map<String, Object?> releaseSurface,
    required Map<String, Object?> cohesionView,
    required Map<String, Object?> tokenView,
    required Map<String, Object?> personaMatView,
    required Map<String, Object?> polishView,
    required Map<String, Object?> omegaBridge,
    required Map<String, Object?> readinessSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'ok': false,
      'final_visual_ok': false,
      'token_polish_ok': false,
      'persona_mat_ok': false,
      'surface_binding_ok': false,
      'mat_snapshot_ok': false,
      'conflicts': <String>[],
      'drivers': <String>['v4_final_coherence_safe_fallback'],
      'summary': 'final_coherence_unavailable',
    };

    final inputs = [
      releaseSurface,
      cohesionView,
      tokenView,
      personaMatView,
      polishView,
      omegaBridge,
      readinessSurface,
    ];
    if (inputs.any((i) => i is! Map)) return fallback;
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;

    final finalVisualOk =
        releaseSurface['ok'] == true && cohesionView['ok'] == true;
    final tokenPolishOk =
        tokenView['ok'] == true && polishView['token_polish_sync_ok'] == true;
    final personaMatOk = personaMatView['ok'] == true;
    final surfaceBindingOk = cohesionView['surface_binding_ok'] == true;
    final matSnapshotOk = personaMatView['mat_snapshot_ok'] == true;

    final conflicts = <String>[
      if (!finalVisualOk) 'final_visual',
      if (!tokenPolishOk) 'token_polish',
      if (!personaMatOk) 'persona_mat',
      if (!surfaceBindingOk) 'surface_binding',
      if (!matSnapshotOk) 'mat_snapshot',
    ]..sort();

    final drivers = <String>[
      ..._collectDrivers(cohesionView['conflict_flags']),
      ..._collectDrivers(tokenView['drivers']),
      ..._collectDrivers(personaMatView['conflict_flags']),
      ..._collectDrivers(polishView['final_polish_conflict_flags']),
      ...conflicts,
    ]..sort();

    final ok = conflicts.isEmpty && drivers.isEmpty;
    final summary = ok
        ? 'final_coherence_ok'
        : 'final_coherence_conflicts:${conflicts.join(',')}';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'final_visual_ok': finalVisualOk,
      'token_polish_ok': tokenPolishOk,
      'persona_mat_ok': personaMatOk,
      'surface_binding_ok': surfaceBindingOk,
      'mat_snapshot_ok': matSnapshotOk,
      'conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'summary': summary,
    });
  }

  static List<String> _collectDrivers(Object? value) {
    if (value is! Iterable) return const <String>[];
    final out = <String>[];
    for (final v in value) {
      final s = v.toString();
      var ascii = true;
      for (final code in s.runes) {
        if (code > 127) {
          ascii = false;
          break;
        }
      }
      if (ascii) out.add(s);
    }
    out.sort();
    return out;
  }
}
