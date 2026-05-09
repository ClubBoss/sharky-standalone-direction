enum SessionDrillSupplementalAssemblySlotV1 {
  world2ShowdownIntro,
  world3PreflopBridgeIntro,
  world10TrackRootIntro,
  world2ShowdownScenarioMeta,
  factualIntroGroup,
  factualSourceMetaGroup,
  factualRecapGroup,
}

class SessionDrillCanonicalSupplementalAssemblyContractV1 {
  const SessionDrillCanonicalSupplementalAssemblyContractV1({
    required this.preActionSlots,
    required this.postActionSlots,
    required this.showsEmbeddedFeedbackBelowTable,
  });

  final List<SessionDrillSupplementalAssemblySlotV1> preActionSlots;
  final List<SessionDrillSupplementalAssemblySlotV1> postActionSlots;
  final bool showsEmbeddedFeedbackBelowTable;
}

SessionDrillCanonicalSupplementalAssemblyContractV1
buildSessionDrillCanonicalSurfacedSupplementalAssemblyV1({
  required bool showsCompactSupplementalContext,
  required bool allowsCompactFactualIntro,
  required bool showWorld2ShowdownIntro,
  required bool showWorld3PreflopBridgeIntro,
  required bool showWorld10TrackRootIntro,
  required bool showWorld2ShowdownScenarioMeta,
  required bool factualContractPresent,
  required bool factualShowsIntro,
  required bool factualShowsSourceMeta,
  required bool factualShowsRecap,
  required bool showsEmbeddedFeedbackBelowTable,
  required bool factualEmbeddedFeedbackBelowTable,
}) {
  final showsFactualIntroContext =
      showsCompactSupplementalContext || allowsCompactFactualIntro;
  final preActionSlots = <SessionDrillSupplementalAssemblySlotV1>[
    if (showsCompactSupplementalContext && showWorld2ShowdownIntro)
      SessionDrillSupplementalAssemblySlotV1.world2ShowdownIntro,
    if (showsCompactSupplementalContext && showWorld3PreflopBridgeIntro)
      SessionDrillSupplementalAssemblySlotV1.world3PreflopBridgeIntro,
    if (showsCompactSupplementalContext && showWorld10TrackRootIntro)
      SessionDrillSupplementalAssemblySlotV1.world10TrackRootIntro,
    if (showsCompactSupplementalContext && showWorld2ShowdownScenarioMeta)
      SessionDrillSupplementalAssemblySlotV1.world2ShowdownScenarioMeta,
    if (!allowsCompactFactualIntro &&
        showsFactualIntroContext &&
        factualContractPresent &&
        factualShowsIntro)
      SessionDrillSupplementalAssemblySlotV1.factualIntroGroup,
    if (showsCompactSupplementalContext &&
        factualContractPresent &&
        factualShowsSourceMeta)
      SessionDrillSupplementalAssemblySlotV1.factualSourceMetaGroup,
  ];
  final postActionSlots = <SessionDrillSupplementalAssemblySlotV1>[
    if (allowsCompactFactualIntro && factualContractPresent && factualShowsIntro)
      SessionDrillSupplementalAssemblySlotV1.factualIntroGroup,
    if (factualContractPresent && factualShowsRecap)
      SessionDrillSupplementalAssemblySlotV1.factualRecapGroup,
  ];
  return SessionDrillCanonicalSupplementalAssemblyContractV1(
    preActionSlots: preActionSlots,
    postActionSlots: postActionSlots,
    showsEmbeddedFeedbackBelowTable: factualContractPresent
        ? factualEmbeddedFeedbackBelowTable
        : showsEmbeddedFeedbackBelowTable,
  );
}
