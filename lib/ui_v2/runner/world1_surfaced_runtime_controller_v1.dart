import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_progression_handoff_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_outcome_lane_semantics_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';

class World1SurfacedOutcomeRuntimeControllerInputV1 {
  const World1SurfacedOutcomeRuntimeControllerInputV1({
    required this.outcomeVisible,
    required this.continueAdvancesFlow,
    required this.autoContinue,
    required this.progressionTarget,
    required this.primaryLabel,
    required this.showsRetrySecondary,
    required this.isPrimaryBusy,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    required this.onBackToMapPressed,
  });

  final bool outcomeVisible;
  final bool continueAdvancesFlow;
  final bool autoContinue;
  final World1CanonicalProgressionTargetV1 progressionTarget;
  final String primaryLabel;
  final bool showsRetrySecondary;
  final bool isPrimaryBusy;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final VoidCallback onBackToMapPressed;
}

World1SurfacedOutcomeProgressionHandoffContractV1
resolveWorld1SurfacedOutcomeRuntimeControllerV1(
  World1SurfacedOutcomeRuntimeControllerInputV1 input,
) {
  final outcomeLaneSemanticsV1 = World1OutcomeLaneSemanticsV1(
    primaryLabel: input.primaryLabel,
    showsRetrySecondary: input.showsRetrySecondary,
  );
  final localPolicyBoundary = buildWorld1CanonicalLocalPolicyBoundaryV1(
    outcomeVisible: input.outcomeVisible,
    continueAdvancesFlow: input.continueAdvancesFlow,
    progressionTarget: input.progressionTarget,
    primaryLabel: outcomeLaneSemanticsV1.primaryLabel,
    secondaryLabel: outcomeLaneSemanticsV1.secondaryLabel,
    isPrimaryBusy: input.isPrimaryBusy,
    onPrimaryPressed: input.onPrimaryPressed,
    onSecondaryPressed: input.onSecondaryPressed,
  );
  return World1SurfacedOutcomeProgressionHandoffContractV1(
    outcomeVisible: input.outcomeVisible,
    continueAdvancesFlow: input.continueAdvancesFlow,
    autoContinue: input.autoContinue,
    progressionTarget: input.progressionTarget,
    localPolicyBoundary: localPolicyBoundary,
    onBackToMapPressed: input.onBackToMapPressed,
  );
}
