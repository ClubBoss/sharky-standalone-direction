class FinalVisualPolishV1 {
  static Map<String, Object> build({
    required Map<String, Object?> v3Snapshot,
    required Map<String, Object?> v4Snapshot,
    required Map<String, Object?> deltaReport,
    required Map<String, Object?> cohesionView,
    required Map<String, Object?> tokenView,
    required Map<String, Object?> personaMatView,
    required Map<String, Object?> polishView,
    required Map<String, Object?> finalCoherenceView,
    required Map<String, Object?> matSnapshotView,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'ok': false,
      'snapshot_alignment_ok': false,
      'token_polish_alignment_ok': false,
      'persona_mat_alignment_ok': false,
      'cohesion_alignment_ok': false,
      'delta_alignment_ok': false,
      'mat_alignment_ok': false,
      'conflicts': <String>[],
      'drivers': <String>['final_visual_polish_safe_fallback'],
      'summary': 'final_visual_polish_unavailable',
    };

    final inputs = [
      v3Snapshot,
      v4Snapshot,
      deltaReport,
      cohesionView,
      tokenView,
      personaMatView,
      polishView,
      finalCoherenceView,
      matSnapshotView,
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;

    bool _mapOk(Map<String, Object?> map) =>
        map.isNotEmpty && map.keys.every((k) => _isAscii(k.toString()));

    final snapshotAlignmentOk = _mapOk(v3Snapshot) && _mapOk(v4Snapshot);
    final tokenPolishAlignmentOk =
        tokenView['ok'] == true && polishView['token_polish_sync_ok'] == true;
    final personaMatAlignmentOk = personaMatView['ok'] == true;
    final cohesionAlignmentOk = cohesionView['ok'] == true;
    final deltaAlignmentOk = _mapOk(deltaReport);
    final matAlignmentOk = matSnapshotView['ok'] == true;

    final conflicts = <String>[
      if (!snapshotAlignmentOk) 'snapshot',
      if (!tokenPolishAlignmentOk) 'token_polish',
      if (!personaMatAlignmentOk) 'persona_mat',
      if (!cohesionAlignmentOk) 'cohesion',
      if (!deltaAlignmentOk) 'delta',
      if (!matAlignmentOk) 'mat',
      if (finalCoherenceView['ok'] == false) 'final_coherence',
    ]..sort();

    List<String> _drivers(Object? value) {
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

    final drivers = <String>[
      ..._drivers(tokenView['drivers']),
      ..._drivers(cohesionView['conflict_flags']),
      ..._drivers(personaMatView['conflict_flags']),
      ..._drivers(polishView['final_polish_conflict_flags']),
      ...conflicts,
    ]..sort();

    final ok = conflicts.isEmpty && drivers.isEmpty;
    final summary = ok
        ? 'final_visual_polish_ok'
        : 'final_visual_polish_conflicts:${conflicts.join(',')}';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'snapshot_alignment_ok': snapshotAlignmentOk,
      'token_polish_alignment_ok': tokenPolishAlignmentOk,
      'persona_mat_alignment_ok': personaMatAlignmentOk,
      'cohesion_alignment_ok': cohesionAlignmentOk,
      'delta_alignment_ok': deltaAlignmentOk,
      'mat_alignment_ok': matAlignmentOk,
      'conflicts': List<String>.unmodifiable(conflicts),
      'drivers': List<String>.unmodifiable(drivers),
      'summary': summary,
    });
  }
}
