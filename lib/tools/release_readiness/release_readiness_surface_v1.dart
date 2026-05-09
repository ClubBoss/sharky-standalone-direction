class ReleaseReadinessSurfaceV1 {
  static Map<String, Object> buildSurface(Map<String, Object> aggregate) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'ok': false,
      'domains': <String, Object>{},
      'drivers': <String>['release_readiness_surface_safe_fallback'],
    };

    if (aggregate.isEmpty ||
        aggregate.keys.any((k) => !_isAscii(k.toString()))) {
      return fallback;
    }

    Map<String, Object> _cleanSection(Object? value) {
      if (value is! Map) return const <String, Object>{};
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final out = <String, Object>{};
      for (final entry in entries) {
        final key = entry.key.toString();
        if (!_isAscii(key)) continue;
        final v = entry.value;
        if (v is Map) {
          out[key] = _cleanSection(v);
        } else if (v is num || v is bool || v is String) {
          out[key] = v as Object;
        }
      }
      return Map<String, Object>.unmodifiable(out);
    }

    const required = <String>[
      'visual',
      'persona',
      'xp_reward',
      'rpg',
      'marketing',
      'navigation',
      'final_polish',
    ];

    final domains = <String, Object>{};
    final drivers = <String>[];
    for (final key in required) {
      final value = _cleanSection(aggregate[key]);
      if (value.isEmpty) {
        drivers.add('missing_or_empty:$key');
      }
      domains[key] = value;
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
