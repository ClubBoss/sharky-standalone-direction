/// Metadata placeholder describing adaptive review weighting.
class AdaptiveReviewWeightingV1 {
  const AdaptiveReviewWeightingV1();

  Map<String, Object?> buildAdaptiveWeightingDescriptor({
    required String personaTier,
    required String recapFamily,
    required String quizFamily,
    required String srsFamily,
  }) => Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'persona_tier': personaTier,
    'recap_family': recapFamily,
    'quiz_family': quizFamily,
    'srs_family': srsFamily,
    'weighting': Map.unmodifiable(<String, Object?>{
      'relationship': 'adaptive_review_weighting',
      'tier_effect': 'placeholder',
      'note': 'Deterministic metadata descriptor; no adaptive logic executed.',
    }),
  });
}

AdaptiveReviewWeightingV1 buildAdaptiveReviewWeightingV1() =>
    const AdaptiveReviewWeightingV1();
