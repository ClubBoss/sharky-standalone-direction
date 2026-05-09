class FusionGlobalContextV1 {
  const FusionGlobalContextV1();

  static Map<String, Object> buildFusionGlobalContextV1({
    required Map<String, Object> cashRuntimeEntry,
    required Map<String, Object> mttRuntimeEntry,
  }) {
    final List<String> cashKeys = _sortedKeys(cashRuntimeEntry);
    final List<String> mttKeys = _sortedKeys(mttRuntimeEntry);
    final List<String> merged = <String>{...cashKeys, ...mttKeys}.toList()
      ..sort();
    final List<String> missing = <String>[];
    if (!_ready(cashRuntimeEntry)) {
      missing.add('cash_runtime_entry');
    }
    if (!_ready(mttRuntimeEntry)) {
      missing.add('mtt_runtime_entry');
    }
    missing.sort();
    return <String, Object>{
      'fusion_global_context_v1': <String, Object>{
        'cash_ready': _ready(cashRuntimeEntry),
        'mtt_ready': _ready(mttRuntimeEntry),
        'fusion_ready': false,
        'cash_signature': cashKeys,
        'mtt_signature': mttKeys,
        'merged_signature': merged,
        'missing_sections': missing,
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
