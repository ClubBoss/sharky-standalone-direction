class ThemeLiftConsolidationPackV1 {
  const ThemeLiftConsolidationPackV1({
    required this.themeAdaptiveFusionPackV1,
    required this.tokenLiftResolutionPackV1,
    required this.personaAdaptiveTokenMappingV1,
    required this.visualMergeLayerV1,
    required this.visualInteractionBlendPackV1,
    required this.adaptiveRenderingPreviewSnapshotV1,
    required this.designLiftReadyGateV1,
  });

  final Object themeAdaptiveFusionPackV1;
  final Object tokenLiftResolutionPackV1;
  final Object personaAdaptiveTokenMappingV1;
  final Object visualMergeLayerV1;
  final Object visualInteractionBlendPackV1;
  final Object adaptiveRenderingPreviewSnapshotV1;
  final Object designLiftReadyGateV1;

  Map<String, Object> asReadOnlyMap() => <String, Object>{
    'fusion': themeAdaptiveFusionPackV1,
    'resolution': tokenLiftResolutionPackV1,
    'token_mapping': personaAdaptiveTokenMappingV1,
    'merge': visualMergeLayerV1,
    'interaction_blend': visualInteractionBlendPackV1,
    'preview': adaptiveRenderingPreviewSnapshotV1,
    'ready_gate': designLiftReadyGateV1,
  };
}
