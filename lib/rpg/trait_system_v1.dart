import 'dart:collection';
import 'dart:math';

class TraitSystemV1 {
  const TraitSystemV1();

  static const List<Map<String, Object>> _traits = <Map<String, Object>>[
    {
      'id': 'discipline',
      'description': 'Consistent decision tempo and risk control.',
      'drivers': <String, Object>{'source': 'mastery+persona'},
    },
    {
      'id': 'focus',
      'description': 'Ability to sustain attention on key signals.',
      'drivers': <String, Object>{'source': 'mastery+persona'},
    },
    {
      'id': 'resilience',
      'description': 'Tolerance for friction and recovery after errors.',
      'drivers': <String, Object>{'source': 'mastery+persona'},
    },
    {
      'id': 'risk_control',
      'description': 'Willingness to modulate aggression and safety.',
      'drivers': <String, Object>{'source': 'mastery+persona'},
    },
    {
      'id': 'pattern_recognition',
      'description': 'Detecting repeat spots and exploit triggers.',
      'drivers': <String, Object>{'source': 'mastery+persona'},
    },
    {
      'id': 'adaptive_learning',
      'description': 'Adjusting choices based on feedback loops.',
      'drivers': <String, Object>{'source': 'mastery+persona'},
    },
  ];

  Map<String, Object> computeTraitsForMasteryState(
    Map<String, Object> masteryState,
    Map<String, Object?> personaSignals,
  ) {
    final soft = (masteryState['soft_progress'] as num?)?.toDouble() ?? 0.0;
    final level = masteryState['level'] as int? ?? 1;
    final alignment =
        (personaSignals['alignment'] as num?)?.toDouble().clamp(-1.0, 1.0) ??
        0.0;
    final base = max(0.0, min(1.0, soft));
    final traitValues = <String, Map<String, Object>>{};

    double scaled(double factor) {
      final v = base * factor + (alignment * 0.1);
      return v.clamp(0.0, 1.0);
    }

    for (final trait in _traits) {
      final id = trait['id']!.toString();
      final factor = 0.6 + (level / 100.0);
      traitValues[id] = <String, Object>{
        'value': scaled(factor),
        'drivers': <String, Object>{
          'level': level,
          'soft_progress': base,
          'alignment': alignment,
        },
      };
    }

    final summary =
        'traits:${traitValues.keys.length} soft:${base.toStringAsFixed(2)}';

    return UnmodifiableMapView<String, Object>({
      'traits': UnmodifiableMapView<String, Map<String, Object>>(traitValues),
      'summary': summary,
    });
  }

  Map<String, Object> exportTraitBundle(
    Map<String, Object> masteryState,
    Map<String, Object?> personaSignals,
  ) {
    return computeTraitsForMasteryState(masteryState, personaSignals);
  }
}
