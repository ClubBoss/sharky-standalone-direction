/// Passive Visual QA Pre-Lift v1.
class VisualQAPreLiftV1 {
  const VisualQAPreLiftV1({
    required this.tokenRegistry,
    required this.themeDeltas,
    required this.materialization,
    required this.personaConsistency,
    required this.surfacePolish,
  });

  final Map<String, Object> tokenRegistry;
  final Map<String, Object> themeDeltas;
  final Map<String, Object> materialization;
  final Map<String, Object> personaConsistency;
  final Map<String, Object> surfacePolish;

  Map<String, Object> run() {
    final bool hasTokens = tokenRegistry.isNotEmpty;
    final bool hasThemeDeltas = themeDeltas.isNotEmpty;
    final bool hasMaterialization = materialization.isNotEmpty;
    final bool hasPersonaConsistency = personaConsistency.isNotEmpty;
    final bool hasSurfacePolish = surfacePolish.isNotEmpty;

    final List<String> missingSections = <String>[];
    if (!hasTokens) missingSections.add('tokens');
    if (!hasThemeDeltas) missingSections.add('theme_deltas');
    if (!hasMaterialization) missingSections.add('materialization');
    if (!hasPersonaConsistency) missingSections.add('persona');
    if (!hasSurfacePolish) missingSections.add('surface');

    final List<String> emptyKeys = <String>[];
    void checkEmpty(Map<String, Object> map, String prefix) {
      map.forEach((key, value) {
        if (value is Map && value.isEmpty) {
          emptyKeys.add('$prefix.$key');
        } else if (value is Iterable && value.isEmpty) {
          emptyKeys.add('$prefix.$key');
        } else if (value is String && value.isEmpty) {
          emptyKeys.add('$prefix.$key');
        }
      });
    }

    checkEmpty(tokenRegistry, 'tokens');
    checkEmpty(themeDeltas, 'theme_deltas');
    checkEmpty(materialization, 'materialization');
    checkEmpty(personaConsistency, 'persona');
    checkEmpty(surfacePolish, 'surface');

    final bool qaReady =
        hasTokens &&
        hasThemeDeltas &&
        hasMaterialization &&
        hasPersonaConsistency &&
        hasSurfacePolish &&
        emptyKeys.isEmpty &&
        missingSections.isEmpty;

    return <String, Object>{
      'has_tokens': hasTokens,
      'has_theme_deltas': hasThemeDeltas,
      'has_materialization': hasMaterialization,
      'has_persona_consistency': hasPersonaConsistency,
      'has_surface_polish': hasSurfacePolish,
      'empty_keys': emptyKeys,
      'missing_sections': missingSections,
      'qa_ready': qaReady,
    };
  }
}
