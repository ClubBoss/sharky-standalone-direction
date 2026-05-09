import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';

enum CanonicalTableSurfacePrimitiveV1 {
  compactHeaderBand,
  promptStatusCapsule,
  projectedTableShell,
  seatStateBadges,
  sceneSupportLane,
  bottomActionHierarchy,
  completionSurface,
}

enum CanonicalTableScenePayloadOwnerV1 {
  authoredDrillPayload,
  sessionProjectionDefaults,
  runtimeNormalizationOnly,
}

enum CanonicalTableCapabilityToggleV1 {
  projectedTable,
  seatTapInteraction,
  boardTapInteraction,
  holeCardsTapInteraction,
  actionChoiceBar,
  betSizingBar,
  textureClassifierBar,
  handChainStepper,
  surfacedScenarioChrome,
  sourceMeta,
  introCard,
  recapCard,
  completionContinuation,
  seatIdMarkers,
  roleBadges,
  forcedBetOverlays,
}

enum CanonicalTableReadinessBoundaryV1 {
  scenarioSpecRequired,
  scenePayloadRequiredForProjectedModes,
  hostMustNotInventSemanticScene,
  unsupportedFamilyStaysOnLegacyHost,
}

enum CanonicalTableAdoptionClusterV1 {
  world10TrackSessions,
  world1CanonicalConvergence,
  world2MixedSurfacedReview,
  world5LateTexture,
}

@immutable
class CanonicalTableRunnerSurfaceContractV1 {
  const CanonicalTableRunnerSurfaceContractV1({
    required this.id,
    required this.label,
    required this.sharedGrammarId,
    required this.primitives,
    required this.scenePayloadOwnership,
    required this.capabilityToggles,
    required this.seatMarkerResponsibility,
    required this.promptPlacementResponsibility,
    required this.supportPlacementResponsibility,
    required this.ctaPlacementResponsibility,
    required this.readinessBoundaries,
  });

  final String id;
  final String label;
  final String sharedGrammarId;
  final List<CanonicalTableSurfacePrimitiveV1> primitives;
  final List<CanonicalTableScenePayloadOwnerV1> scenePayloadOwnership;
  final List<CanonicalTableCapabilityToggleV1> capabilityToggles;
  final String seatMarkerResponsibility;
  final String promptPlacementResponsibility;
  final String supportPlacementResponsibility;
  final String ctaPlacementResponsibility;
  final List<CanonicalTableReadinessBoundaryV1> readinessBoundaries;

  bool supports(CanonicalTableCapabilityToggleV1 toggle) {
    return capabilityToggles.contains(toggle);
  }
}

@immutable
class CanonicalTableAdoptionRecommendationV1 {
  const CanonicalTableAdoptionRecommendationV1({
    required this.cluster,
    required this.label,
    required this.whyItWins,
    required this.safeForPhaseEntryMigration,
    required this.exactNextStep,
  });

  final CanonicalTableAdoptionClusterV1 cluster;
  final String label;
  final String whyItWins;
  final bool safeForPhaseEntryMigration;
  final String exactNextStep;
}

const String kCanonicalTableRunnerSurfaceContractIdV1 =
    'canonicalTableRunnerSurfaceV1';

const CanonicalTableRunnerSurfaceContractV1
kCanonicalTableRunnerSurfaceContractV1 = CanonicalTableRunnerSurfaceContractV1(
  id: kCanonicalTableRunnerSurfaceContractIdV1,
  label: 'Unified canonical learner-facing table and runner surface',
  sharedGrammarId: kCanonicalSharedLearnerHostGrammarIdV1,
  primitives: <CanonicalTableSurfacePrimitiveV1>[
    CanonicalTableSurfacePrimitiveV1.compactHeaderBand,
    CanonicalTableSurfacePrimitiveV1.promptStatusCapsule,
    CanonicalTableSurfacePrimitiveV1.projectedTableShell,
    CanonicalTableSurfacePrimitiveV1.seatStateBadges,
    CanonicalTableSurfacePrimitiveV1.sceneSupportLane,
    CanonicalTableSurfacePrimitiveV1.bottomActionHierarchy,
    CanonicalTableSurfacePrimitiveV1.completionSurface,
  ],
  scenePayloadOwnership: <CanonicalTableScenePayloadOwnerV1>[
    CanonicalTableScenePayloadOwnerV1.authoredDrillPayload,
    CanonicalTableScenePayloadOwnerV1.sessionProjectionDefaults,
    CanonicalTableScenePayloadOwnerV1.runtimeNormalizationOnly,
  ],
  capabilityToggles: <CanonicalTableCapabilityToggleV1>[
    CanonicalTableCapabilityToggleV1.projectedTable,
    CanonicalTableCapabilityToggleV1.seatTapInteraction,
    CanonicalTableCapabilityToggleV1.boardTapInteraction,
    CanonicalTableCapabilityToggleV1.holeCardsTapInteraction,
    CanonicalTableCapabilityToggleV1.actionChoiceBar,
    CanonicalTableCapabilityToggleV1.betSizingBar,
    CanonicalTableCapabilityToggleV1.textureClassifierBar,
    CanonicalTableCapabilityToggleV1.handChainStepper,
    CanonicalTableCapabilityToggleV1.surfacedScenarioChrome,
    CanonicalTableCapabilityToggleV1.sourceMeta,
    CanonicalTableCapabilityToggleV1.introCard,
    CanonicalTableCapabilityToggleV1.recapCard,
    CanonicalTableCapabilityToggleV1.completionContinuation,
    CanonicalTableCapabilityToggleV1.seatIdMarkers,
    CanonicalTableCapabilityToggleV1.roleBadges,
    CanonicalTableCapabilityToggleV1.forcedBetOverlays,
  ],
  seatMarkerResponsibility:
      'The canonical table shell owns seat-id markers, role badges, and blind/forced-bet overlays. Host families pass normalized labels and visibility state; they do not compose bespoke overlay widgets.',
  promptPlacementResponsibility:
      'Prompt and progression status belong above the table in the compact header band and prompt capsule, not inside the felt scene.',
  supportPlacementResponsibility:
      'Why-text, recap, source meta, and post-action support belong below the table in the scene support lane.',
  ctaPlacementResponsibility:
      'Action bars and completion continuation belong in the bottom action hierarchy or completion surface, not inline in the scene shell.',
  readinessBoundaries: <CanonicalTableReadinessBoundaryV1>[
    CanonicalTableReadinessBoundaryV1.scenarioSpecRequired,
    CanonicalTableReadinessBoundaryV1.scenePayloadRequiredForProjectedModes,
    CanonicalTableReadinessBoundaryV1.hostMustNotInventSemanticScene,
    CanonicalTableReadinessBoundaryV1.unsupportedFamilyStaysOnLegacyHost,
  ],
);

const CanonicalTableAdoptionRecommendationV1
kCanonicalTableFirstAdoptionRecommendationV1 = CanonicalTableAdoptionRecommendationV1(
  cluster: CanonicalTableAdoptionClusterV1.world10TrackSessions,
  label: 'World 10 track-session canonical table cluster',
  whyItWins:
      'It is the largest remaining same-family learner-facing population and already sits on SessionDrillPlayer, so it offers the most leverage toward one canonical table shell.',
  safeForPhaseEntryMigration: false,
  exactNextStep:
      'Use this as the first dedicated migration cluster in the next pass; do not force it in the phase-entry turn because it still combines host-gate and scene-payload canonicalization across 30 sessions.',
);
