import 'package:poker_analyzer/ui_v2/persona/ai_personalization/tier_b_master_bundle_v1.dart';

class ConsolidationQAV4 {
  const ConsolidationQAV4({
    required this.v4ThemeSnapshot,
    required this.personaSnapshot,
    required this.masterBundle,
  });

  final Map<String, Object> v4ThemeSnapshot;
  final Map<String, Object> personaSnapshot;
  final TierBMasterBundleV1 masterBundle;

  Map<String, Object> toReadOnlyMap() {
    final tierB = masterBundle.toReadOnlyMap();
    final themeOk = v4ThemeSnapshot.isNotEmpty;
    final personaOk = personaSnapshot.isNotEmpty;
    final personalizationOk = tierB.isNotEmpty;
    return Map<String, Object>.unmodifiable({
      'v4ThemeSnapshot': v4ThemeSnapshot,
      'personaSnapshot': personaSnapshot,
      'masterBundle': tierB,
      'theme_ok': themeOk,
      'persona_ok': personaOk,
      'personalization_ok': personalizationOk,
    });
  }
}
