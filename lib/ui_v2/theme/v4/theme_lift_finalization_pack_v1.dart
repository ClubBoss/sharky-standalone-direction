class ThemeLiftFinalizationPackV1 {
  const ThemeLiftFinalizationPackV1({
    required this.themeAdaptiveFusionPackV1,
    required this.themeLiftConsolidationPackV1,
    required this.themeFusionConsolidationSyncPackV1,
    required this.themeLiftPreflightValidatorV1,
    required this.tokenLiftResolutionPackV1,
    required this.visualMergeLayerV1,
    required this.visualInteractionBlendPackV1,
    required this.adaptiveRenderingPreviewSnapshotV1,
    required this.designLiftReadyGateV1,
  });

  final Object themeAdaptiveFusionPackV1;
  final Object themeLiftConsolidationPackV1;
  final Object themeFusionConsolidationSyncPackV1;
  final Object themeLiftPreflightValidatorV1;
  final Object tokenLiftResolutionPackV1;
  final Object visualMergeLayerV1;
  final Object visualInteractionBlendPackV1;
  final Object adaptiveRenderingPreviewSnapshotV1;
  final Object designLiftReadyGateV1;

  Map<String, Object> asReadOnlyMap() => <String, Object>{
    'adaptive_fusion': themeAdaptiveFusionPackV1,
    'consolidation': themeLiftConsolidationPackV1,
    'sync': themeFusionConsolidationSyncPackV1,
    'preflight': themeLiftPreflightValidatorV1,
    'token_resolution': tokenLiftResolutionPackV1,
    'merge': visualMergeLayerV1,
    'interaction_blend': visualInteractionBlendPackV1,
    'preview': adaptiveRenderingPreviewSnapshotV1,
    'ready_gate': designLiftReadyGateV1,
  };
}
