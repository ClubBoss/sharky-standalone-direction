import 'table_context_bridge_v1.dart';
import 'table_personalization_bridge_v1.dart';

/// Tier-B system bridge for persona context and personalization (Phi-32.18).
class AIPersonalizationTierBSystemBridgeV1 {
  const AIPersonalizationTierBSystemBridgeV1({
    required this.tableViewShellMap,
    required this.tierBOutputMap,
    required this.tierBHintsMap,
  });

  final Object tableViewShellMap;
  final Object tierBOutputMap;
  final Object tierBHintsMap;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> context = TableContextBridgeV1(
      tableViewShellMap,
      tierBOutputMap,
      tierBHintsMap,
    ).asReadOnlyMap();

    final Map<String, Object> personalization = TablePersonalizationBridgeV1(
      context,
      tierBOutputMap,
      tierBHintsMap,
    ).asReadOnlyMap();

    final bool contextReady = context['readiness'] == true;
    final bool personalizationReady = personalization['readiness'] == true;

    return <String, Object>{
      'context': context,
      'personalization': personalization,
      'bridge_ready': contextReady && personalizationReady,
    };
  }
}
