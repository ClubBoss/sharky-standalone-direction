enum SessionDrillCanonicalTopSectionDensityV1 {
  generic,
  embeddedScenario,
  world2Surfaced,
}

enum SessionDrillCanonicalRenderSurfaceFamilyV1 {
  generic,
  world2Surfaced,
  world10TrackFinite,
}

class SessionDrillCanonicalSurfaceSelectionStateV1 {
  const SessionDrillCanonicalSurfaceSelectionStateV1({
    required this.showsEmbeddedFeedbackBelowTable,
    required this.showsSurfacedWorld2Host,
    required this.usesWorld2ScaffoldChromeReduction,
    required this.topSectionDensity,
  });

  final bool showsEmbeddedFeedbackBelowTable;
  final bool showsSurfacedWorld2Host;
  final bool usesWorld2ScaffoldChromeReduction;
  final SessionDrillCanonicalTopSectionDensityV1 topSectionDensity;
}

SessionDrillCanonicalSurfaceSelectionStateV1
buildSessionDrillCanonicalSurfaceSelectionStateV1({
  required bool showsEmbeddedScenarioTable,
  required bool isWorld2SurfacedScenarioSession,
  required bool isCompleted,
}) {
  final showsSurfacedWorld2Host =
      showsEmbeddedScenarioTable && isWorld2SurfacedScenarioSession;
  return SessionDrillCanonicalSurfaceSelectionStateV1(
    showsEmbeddedFeedbackBelowTable: showsEmbeddedScenarioTable && !isCompleted,
    showsSurfacedWorld2Host: showsSurfacedWorld2Host,
    usesWorld2ScaffoldChromeReduction: showsSurfacedWorld2Host,
    topSectionDensity: showsSurfacedWorld2Host
        ? SessionDrillCanonicalTopSectionDensityV1.world2Surfaced
        : (showsEmbeddedScenarioTable
              ? SessionDrillCanonicalTopSectionDensityV1.embeddedScenario
              : SessionDrillCanonicalTopSectionDensityV1.generic),
  );
}

SessionDrillCanonicalRenderSurfaceFamilyV1
resolveSessionDrillCanonicalRenderSurfaceFamilyV1({
  required bool hasSurfacedWorld2Adapter,
  required bool hasWorld10TrackCluster,
}) {
  if (hasSurfacedWorld2Adapter) {
    return SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced;
  }
  if (hasWorld10TrackCluster) {
    return SessionDrillCanonicalRenderSurfaceFamilyV1.world10TrackFinite;
  }
  return SessionDrillCanonicalRenderSurfaceFamilyV1.generic;
}
