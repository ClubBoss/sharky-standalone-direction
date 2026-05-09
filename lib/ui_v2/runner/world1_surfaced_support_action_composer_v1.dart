import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_spacing.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_family_extras_slots_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_teaching_section_stack_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_support_action_runtime_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/campaign_ui_kit_v1.dart';

class World1SurfacedLandscapeHostExtrasFeedV1 {
  const World1SurfacedLandscapeHostExtrasFeedV1({
    required this.showHintBubble,
    required this.hintText,
    required this.feedbackText,
    required this.outcomeVisible,
    required this.isCampaignSpineSession,
    required this.pulseFailure,
    required this.loopRewardBanner,
    required this.spineMistakesCount,
    required this.spineRankLabel,
    required this.packLabel,
    required this.outcomeLabel,
  });

  final bool showHintBubble;
  final String hintText;
  final String? feedbackText;
  final bool outcomeVisible;
  final bool isCampaignSpineSession;
  final bool pulseFailure;
  final String? loopRewardBanner;
  final int spineMistakesCount;
  final String spineRankLabel;
  final String packLabel;
  final String outcomeLabel;
}

class World1SurfacedSupportActionWidgetSlotsV1 {
  const World1SurfacedSupportActionWidgetSlotsV1({
    required this.portraitSeatQuizCoachStrip,
    required this.portraitHandLoopCoachStrip,
    required this.portraitOutcomeAction,
    required this.landscapeOutcomeAction,
    required this.portraitSeatQuizConfirmPanel,
    required this.landscapeSeatQuizConfirmPanel,
    required this.portraitHandLoopBar,
    required this.landscapeHandLoopBar,
    required this.landscapeOutcomeStatus,
  });

  final Widget? portraitSeatQuizCoachStrip;
  final Widget? portraitHandLoopCoachStrip;
  final Widget? portraitOutcomeAction;
  final Widget? landscapeOutcomeAction;
  final Widget? portraitSeatQuizConfirmPanel;
  final Widget? landscapeSeatQuizConfirmPanel;
  final Widget? portraitHandLoopBar;
  final Widget? landscapeHandLoopBar;
  final Widget? landscapeOutcomeStatus;
}

class World1SurfacedSupportActionComposerInputV1 {
  const World1SurfacedSupportActionComposerInputV1({
    required this.compactPortrait,
    required this.showHandLoopActionBar,
    required this.introCaptionActive,
    required this.feltInstructionVisible,
    required this.showBottomCoachStrip,
    required this.showSeatQuizPrelude,
    required this.introCaptionContinueOnPressed,
    required this.seatQuizIdleGuidanceText,
    required this.confirmGhostControlKey,
    required this.runtimeState,
    required this.landscapeExtrasFeed,
    required this.slots,
  });

  final bool compactPortrait;
  final bool showHandLoopActionBar;
  final bool introCaptionActive;
  final bool feltInstructionVisible;
  final bool showBottomCoachStrip;
  final bool showSeatQuizPrelude;
  final VoidCallback? introCaptionContinueOnPressed;
  final String seatQuizIdleGuidanceText;
  final Key confirmGhostControlKey;
  final World1SurfacedSupportActionRuntimeStateV1 runtimeState;
  final World1SurfacedLandscapeHostExtrasFeedV1 landscapeExtrasFeed;
  final World1SurfacedSupportActionWidgetSlotsV1 slots;
}

class World1SurfacedSupportActionComposerOutputV1 {
  const World1SurfacedSupportActionComposerOutputV1({
    required this.portraitSupportContent,
    required this.landscapeSupportContent,
    required this.portraitActionSurface,
    required this.landscapeActionSurface,
    required this.landscapeHostContent,
  });

  final World1LearnerHostSupportContentContractV1? portraitSupportContent;
  final World1LearnerHostSupportContentContractV1? landscapeSupportContent;
  final Widget? portraitActionSurface;
  final Widget? landscapeActionSurface;
  final World1LearnerHostContentContractV1 landscapeHostContent;
}

World1SurfacedSupportActionComposerOutputV1
resolveWorld1SurfacedSupportActionComposerV1(
  World1SurfacedSupportActionComposerInputV1 input,
) {
  return World1SurfacedSupportActionComposerOutputV1(
    portraitSupportContent: World1LearnerHostSupportContentContractV1(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: input.showHandLoopActionBar || input.showBottomCoachStrip
                ? 0
                : 18,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: input.runtimeState.showsPortraitIdleGuidance ? 1 : 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child:
                      input.introCaptionActive || input.feltInstructionVisible
                      ? const SizedBox.shrink()
                      : Text(
                          input.seatQuizIdleGuidanceText,
                          style: AppTypography.caption.copyWith(
                            color: SharkyTokensV1.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (input.runtimeState.showsPortraitSeatQuizCoachStrip &&
              input.slots.portraitSeatQuizCoachStrip != null)
            input.slots.portraitSeatQuizCoachStrip!,
          if (input.runtimeState.showsPortraitHandLoopCoachStrip &&
              input.slots.portraitHandLoopCoachStrip != null)
            input.slots.portraitHandLoopCoachStrip!,
        ],
      ),
    ),
    landscapeSupportContent: World1LearnerHostSupportContentContractV1(
      child: SharedLearnerTeachingSectionStackV1(
        preTeachingBlocks: <Widget>[
          SizedBox(
            height: 18,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: input.runtimeState.showsPortraitIdleGuidance ? 1 : 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: input.introCaptionActive || input.feltInstructionVisible
                    ? const SizedBox.shrink()
                    : Text(
                        input.seatQuizIdleGuidanceText,
                        style: AppTypography.caption.copyWith(
                          color: SharkyTokensV1.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
        teachingBlock: input.runtimeState.showsLandscapeOutcomeStatus
            ? input.slots.landscapeOutcomeStatus
            : null,
      ),
    ),
    portraitActionSurface: _resolvePortraitActionSurfaceV1(input),
    landscapeActionSurface: _resolveLandscapeActionSurfaceV1(input),
    landscapeHostContent: World1LearnerHostContentContractV1(
      extrasSlots: SharedLearnerFamilyExtrasSlotsV1(
        beforePrimaryActionChildren: <Widget>[
          if (input.landscapeExtrasFeed.showHintBubble) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              key: const Key('microtask_hint_bubble'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: SharkyTokensV1.semanticInfo.withOpacity(0.15),
                borderRadius: BorderRadius.circular(SharkyTokensV1.radiusMd),
                border: Border.all(
                  color: SharkyTokensV1.semanticInfo.withOpacity(0.8),
                ),
              ),
              child: Text(
                input.landscapeExtrasFeed.hintText,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textPrimary,
                ),
              ),
            ),
          ],
          if (input.landscapeExtrasFeed.feedbackText != null &&
              input.landscapeExtrasFeed.feedbackText!.trim().isNotEmpty &&
              !input.landscapeExtrasFeed.outcomeVisible) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              input.landscapeExtrasFeed.feedbackText!,
              maxLines: input.landscapeExtrasFeed.isCampaignSpineSession
                  ? 2
                  : null,
              overflow: input.landscapeExtrasFeed.isCampaignSpineSession
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              style: AppTypography.caption.copyWith(
                color: input.landscapeExtrasFeed.pulseFailure
                    ? SharkyTokensV1.semanticLoss
                    : SharkyTokensV1.textSecondary,
              ),
            ),
          ],
        ],
        afterPrimaryActionChildren: <Widget>[
          if (input.landscapeExtrasFeed.loopRewardBanner != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              key: const Key('microtask_loop_reward_banner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: SharkyTokensV1.semanticWin.withOpacity(0.16),
                borderRadius: BorderRadius.circular(SharkyTokensV1.radiusSm),
                border: Border.all(
                  color: SharkyTokensV1.semanticWin.withOpacity(0.8),
                ),
              ),
              child: Text(
                input.landscapeExtrasFeed.loopRewardBanner!,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: SharkyTokensV1.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
        buildPromptRevealExtraChildren: (sheetContext) {
          final detailTextStyle = AppTypography.caption.copyWith(
            color: SharkyTokensV1.textSecondary,
            height: 1.25,
          );
          return <Widget>[
            const SizedBox(height: 8),
            Text(
              'Mistakes: ${input.landscapeExtrasFeed.spineMistakesCount}',
              key: const Key('spine_calibration_mistakes_value'),
              style: detailTextStyle,
            ),
            Text(
              'Rank: ${input.landscapeExtrasFeed.spineRankLabel}',
              key: const Key('spine_rank_value'),
              style: detailTextStyle,
            ),
            Text(
              'Pack: ${input.landscapeExtrasFeed.packLabel}',
              key: const Key('spine_campaign_pack_id_value'),
              style: detailTextStyle,
            ),
            Text(
              'Outcome: ${input.landscapeExtrasFeed.outcomeLabel}',
              key: const Key('spine_outcome_value'),
              style: detailTextStyle,
            ),
          ];
        },
      ),
    ),
  );
}

Widget? _resolvePortraitActionSurfaceV1(
  World1SurfacedSupportActionComposerInputV1 input,
) {
  switch (input.runtimeState.portraitActionMode) {
    case World1SurfacedActionModeV1.introContinue:
      return IgnorePointer(
        ignoring: false,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 36,
                width: double.infinity,
                child: FilledButton(
                  key: input.showSeatQuizPrelude
                      ? const Key('microtask_prelude_continue_cta_v1')
                      : const Key('microtask_intro_continue_cta_v1'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(124, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 0,
                    ),
                    tapTargetSize: MaterialTapTargetSize.padded,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: input.introCaptionContinueOnPressed,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('CONTINUE', maxLines: 1, softWrap: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    case World1SurfacedActionModeV1.outcome:
      return input.slots.portraitOutcomeAction;
    case World1SurfacedActionModeV1.seatQuizConfirm:
      return input.slots.portraitSeatQuizConfirmPanel;
    case World1SurfacedActionModeV1.handLoopBar:
      return SizedBox(
        height: input.compactPortrait ? 56 : 62,
        child: input.slots.portraitHandLoopBar,
      );
    case World1SurfacedActionModeV1.hiddenConfirmGhost:
      return _buildHiddenConfirmGhostV1(input.confirmGhostControlKey);
    case World1SurfacedActionModeV1.none:
      return null;
  }
}

Widget? _resolveLandscapeActionSurfaceV1(
  World1SurfacedSupportActionComposerInputV1 input,
) {
  switch (input.runtimeState.landscapeActionMode) {
    case World1SurfacedActionModeV1.outcome:
      return input.slots.landscapeOutcomeAction;
    case World1SurfacedActionModeV1.seatQuizConfirm:
      return input.slots.landscapeSeatQuizConfirmPanel;
    case World1SurfacedActionModeV1.handLoopBar:
      return input.slots.landscapeHandLoopBar;
    case World1SurfacedActionModeV1.hiddenConfirmGhost:
      return _buildHiddenConfirmGhostV1(input.confirmGhostControlKey);
    case World1SurfacedActionModeV1.introContinue:
    case World1SurfacedActionModeV1.none:
      return null;
  }
}

Widget _buildHiddenConfirmGhostV1(Key controlKey) {
  return Opacity(
    opacity: 0,
    child: SizedBox(
      width: 1,
      height: 1,
      child: CampaignPrimaryCtaV1(
        controlKey: controlKey,
        onPressed: () {},
        label: 'CONFIRM',
        compact: true,
        microAnimationsEnabled: false,
      ),
    ),
  );
}
