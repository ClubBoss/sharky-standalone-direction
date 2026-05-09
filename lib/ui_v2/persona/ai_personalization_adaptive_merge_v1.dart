/// Passive adaptive merge layer for personalization (Phi-30).
class AIPersonalizationAdaptiveMergeV1 {
  const AIPersonalizationAdaptiveMergeV1({
    required this.accentPathwaysMap,
    required this.scalingPathwaysMap,
  });

  final Map<String, Object> accentPathwaysMap;
  final Map<String, Object> scalingPathwaysMap;

  Map<String, Object> run() {
    final bool hasAccentPathways = accentPathwaysMap.isNotEmpty;
    final bool hasScalingPathways = scalingPathwaysMap.isNotEmpty;

    final List<String> adaptiveMergeMissing = <String>[];
    if (!hasAccentPathways) adaptiveMergeMissing.add('mp_accent');
    if (!hasScalingPathways) adaptiveMergeMissing.add('mp_scaling');

    final Map<String, Object> adaptivePathwaysMap = <String, Object>{
      'mp_accent': accentPathwaysMap,
      'mp_scaling': scalingPathwaysMap,
    };

    final bool adaptiveMergeReady =
        hasAccentPathways && hasScalingPathways && adaptiveMergeMissing.isEmpty;

    return <String, Object>{
      'has_accent_pathways': hasAccentPathways,
      'has_scaling_pathways': hasScalingPathways,
      'adaptive_merge_missing': adaptiveMergeMissing,
      'adaptive_pathways_map': adaptivePathwaysMap,
      'adaptive_merge_ready': adaptiveMergeReady,
    };
  }
}
