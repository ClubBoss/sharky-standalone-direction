class V4CohesionReleaseSurfaceV1 {
  static Map<String, Object> build({
    required Map<String, Object?> cohesionQaView,
    required Map<String, Object?> tokenVerificationView,
    required Map<String, Object?> personaMatConsistencyView,
    required Map<String, Object?> finalPolishView,
    required Map<String, Object?> finalOmegaBridge,
    required Map<String, Object?> readinessSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    Map<String, Object> _clean(Object? value) {
      if (value is! Map) return const <String, Object>{};
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final out = <String, Object>{};
      for (final entry in entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) continue;
        final v = entry.value;
        if (v is Map) {
          out[key] = _clean(v.map((k, val) => MapEntry(k.toString(), val)));
        } else if (v is String) {
          if (_isAscii(v)) out[key] = v;
        } else if (v is num || v is bool) {
          out[key] = v as Object;
        }
      }
      return Map<String, Object>.unmodifiable(out);
    }

    final visual = _clean(cohesionQaView);
    final tokens = _clean(tokenVerificationView);
    final persona = _clean(personaMatConsistencyView);
    final polish = _clean(finalPolishView);
    final mat = _clean(finalOmegaBridge);
    final release = _clean(readinessSurface);

    final conflicts = <String>[
      if (visual.isEmpty) 'visual',
      if (tokens.isEmpty) 'tokens',
      if (persona.isEmpty) 'persona',
      if (polish.isEmpty) 'polish',
      if (mat.isEmpty) 'omega_bridge',
      if (release.isEmpty) 'readiness_surface',
    ]..sort();
    final ok = conflicts.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'visual_blocks': visual,
      'persona_blocks': persona,
      'cohesion_blocks': tokens,
      'polish_blocks': polish,
      'mat_blocks': mat,
      'conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(conflicts),
    });
  }
}
