/// Metadata describing persona-adaptive content template assets.
class PersonaAdaptiveTemplateV1 {
  const PersonaAdaptiveTemplateV1();

  Map<String, Object?> build() {
    final files = <String, Object>{
      'persona_map_json': 'persona_map.json',
      'weighting_map_json': 'weighting_map.json',
      'adaptive_hints_json': 'adaptive_hints.json',
    };
    final tapExplain = List.unmodifiable(<String>[
      'persona_shift',
      'hint_strength',
      'adaptive_weight',
    ]);
    return Map.unmodifiable(<String, Object?>{
      'version': 'v1',
      'files': Map.unmodifiable(files),
      'tap_to_explain_tokens': tapExplain,
      'note': 'Deterministic PersonaAdaptiveTemplateV1; no logic, no IO.',
    });
  }
}

PersonaAdaptiveTemplateV1 buildPersonaAdaptiveTemplateV1() =>
    const PersonaAdaptiveTemplateV1();
