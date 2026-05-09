class PersonaFusionRuntimeBridgeV1 {
  const PersonaFusionRuntimeBridgeV1({
    this.personaFusionBridgeMap = const <String, Object>{},
    this.cSeriesRuntimeEntrySurface = const <String, Object>{},
    this.mttRuntimeEntrySurface = const <String, Object>{},
    this.fusionGlobalContext = const <String, Object>{},
  });

  PersonaFusionRuntimeBridgeV1.fromInputs({
    Map<String, Object?>? personaFusionBridgeMap,
    Map<String, Object?>? cSeriesRuntimeEntrySurface,
    Map<String, Object?>? mttRuntimeEntrySurface,
    Map<String, Object?>? fusionGlobalContext,
  }) : this(
         personaFusionBridgeMap: _safe(personaFusionBridgeMap),
         cSeriesRuntimeEntrySurface: _safe(cSeriesRuntimeEntrySurface),
         mttRuntimeEntrySurface: _safe(mttRuntimeEntrySurface),
         fusionGlobalContext: _safe(fusionGlobalContext),
       );

  final Map<String, Object> personaFusionBridgeMap;
  final Map<String, Object> cSeriesRuntimeEntrySurface;
  final Map<String, Object> mttRuntimeEntrySurface;
  final Map<String, Object> fusionGlobalContext;

  Map<String, Object> build() {
    final Map<String, Object?> bridgeBody =
        personaFusionBridgeMap['persona_fusion_bridge_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final String fusionTag = (bridgeBody['fusion_persona_tag'] as String? ?? '')
        .toLowerCase();
    final bool fusionReady =
        fusionGlobalContext['fusion_context_ready'] == true;
    final bool cSeriesReady =
        cSeriesRuntimeEntrySurface['runtime_ready'] == true;
    final bool mttReady = mttRuntimeEntrySurface['runtime_ready'] == true;
    String runtimeTag = 'persona_runtime_neutral';
    if (fusionReady) {
      runtimeTag = fusionTag.isEmpty ? 'persona_fusion_bridge' : fusionTag;
    } else if (cSeriesReady) {
      runtimeTag = 'persona_cseries_runtime';
    } else if (mttReady) {
      runtimeTag = 'persona_mtt_runtime';
    }
    return <String, Object>{
      'persona_fusion_runtime_bridge_v1': <String, Object>{
        'runtime_persona_tag': _ascii(runtimeTag),
        'ready': true,
      },
    };
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      target[entry.key] = entry.value ?? '';
    }
    return target;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
