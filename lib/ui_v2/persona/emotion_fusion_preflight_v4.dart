class EmotionFusionPreflightV4 {
  EmotionFusionPreflightV4({required Map<String, Object?> fusion})
    : hasMoodFusion = fusion['moodFusion'] != null,
      hasToneFusion = fusion['toneFusion'] != null,
      hasArousalFusion = fusion['arousalFusion'] != null,
      hasValenceFusion = fusion['valenceFusion'] != null;

  final bool hasMoodFusion;
  final bool hasToneFusion;
  final bool hasArousalFusion;
  final bool hasValenceFusion;

  Map<String, Object?> asReadOnlyMap() => {
    'hasMoodFusion': hasMoodFusion,
    'hasToneFusion': hasToneFusion,
    'hasArousalFusion': hasArousalFusion,
    'hasValenceFusion': hasValenceFusion,
  };
}
