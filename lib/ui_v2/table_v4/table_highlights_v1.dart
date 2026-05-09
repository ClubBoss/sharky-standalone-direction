/// Passive context-driven highlights V1 (Phi-62.0).
class TableHighlightsV1 {
  const TableHighlightsV1(
    this.layoutV2Map,
    this.compositionFrameV1Map,
    this.interactionZonesV1Map,
    this.actionButtonsGeometryV1Map,
    this.chipsPotGeometryV1Map,
    this.tokensV1Map,
  );

  final Object layoutV2Map;
  final Object compositionFrameV1Map;
  final Object interactionZonesV1Map;
  final Object actionButtonsGeometryV1Map;
  final Object chipsPotGeometryV1Map;
  final Object tokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object layoutCandidate = layoutV2Map;
    final Object interactionCandidate = interactionZonesV1Map;
    final Object actionsCandidate = actionButtonsGeometryV1Map;
    final Object chipsCandidate = chipsPotGeometryV1Map;
    final Object tokensCandidate = tokensV1Map;
    final bool hasLayout = layoutCandidate is Map && layoutCandidate.isNotEmpty;
    final bool hasInteraction =
        interactionCandidate is Map && interactionCandidate.isNotEmpty;
    final bool hasActions =
        actionsCandidate is Map && actionsCandidate.isNotEmpty;
    final bool hasChips = chipsCandidate is Map && chipsCandidate.isNotEmpty;
    final bool hasTokens = tokensCandidate is Map && tokensCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasLayout) missing.add('layout_v2_map');
    if (!hasInteraction) missing.add('interaction_zones_v1_map');
    if (!hasActions) missing.add('action_buttons_geometry_v1_map');
    if (!hasChips) missing.add('chips_pot_geometry_v1_map');
    if (!hasTokens) missing.add('tokens_v1_map');

    Map<String, Object> _mapFrom(Object source, String key) {
      if (source is Map && source[key] is Map<String, Object>) {
        return source[key] as Map<String, Object>;
      }
      return <String, Object>{};
    }

    final Map<String, Object> board = _mapFrom(layoutCandidate, 'board')
      ..addAll(_mapFrom(layoutCandidate, 'layout'));
    final Map<String, Object> interactions = _mapFrom(
      interactionCandidate,
      'table_interaction_zones_v1',
    );
    final Map<String, Object> actions = _mapFrom(
      actionsCandidate,
      'action_buttons_geometry_v1',
    );
    final Map<String, Object> chips = _mapFrom(
      chipsCandidate,
      'chips_pot_geometry_v1',
    );
    final Map<String, Object> tokens = _mapFrom(
      tokensCandidate,
      'table_surface_tokens_v1',
    );

    final Map<String, Object> tapZones =
        interactions['tap_zones'] as Map<String, Object>? ?? <String, Object>{};
    final Map<String, Object> highlights = <String, Object>{
      'board_highlight': <String, Object>{
        'rect': board,
        'ready': board.isNotEmpty,
      },
      'hero_highlight': <String, Object>{
        'rect': tapZones['hero_cards'] ?? <Object>{},
        'ready': tapZones['hero_cards'] != null,
      },
      'villain_highlight': <String, Object>{
        'rect': tapZones['villain_cards'] ?? <Object>{},
        'ready': tapZones['villain_cards'] != null,
      },
      'pot_highlight': <String, Object>{
        'rect': chips['pot_zone'] ?? <Object>{},
        'ready': chips['pot_zone'] != null,
      },
      'action_highlight': <String, Object>{
        'rect': actions['primary_zone'] ?? <Object>{},
        'ready': actions['primary_zone'] != null,
      },
      'alpha': tokens['alpha'] ?? 1.0,
      'ready': missing.isEmpty,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'table_highlights_v1': highlights,
      'readiness': readiness,
      'missing': missing,
    };
  }
}
