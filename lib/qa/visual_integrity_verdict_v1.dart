class VisualIntegrityVerdictV1 {
  const VisualIntegrityVerdictV1(this.visualIntegritySealMap);

  final Object visualIntegritySealMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> seal =
        visualIntegritySealMap is Map &&
            (visualIntegritySealMap as Map)['visual_integrity_seal_v1'] is Map
        ? (visualIntegritySealMap as Map)['visual_integrity_seal_v1']
              as Map<String, Object>
        : <String, Object>{};
    final Map<String, Object> sealBody = seal['seal'] is Map
        ? (seal['seal'] as Map).cast<String, Object>()
        : seal;
    final bool sealOk = seal['seal_ready'] == true;
    final bool cohesionOk =
        sealBody['gate'] is Map && (sealBody['summary'] is Map);
    final bool snapshotOk =
        sealBody['snapshot'] is Map && (sealBody['snapshot'] as Map).isNotEmpty;
    final List<String> missing = <String>[
      if (seal.isEmpty) 'visual_integrity_seal_v1',
      if (!cohesionOk) 'visual_cohesion_sources',
      if (!snapshotOk) 'table_visual_snapshot_v1',
    ];
    final bool ready = sealOk && cohesionOk && snapshotOk;
    return <String, Object>{
      'visual_integrity_verdict_v1': <String, Object>{
        'verdict': <String, Object>{
          'seal_ok': sealOk,
          'cohesion_ok': cohesionOk,
          'snapshot_ok': snapshotOk,
        },
        'verdict_ready': ready,
        'missing': missing,
      },
      'readiness': ready,
    };
  }
}
