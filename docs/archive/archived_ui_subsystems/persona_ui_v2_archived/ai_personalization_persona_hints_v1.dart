/// Passive persona hints aggregator for personalization (Phi-25).
class AIPersonalizationPersonaHintsV1 {
  const AIPersonalizationPersonaHintsV1({
    required this.focusApplicationMap,
    required this.tempoApplicationMap,
    required this.accentApplicationMap,
  });

  final Map<String, Object> focusApplicationMap;
  final Map<String, Object> tempoApplicationMap;
  final Map<String, Object> accentApplicationMap;

  Map<String, Object> run() {
    final bool hasFocusApp = focusApplicationMap.isNotEmpty;
    final bool hasTempoApp = tempoApplicationMap.isNotEmpty;
    final bool hasAccentApp = accentApplicationMap.isNotEmpty;

    final List<String> personaHintsMissing = <String>[];
    if (!hasFocusApp) personaHintsMissing.add('hints_focus');
    if (!hasTempoApp) personaHintsMissing.add('hints_tempo');
    if (!hasAccentApp) personaHintsMissing.add('hints_accent');

    final Map<String, Object> personaHintsMap = <String, Object>{
      'hints_focus': focusApplicationMap,
      'hints_tempo': tempoApplicationMap,
      'hints_accent': accentApplicationMap,
    };

    final bool personaHintsReady =
        hasFocusApp &&
        hasTempoApp &&
        hasAccentApp &&
        personaHintsMissing.isEmpty;

    return <String, Object>{
      'has_focus_app': hasFocusApp,
      'has_tempo_app': hasTempoApp,
      'has_accent_app': hasAccentApp,
      'persona_hints_missing': personaHintsMissing,
      'persona_hints_map': personaHintsMap,
      'persona_hints_ready': personaHintsReady,
    };
  }
}
