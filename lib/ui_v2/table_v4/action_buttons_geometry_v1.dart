/// Passive action buttons geometry V1 (Phi-60.0).
class ActionButtonsGeometryV1 {
  const ActionButtonsGeometryV1(
    this.interactionZonesV1Map,
    this.compositionFrameV1Map,
    this.tokensV1Map,
  );

  final Object interactionZonesV1Map;
  final Object compositionFrameV1Map;
  final Object tokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object interactionCandidate = interactionZonesV1Map;
    final Object compositionCandidate = compositionFrameV1Map;
    final Object tokensCandidate = tokensV1Map;
    final bool hasInteraction =
        interactionCandidate is Map && interactionCandidate.isNotEmpty;
    final bool hasComposition =
        compositionCandidate is Map && compositionCandidate.isNotEmpty;
    final bool hasTokens = tokensCandidate is Map && tokensCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasInteraction) missing.add('interaction_zones_v1');
    if (!hasComposition) missing.add('composition_frame_v1');
    if (!hasTokens) missing.add('tokens_v1_map');

    final Map<String, Object> interaction = hasInteraction
        ? interactionCandidate as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> actionBar =
        interaction['table_interaction_zones_v1'] is Map<String, Object>
        ? (interaction['table_interaction_zones_v1']
                      as Map<String, Object>)['action_bar_zone']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> spacing = hasTokens
        ? (((tokensCandidate as Map)['table_surface_tokens_v1']
                      as Map?)?['spacing']
                  as Map<String, Object>? ??
              <String, Object>{})
        : <String, Object>{};

    Map<String, Object> _rectFrom(Map<String, Object>? source) {
      if (source == null) return <String, Object>{};
      return source['rect'] is Map
          ? source['rect'] as Map<String, Object>
          : <String, Object>{};
    }

    final Map<String, Object> primaryZone = _rectFrom(actionBar);
    final Map<String, Object> secondaryZone = _rectFrom(actionBar);
    final List<Map<String, Object>> buttonSlots = <Map<String, Object>>[
      <String, Object>{'id': 'fold', 'rect': primaryZone},
      <String, Object>{'id': 'call', 'rect': primaryZone},
      <String, Object>{'id': 'raise', 'rect': primaryZone},
    ];

    final Map<String, Object> geometry = <String, Object>{
      'primary_zone': <String, Object>{
        'rect': primaryZone,
        'ready': hasInteraction,
      },
      'secondary_zone': <String, Object>{
        'rect': secondaryZone,
        'ready': hasInteraction,
      },
      'button_slots': buttonSlots,
      'spacing': spacing,
      'ready': missing.isEmpty,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'action_buttons_geometry_v1': geometry,
      'readiness': readiness,
      'missing': missing,
    };
  }
}
