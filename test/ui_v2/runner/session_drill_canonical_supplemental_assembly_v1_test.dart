import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_supplemental_assembly_v1.dart';

void main() {
  test(
    'session drill surfaced supplemental assembly resolves compact pre-action slots',
    () {
      final contract = buildSessionDrillCanonicalSurfacedSupplementalAssemblyV1(
        showsCompactSupplementalContext: true,
        allowsCompactFactualIntro: false,
        showWorld2ShowdownIntro: true,
        showWorld3PreflopBridgeIntro: true,
        showWorld10TrackRootIntro: true,
        showWorld2ShowdownScenarioMeta: true,
        factualContractPresent: true,
        factualShowsIntro: true,
        factualShowsSourceMeta: true,
        factualShowsRecap: true,
        showsEmbeddedFeedbackBelowTable: true,
        factualEmbeddedFeedbackBelowTable: false,
      );

      expect(contract.preActionSlots, <SessionDrillSupplementalAssemblySlotV1>[
        SessionDrillSupplementalAssemblySlotV1.world2ShowdownIntro,
        SessionDrillSupplementalAssemblySlotV1.world3PreflopBridgeIntro,
        SessionDrillSupplementalAssemblySlotV1.world10TrackRootIntro,
        SessionDrillSupplementalAssemblySlotV1.world2ShowdownScenarioMeta,
        SessionDrillSupplementalAssemblySlotV1.factualIntroGroup,
        SessionDrillSupplementalAssemblySlotV1.factualSourceMetaGroup,
      ]);
      expect(contract.postActionSlots, <SessionDrillSupplementalAssemblySlotV1>[
        SessionDrillSupplementalAssemblySlotV1.factualRecapGroup,
      ]);
      expect(contract.showsEmbeddedFeedbackBelowTable, isFalse);
    },
  );

  test(
    'session drill surfaced supplemental assembly hides compact slots when not eligible',
    () {
      final contract = buildSessionDrillCanonicalSurfacedSupplementalAssemblyV1(
        showsCompactSupplementalContext: false,
        allowsCompactFactualIntro: false,
        showWorld2ShowdownIntro: true,
        showWorld3PreflopBridgeIntro: true,
        showWorld10TrackRootIntro: true,
        showWorld2ShowdownScenarioMeta: true,
        factualContractPresent: false,
        factualShowsIntro: false,
        factualShowsSourceMeta: false,
        factualShowsRecap: false,
        showsEmbeddedFeedbackBelowTable: true,
        factualEmbeddedFeedbackBelowTable: false,
      );

      expect(contract.preActionSlots, isEmpty);
      expect(contract.postActionSlots, isEmpty);
      expect(contract.showsEmbeddedFeedbackBelowTable, isTrue);
    },
  );

  test(
    'session drill surfaced supplemental assembly can defer factual intro to post-action compact slot',
    () {
      final contract = buildSessionDrillCanonicalSurfacedSupplementalAssemblyV1(
        showsCompactSupplementalContext: false,
        allowsCompactFactualIntro: true,
        showWorld2ShowdownIntro: false,
        showWorld3PreflopBridgeIntro: false,
        showWorld10TrackRootIntro: false,
        showWorld2ShowdownScenarioMeta: false,
        factualContractPresent: true,
        factualShowsIntro: true,
        factualShowsSourceMeta: false,
        factualShowsRecap: true,
        showsEmbeddedFeedbackBelowTable: true,
        factualEmbeddedFeedbackBelowTable: true,
      );

      expect(contract.preActionSlots, isEmpty);
      expect(contract.postActionSlots, <SessionDrillSupplementalAssemblySlotV1>[
        SessionDrillSupplementalAssemblySlotV1.factualIntroGroup,
        SessionDrillSupplementalAssemblySlotV1.factualRecapGroup,
      ]);
      expect(contract.showsEmbeddedFeedbackBelowTable, isTrue);
    },
  );
}
