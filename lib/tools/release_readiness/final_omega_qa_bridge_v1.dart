class FinalOmegaQABridgeV1 {
  static Map<String, Object> build({
    required Map<String, Object?> cohesionQaView,
    required Map<String, Object?> tokenVerificationView,
    required Map<String, Object?> personaMatConsistencyView,
    required Map<String, Object?> finalPolishView,
    required Map<String, Object?> regressionGateOutput,
    required Map<String, Object?> releaseReadinessSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    Map<String, Object> _clean(Map<String, Object?> input) {
      final entries = input.entries.toList()
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

    const fallback = <String, Object>{
      'ok': false,
      'visual': <String, Object>{},
      'persona': <String, Object>{},
      'xp_reward': <String, Object>{},
      'rpg': <String, Object>{},
      'marketing': <String, Object>{},
      'navigation': <String, Object>{},
      'polish': <String, Object>{},
      'drivers': <String>['final_omega_qa_bridge_safe_fallback'],
      'conflicts': <String>[],
    };

    final participants = [
      cohesionQaView,
      tokenVerificationView,
      personaMatConsistencyView,
      finalPolishView,
      regressionGateOutput,
      releaseReadinessSurface,
    ];
    if (participants.any(
      (p) => (p as Map).keys.any((k) => !_isAscii(k.toString())),
    ))
      return fallback;

    final visual = _clean({
      'cohesion': cohesionQaView,
      'tokens': tokenVerificationView,
      'polish': finalPolishView,
    });
    final persona = _clean({'persona_mat': personaMatConsistencyView});
    final xp = _clean({
      'xp':
          regressionGateOutput['xp_reward_gate'] as Map<String, Object?>? ??
          const <String, Object?>{},
      'xp_surface':
          regressionGateOutput['xp_reward_surface_gate']
              as Map<String, Object?>? ??
          const <String, Object?>{},
    });
    final rpg = _clean({
      'rpg':
          regressionGateOutput['rpg_gate'] as Map<String, Object?>? ??
          const <String, Object?>{},
      'snapshot':
          regressionGateOutput['rpg_stability_snapshot_gate']
              as Map<String, Object?>? ??
          const <String, Object?>{},
    });
    final marketing = _clean({
      'marketing':
          regressionGateOutput['marketing_analytics_polish_gate']
              as Map<String, Object?>? ??
          const <String, Object?>{},
    });
    final navigation = _clean({
      'navigation':
          releaseReadinessSurface['navigation'] as Map<String, Object?>? ??
          const <String, Object?>{},
    });
    final polish = _clean({'final_polish': finalPolishView});

    final conflicts = <String>[
      if (visual.isEmpty) 'visual',
      if (persona.isEmpty) 'persona',
      if (xp.isEmpty) 'xp_reward',
      if (rpg.isEmpty) 'rpg',
      if (marketing.isEmpty) 'marketing',
      if (navigation.isEmpty) 'navigation',
      if (polish.isEmpty) 'polish',
    ]..sort();

    final ok = conflicts.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'visual': visual,
      'persona': persona,
      'xp_reward': xp,
      'rpg': rpg,
      'marketing': marketing,
      'navigation': navigation,
      'polish': polish,
      'drivers': List<String>.unmodifiable(conflicts),
      'conflicts': List<String>.unmodifiable(conflicts),
    });
  }
}
