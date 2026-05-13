class PersonaRuntimeAdaptiveBehaviorV1 {
  const PersonaRuntimeAdaptiveBehaviorV1({
    this.personaFusionRuntimeBridgeMap = const <String, Object>{},
  });

  PersonaRuntimeAdaptiveBehaviorV1.fromInputs({
    Map<String, Object?>? personaFusionRuntimeBridgeMap,
  }) : this(
         personaFusionRuntimeBridgeMap: _safe(personaFusionRuntimeBridgeMap),
       );

  final Map<String, Object> personaFusionRuntimeBridgeMap;

  Map<String, Object> build() {
    final Map<String, Object?> bridgeBody =
        personaFusionRuntimeBridgeMap['persona_fusion_runtime_bridge_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final String runtimeTag =
        (bridgeBody['runtime_persona_tag'] as String? ?? '').toLowerCase();
    String behaviorTag = 'adaptive_neutral';
    double intensity = 0.5;
    if (runtimeTag.startsWith('fusion')) {
      behaviorTag = 'adaptive_fusion';
      intensity = 0.7;
    } else if (runtimeTag.contains('cseries')) {
      behaviorTag = 'adaptive_cseries';
      intensity = 0.6;
    } else if (runtimeTag.contains('mtt')) {
      behaviorTag = 'adaptive_mtt';
      intensity = 0.55;
    }
    return <String, Object>{
      'persona_runtime_adaptive_behavior_v1': <String, Object>{
        'behavior_tag': _ascii(behaviorTag),
        'intensity': intensity,
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
