import 'package:poker_analyzer/ui_v2/runner/factual_runner_host_contract_v1.dart';

enum SessionDrillFactualSupplementFallbackSlotV1 {
  positionIntro,
  outsIntro,
  initiativeIntro,
  textureIntro,
  positionRecap,
  outsRecap,
  initiativeRecap,
  textureRecap,
  sourceMeta,
}

class SessionDrillCanonicalFactualSupplementFallbackV1 {
  const SessionDrillCanonicalFactualSupplementFallbackV1({
    required this.introSlots,
    required this.recapSlots,
    required this.showSourceMetaFallback,
  });

  final List<SessionDrillFactualSupplementFallbackSlotV1> introSlots;
  final List<SessionDrillFactualSupplementFallbackSlotV1> recapSlots;
  final bool showSourceMetaFallback;
}

SessionDrillCanonicalFactualSupplementFallbackV1
buildSessionDrillCanonicalFactualSupplementFallbackV1({
  required FactualRunnerHostFamilyV1 family,
  required bool showsIntro,
  required bool showsRecap,
  required bool authoredIntroPresent,
  required bool authoredRecapPresent,
  required bool showsSourceMeta,
}) {
  final introSlots = <SessionDrillFactualSupplementFallbackSlotV1>[
    if (showsIntro && !authoredIntroPresent)
      ...switch (family) {
        FactualRunnerHostFamilyV1.position => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.positionIntro,
          ],
        FactualRunnerHostFamilyV1.outs => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.outsIntro,
          ],
        FactualRunnerHostFamilyV1.initiative => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.initiativeIntro,
          ],
        FactualRunnerHostFamilyV1.texture => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.textureIntro,
          ],
        FactualRunnerHostFamilyV1.factualHandChain =>
          const <SessionDrillFactualSupplementFallbackSlotV1>[],
      },
  ];
  final recapSlots = <SessionDrillFactualSupplementFallbackSlotV1>[
    if (showsRecap && !authoredRecapPresent)
      ...switch (family) {
        FactualRunnerHostFamilyV1.position => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.positionRecap,
          ],
        FactualRunnerHostFamilyV1.outs => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.outsRecap,
          ],
        FactualRunnerHostFamilyV1.initiative => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.initiativeRecap,
          ],
        FactualRunnerHostFamilyV1.texture => const <
            SessionDrillFactualSupplementFallbackSlotV1>[
            SessionDrillFactualSupplementFallbackSlotV1.textureRecap,
          ],
        FactualRunnerHostFamilyV1.factualHandChain =>
          const <SessionDrillFactualSupplementFallbackSlotV1>[],
      },
  ];
  return SessionDrillCanonicalFactualSupplementFallbackV1(
    introSlots: introSlots,
    recapSlots: recapSlots,
    showSourceMetaFallback: showsSourceMeta,
  );
}
