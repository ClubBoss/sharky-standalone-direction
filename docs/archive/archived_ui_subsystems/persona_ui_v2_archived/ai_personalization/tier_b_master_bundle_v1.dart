import '../emotion/engine_tier_a_v1.dart';
import 'tier_b_core_v1.dart';

class TierBMasterBundleV1 {
  const TierBMasterBundleV1({
    required this.finalSynthesis,
    required this.telemetry,
    required this.relay,
    required this.tierAValues,
    required this.tierBValues,
  });

  final Map<String, Object> finalSynthesis;
  final Map<String, Object> telemetry;
  final Map<String, Object> relay;
  final Map<String, Object> tierAValues;
  final Map<String, Object> tierBValues;

  factory TierBMasterBundleV1.fromEngines({
    required EmotionEngineTierAV1 tierA,
    required TierBPersonalizationCoreV1 tierB,
    Map<String, Object> telemetry = const <String, Object>{
      'channel': 'tier_b',
      'version': 'v1',
    },
    Map<String, Object> relay = const <String, Object>{
      'target': 'personalization_bridge',
      'layer': 'tier_b',
    },
  }) {
    final tierAData = tierA.asMap();
    final tierBData = tierB.toReadOnlyMap();
    return TierBMasterBundleV1(
      finalSynthesis: Map<String, Object>.unmodifiable({
        'tier': 'B',
        'tierA': tierAData,
        'tierB': tierBData,
      }),
      telemetry: Map<String, Object>.unmodifiable(telemetry),
      relay: Map<String, Object>.unmodifiable(relay),
      tierAValues: Map<String, Object>.unmodifiable(tierAData),
      tierBValues: Map<String, Object>.unmodifiable(tierBData),
    );
  }

  Map<String, Object> toReadOnlyMap() => Map<String, Object>.unmodifiable({
    'finalSynthesis': finalSynthesis,
    'telemetry': telemetry,
    'relay': relay,
    'tierAValues': tierAValues,
    'tierBValues': tierBValues,
  });
}
