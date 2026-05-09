import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_host_section_responsibility_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_family_extras_slots_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_shell_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';

class World1SurfacedHeaderPromptInputV1 {
  const World1SurfacedHeaderPromptInputV1({
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

class World1SurfacedPresentationInputV1 {
  const World1SurfacedPresentationInputV1({
    required this.portraitLayout,
    required this.compactPortrait,
    required this.useRunnerCompactHeader,
    required this.useFeltOverlayAsPromptSource,
    required this.compactHeaderUnderFeedbackPressure,
    required this.collapsePortraitHeaderForFeltCaption,
    required this.currentModeIsSeatQuiz,
    required this.hideStepPromptInHeader,
    required this.showCompactInstructionOverlay,
    required this.showBottomCoachStrip,
    required this.mediaSize,
  });

  final bool portraitLayout;
  final bool compactPortrait;
  final bool useRunnerCompactHeader;
  final bool useFeltOverlayAsPromptSource;
  final bool compactHeaderUnderFeedbackPressure;
  final bool collapsePortraitHeaderForFeltCaption;
  final bool currentModeIsSeatQuiz;
  final bool hideStepPromptInHeader;
  final bool showCompactInstructionOverlay;
  final bool showBottomCoachStrip;
  final Size mediaSize;
}

class World1SurfacedCapabilityInputV1 {
  const World1SurfacedCapabilityInputV1({
    required this.promptSourceId,
    required this.showIntro,
    required this.showSourceMeta,
    required this.showRecap,
    required this.showCompletionInHeader,
    required this.showEmbeddedFeedbackBelowTable,
  });

  final String promptSourceId;
  final bool showIntro;
  final bool showSourceMeta;
  final bool showRecap;
  final bool showCompletionInHeader;
  final bool showEmbeddedFeedbackBelowTable;
}

class World1SurfacedRenderModelInputV1 {
  const World1SurfacedRenderModelInputV1({
    required this.headerPromptInput,
    required this.presentationInput,
    required this.capabilityInput,
    required this.outcomeProgressionHandoffContract,
    required this.shellSlots,
    required this.tableSection,
    required this.topPromptText,
    required this.detailsPrompt,
    required this.sessionTitle,
    required this.stepLabel,
    required this.outerPadding,
    required this.portraitLayout,
    required this.shellBody,
  });

  final World1SurfacedHeaderPromptInputV1 headerPromptInput;
  final World1SurfacedPresentationInputV1 presentationInput;
  final World1SurfacedCapabilityInputV1 capabilityInput;
  final World1SurfacedOutcomeProgressionHandoffContractV1
  outcomeProgressionHandoffContract;
  final World1CanonicalShellSlotsV1 shellSlots;
  final Widget tableSection;
  final String topPromptText;
  final String detailsPrompt;
  final String sessionTitle;
  final String stepLabel;
  final EdgeInsets outerPadding;
  final bool portraitLayout;
  final Widget shellBody;
}

class World1SurfacedRenderModelV1 {
  const World1SurfacedRenderModelV1({
    required this.headerPromptContract,
    required this.presentationContract,
    required this.capabilityContract,
    required this.pathWiringContract,
    required this.familyAdapter,
    required this.sharedShellPayload,
  });

  final World1SurfacedHeaderPromptContractV1 headerPromptContract;
  final World1SurfacedPresentationContractV1 presentationContract;
  final World1SurfacedCapabilityContractV1 capabilityContract;
  final World1SurfacedPathWiringContractV1 pathWiringContract;
  final World1SurfacedFamilyAdapterV1 familyAdapter;
  final World1SurfacedSharedShellPayloadContractV1 sharedShellPayload;
}

World1SurfacedSharedShellPayloadContractV1
resolveWorld1SurfacedSharedShellPayloadContractV1({
  required EdgeInsets outerPadding,
  required Widget shellBody,
  required bool portraitLayout,
  required bool compactPortrait,
  required World1CanonicalShellSlotsV1 shellSlots,
}) {
  return _resolveWorld1SurfacedSharedShellPayloadContractV1(
    outerPadding: outerPadding,
    shellBody: shellBody,
    portraitLayout: portraitLayout,
    compactPortrait: compactPortrait,
    shellSlots: shellSlots,
  );
}

World1SurfacedRenderModelV1 resolveWorld1SurfacedRenderModelV1(
  World1SurfacedRenderModelInputV1 input,
) {
  final headerPromptContract = World1SurfacedHeaderPromptContractV1(
    statusText: input.headerPromptInput.statusText,
    headlineText: input.headerPromptInput.headlineText,
    headerPromptText: input.headerPromptInput.headerPromptText,
    headerPromptKey: input.headerPromptInput.headerPromptKey,
    headerMaxLines: input.headerPromptInput.headerMaxLines,
    headerOverflow: input.headerPromptInput.headerOverflow,
    headerSoftWrap: input.headerPromptInput.headerSoftWrap,
    canOpenDetailsSheet: input.headerPromptInput.canOpenDetailsSheet,
  );
  final presentationContract = _resolveWorld1SurfacedPresentationContractV1(
    input.presentationInput,
  );
  final pathInputContract = _resolveWorld1SurfacedPathInputContractV1(
    headerPromptContract: headerPromptContract,
    shellSlots: input.shellSlots,
    tableSection: input.tableSection,
  );
  final capabilityContract = _resolveWorld1SurfacedCapabilityContractV1(
    input: input.capabilityInput,
    outcomeProgressionHandoffContract: input.outcomeProgressionHandoffContract,
    shellSlots: input.shellSlots,
  );
  final pathWiringContract = World1SurfacedPathWiringContractV1(
    capabilityContract: capabilityContract,
    headerPromptContract: headerPromptContract,
    presentationContract: presentationContract,
    outcomeProgressionHandoffContract: input.outcomeProgressionHandoffContract,
    pathInputContract: pathInputContract,
    topPromptText: input.topPromptText,
    detailsPrompt: input.detailsPrompt,
  );
  final resolver = World1SurfacedFamilyResolverV1(
    sections: capabilityContract.sections,
    promptSourceId: capabilityContract.promptSourceId,
    showsActionZone: capabilityContract.showsActionZone,
    showsCompletionContinuationSurface:
        capabilityContract.showsCompletionContinuationSurface,
  );
  final familyAdapter = World1SurfacedFamilyAdapterV1(
    sessionTitle: input.sessionTitle,
    stepLabel: input.stepLabel,
    promptStatusText: headerPromptContract.statusText ?? input.sessionTitle,
    prompt: input.detailsPrompt,
    compactPromptText: input.topPromptText,
    resolver: resolver,
    headerPromptContract: headerPromptContract,
    presentationContract: presentationContract,
    outcomeProgressionHandoffContract: input.outcomeProgressionHandoffContract,
    pathInputContract: pathInputContract,
  );
  final sharedShellPayload = _resolveWorld1SurfacedSharedShellPayloadContractV1(
    outerPadding: input.outerPadding,
    shellBody: input.shellBody,
    portraitLayout: input.portraitLayout,
    compactPortrait: input.presentationInput.compactPortrait,
    shellSlots: input.shellSlots,
  );
  return World1SurfacedRenderModelV1(
    headerPromptContract: headerPromptContract,
    presentationContract: presentationContract,
    capabilityContract: capabilityContract,
    pathWiringContract: pathWiringContract,
    familyAdapter: familyAdapter,
    sharedShellPayload: sharedShellPayload,
  );
}

World1SurfacedPathInputContractV1 _resolveWorld1SurfacedPathInputContractV1({
  required World1SurfacedHeaderPromptContractV1 headerPromptContract,
  required World1CanonicalShellSlotsV1 shellSlots,
  required Widget tableSection,
}) {
  final landscapeHostContent =
      shellSlots.landscapeHostContent ??
      const World1LearnerHostContentContractV1(
        extrasSlots: SharedLearnerFamilyExtrasSlotsV1.empty(),
      );
  return World1SurfacedPathInputContractV1(
    headerPrompt: headerPromptContract,
    tableSection: tableSection,
    portraitSupportContent: shellSlots.portraitSupportContent,
    landscapeSupportContent: shellSlots.landscapeSupportContent,
    extrasSlots: landscapeHostContent.extrasSlots,
    actionSurface: shellSlots.landscapeActionSurface,
  );
}

World1SurfacedCapabilityContractV1 _resolveWorld1SurfacedCapabilityContractV1({
  required World1SurfacedCapabilityInputV1 input,
  required World1SurfacedOutcomeProgressionHandoffContractV1
  outcomeProgressionHandoffContract,
  required World1CanonicalShellSlotsV1 shellSlots,
}) {
  final showsActionZone =
      shellSlots.portraitActionSurface != null ||
      shellSlots.landscapeActionSurface != null;
  return World1SurfacedCapabilityContractV1(
    promptSourceId: input.promptSourceId,
    sections: RunnerHostSectionResponsibilityV1(
      showIntro: input.showIntro,
      showSourceMeta: input.showSourceMeta,
      showRecap: input.showRecap,
      showCompletionInHeader: input.showCompletionInHeader,
      showEmbeddedFeedbackBelowTable: input.showEmbeddedFeedbackBelowTable,
    ),
    showsActionZone: showsActionZone,
    showsCompletionContinuationSurface:
        outcomeProgressionHandoffContract.outcomeVisible,
  );
}

World1SurfacedPresentationContractV1
_resolveWorld1SurfacedPresentationContractV1(
  World1SurfacedPresentationInputV1 input,
) {
  final promptSourceMode = input.useFeltOverlayAsPromptSource
      ? World1SurfacedPromptSourceModeV1.feltOverlay
      : World1SurfacedPromptSourceModeV1.headerPrompt;
  final supportPlacementMode = input.portraitLayout
      ? World1SurfacedSupportPlacementModeV1.portraitBottomOverlay
      : World1SurfacedSupportPlacementModeV1.landscapeBelowTable;
  final promptStripHeight =
      input.portraitLayout &&
          !input.useFeltOverlayAsPromptSource &&
          !(input.useRunnerCompactHeader && input.compactPortrait)
      ? 20.0
      : 0.0;
  final pinnedBarHeight = input.portraitLayout ? 76.0 : 0.0;
  final pinnedOverlayReserveHeight = input.portraitLayout
      ? (promptStripHeight + pinnedBarHeight)
      : 0.0;
  final topPanelHeightFactor = input.useRunnerCompactHeader
      ? (input.compactHeaderUnderFeedbackPressure
            ? (input.compactPortrait ? 0.05 : 0.056)
            : (input.compactPortrait ? 0.055 : 0.062))
      : (input.collapsePortraitHeaderForFeltCaption
            ? (input.currentModeIsSeatQuiz
                  ? (input.compactPortrait ? 0.084 : 0.09)
                  : (input.compactPortrait ? 0.08 : 0.086))
            : (input.currentModeIsSeatQuiz ? 0.12 : 0.11));
  final topPanelMinHeight = input.useRunnerCompactHeader
      ? (input.compactHeaderUnderFeedbackPressure
            ? (input.compactPortrait ? 34.0 : 38.0)
            : (input.compactPortrait ? 38.0 : 42.0))
      : (input.collapsePortraitHeaderForFeltCaption
            ? (input.compactPortrait ? 46.0 : 52.0)
            : 64.0);
  final topPanelUpperHeight = input.useRunnerCompactHeader
      ? (input.compactHeaderUnderFeedbackPressure
            ? (input.compactPortrait ? 38.0 : 42.0)
            : (input.compactPortrait ? 40.0 : 46.0))
      : (input.collapsePortraitHeaderForFeltCaption
            ? (input.compactPortrait ? 58.0 : 72.0)
            : (input.compactPortrait ? 108.0 : 138.0));
  final topPanelMaxHeight = input.portraitLayout
      ? (input.mediaSize.height * topPanelHeightFactor).clamp(
          topPanelMinHeight,
          topPanelUpperHeight,
        )
      : topPanelUpperHeight;
  final topPanelConstraints = input.portraitLayout
      ? BoxConstraints(
          minHeight: topPanelMaxHeight,
          maxHeight: topPanelMaxHeight,
        )
      : BoxConstraints(maxHeight: topPanelMaxHeight);
  return World1SurfacedPresentationContractV1(
    layoutMode: input.portraitLayout
        ? World1SurfacedLayoutModeV1.portrait
        : World1SurfacedLayoutModeV1.landscape,
    compactPortrait: input.compactPortrait,
    usesCompactHeader: input.useRunnerCompactHeader,
    promptSourceMode: promptSourceMode,
    supportPlacementMode: supportPlacementMode,
    hidesStepPromptInHeader: input.hideStepPromptInHeader,
    showsCompactInstructionOverlay: input.showCompactInstructionOverlay,
    showsBottomCoachStrip: input.showBottomCoachStrip,
    promptStripHeight: promptStripHeight,
    pinnedBarHeight: pinnedBarHeight,
    pinnedOverlayReserveHeight: pinnedOverlayReserveHeight,
    topPanelConstraints: topPanelConstraints,
  );
}

World1SurfacedSharedShellPayloadContractV1
_resolveWorld1SurfacedSharedShellPayloadContractV1({
  required EdgeInsets outerPadding,
  required Widget shellBody,
  required bool portraitLayout,
  required bool compactPortrait,
  required World1CanonicalShellSlotsV1 shellSlots,
}) {
  final resolved = resolveWorld1CanonicalShellContractV1(
    World1CanonicalShellContractInputV1(
      outerPadding: outerPadding,
      shellBody: shellBody,
      portraitLayout: portraitLayout,
      compactPortrait: compactPortrait,
      shellSlots: shellSlots,
    ),
  );
  return World1SurfacedSharedShellPayloadContractV1(
    outerPadding: resolved.outerPadding,
    shellContract: resolved.shellContract,
    portraitOverlay: resolved.portraitOverlay,
  );
}
