// FIX: Manual override for Safe Typing
class TableBehaviorSeedV1 {
  final Map<String, dynamic> tablePersonalityEnvelopeV1Map;
  final Map<String, dynamic> tablePersonalityRenderContextV1Map;
  final Map<String, dynamic> tableUIPersonalitySealV1Map;
  final Map<String, dynamic> tableAdaptivePersonaSpecV1Map;
  final Map<String, dynamic> tableFusionPersonaV1Map;
  final Map<String, dynamic> tableHintMapV1;

  TableBehaviorSeedV1({
    required Map<String, dynamic> tablePersonalityEnvelopeV1Map,
    required Map<String, dynamic> tablePersonalityRenderContextV1Map,
    required Map<String, dynamic> tableUIPersonalitySealV1Map,
    required Map<String, dynamic> tableAdaptivePersonaSpecV1Map,
    required Map<String, dynamic> tableFusionPersonaV1Map,
    required Map<String, dynamic> tableHintMapV1,
  }) : tablePersonalityEnvelopeV1Map = tablePersonalityEnvelopeV1Map,
       tablePersonalityRenderContextV1Map = tablePersonalityRenderContextV1Map,
       tableUIPersonalitySealV1Map = tableUIPersonalitySealV1Map,
       tableAdaptivePersonaSpecV1Map = tableAdaptivePersonaSpecV1Map,
       tableFusionPersonaV1Map = tableFusionPersonaV1Map,
       tableHintMapV1 = tableHintMapV1;

  bool get isValid {
    return tablePersonalityEnvelopeV1Map.isNotEmpty &&
        tablePersonalityRenderContextV1Map.isNotEmpty &&
        tableUIPersonalitySealV1Map.isNotEmpty &&
        tableAdaptivePersonaSpecV1Map.isNotEmpty &&
        tableFusionPersonaV1Map.isNotEmpty &&
        tableHintMapV1.isNotEmpty;
  }
}
