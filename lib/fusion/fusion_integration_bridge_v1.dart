class FusionIntegrationBridgeV1 {
  const FusionIntegrationBridgeV1();

  static Map<String, Object> buildFusionIntegrationBridgeV1({
    required Map<String, Object> fusionGlobalContext,
    required Map<String, Object> cSeriesRuntimeEntry,
    required Map<String, Object> mttRuntimeEntry,
  }) {
    final List<String> fusionSignature = _sortedKeys(fusionGlobalContext);
    final List<String> cSeriesSignature = _sortedKeys(cSeriesRuntimeEntry);
    final List<String> mttSignature = _sortedKeys(mttRuntimeEntry);
    final List<String> mergedSignature = <String>{
      ...fusionSignature,
      ...cSeriesSignature,
      ...mttSignature,
    }.toList()..sort();
    final List<String> missingSections = <String>[];
    if (!_ready(fusionGlobalContext)) {
      missingSections.add('fusion_global_context');
    }
    if (!_ready(cSeriesRuntimeEntry)) {
      missingSections.add('c_series_runtime_entry');
    }
    if (!_ready(mttRuntimeEntry)) {
      missingSections.add('mtt_runtime_entry');
    }
    missingSections.sort();
    return <String, Object>{
      'fusion_integration_bridge_v1': <String, Object>{
        'fusion_ready': false,
        'c_series_ready': false,
        'mtt_ready': false,
        'bridge_ready': false,
        'fusion_signature': fusionSignature,
        'c_series_signature': cSeriesSignature,
        'mtt_signature': mttSignature,
        'merged_signature': mergedSignature,
        'missing_sections': missingSections,
        'ready': false,
      },
    };
  }

  static bool _ready(Map<String, Object> map) {
    final Object? flag = map['ready'];
    return flag is bool && flag;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}
