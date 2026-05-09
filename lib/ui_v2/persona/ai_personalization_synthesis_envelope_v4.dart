class AIPersonalizationSynthesisEnvelopeV4 {
  AIPersonalizationSynthesisEnvelopeV4({
    required Map<String, Object?> finalSynthesis,
    required Map<String, Object?> merged,
  }) : _finalSynthesis = Map.of(finalSynthesis),
       _merged = Map.of(merged);

  final Map<String, Object?> _finalSynthesis;
  final Map<String, Object?> _merged;

  Map<String, Object?> asReadOnlyMap() => {
    'finalSynthesis': _finalSynthesis,
    'merged': _merged,
  };
}
