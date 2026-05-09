/// Passive table hint map V1 (Phi-74.0).
class TableHintMapV1 {
  const TableHintMapV1(this.tablePersonalizationBridgeV1Map);

  final Object tablePersonalizationBridgeV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object bridgeCandidate = tablePersonalizationBridgeV1Map;
    final bool hasBridge =
        bridgeCandidate is Map && (bridgeCandidate as Map).isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasBridge) missing.add('table_personalization_bridge_v1');
    final Map<String, Object> bridge = hasBridge
        ? ((bridgeCandidate as Map)['table_personalization_bridge_v1']
                  as Map<String, Object>? ??
              <String, Object>{})
        : <String, Object>{};
    final Map<String, Object> hints = <String, Object>{
      'focus': bridge['persona_hints'] ?? <Object>{},
      'tempo': bridge['table_context'] ?? <Object>{},
      'risk': bridge['persona_output'] ?? <Object>{},
    };
    final bool hintReady = missing.isEmpty;
    return <String, Object>{
      'table_hint_map_v1': <String, Object>{
        'hints': hints,
        'hint_ready': hintReady,
      },
      'readiness': hintReady,
      'missing': missing,
    };
  }
}
