import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_colors.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_scene_support_lane_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_composer_contract_v1.dart';

class World1CanonicalShellSlotsV1 {
  const World1CanonicalShellSlotsV1({
    required this.topShell,
    required this.portraitSupportContent,
    required this.landscapeSupportContent,
    required this.portraitActionSurface,
    required this.landscapeHostContent,
    required this.landscapeActionSurface,
  });

  final Widget? topShell;
  final World1LearnerHostSupportContentContractV1? portraitSupportContent;
  final World1LearnerHostSupportContentContractV1? landscapeSupportContent;
  final Widget? portraitActionSurface;
  final World1LearnerHostContentContractV1? landscapeHostContent;
  final Widget? landscapeActionSurface;
}

class World1CanonicalShellContractInputV1 {
  const World1CanonicalShellContractInputV1({
    required this.outerPadding,
    required this.shellBody,
    required this.portraitLayout,
    required this.compactPortrait,
    required this.shellSlots,
  });

  final EdgeInsets outerPadding;
  final Widget shellBody;
  final bool portraitLayout;
  final bool compactPortrait;
  final World1CanonicalShellSlotsV1 shellSlots;
}

class World1CanonicalShellContractResolvedV1 {
  const World1CanonicalShellContractResolvedV1({
    required this.outerPadding,
    required this.shellContract,
    required this.portraitOverlay,
  });

  final EdgeInsets outerPadding;
  final SurfacedLearnerHostShellContractV1 shellContract;
  final Widget? portraitOverlay;
}

World1CanonicalShellContractResolvedV1 resolveWorld1CanonicalShellContractV1(
  World1CanonicalShellContractInputV1 input,
) {
  final portraitSupportChild = input.shellSlots.portraitSupportContent?.child;
  final portraitActionSurface = input.shellSlots.portraitActionSurface;
  final usesCanonicalBottomBandV1 =
      input.shellSlots.topShell != null && input.portraitLayout;
  final portraitBottomBandChildV1 = usesCanonicalBottomBandV1
      ? _buildPortraitBottomBandChildV1(
          supportChild: portraitSupportChild,
          actionSurface: portraitActionSurface,
        )
      : null;
  return World1CanonicalShellContractResolvedV1(
    outerPadding: input.outerPadding,
    shellContract: SurfacedLearnerHostShellContractV1(
      outerPadding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(input.compactPortrait ? 20 : 18),
      shellGradientColors: usesCanonicalBottomBandV1
          ? <Color>[
              AppColors.darkCard.withOpacity(0.985),
              AppColors.surface.withOpacity(0.97),
            ]
          : const <Color>[Colors.transparent, Colors.transparent],
      shadowColor: usesCanonicalBottomBandV1
          ? AppColors.shadow.withOpacity(0.18)
          : Colors.transparent,
      shadowBlurRadius: usesCanonicalBottomBandV1 ? 14 : 0,
      headerPadding: usesCanonicalBottomBandV1
          ? const EdgeInsets.fromLTRB(8, 1, 8, 0)
          : EdgeInsets.zero,
      header: input.shellSlots.topShell ?? const SizedBox.shrink(),
      body: input.shellBody,
      bottomBandMaxHeight: usesCanonicalBottomBandV1
          ? (input.compactPortrait ? 176 : 220)
          : 0,
      bottomBandPadding: usesCanonicalBottomBandV1
          ? EdgeInsets.fromLTRB(10, input.compactPortrait ? 1 : 3, 10, 6)
          : EdgeInsets.zero,
      bottomBandSurfaceKey: const Key('microtask_scene_support_lane_v1'),
      bottomBandCompact: true,
      wrapBottomBandInSupportLane: usesCanonicalBottomBandV1,
      bottomBandSurfaceColor: usesCanonicalBottomBandV1
          ? SharkyTokensV1.surfaceCard.withOpacity(0.34)
          : Colors.transparent,
      bottomBandBorderColor: usesCanonicalBottomBandV1
          ? SharkyTokensV1.slate600.withOpacity(0.52)
          : Colors.transparent,
      bottomBandChild: portraitBottomBandChildV1,
    ),
    portraitOverlay: usesCanonicalBottomBandV1
        ? null
        : input.portraitLayout
        ? Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPortraitSupportOverlayV1(
              compactPortrait: input.compactPortrait,
              supportChild: portraitSupportChild,
              actionSurface: portraitActionSurface,
            ),
          )
        : null,
  );
}

Widget? _buildPortraitBottomBandChildV1({
  required Widget? supportChild,
  required Widget? actionSurface,
}) {
  if (supportChild == null && actionSurface == null) {
    return null;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (supportChild != null) supportChild,
      if (actionSurface != null) actionSurface,
    ],
  );
}

Widget _buildPortraitSupportOverlayV1({
  required bool compactPortrait,
  required Widget? supportChild,
  required Widget? actionSurface,
}) {
  if (supportChild == null) {
    return const SizedBox.shrink();
  }
  return SafeArea(
    top: false,
    minimum: const EdgeInsets.only(bottom: 2),
    child: Container(
      padding: EdgeInsets.fromLTRB(6, 4, 6, compactPortrait ? 2 : 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.background.withOpacity(0.0),
            AppColors.background.withOpacity(0.80),
            AppColors.background.withOpacity(0.95),
          ],
          stops: const <double>[0.0, 0.35, 1.0],
        ),
      ),
      child: RunnerSceneSupportLaneV1(
        surfaceKey: const Key('microtask_scene_support_lane_v1'),
        compact: true,
        surfaceColor: SharkyTokensV1.surfaceCard.withOpacity(0.34),
        borderColor: SharkyTokensV1.slate600.withOpacity(0.52),
        contentPadding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [supportChild, if (actionSurface != null) actionSurface],
        ),
      ),
    ),
  );
}
