class PersonaProfileModelV1 {
  PersonaProfileModelV1({
    required this.personaId,
    required Map<String, String> staticTraits,
    required Map<String, String> aiInsights,
    required this.shortSummary,
    required this.longSummary,
  }) : _staticTraits = Map.unmodifiable(staticTraits),
       _aiInsights = Map.unmodifiable(aiInsights);

  final String personaId;
  final Map<String, String> _staticTraits;
  final Map<String, String> _aiInsights;
  final String shortSummary;
  final String longSummary;

  Map<String, String> get staticTraits => _staticTraits;
  Map<String, String> get aiInsights => _aiInsights;
}
