class V4PersonaMatConsistencyViewV4 {
  Map<String, Object?> buildPersonaMatConsistencyView(
    Map<String, Object?> personaBundle,
    Map<String, Object?> matSnapshot,
    Map<String, Object?> v4Snapshot, {
    Map<String, Object?> cohesionView = const <String, Object?>{},
    Map<String, Object?> tokenView = const <String, Object?>{},
    Map<String, Object?> polishBundle = const <String, Object?>{},
  }) {
    bool asciiOk = true;
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    List<String> _listFromKeys(Map<String, Object?> map) {
      final out = <String>[];
      for (final key in map.keys) {
        final s = key.toString();
        if (_isAscii(s)) {
          out.add(s);
        } else {
          asciiOk = false;
        }
      }
      out.sort();
      return out;
    }

    List<String> _asciiList(Object? value) {
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

    final personaKeys = _listFromKeys(personaBundle);
    final matKeys = _listFromKeys(matSnapshot);
    final snapKeys = _listFromKeys(v4Snapshot);

    final missingKeys = <String>[];
    for (final key in ['title', 'short']) {
      if (!personaKeys.contains(key)) missingKeys.add('persona:$key');
    }
    if (matKeys.isEmpty) missingKeys.add('mat:snapshot');
    if (snapKeys.isEmpty) missingKeys.add('v4:snapshot');

    final mismatchedFields = <String>[];
    final shared = matKeys.toSet().intersection(snapKeys.toSet()).toList()
      ..sort();
    for (final key in shared) {
      final mv = matSnapshot[key];
      final vv = v4Snapshot[key];
      if (mv != null && vv != null && mv.toString() != vv.toString()) {
        mismatchedFields.add(key);
      }
    }

    final snapshotConflicts = <String>[
      ...matKeys.where((k) => !snapKeys.contains(k)).map((k) => 'mat_only:$k'),
      ...snapKeys.where((k) => !matKeys.contains(k)).map((k) => 'v4_only:$k'),
    ]..sort();

    final drivers = _asciiList(personaBundle['drivers']);
    final cohesionOk = cohesionView['ok'] == true;
    final tokenOk = tokenView['ok'] == true;
    final polishOk = polishBundle['ok'] == true;

    final conflictFlags = <String>[];
    if (!cohesionOk) conflictFlags.add('cohesion');
    if (!tokenOk) conflictFlags.add('token_view');
    if (!polishOk) conflictFlags.add('polish_bundle');
    conflictFlags.sort();

    if (!asciiOk) return _fallback();

    final ok =
        missingKeys.isEmpty &&
        mismatchedFields.isEmpty &&
        snapshotConflicts.isEmpty &&
        drivers.isEmpty &&
        conflictFlags.isEmpty;

    final personaSnapshotOk = personaKeys.contains('title');
    final matSnapshotOk = matKeys.isNotEmpty;
    final v4SnapshotAlignmentOk = mismatchedFields.isEmpty;
    final personaV4MatCrosscheckOk =
        ok && personaSnapshotOk && matSnapshotOk && v4SnapshotAlignmentOk;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'persona_snapshot_ok': personaSnapshotOk,
      'mat_snapshot_ok': matSnapshotOk,
      'v4_snapshot_alignment_ok': v4SnapshotAlignmentOk,
      'persona_v4_mat_crosscheck_ok': personaV4MatCrosscheckOk,
      'missing_keys': List<String>.unmodifiable(missingKeys..sort()),
      'mismatched_fields': List<String>.unmodifiable(mismatchedFields..sort()),
      'snapshot_conflicts': List<String>.unmodifiable(
        snapshotConflicts..sort(),
      ),
      'missing_persona_keys': List<String>.unmodifiable(
        missingKeys.where((e) => e.startsWith('persona')).toList()..sort(),
      ),
      'missing_mat_keys': List<String>.unmodifiable(
        missingKeys.where((e) => e.startsWith('mat')).toList()..sort(),
      ),
      'conflict_flags': List<String>.unmodifiable(conflictFlags),
      'drivers': List<String>.unmodifiable(drivers),
    });
  }

  Map<String, Object> _fallback() => const <String, Object>{
    'ok': false,
    'missing_keys': <String>[],
    'mismatched_fields': <String>[],
    'snapshot_conflicts': <String>[],
    'drivers': <String>['persona_mat_consistency_view_safe_fallback'],
  };
}
