import 'package:flutter/widgets.dart'
    show
        Widget,
        StatelessWidget,
        Stack,
        Opacity,
        ColoredBox,
        Color,
        ClipRRect,
        BorderRadius,
        Key,
        BuildContext;

import 'color_cue_model_v1.dart';
import 'color_compute_model_v1.dart';
import 'color_strength_integrator_v3.dart';

class ColorOverlayContainerV1 extends StatelessWidget {
  const ColorOverlayContainerV1({
    Key? key,
    required this.child,
    this.colorModel,
    this.enabled,
    this.colorCompute,
    this.compositeColorStrength,
    this.finalColorDelta,
    this.strengthIntegratorV3,
  }) : super(key: key);

  final Widget child;
  final ColorCueModelV1? colorModel;
  final bool? enabled;
  final ColorComputeModelV1? colorCompute;
  final double? compositeColorStrength;
  final double? finalColorDelta;
  final ColorStrengthIntegratorV3? strengthIntegratorV3;

  void handshakeIntegrator(ColorStrengthIntegratorV3? integrator) {
    // TODO Phase-5 lock handshake
  }

  @override
  Widget build(BuildContext context) {
    final double effectiveColorStrength = (compositeColorStrength ?? 0.0).clamp(
      0.0,
      1.0,
    );
    final double effectiveColorStrengthV2 = (compositeColorStrength ?? 0.0)
        .clamp(0.0, 1.0); // TODO Phase-5: V2 shaping here

    if (enabled == true && colorModel?.hueShift != null) {
      final compositeStrength = effectiveColorStrength;
      final strength = (compositeStrength * 0.15).clamp(0.0, 0.15);
      final overlayColor =
          colorCompute?.mapHueToDevColor(colorModel!.hueShift!) ??
          const Color(0xFFFF0000);
      return Stack(
        children: [
          child,
          Opacity(
            opacity: strength,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ColoredBox(color: overlayColor),
            ),
          ),
          Opacity(
            opacity: (strength * 0.25).clamp(0.0, 0.08),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(color: overlayColor),
            ),
          ),
        ],
      );
    }
    return child;
  }
}
