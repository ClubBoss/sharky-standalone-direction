import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';

enum DrillHostCapabilityV1 {
  promptZone,
  promptDetailsReveal,
  embeddedTableZone,
  surfacedScenarioChrome,
  actionZone,
  seatTapInteraction,
  boardTapInteraction,
  holeCardsTapInteraction,
  handChainProgression,
  introSection,
  recapSection,
  sourceMetaSection,
  embeddedFeedbackBelowTable,
  completionContinuationZone,
}

enum DrillHostContinuationStyleV1 { inlineReset, completionSurface }

@immutable
class DrillHostCapabilityContractInputV1 {
  const DrillHostCapabilityContractInputV1({
    required this.sessionId,
    required this.spec,
    required this.currentDrillIndex,
    required this.currentChainStepIndex,
    required this.isCompleted,
    required this.showsSurfacedScenarioHostV1,
    required this.showsEmbeddedScenarioTableV1,
    this.sections = const RunnerHostSectionResponsibilityV1(),
  });

  final String sessionId;
  final DrillSpecV1 spec;
  final int currentDrillIndex;
  final int currentChainStepIndex;
  final bool isCompleted;
  final bool showsSurfacedScenarioHostV1;
  final bool showsEmbeddedScenarioTableV1;
  final RunnerHostSectionResponsibilityV1 sections;
}

@immutable
class DrillHostCapabilityContractV1 {
  const DrillHostCapabilityContractV1({
    required this.promptSourceId,
    required this.capabilities,
    required this.sections,
    required this.continuationStyle,
  });

  final String promptSourceId;
  final Set<DrillHostCapabilityV1> capabilities;
  final RunnerHostSectionResponsibilityV1 sections;
  final DrillHostContinuationStyleV1 continuationStyle;

  bool hasCapability(DrillHostCapabilityV1 capability) {
    return capabilities.contains(capability);
  }

  bool get showsEmbeddedScenarioTable =>
      hasCapability(DrillHostCapabilityV1.embeddedTableZone);
  bool get showsSurfacedScenarioHost =>
      hasCapability(DrillHostCapabilityV1.surfacedScenarioChrome);
  bool get showsActionZone => hasCapability(DrillHostCapabilityV1.actionZone);
  bool get showsCompletionContinuationSurface =>
      continuationStyle == DrillHostContinuationStyleV1.completionSurface;
}

DrillHostCapabilityContractV1 resolveDrillHostCapabilityContractV1(
  DrillHostCapabilityContractInputV1 input,
) {
  final capabilities = <DrillHostCapabilityV1>{
    DrillHostCapabilityV1.promptZone,
    DrillHostCapabilityV1.promptDetailsReveal,
  };
  if (input.showsEmbeddedScenarioTableV1) {
    capabilities.add(DrillHostCapabilityV1.embeddedTableZone);
  }
  if (input.showsSurfacedScenarioHostV1) {
    capabilities.add(DrillHostCapabilityV1.surfacedScenarioChrome);
  }
  if (input.sections.showIntro) {
    capabilities.add(DrillHostCapabilityV1.introSection);
  }
  if (input.sections.showRecap) {
    capabilities.add(DrillHostCapabilityV1.recapSection);
  }
  if (input.sections.showSourceMeta) {
    capabilities.add(DrillHostCapabilityV1.sourceMetaSection);
  }
  if (input.sections.showEmbeddedFeedbackBelowTable) {
    capabilities.add(DrillHostCapabilityV1.embeddedFeedbackBelowTable);
  }
  switch (input.spec.kind) {
    case DrillKindV1.seatTap:
      capabilities.add(DrillHostCapabilityV1.seatTapInteraction);
      break;
    case DrillKindV1.boardTap:
      capabilities.add(DrillHostCapabilityV1.boardTapInteraction);
      break;
    case DrillKindV1.holeCardsTap:
      capabilities.add(DrillHostCapabilityV1.holeCardsTapInteraction);
      break;
    case DrillKindV1.handChain:
      capabilities.add(DrillHostCapabilityV1.handChainProgression);
      if (!input.isCompleted) {
        capabilities.add(DrillHostCapabilityV1.actionZone);
      }
      break;
    case DrillKindV1.actionChoice:
    case DrillKindV1.betSizingChoice:
    case DrillKindV1.showdownWinnerChoice:
    case DrillKindV1.positionThinkingChoice:
    case DrillKindV1.initiativeAggressorChoice:
    case DrillKindV1.outsCountChoice:
    case DrillKindV1.boardTextureClassifier:
    case DrillKindV1.rangeBucketClassifier:
      if (!input.isCompleted) {
        capabilities.add(DrillHostCapabilityV1.actionZone);
      }
      break;
  }
  final continuationStyle = input.isCompleted
      ? DrillHostContinuationStyleV1.completionSurface
      : DrillHostContinuationStyleV1.inlineReset;
  if (continuationStyle == DrillHostContinuationStyleV1.completionSurface) {
    capabilities.add(DrillHostCapabilityV1.completionContinuationZone);
  }
  return DrillHostCapabilityContractV1(
    promptSourceId: switch (input.spec.kind) {
      DrillKindV1.handChain =>
        '${input.sessionId}#drill${input.currentDrillIndex + 1}#step${input.currentChainStepIndex + 1}',
      _ => '${input.sessionId}#drill${input.currentDrillIndex + 1}',
    },
    capabilities: Set<DrillHostCapabilityV1>.unmodifiable(capabilities),
    sections: input.sections,
    continuationStyle: continuationStyle,
  );
}
