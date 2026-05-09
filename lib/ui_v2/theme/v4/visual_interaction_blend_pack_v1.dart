class VisualInteractionBlendPackV1 {
  const VisualInteractionBlendPackV1({
    required this.tokenLiftResolutionPackV1,
    required this.visualMergeLayerV1,
    required this.adaptiveRenderingPreviewSnapshotV1,
    required this.designLiftReadyGateV1,
  });

  final Object tokenLiftResolutionPackV1;
  final Object visualMergeLayerV1;
  final Object adaptiveRenderingPreviewSnapshotV1;
  final Object designLiftReadyGateV1;

  Map<String, Object> asReadOnlyMap() => <String, Object>{
    'tokens': tokenLiftResolutionPackV1,
    'merge': visualMergeLayerV1,
    'preview': adaptiveRenderingPreviewSnapshotV1,
    'ready': designLiftReadyGateV1,
  };
}
