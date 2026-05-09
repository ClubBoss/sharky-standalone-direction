/// Metadata descriptor for the reinforcement pipeline.
class ReinforcementPipelineDescriptorV1 {
  const ReinforcementPipelineDescriptorV1();

  Map<String, Object?> buildPipelineDescriptor({
    required String recapFamily,
    required String quizFamily,
    required String srsFamily,
    required String personaTier,
  }) => Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'recap_family': recapFamily,
    'quiz_family': quizFamily,
    'srs_family': srsFamily,
    'persona_tier': personaTier,
    'pipeline_descriptor': Map.unmodifiable(<String, Object?>{
      'stages': List.unmodifiable(<String>[
        'recap_to_quiz_link_v2',
        'srs_review_link_v1',
        'adaptive_review_weighting_v1',
        'aggregation_v1',
        'reinforcement_chain_v1',
      ]),
      'note': 'Pure metadata; no pipeline logic executed.',
    }),
  });
}

ReinforcementPipelineDescriptorV1 buildReinforcementPipelineDescriptorV1() =>
    const ReinforcementPipelineDescriptorV1();
