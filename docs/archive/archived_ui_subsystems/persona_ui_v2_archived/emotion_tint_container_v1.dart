import 'package:flutter/widgets.dart';

class EmotionTintContainerV1 extends StatelessWidget {
  const EmotionTintContainerV1({
    Key? key,
    required this.child,
    this.tintStrength,
    this.enabled,
    this.warmth,
    this.sharpness,
    this.intensity,
    this.compositeStrength,
    this.compositeBlendFactor,
    this.devUseCompositeTint,
  }) : super(key: key);

  final Widget child;
  final double? tintStrength;
  final bool? enabled;
  final double? warmth;
  final double? sharpness;
  final double? intensity;
  final double? compositeStrength;
  final double? compositeBlendFactor;
  final bool? devUseCompositeTint;

  @override
  Widget build(BuildContext context) {
    double effectiveStrength = devUseCompositeTint == true
        ? (compositeStrength ?? 0.0)
        : tintFactor;
    final double base = effectiveStrength;
    final double? blend = compositeBlendFactor;
    if (devUseCompositeTint == true && blend != null) {
      effectiveStrength = _blendStrength(
        base,
        (compositeStrength ?? tintFactor),
        blend,
      );
    }

    if (enabled == true && effectiveStrength > 0.0) {
      return Opacity(
        opacity: (1.0 - effectiveStrength.clamp(0.0, 1.0)),
        child: child,
      );
    }
    return child;
  }

  double _computeTintFactor(double? strength) {
    if (strength == null) return 0.0;
    if (strength < 0.0) return 0.0;
    return strength;
  }

  double get tintFactor => _computeTintFactor(tintStrength);

  double _blendStrength(double base, double composite, double? blend) {
    // TODO Phase-4.2 blending logic
    if (blend == null) return base;
    final b = blend.clamp(0.0, 1.0);
    return base + (composite - base) * b;
  }
}
