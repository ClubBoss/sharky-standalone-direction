/// Passive Persona/Theme Consistency Gate v1.
class PersonaThemeConsistencyGateV1 {
  const PersonaThemeConsistencyGateV1({
    required this.personaBundle,
    required this.v4ActivationBundle,
    required this.materialization,
    required this.tableSurfacePolish,
  });

  final Map<String, Object> personaBundle;
  final Map<String, Object> v4ActivationBundle;
  final Map<String, Object> materialization;
  final Map<String, Object> tableSurfacePolish;

  Map<String, Object> run() {
    final bool hasPersona = personaBundle.isNotEmpty;
    final bool hasActivation = v4ActivationBundle.isNotEmpty;
    final bool hasMaterialization = materialization.isNotEmpty;
    final bool hasSurfacePolish = tableSurfacePolish.isNotEmpty;

    final List<String> missingSections = <String>[];
    if (!hasPersona) missingSections.add('persona');
    if (!hasActivation) missingSections.add('activation');
    if (!hasMaterialization) missingSections.add('materialization');
    if (!hasSurfacePolish) missingSections.add('surface_polish');

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

    checkEmpty(personaBundle, 'persona');
    checkEmpty(v4ActivationBundle, 'activation');
    checkEmpty(materialization, 'materialization');
    checkEmpty(tableSurfacePolish, 'surface_polish');

    final bool consistencyReady =
        hasPersona &&
        hasActivation &&
        hasMaterialization &&
        hasSurfacePolish &&
        emptyKeys.isEmpty &&
        missingSections.isEmpty;

    return <String, Object>{
      'has_persona_bundle': hasPersona,
      'has_activation_bundle': hasActivation,
      'has_materialization': hasMaterialization,
      'has_surface_polish': hasSurfacePolish,
      'missing_sections': missingSections,
      'empty_keys': emptyKeys,
      'consistency_ready': consistencyReady,
    };
  }
}
