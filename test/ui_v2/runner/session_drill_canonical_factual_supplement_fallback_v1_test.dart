import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_factual_supplement_fallback_v1.dart';

void main() {
  test(
    'session drill factual supplement fallback resolves intro and recap slots',
    () {
      final fallback = buildSessionDrillCanonicalFactualSupplementFallbackV1(
        family: FactualRunnerHostFamilyV1.initiative,
        showsIntro: true,
        showsRecap: true,
        authoredIntroPresent: false,
        authoredRecapPresent: false,
        showsSourceMeta: true,
      );

      expect(fallback.introSlots, <SessionDrillFactualSupplementFallbackSlotV1>[
        SessionDrillFactualSupplementFallbackSlotV1.initiativeIntro,
      ]);
      expect(fallback.recapSlots, <SessionDrillFactualSupplementFallbackSlotV1>[
        SessionDrillFactualSupplementFallbackSlotV1.initiativeRecap,
      ]);
      expect(fallback.showSourceMetaFallback, isTrue);
    },
  );

  test(
    'session drill factual supplement fallback suppresses authored fallback slots',
    () {
      final fallback = buildSessionDrillCanonicalFactualSupplementFallbackV1(
        family: FactualRunnerHostFamilyV1.position,
        showsIntro: true,
        showsRecap: true,
        authoredIntroPresent: true,
        authoredRecapPresent: true,
        showsSourceMeta: false,
      );

      expect(fallback.introSlots, isEmpty);
      expect(fallback.recapSlots, isEmpty);
      expect(fallback.showSourceMetaFallback, isFalse);
    },
  );
}
