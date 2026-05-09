import 'package:poker_analyzer/ui_v2/persona/ai_personalization/tier_b_core_v1.dart';
import 'package:poker_analyzer/ui_v2/persona/ai_personalization/tier_b_master_bundle_v1.dart';
import 'package:poker_analyzer/ui_v2/persona/emotion/engine_tier_a_v1.dart';

class StabilityQABridgeV2 {
  const StabilityQABridgeV2({
    required this.tierAValues,
    required this.tierBValues,
    required this.masterBundle,
    required this.flags,
  });

  final Map<String, Object> tierAValues;
  final Map<String, Object> tierBValues;
  final Map<String, Object> masterBundle;
  final Map<String, Object> flags;

  factory StabilityQABridgeV2.fromBundles({
    required EmotionEngineTierAV1 tierA,
    required TierBPersonalizationCoreV1 tierB,
    required TierBMasterBundleV1 master,
  }) {
    final tierAMap = tierA.asMap();
    final tierBMap = tierB.toReadOnlyMap();
    final masterMap = master.toReadOnlyMap();
    final flags = Map<String, Object>.unmodifiable({
      'tierA_present': tierAMap.isNotEmpty,
      'tierB_present': tierBMap.isNotEmpty,
      'master_present': masterMap.isNotEmpty,
      'tier_consistent': true,
    });
    return StabilityQABridgeV2(
      tierAValues: Map<String, Object>.unmodifiable(tierAMap),
      tierBValues: Map<String, Object>.unmodifiable(tierBMap),
      masterBundle: Map<String, Object>.unmodifiable(masterMap),
      flags: flags,
    );
  }

  Map<String, Object> toReadOnlyMap() => Map<String, Object>.unmodifiable({
    'tierAValues': tierAValues,
    'tierBValues': tierBValues,
    'masterBundle': masterBundle,
    'flags': flags,
  });

  static Map<String, Object?> build(Map<String, Object?> crest) {
    return {
      'stability_qa_bridge_v2': {
        'crest': Map<String, Object?>.unmodifiable(crest),
      },
    };
  }
}
