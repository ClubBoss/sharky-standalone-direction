class SmartPackAffinityV1 {
  const SmartPackAffinityV1();

  Map<String, Object> computeAffinity({
    required Map<String, Object> normalizedMetadata,
    required Map<String, Object> personaSignals,
    required Map<String, Object> coachingFinal,
    required Map<String, Object> rpgFusion,
    required Map<String, Object> xpRewardSurface,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'affinity_scores': <String, int>{},
      'drivers': <String>['smart_pack_affinity_safe_fallback'],
      'conflicts': <String>[],
      'ok': false,
    };

    if (normalizedMetadata.isEmpty) return fallback;
    final packs = (normalizedMetadata['metadata'] as Map?)?['packs'];
    if (packs is! List) return fallback;

    int _clamp(int v) => v.clamp(0, 100);

    final scores = <String, int>{};
    final drivers = <String>[];
    final conflicts = <String>[];

    for (final pack in packs) {
      if (pack is! Map) {
        conflicts.add('invalid_pack');
        continue;
      }
      final id = pack['id']?.toString() ?? '';
      if (id.isEmpty || !_isAscii(id)) {
        conflicts.add('invalid_id');
        continue;
      }
      var score = 0;
      if (personaSignals.isNotEmpty) score += 40;
      if (coachingFinal.isNotEmpty) score += 30;
      final eff =
          (rpgFusion['fusion'] as Map?)?['effective_power'] as num? ?? 0;
      if (eff > 0) score += 20;
      if (xpRewardSurface.isNotEmpty) score += 10;
      scores[id] = _clamp(score);
      drivers.add('pack:$id');
    }

    drivers.sort();
    conflicts.sort();
    final ok = conflicts.isEmpty;

    return <String, Object>{
      'affinity_scores': Map<String, int>.unmodifiable(scores),
      'drivers': List<String>.unmodifiable(drivers),
      'conflicts': List<String>.unmodifiable(conflicts),
      'ok': ok,
    };
  }
}
