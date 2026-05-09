/// Passive table view skeleton V1 (Phi-70.0).
class TableViewSkeletonV1 {
  const TableViewSkeletonV1(this.tableRenderEnvelopeV1Map);

  final Object tableRenderEnvelopeV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object envelopeCandidate = tableRenderEnvelopeV1Map;
    final bool hasEnvelope =
        envelopeCandidate is Map && envelopeCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasEnvelope) missing.add('table_render_envelope_v1');
    final bool skeletonReady = missing.isEmpty;
    final Map<String, Object> structure = <String, Object>{
      'root': 'table_view',
      'children': <String>[
        'board',
        'hero_cards',
        'villain_cards',
        'pot',
        'stacks',
        'action_bar',
        'highlights',
        'depth_layers',
      ],
      'metadata': <String, String>{
        'version': 'v1',
        'type': 'table_view_skeleton',
      },
    };
    return <String, Object>{
      'table_view_skeleton_v1': <String, Object>{
        'structure': structure,
        'skeleton_ready': skeletonReady,
      },
      'readiness': skeletonReady,
      'missing': missing,
    };
  }
}
