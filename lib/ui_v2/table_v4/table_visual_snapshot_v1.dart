/// Passive table visual snapshot V1 (Phi-64.0).
class TableVisualSnapshotV1 {
  const TableVisualSnapshotV1(
    this.layoutV2Map,
    this.compositionFrameV1Map,
    this.interactionZonesV1Map,
    this.actionButtonsGeometryV1Map,
    this.chipsPotGeometryV1Map,
    this.tableHighlightsV1Map,
    this.tableDepthMappingV1Map,
    this.tokensV1Map,
  );

  final Object layoutV2Map;
  final Object compositionFrameV1Map;
  final Object interactionZonesV1Map;
  final Object actionButtonsGeometryV1Map;
  final Object chipsPotGeometryV1Map;
  final Object tableHighlightsV1Map;
  final Object tableDepthMappingV1Map;
  final Object tokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    final List<String> missing = <String>[];
    bool _check(Object o, String name) {
      final ok = o is Map && o.isNotEmpty;
      if (!ok) missing.add(name);
      return ok;
    }

    final bool ready =
        _check(layoutV2Map, 'layout') &&
        _check(compositionFrameV1Map, 'composition') &&
        _check(interactionZonesV1Map, 'interaction') &&
        _check(actionButtonsGeometryV1Map, 'actions') &&
        _check(chipsPotGeometryV1Map, 'chips_pot') &&
        _check(tableHighlightsV1Map, 'highlights') &&
        _check(tableDepthMappingV1Map, 'depth') &&
        _check(tokensV1Map, 'tokens');

    return <String, Object>{
      'table_visual_snapshot_v1': <String, Object>{
        'layout': layoutV2Map,
        'composition': compositionFrameV1Map,
        'interaction': interactionZonesV1Map,
        'actions': actionButtonsGeometryV1Map,
        'chips_pot': chipsPotGeometryV1Map,
        'highlights': tableHighlightsV1Map,
        'depth': tableDepthMappingV1Map,
        'tokens': tokensV1Map,
        'ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
