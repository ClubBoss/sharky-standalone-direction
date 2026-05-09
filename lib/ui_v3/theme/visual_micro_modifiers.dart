import 'visual_theme_v3.dart';

class VisualMicroModifiers {
  VisualMicroModifiers(this.palette);

  final PersonalizationPalette palette;

  // TODO(Φ-AI): enable adaptive glow tuning here later.
  double scaleGlow(double baseGlow) => baseGlow;

  // TODO(Φ-AI): enable adaptive intensity tuning here later.
  double scaleIntensity(double baseIntensity) => baseIntensity;

  // TODO(Φ-AI): enable adaptive accent tuning here later.
  double applyAccentFactor(double baseAccent) => baseAccent;
}
