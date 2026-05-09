/// Metadata-only aggregation of recap/quiz/SRS/weighting pointers.
class AdaptiveMultiLinkAggregationV1 {
  const AdaptiveMultiLinkAggregationV1();

  Map<String, Object?> buildAggregatedDescriptor({
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
    'aggregate': Map.unmodifiable(<String, Object?>{
      'recap_to_quiz': 'placeholder_link_v2',
      'quiz_srs': 'placeholder_srs_link_v1',
      'weighting': 'placeholder_weighting_v1',
      'note': 'Deterministic metadata-only aggregation; no logic executed.',
    }),
  });
}

AdaptiveMultiLinkAggregationV1 buildAdaptiveMultiLinkAggregationV1() =>
    const AdaptiveMultiLinkAggregationV1();
