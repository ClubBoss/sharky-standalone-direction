/// Passive table interaction zones V1 (Phi-59.0).
class TableInteractionZonesV1 {
  const TableInteractionZonesV1(
    this.compositionFrameV1Map,
    this.layoutV2Map,
    this.tokensV1Map,
  );

  final Object compositionFrameV1Map;
  final Object layoutV2Map;
  final Object tokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object compositionCandidate = compositionFrameV1Map;
    final Object layoutCandidate = layoutV2Map;
    final Object tokensCandidate = tokensV1Map;
    final bool hasComposition =
        compositionCandidate is Map && compositionCandidate.isNotEmpty;
    final bool hasLayout = layoutCandidate is Map && layoutCandidate.isNotEmpty;
    final bool hasTokens = tokensCandidate is Map && tokensCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasComposition) missing.add('composition_frame_v1');
    if (!hasLayout) missing.add('layout_v2_map');
    if (!hasTokens) missing.add('tokens_v1_map');

    final Map<String, Object> comp = hasComposition
        ? (compositionCandidate as Map)['table_composition_frame_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> layout = hasLayout
        ? (layoutCandidate as Map)['board_adaptive_layout_v2']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> zones = <String, Object>{
      'action_bar_zone': <String, Object>{
        'rect': comp['board'] ?? <Object>{},
        'ready': hasComposition,
      },
      'tap_zones': <String, Object>{
        'board': comp['board'] ?? <Object>{},
        'hero_cards': layout['computed_zones'] ?? <Object>{},
        'villain_cards': layout['computed_zones'] ?? <Object>{},
      },
      'safe_regions': layout['breakpoints'] ?? <Object>{},
      'spacing': hasTokens
          ? (((tokensCandidate as Map)['table_surface_tokens_v1']
                    as Map?)?['spacing'] ??
                <Object>{})
          : <Object>{},
      'ready': missing.isEmpty,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'table_interaction_zones_v1': zones,
      'readiness': readiness,
      'missing': missing,
    };
  }
}
