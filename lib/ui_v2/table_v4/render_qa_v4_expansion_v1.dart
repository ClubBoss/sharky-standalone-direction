class RenderQAV4ExpansionV1 {
  const RenderQAV4ExpansionV1(
    Object? finalRenderEnvelopeFusionV4Map,
    Object? tableFinalVisualFusionV4Map,
    Object? tableVisualSurfaceV4Map,
    Object? tableRenderSurfaceV4Map,
    Object? tableVisualSnapshotV4Map,
  ) : _finalRenderEnvelopeFusionV4Map = finalRenderEnvelopeFusionV4Map,
      _tableFinalVisualFusionV4Map = tableFinalVisualFusionV4Map,
      _tableVisualSurfaceV4Map = tableVisualSurfaceV4Map,
      _tableRenderSurfaceV4Map = tableRenderSurfaceV4Map,
      _tableVisualSnapshotV4Map = tableVisualSnapshotV4Map;

  final Object? _finalRenderEnvelopeFusionV4Map;
  final Object? _tableFinalVisualFusionV4Map;
  final Object? _tableVisualSurfaceV4Map;
  final Object? _tableRenderSurfaceV4Map;
  final Object? _tableVisualSnapshotV4Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> inputs = <String, Object?>{
      'final_render_envelope_fusion_v4': _finalRenderEnvelopeFusionV4Map,
      'table_final_visual_fusion_v4': _tableFinalVisualFusionV4Map,
      'table_render_surface_v4': _tableRenderSurfaceV4Map,
      'table_visual_snapshot_v4': _tableVisualSnapshotV4Map,
      'table_visual_surface_v4': _tableVisualSurfaceV4Map,
    };
    final List<String> keys = inputs.keys.toList()..sort();
    final Map<String, Object> sections = <String, Object>{};
    final List<String> missing = <String>[];
    bool expansionReady = true;

    for (final String key in keys) {
      final Object? value = inputs[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty) {
        missing.add(key);
      }
      if (!(exists && isMap && nonEmpty && ready)) {
        expansionReady = false;
      }
      sections[key] = <String, Object>{
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }

    return <String, Object>{
      'render_qa_v4_expansion_v1': <String, Object>{
        'sections': sections,
        'missing': missing,
        'expansion_ready': expansionReady,
      },
      'readiness': expansionReady,
    };
  }
}
