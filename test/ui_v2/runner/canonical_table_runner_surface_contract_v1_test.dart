import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_table_runner_surface_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_host_grammar_v1.dart';

void main() {
  test('canonical table runner surface contract is explicit and complete', () {
    final contract = kCanonicalTableRunnerSurfaceContractV1;

    expect(contract.id, kCanonicalTableRunnerSurfaceContractIdV1);
    expect(contract.sharedGrammarId, kCanonicalSharedLearnerHostGrammarIdV1);
    expect(
      contract.primitives,
      containsAll(const <CanonicalTableSurfacePrimitiveV1>[
        CanonicalTableSurfacePrimitiveV1.compactHeaderBand,
        CanonicalTableSurfacePrimitiveV1.promptStatusCapsule,
        CanonicalTableSurfacePrimitiveV1.projectedTableShell,
        CanonicalTableSurfacePrimitiveV1.seatStateBadges,
        CanonicalTableSurfacePrimitiveV1.sceneSupportLane,
        CanonicalTableSurfacePrimitiveV1.bottomActionHierarchy,
        CanonicalTableSurfacePrimitiveV1.completionSurface,
      ]),
    );
    expect(
      contract.scenePayloadOwnership,
      equals(const <CanonicalTableScenePayloadOwnerV1>[
        CanonicalTableScenePayloadOwnerV1.authoredDrillPayload,
        CanonicalTableScenePayloadOwnerV1.sessionProjectionDefaults,
        CanonicalTableScenePayloadOwnerV1.runtimeNormalizationOnly,
      ]),
    );
    expect(
      contract.capabilityToggles,
      containsAll(const <CanonicalTableCapabilityToggleV1>[
        CanonicalTableCapabilityToggleV1.projectedTable,
        CanonicalTableCapabilityToggleV1.seatTapInteraction,
        CanonicalTableCapabilityToggleV1.boardTapInteraction,
        CanonicalTableCapabilityToggleV1.holeCardsTapInteraction,
        CanonicalTableCapabilityToggleV1.actionChoiceBar,
        CanonicalTableCapabilityToggleV1.betSizingBar,
        CanonicalTableCapabilityToggleV1.textureClassifierBar,
        CanonicalTableCapabilityToggleV1.handChainStepper,
        CanonicalTableCapabilityToggleV1.seatIdMarkers,
        CanonicalTableCapabilityToggleV1.roleBadges,
        CanonicalTableCapabilityToggleV1.forcedBetOverlays,
      ]),
    );
    expect(
      contract.readinessBoundaries,
      containsAll(const <CanonicalTableReadinessBoundaryV1>[
        CanonicalTableReadinessBoundaryV1.scenarioSpecRequired,
        CanonicalTableReadinessBoundaryV1.scenePayloadRequiredForProjectedModes,
        CanonicalTableReadinessBoundaryV1.hostMustNotInventSemanticScene,
        CanonicalTableReadinessBoundaryV1.unsupportedFamilyStaysOnLegacyHost,
      ]),
    );
    expect(contract.seatMarkerResponsibility, contains('seat-id markers'));
    expect(contract.promptPlacementResponsibility, contains('above the table'));
    expect(
      contract.supportPlacementResponsibility,
      contains('below the table'),
    );
    expect(contract.ctaPlacementResponsibility, contains('bottom action'));
  });

  test(
    'phase-entry recommendation picks world10 and does not force migration',
    () {
      final recommendation = kCanonicalTableFirstAdoptionRecommendationV1;

      expect(
        recommendation.cluster,
        CanonicalTableAdoptionClusterV1.world10TrackSessions,
      );
      expect(recommendation.safeForPhaseEntryMigration, isFalse);
      expect(recommendation.label, contains('World 10'));
      expect(
        recommendation.whyItWins,
        contains('largest remaining same-family'),
      );
      expect(recommendation.exactNextStep, contains('next pass'));
    },
  );
}
