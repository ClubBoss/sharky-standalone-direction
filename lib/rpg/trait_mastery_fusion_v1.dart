import 'dart:collection';

class TraitMasteryFusionV1 {
  const TraitMasteryFusionV1();

  Map<String, Object> fuse(
    Map<String, Object> masteryState,
    Map<String, Object> traitBundle,
  ) {
    final level = masteryState['level'] as int? ?? 1;
    final xp = masteryState['xp'] as int? ?? 0;
    final xpToNext = masteryState['xp_to_next'] as int? ?? 0;
    final soft = (masteryState['soft_progress'] as num?)?.toDouble() ?? 0.0;
    final traitsMap =
        traitBundle['traits'] as Map<String, Object>? ??
        const <String, Object>{};

    final values = <double>[];
    final flattenedTraits = <String, double>{};
    traitsMap.forEach((key, value) {
      if (value is Map && value['value'] is num) {
        final v = (value['value'] as num).toDouble();
        flattenedTraits[key] = v;
        values.add(v);
      }
    });
    final avgTrait = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a + b) / values.length.toDouble();

    final masteryWeight = soft;
    final traitWeight = avgTrait;
    final effectivePower = (soft * 0.6) + (avgTrait * 0.4);

    final fusion = UnmodifiableMapView<String, Object>({
      'mastery_weight': masteryWeight,
      'trait_weight': traitWeight,
      'effective_power': effectivePower,
      'drivers': UnmodifiableMapView<String, Object>({
        'trait_count': flattenedTraits.length,
        'soft_progress': soft,
      }),
    });

    final summary =
        'lvl:$level xp:$xp eff:${effectivePower.toStringAsFixed(2)} traits:${flattenedTraits.length}';

    return UnmodifiableMapView<String, Object>({
      'level': level,
      'xp': xp,
      'xp_to_next': xpToNext,
      'soft_progress': soft,
      'traits': UnmodifiableMapView<String, double>(flattenedTraits),
      'fusion': fusion,
      'summary': summary,
    });
  }
}
