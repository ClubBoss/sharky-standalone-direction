import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_table_adjacent_frame_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_top_level_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/surfaced_learner_host_shell_v1.dart';

class SharedLearnerCanonicalConsumerPathV1 extends StatelessWidget {
  const SharedLearnerCanonicalConsumerPathV1({
    super.key,
    required this.shellContract,
    this.topLevelShellContract,
    this.frameTopRegion,
    required this.frameViewportRegion,
    this.frameBottomRegion,
    this.overlayChild,
  });

  final SurfacedLearnerHostShellContractV1 shellContract;
  final SharedLearnerTopLevelShellContractV1? topLevelShellContract;
  final Widget? frameTopRegion;
  final Widget frameViewportRegion;
  final Widget? frameBottomRegion;
  final Widget? overlayChild;

  @override
  Widget build(BuildContext context) {
    final shell = SurfacedLearnerHostShellV1(
      contract: SurfacedLearnerHostShellContractV1(
        outerPadding: shellContract.outerPadding,
        borderRadius: shellContract.borderRadius,
        shellGradientColors: shellContract.shellGradientColors,
        shadowColor: shellContract.shadowColor,
        shadowBlurRadius: shellContract.shadowBlurRadius,
        headerPadding: shellContract.headerPadding,
        header: shellContract.header,
        body: SharedLearnerTableAdjacentFrameV1(
          topRegion: frameTopRegion,
          viewportRegion: frameViewportRegion,
          bottomRegion: frameBottomRegion,
        ),
        bottomBandMaxHeight: shellContract.bottomBandMaxHeight,
        bottomBandPadding: shellContract.bottomBandPadding,
        bottomBandSurfaceKey: shellContract.bottomBandSurfaceKey,
        bottomBandCompact: shellContract.bottomBandCompact,
        wrapBottomBandInSupportLane: shellContract.wrapBottomBandInSupportLane,
        bottomBandSurfaceColor: shellContract.bottomBandSurfaceColor,
        bottomBandBorderColor: shellContract.bottomBandBorderColor,
        bottomBandChild: shellContract.bottomBandChild,
        bottomBandSafeAreaMinimum: shellContract.bottomBandSafeAreaMinimum,
      ),
    );
    if (overlayChild == null) {
      if (topLevelShellContract == null) {
        return shell;
      }
      return SharedLearnerTopLevelShellV1(
        contract: topLevelShellContract!,
        child: shell,
      );
    }
    final stackedShell = Stack(children: [shell, overlayChild!]);
    if (topLevelShellContract == null) {
      return stackedShell;
    }
    return SharedLearnerTopLevelShellV1(
      contract: topLevelShellContract!,
      child: stackedShell,
    );
  }
}
