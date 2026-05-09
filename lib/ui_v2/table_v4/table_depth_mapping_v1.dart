/// Passive table depth mapping V1 (Phi-63.0).
class TableDepthMappingV1 {
  const TableDepthMappingV1(
    this.layoutV2Map,
    this.compositionFrameV1Map,
    this.interactionZonesV1Map,
    this.actionButtonsGeometryV1Map,
    this.chipsPotGeometryV1Map,
    this.tableHighlightsV1Map,
    this.tokensV1Map,
  );

  final Object layoutV2Map;
  final Object compositionFrameV1Map;
  final Object interactionZonesV1Map;
  final Object actionButtonsGeometryV1Map;
  final Object chipsPotGeometryV1Map;
  final Object tableHighlightsV1Map;
  final Object tokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    final bool ready =
        layoutV2Map is Map &&
        compositionFrameV1Map is Map &&
        interactionZonesV1Map is Map &&
        actionButtonsGeometryV1Map is Map &&
        chipsPotGeometryV1Map is Map &&
        tableHighlightsV1Map is Map &&
        tokensV1Map is Map &&
        (layoutV2Map as Map).isNotEmpty &&
        (compositionFrameV1Map as Map).isNotEmpty &&
        (interactionZonesV1Map as Map).isNotEmpty &&
        (actionButtonsGeometryV1Map as Map).isNotEmpty &&
        (chipsPotGeometryV1Map as Map).isNotEmpty &&
        (tableHighlightsV1Map as Map).isNotEmpty &&
        (tokensV1Map as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!ready) missing.add('inputs_incomplete');
    final Map<String, double> depth = <String, double>{
      'board': 0.0,
      'pot': 0.1,
      'chips': 0.15,
      'hero_highlight': 0.2,
      'villain_highlight': 0.2,
      'action_buttons': 0.3,
      'action_highlight': 0.35,
    };
    return <String, Object>{
      'table_depth_mapping_v1': <String, Object>{
        'depth': depth,
        'ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
