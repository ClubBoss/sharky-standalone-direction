/// Metadata descriptor for the reinforcement pipeline across recap/quiz/SRS.
class ReinforcementChainBuilderV1 {
  const ReinforcementChainBuilderV1();

  Map<String, Object?> buildReinforcementChainDescriptor({
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
    'pipeline': Map.unmodifiable(<String, Object?>{
      'stage_order': List.unmodifiable(<String>[
        'recap_to_quiz_link_v2',
        'srs_link_v1',
        'adaptive_weighting_v1',
        'aggregation_v1',
      ]),
      'note':
          'Deterministic metadata-only descriptor; no pipeline logic executed.',
    }),
  });
}

ReinforcementChainBuilderV1 buildReinforcementChainBuilderV1() =>
    const ReinforcementChainBuilderV1();
