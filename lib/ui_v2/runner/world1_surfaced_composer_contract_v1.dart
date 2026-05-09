import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_family_extras_slots_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_local_policy_boundary_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_progression_handoff_v1.dart';

class World1LearnerHostSupportContentContractV1 {
  const World1LearnerHostSupportContentContractV1({required this.child});

  final Widget child;
}

class World1LearnerHostContentContractV1 {
  const World1LearnerHostContentContractV1({required this.extrasSlots});

  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
}

class World1SurfacedHeaderPromptContractV1 {
  const World1SurfacedHeaderPromptContractV1({
    required this.statusText,
    required this.headlineText,
    required this.headerPromptText,
    required this.headerPromptKey,
    required this.headerMaxLines,
    required this.headerOverflow,
    required this.headerSoftWrap,
    required this.canOpenDetailsSheet,
  });

  final String? statusText;
  final String headlineText;
  final String headerPromptText;
  final Key headerPromptKey;
  final int headerMaxLines;
  final TextOverflow headerOverflow;
  final bool headerSoftWrap;
  final bool canOpenDetailsSheet;
}

class World1SurfacedPathInputContractV1 {
  const World1SurfacedPathInputContractV1({
    required this.headerPrompt,
    required this.tableSection,
    required this.portraitSupportContent,
    required this.landscapeSupportContent,
    required this.extrasSlots,
    required this.actionSurface,
  });

  final World1SurfacedHeaderPromptContractV1 headerPrompt;
  final Widget tableSection;
  final World1LearnerHostSupportContentContractV1? portraitSupportContent;
  final World1LearnerHostSupportContentContractV1? landscapeSupportContent;
  final SharedLearnerFamilyExtrasSlotsV1 extrasSlots;
  final Widget? actionSurface;
}

class World1SurfacedPathWiringContractV1 {
  const World1SurfacedPathWiringContractV1({
    required this.capabilityContract,
    required this.headerPromptContract,
    required this.presentationContract,
    required this.outcomeProgressionHandoffContract,
    required this.pathInputContract,
    required this.topPromptText,
    required this.detailsPrompt,
  });

  final World1SurfacedCapabilityContractV1 capabilityContract;
  final World1SurfacedHeaderPromptContractV1 headerPromptContract;
  final World1SurfacedPresentationContractV1 presentationContract;
  final World1SurfacedOutcomeProgressionHandoffContractV1
  outcomeProgressionHandoffContract;
  final World1SurfacedPathInputContractV1 pathInputContract;
  final String topPromptText;
  final String detailsPrompt;
}

class World1SurfacedCapabilityContractV1 {
  const World1SurfacedCapabilityContractV1({
    required this.promptSourceId,
    required this.sections,
    required this.showsActionZone,
    required this.showsCompletionContinuationSurface,
  });

  final String promptSourceId;
  final RunnerHostSectionResponsibilityV1 sections;
  final bool showsActionZone;
  final bool showsCompletionContinuationSurface;
}

class World1SurfacedFamilyResolverV1 {
  const World1SurfacedFamilyResolverV1({
    required this.sections,
    required this.promptSourceId,
    required this.showsActionZone,
    required this.showsCompletionContinuationSurface,
  });

  final RunnerHostSectionResponsibilityV1 sections;
  final String promptSourceId;
  final bool showsActionZone;
  final bool showsCompletionContinuationSurface;
}

class World1SurfacedFamilyAdapterV1 {
  const World1SurfacedFamilyAdapterV1({
    required this.sessionTitle,
    required this.stepLabel,
    required this.promptStatusText,
    required this.prompt,
    required this.compactPromptText,
    required this.resolver,
    required this.headerPromptContract,
    required this.presentationContract,
    required this.outcomeProgressionHandoffContract,
    required this.pathInputContract,
  });

  final String sessionTitle;
  final String stepLabel;
  final String promptStatusText;
  final String prompt;
  final String compactPromptText;
  final World1SurfacedFamilyResolverV1 resolver;
  final World1SurfacedHeaderPromptContractV1 headerPromptContract;
  final World1SurfacedPresentationContractV1 presentationContract;
  final World1SurfacedOutcomeProgressionHandoffContractV1
  outcomeProgressionHandoffContract;
  final World1SurfacedPathInputContractV1 pathInputContract;
}

class World1SurfacedSharedShellPayloadContractV1 {
  const World1SurfacedSharedShellPayloadContractV1({
    required this.outerPadding,
    required this.shellContract,
    required this.portraitOverlay,
  });

  final EdgeInsets outerPadding;
  final SurfacedLearnerHostShellContractV1 shellContract;
  final Widget? portraitOverlay;
}

class World1SurfacedOutcomeProgressionHandoffContractV1 {
  const World1SurfacedOutcomeProgressionHandoffContractV1({
    required this.outcomeVisible,
    required this.continueAdvancesFlow,
    required this.autoContinue,
    required this.progressionTarget,
    required this.localPolicyBoundary,
    required this.onBackToMapPressed,
  });

  final bool outcomeVisible;
  final bool continueAdvancesFlow;
  final bool autoContinue;
  final World1CanonicalProgressionTargetV1 progressionTarget;
  final SharedLearnerLocalPolicyBoundaryV1 localPolicyBoundary;
  final VoidCallback onBackToMapPressed;
}

enum World1SurfacedLayoutModeV1 { portrait, landscape }

enum World1SurfacedPromptSourceModeV1 { headerPrompt, feltOverlay }

enum World1SurfacedSupportPlacementModeV1 {
  portraitBottomOverlay,
  landscapeBelowTable,
}

class World1SurfacedPresentationContractV1 {
  const World1SurfacedPresentationContractV1({
    required this.layoutMode,
    required this.compactPortrait,
    required this.usesCompactHeader,
    required this.promptSourceMode,
    required this.supportPlacementMode,
    required this.hidesStepPromptInHeader,
    required this.showsCompactInstructionOverlay,
    required this.showsBottomCoachStrip,
    required this.promptStripHeight,
    required this.pinnedBarHeight,
    required this.pinnedOverlayReserveHeight,
    required this.topPanelConstraints,
  });

  final World1SurfacedLayoutModeV1 layoutMode;
  final bool compactPortrait;
  final bool usesCompactHeader;
  final World1SurfacedPromptSourceModeV1 promptSourceMode;
  final World1SurfacedSupportPlacementModeV1 supportPlacementMode;
  final bool hidesStepPromptInHeader;
  final bool showsCompactInstructionOverlay;
  final bool showsBottomCoachStrip;
  final double promptStripHeight;
  final double pinnedBarHeight;
  final double pinnedOverlayReserveHeight;
  final BoxConstraints topPanelConstraints;
}
