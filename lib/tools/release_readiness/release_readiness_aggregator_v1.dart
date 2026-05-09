class ReleaseReadinessAggregatorV1 {
  static Map<String, Object> buildAggregate(Map<String, Object> allExports) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    Map<String, Object> _sanitizeMap(Map<String, Object> input) {
      final entries = input.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final out = <String, Object>{};
      for (final entry in entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) continue;
        final value = entry.value;
        if (value is Map) {
          out[key] = _sanitizeMap(
            value.map((k, v) => MapEntry(k.toString(), v as Object)),
          );
        } else if (value is num) {
          final clamped = value.toDouble().clamp(-100000.0, 100000.0);
          out[key] = clamped;
        } else if (value is bool || value is String) {
          out[key] = value;
        }
      }
      return Map<String, Object>.unmodifiable(out);
    }

    const fallback = <String, Object>{
      'ok': false,
      'domains': <String, Object>{},
      'drivers': <String>['release_readiness_aggregate_safe_fallback'],
    };

    if (allExports.isEmpty ||
        allExports.keys.any((k) => !_isAscii(k.toString()))) {
      return fallback;
    }

    Map<String, Object> _safeSection(String key, List<String> sources) {
      final section = <String, Object>{};
      for (final source in sources) {
        final value = allExports[source];
        if (value is Map<String, Object>) {
          section[source] = _sanitizeMap(value);
        } else if (value is Map) {
          section[source] = _sanitizeMap(
            value.map((k, v) => MapEntry(k.toString(), v as Object)),
          );
        }
      }
      return Map<String, Object>.unmodifiable(section);
    }

    final domainsRaw = <String, Object>{
      'visual': _safeSection('v4_visual_qa', [
        'v4_visual_qa',
        'v4_token_verification_view',
        'v4_theme_polish_view',
        'v4_persona_mat_consistency_view',
      ]),
      'persona': _safeSection('persona_stack', [
        'persona_signals',
        'persona_final',
        'persona_aggregator',
        'persona_advice',
        'coaching_consistency_report_v1',
      ]),
      'xp_reward': _safeSection('xp_reward_stack', [
        'xp_reward_gate',
        'xp_reward_surface_gate',
        'xp_curve_gate',
        'xp_persona_alignment_gate',
        'xp_reward_rpg_interplay_gate',
      ]),
      'rpg': _safeSection('rpg_stack', [
        'rpg_fusion',
        'rpg_surface_weights',
        'rpg_snapshot',
      ]),
      'marketing': _safeSection('marketing_stack', [
        'marketing_analytics_surface',
        'funnel_retention_qa',
      ]),
      'navigation': _safeSection('navigation_stack', [
        'navigation_hardening_v1',
      ]),
      'final_polish': _safeSection('final_polish_stack', [
        'final_cross_domain_polish_gate',
      ]),
      'readiness_report': _safeSection('readiness_report', [
        'release_readiness_report_v1',
      ]),
    };

    final domains = <String, Object>{};
    final drivers = <String>[];
    final okFlags = <bool>{};
    for (final entry in domainsRaw.entries) {
      if (entry.value is! Map || (entry.value as Map).isEmpty) {
        drivers.add('missing_domain:${entry.key}');
      }
      final map = entry.value as Map;
      if (map.containsKey('ok') && map['ok'] is bool) {
        okFlags.add(map['ok'] as bool);
      }
      domains[entry.key] = entry.value;
    }
    if (okFlags.length > 1) {
      drivers.add('ok_conflict');
    }

    drivers.sort();
    final ok = drivers.isEmpty;

    return Map<String, Object>.unmodifiable(<String, Object>{
      'ok': ok,
      'domains': Map<String, Object>.unmodifiable(domains),
      'drivers': List<String>.unmodifiable(drivers),
    });
  }
}
