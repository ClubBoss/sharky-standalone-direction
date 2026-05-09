/// Metadata bridge that references all C-Series federation builders.
Map<String, Object?> buildCSeriesFederationBridgeV1() {
  final federations = Map.unmodifiable(<String, Object?>{
    'entry': 'buildContentEntryLayerV1()',
    'theory': 'buildTheoryPackFederationV1()',
    'mixed_checkpoint': 'buildMixedCheckpointFederationV1()',
    'recap': 'buildRecapFederationV1()',
    'micro_quiz': 'buildMicroQuizFederationV1()',
    'srs': 'buildSRSFederationV1()',
    'adaptive': 'buildPersonaAdaptiveFederationV1()',
    'cumulative_review': 'buildCumulativeReviewFederationV1()',
  });

  return Map.unmodifiable(<String, Object?>{
    'version': 'v1',
    'description': 'Unified bridge aggregating all C-Series federations.',
    'federations': federations,
  });
}
