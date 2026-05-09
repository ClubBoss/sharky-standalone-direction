import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_scene_support_lane_v1.dart';

class SurfacedLearnerHostShellContractV1 {
  const SurfacedLearnerHostShellContractV1({
    required this.outerPadding,
    required this.borderRadius,
    required this.shellGradientColors,
    required this.shadowColor,
    required this.shadowBlurRadius,
    required this.headerPadding,
    required this.header,
    required this.body,
    required this.bottomBandMaxHeight,
    required this.bottomBandPadding,
    required this.bottomBandSurfaceKey,
    required this.bottomBandCompact,
    required this.wrapBottomBandInSupportLane,
    required this.bottomBandSurfaceColor,
    required this.bottomBandBorderColor,
    required this.bottomBandChild,
    this.bottomBandSafeAreaMinimum = EdgeInsets.zero,
  });

  final EdgeInsets outerPadding;
  final BorderRadius borderRadius;
  final List<Color> shellGradientColors;
  final Color shadowColor;
  final double shadowBlurRadius;
  final EdgeInsets headerPadding;
  final Widget header;
  final Widget body;
  final double bottomBandMaxHeight;
  final EdgeInsets bottomBandPadding;
  final Key bottomBandSurfaceKey;
  final bool bottomBandCompact;
  final bool wrapBottomBandInSupportLane;
  final Color bottomBandSurfaceColor;
  final Color bottomBandBorderColor;
  final Widget? bottomBandChild;
  final EdgeInsets bottomBandSafeAreaMinimum;
}

class SurfacedLearnerHostShellV1 extends StatelessWidget {
  const SurfacedLearnerHostShellV1({super.key, required this.contract});

  final SurfacedLearnerHostShellContractV1 contract;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: contract.outerPadding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: contract.borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: contract.shellGradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: contract.shadowColor,
              blurRadius: contract.shadowBlurRadius,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(padding: contract.headerPadding, child: contract.header),
            Expanded(child: contract.body),
            if (contract.bottomBandChild != null)
              SafeArea(
                top: false,
                minimum: contract.bottomBandSafeAreaMinimum,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: contract.bottomBandMaxHeight,
                  ),
                  child: SingleChildScrollView(
                    padding: contract.bottomBandPadding,
                    child: contract.wrapBottomBandInSupportLane
                        ? RunnerSceneSupportLaneV1(
                            surfaceKey: contract.bottomBandSurfaceKey,
                            compact: contract.bottomBandCompact,
                            surfaceColor: contract.bottomBandSurfaceColor,
                            borderColor: contract.bottomBandBorderColor,
                            child: contract.bottomBandChild!,
                          )
                        : contract.bottomBandChild!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
