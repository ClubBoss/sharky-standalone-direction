/// Passive table composition frame V1 (Phi-58.3).
class TableCompositionFrameV1 {
  const TableCompositionFrameV1(
    this.layoutV2Map,
    this.tokensV1Map,
    this.surfacePolishMap,
  );

  final Object layoutV2Map;
  final Object tokensV1Map;
  final Object surfacePolishMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<dynamic, dynamic>? layoutSource = layoutV2Map is Map
        ? layoutV2Map as Map<dynamic, dynamic>
        : null;
    final Map<dynamic, dynamic>? tokensSource = tokensV1Map is Map
        ? tokensV1Map as Map<dynamic, dynamic>
        : null;
    final Map<dynamic, dynamic>? polishSource = surfacePolishMap is Map
        ? surfacePolishMap as Map<dynamic, dynamic>
        : null;
    final bool hasLayout = layoutSource != null && layoutSource.isNotEmpty;
    final bool hasTokens = tokensSource != null && tokensSource.isNotEmpty;
    final bool hasPolish = polishSource != null && polishSource.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasLayout) missing.add('layout_v2_map');
    if (!hasTokens) missing.add('tokens_v1_map');
    if (!hasPolish) missing.add('surface_polish_map');

    final Map<String, Object> layout;
    if (layoutSource != null && layoutSource.isNotEmpty) {
      layout = _asStringObjectMap(layoutSource['board_adaptive_layout_v2']);
    } else {
      layout = <String, Object>{};
    }
    final Map<String, Object> tokens;
    if (tokensSource != null && tokensSource.isNotEmpty) {
      tokens = _asStringObjectMap(tokensSource['table_surface_tokens_v1']);
    } else {
      tokens = <String, Object>{};
    }
    final Map<String, Object> polish;
    if (polishSource != null && polishSource.isNotEmpty) {
      polish = _asStringObjectMap(polishSource);
    } else {
      polish = <String, Object>{};
    }
    final Map<String, Object> boardComposition = <String, Object>{
      'board': layout['breakpoints'] ?? <Object>{},
      'slots': layout['computed_zones'] ?? <Object>{},
      'card_regions': layout['computed_zones'] ?? <Object>{},
      'felt': <String, Object>{
        'color': ((tokens['color'] as Map?)?['felt_bg'] ?? '#006644'),
        'radius': ((tokens['radius'] as Map?)?['board'] ?? 8),
      },
      'spacing': tokens['spacing'] ?? <Object>{},
      'polish': polish,
      'ready': missing.isEmpty,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'table_composition_frame_v1': boardComposition,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

Map<String, Object> _asStringObjectMap(Object? value) {
  if (value is Map) return Map<String, Object>.from(value);
  return <String, Object>{};
}
