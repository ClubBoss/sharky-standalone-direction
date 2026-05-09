class MATSnapshotConsistencyV1 {
  static Map<String, Object> build({
    required Map<String, Object?> v3Snapshot,
    required Map<String, Object?> v4Snapshot,
    required Map<String, Object?> deltaReport,
    required Map<String, Object?> cohesionView,
    required Map<String, Object?> tokenView,
    required Map<String, Object?> personaMatView,
    required Map<String, Object?> polishView,
    required Map<String, Object?> finalCoherenceView,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'ok': false,
      'mat_v3_ok': false,
      'mat_v4_ok': false,
      'delta_ok': false,
      'cohesion_sync_ok': false,
      'token_sync_ok': false,
      'persona_mat_sync_ok': false,
      'polish_alignment_ok': false,
      'conflicts': <String>[],
      'drivers': <String>['mat_snapshot_consistency_safe_fallback'],
      'summary': 'mat_snapshot_consistency_unavailable',
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
    ];
    if (inputs.any((m) => (m as Map).keys.any((k) => !_isAscii(k.toString()))))
      return fallback;

    bool _mapNotEmpty(Map<String, Object?> map) =>
        map.isNotEmpty && map.keys.every((k) => _isAscii(k.toString()));

    final matV3Ok = _mapNotEmpty(v3Snapshot);
    final matV4Ok = _mapNotEmpty(v4Snapshot);
    final deltaOk = _mapNotEmpty(deltaReport);
    final cohesionSyncOk = cohesionView['ok'] == true;
    final tokenSyncOk = tokenView['ok'] == true;
    final personaMatSyncOk = personaMatView['ok'] == true;
    final polishAlignmentOk = polishView['visual_polish_ok'] == true;

    final conflicts = <String>[
      if (!matV3Ok) 'mat_v3',
      if (!matV4Ok) 'mat_v4',
      if (!deltaOk) 'delta',
      if (!cohesionSyncOk) 'cohesion',
      if (!tokenSyncOk) 'token',
      if (!personaMatSyncOk) 'persona_mat',
      if (!polishAlignmentOk) 'polish',
      if (finalCoherenceView['ok'] == false) 'final_coherence',
    ]..sort();

    final drivers = <String>[
      ..._collectDrivers(cohesionView['conflicts']),
      ..._collectDrivers(tokenView['drivers']),
      ..._collectDrivers(personaMatView['conflict_flags']),
      ..._collectDrivers(polishView['final_polish_conflict_flags']),
      ...conflicts,
    ]..sort();

    final ok = conflicts.isEmpty && drivers.isEmpty;
    final summary = ok
        ? 'mat_snapshot_consistency_ok'
        : 'mat_snapshot_consistency_conflicts:${conflicts.join(',')}';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'mat_v3_ok': matV3Ok,
      'mat_v4_ok': matV4Ok,
      'delta_ok': deltaOk,
      'cohesion_sync_ok': cohesionSyncOk,
      'token_sync_ok': tokenSyncOk,
      'persona_mat_sync_ok': personaMatSyncOk,
      'polish_alignment_ok': polishAlignmentOk,
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
