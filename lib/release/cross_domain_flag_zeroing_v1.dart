class CrossDomainFlagZeroingV1 {
  const CrossDomainFlagZeroingV1(
    this.consolidatedScoringLockInV1Map,
    this.qaFinalIntegrationSurfaceV1Map,
    this.systemQACrownV1Map,
    this.qaReleaseSummaryV1Map,
    this.tableUIPathVerdictV1Map,
    this.tableRenderPathVerdictV1Map,
    this.stabilityConsistencyPassV3Map,
  );

  final Object consolidatedScoringLockInV1Map;
  final Object qaFinalIntegrationSurfaceV1Map;
  final Object systemQACrownV1Map;
  final Object qaReleaseSummaryV1Map;
  final Object tableUIPathVerdictV1Map;
  final Object tableRenderPathVerdictV1Map;
  final Object stabilityConsistencyPassV3Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    List<String> falseFlags(Map<String, Object> map) {
      const List<String> keys = <String>[
        'readiness',
        'ready',
        'valid',
        'gate_ready',
        'seal_ready',
        'pass_ready',
        'fusion_ready',
        'closure_ready',
        'surface_ready',
        'lockin_ready',
        'path_ready',
        'hot_ready',
        'warm_ready',
        'cold_ready',
      ];
      return keys
          .where(
            (key) =>
                map.containsKey(key) && map[key] is bool && map[key] == false,
          )
          .map((key) => key)
          .toList();
    }

    final Map<String, Object> domains = <String, Object>{
      'behavior': m(tableUIPathVerdictV1Map),
      'qa_final_integration': m(qaFinalIntegrationSurfaceV1Map),
      'release_summary': m(qaReleaseSummaryV1Map),
      'render_path': m(tableRenderPathVerdictV1Map),
      'scoring_lockin': m(consolidatedScoringLockInV1Map),
      'stability': m(stabilityConsistencyPassV3Map),
      'system_crown': m(systemQACrownV1Map),
    };

    final List<String> missing = <String>[];
    final List<String> inconsistent = <String>[];
    domains.forEach((key, value) {
      final Map<String, Object> map = value is Map
          ? value.cast<String, Object>()
          : <String, Object>{};
      if (map.isEmpty) {
        missing.add(key);
      } else {
        inconsistent.addAll(falseFlags(map).map((flag) => '$key:$flag'));
      }
    });

    final bool readyFlag =
        missing.isEmpty && inconsistent.isEmpty && domains.values.every(ready);

    return <String, Object>{
      'cross_domain_flag_zeroing_v1': <String, Object>{
        'domains': domains,
        'inconsistent': inconsistent,
        'missing': missing,
        'zeroing_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }

  // compat forwarder
  Map<String, Object> toReadOnlyMap() => asReadOnlyMap();
}
