/// Passive accent merge v3 adapter for personalization (Phi-35).
class AIPersonalizationAccentMergeV3 {
  const AIPersonalizationAccentMergeV3({
    required this.accentIntentMap,
    required this.accentLiftMap,
    required this.behavioralGradientMap,
  });

  final Map<String, Object> accentIntentMap;
  final Map<String, Object> accentLiftMap;
  final Map<String, Object> behavioralGradientMap;

  Map<String, Object> run() {
    final bool hasIntent = accentIntentMap.isNotEmpty;
    final bool hasLift = accentLiftMap.isNotEmpty;
    final bool hasGradient = behavioralGradientMap.isNotEmpty;

    final List<String> accentMergeMissing = <String>[];
    if (!hasIntent) accentMergeMissing.add('am_intent');
    if (!hasLift) accentMergeMissing.add('am_lift');
    if (!hasGradient) accentMergeMissing.add('am_gradient');

    final Map<String, Object> accentMergeMap = <String, Object>{
      'am_intent': accentIntentMap,
      'am_lift': accentLiftMap,
      'am_gradient': behavioralGradientMap,
    };

    final bool accentMergeReady =
        hasIntent && hasLift && hasGradient && accentMergeMissing.isEmpty;

    return <String, Object>{
      'has_intent': hasIntent,
      'has_lift': hasLift,
      'has_gradient': hasGradient,
      'accent_merge_missing': accentMergeMissing,
      'accent_merge_map': accentMergeMap,
      'accent_merge_ready': accentMergeReady,
    };
  }
}
