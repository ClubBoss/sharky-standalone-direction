/// Passive adaptive tempo adapter for personalization (Phi-19).
class AIPersonalizationTempoV1 {
  const AIPersonalizationTempoV1(this.accentScaffoldMap);

  final Map<String, Object> accentScaffoldMap;

  Map<String, Object> run() {
    final bool hasAccent = accentScaffoldMap.isNotEmpty;
    final Map<String, Object> tempoMap = <String, Object>{};
    final List<String> tempoMissing = <String>[];

    void _pick(String sourceKey, String targetKey) {
      if (accentScaffoldMap.containsKey(sourceKey)) {
        final Object value = accentScaffoldMap[sourceKey] as Object;
        tempoMap[targetKey] = value;
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          tempoMissing.add(targetKey);
        }
      } else {
        tempoMissing.add(targetKey);
      }
    }

    _pick('accent_persona', 'tempo_persona');
    _pick('accent_consistency', 'tempo_consistency');
    _pick('accent_aggregate', 'tempo_aggregate');
    _pick('accent_tier_a', 'tempo_tier_a');

    final bool tempoReady = hasAccent && tempoMissing.isEmpty;

    return <String, Object>{
      'has_accent': hasAccent,
      'tempo_missing': tempoMissing,
      'tempo_map': tempoMap,
      'tempo_ready': tempoReady,
    };
  }
}
