Map<String, Object> buildFinalBetaExportV1({
  required Map<String, Object> release_guard,
  required Map<String, Object> release_sync_surface,
  required Map<String, Object> release_sync_snapshot,
  required Map<String, Object> v4_final_cohesion_sweep,
  required Map<String, Object> v4_token_final_verification,
  required Map<String, Object> persona_v4_mat_final,
  required Map<String, Object> final_v4_polish,
  required Map<String, Object> final_coherence_pass,
  required Map<String, Object> final_visual_polish,
  required Map<String, Object> final_marketing_readiness,
  required Map<String, Object> final_marketing_onboarding,
  required Map<String, Object> final_marketing_onboarding_coherence,
  required Map<String, Object> smart_pack_surface,
  required Map<String, Object> regression_platform_snapshot,
  required Map<String, Object> final_rpg_stability,
  required Map<String, Object> final_xp_reward,
  required Map<String, Object> final_release_sync_surface,
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
    'beta_ready_ok': false,
    'alignment_score': 0,
    'conflict_flags': <String>[],
    'drivers': <String>['final_beta_export_safe_fallback'],
    'sections': <String, Object>{},
    'snapshot': <String, Object>{},
  };

  final inputs = [
    release_guard,
    release_sync_surface,
    release_sync_snapshot,
    v4_final_cohesion_sweep,
    v4_token_final_verification,
    persona_v4_mat_final,
    final_v4_polish,
    final_coherence_pass,
    final_visual_polish,
    final_marketing_readiness,
    final_marketing_onboarding,
    final_marketing_onboarding_coherence,
    smart_pack_surface,
    regression_platform_snapshot,
    final_rpg_stability,
    final_xp_reward,
    final_release_sync_surface,
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
    ..._asciiList(release_guard['conflict_flags']),
    ..._asciiList(release_sync_surface['conflict_flags']),
    ..._asciiList(release_sync_snapshot['conflict_flags']),
    ..._asciiList(regression_platform_snapshot['conflict_flags']),
  ]..sort();

  final drivers = <String>[
    ..._asciiList(release_guard['drivers']),
    ..._asciiList(release_sync_surface['drivers']),
    ..._asciiList(release_sync_snapshot['drivers']),
    ..._asciiList(regression_platform_snapshot['drivers']),
    'rpg',
    'xp',
    'coaching',
    'persona',
    'marketing',
    'v4',
  ]..sort();

  bool _ok(Object? v) => v == true;
  final ok =
      conflictFlags.isEmpty &&
      _ok(release_guard['release_guard_ok']) &&
      _ok(release_sync_surface['release_sync_surface_ok']) &&
      _ok(release_sync_snapshot['release_sync_ok']) &&
      _ok(regression_platform_snapshot['final_regression_platform_ok']);

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
    'release_guard': release_guard,
    'release_sync_surface': release_sync_surface,
    'release_sync_snapshot': release_sync_snapshot,
    'v4_final_cohesion_sweep': v4_final_cohesion_sweep,
    'v4_token_final_verification': v4_token_final_verification,
    'persona_v4_mat_final': persona_v4_mat_final,
    'final_v4_polish': final_v4_polish,
    'final_coherence_pass': final_coherence_pass,
    'final_visual_polish': final_visual_polish,
    'final_marketing_readiness': final_marketing_readiness,
    'final_marketing_onboarding': final_marketing_onboarding,
    'final_marketing_onboarding_coherence':
        final_marketing_onboarding_coherence,
    'smart_pack_surface': smart_pack_surface,
    'regression_platform_snapshot': regression_platform_snapshot,
    'final_rpg_stability': final_rpg_stability,
    'final_xp_reward': final_xp_reward,
    'final_release_sync_surface': final_release_sync_surface,
  });

  final snapshot = _orderMap(<String, Object>{...sections});

  return <String, Object>{
    'beta_ready_ok': ok,
    'alignment_score': _clamp(100 - (conflictFlags.length * 3)),
    'conflict_flags': List<String>.unmodifiable(conflictFlags),
    'drivers': List<String>.unmodifiable(drivers),
    'sections': sections,
    'snapshot': snapshot,
  };
}
