/// Passive adaptive UI hooks aggregator for personalization (Phi-21).
class AIPersonalizationAdaptiveUIHooksV1 {
  const AIPersonalizationAdaptiveUIHooksV1({
    required this.accentMap,
    required this.tempoMap,
    required this.focusMap,
  });

  final Map<String, Object> accentMap;
  final Map<String, Object> tempoMap;
  final Map<String, Object> focusMap;

  Map<String, Object> run() {
    final bool hasAccent = accentMap.isNotEmpty;
    final bool hasTempo = tempoMap.isNotEmpty;
    final bool hasFocus = focusMap.isNotEmpty;

    final List<String> adaptiveMissing = <String>[];
    if (!hasAccent) adaptiveMissing.add('ui_accent');
    if (!hasTempo) adaptiveMissing.add('ui_tempo');
    if (!hasFocus) adaptiveMissing.add('ui_focus');

    final Map<String, Object> adaptiveUiMap = <String, Object>{
      'ui_accent': accentMap,
      'ui_tempo': tempoMap,
      'ui_focus': focusMap,
    };

    final bool adaptiveReady =
        hasAccent && hasTempo && hasFocus && adaptiveMissing.isEmpty;

    return <String, Object>{
      'has_accent': hasAccent,
      'has_tempo': hasTempo,
      'has_focus': hasFocus,
      'adaptive_missing': adaptiveMissing,
      'adaptive_ui_map': adaptiveUiMap,
      'adaptive_ready': adaptiveReady,
    };
  }
}
