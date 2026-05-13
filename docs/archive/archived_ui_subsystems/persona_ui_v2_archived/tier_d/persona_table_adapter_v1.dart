class PersonaTableAdapterV1 {
  static const String baseTag_fusion = 'fusion';
  static const String baseTag_cseries = 'cseries';
  static const String baseTag_mtt = 'mtt';

  const PersonaTableAdapterV1({
    this.personaRuntimeAdaptiveBehaviorMap = const <String, Object>{},
    this.personaFusionRuntimeBridgeMap = const <String, Object>{},
  });

  PersonaTableAdapterV1.fromInputs({
    Map<String, Object?>? personaRuntimeAdaptiveBehaviorMap,
    Map<String, Object?>? personaFusionRuntimeBridgeMap,
  }) : this(
         personaRuntimeAdaptiveBehaviorMap: _safe(
           personaRuntimeAdaptiveBehaviorMap,
         ),
         personaFusionRuntimeBridgeMap: _safe(personaFusionRuntimeBridgeMap),
       );

  final Map<String, Object> personaRuntimeAdaptiveBehaviorMap;
  final Map<String, Object> personaFusionRuntimeBridgeMap;

  Map<String, Object> build() {
    final Map<String, Object?> behaviorBody =
        personaRuntimeAdaptiveBehaviorMap['persona_runtime_adaptive_behavior_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final Map<String, Object?> bridgeBody =
        personaFusionRuntimeBridgeMap['persona_fusion_runtime_bridge_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final String baseTag =
        (behaviorBody['behavior_tag'] as String? ?? 'adaptive_neutral')
            .toLowerCase();
    final String bridgeTag =
        (bridgeBody['runtime_persona_tag'] as String? ?? '').toLowerCase();
    String tablePersonaTag = baseTag;
    if (bridgeTag.startsWith('fusion')) {
      tablePersonaTag = '$baseTag_fusion';
    } else if (bridgeTag.contains('cseries')) {
      tablePersonaTag = '$baseTag_cseries';
    } else if (bridgeTag.contains('mtt')) {
      tablePersonaTag = '$baseTag_mtt';
    }
    final double intensity =
        (behaviorBody['intensity'] as num?)?.toDouble() ?? 0.5;
    return <String, Object>{
      'persona_table_adapter_v1': <String, Object>{
        'table_persona_tag': _ascii(tablePersonaTag),
        'intensity': intensity,
        'ready': true,
      },
    };
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> result = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      result[entry.key] = entry.value ?? '';
    }
    return result;
  }

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
