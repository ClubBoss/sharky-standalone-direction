import 'visual_identity_v4_visual_tier.dart';

class VisualIdentityV4SurfaceTier {
  final String name;
  double radiusHint;
  double shadowHint;
  double contrastHint;
  double radiusDelta;
  double shadowDelta;
  double contrastDelta;
  double colorDelta;

  VisualIdentityV4SurfaceTier(
    this.name, {
    this.radiusHint = 0.0,
    this.shadowHint = 0.0,
    this.contrastHint = 0.0,
    this.radiusDelta = 0.0,
    this.shadowDelta = 0.0,
    this.contrastDelta = 0.0,
    this.colorDelta = 0.0,
  });

  void applyVisualTier(VisualIdentityV4VisualTier v) {
    radiusHint = v.radiusHint;
    shadowHint = v.shadowHint;
    contrastHint = v.contrastHint;
    radiusDelta = v.radiusDelta;
    shadowDelta = v.shadowDelta;
    contrastDelta = v.contrastDelta;
    colorDelta = v.colorDelta;
  }

  Map<String, dynamic> export() {
    return {
      'name': name,
      'radiusHint': radiusHint,
      'shadowHint': shadowHint,
      'contrastHint': contrastHint,
      'radiusDelta': radiusDelta,
      'shadowDelta': shadowDelta,
      'contrastDelta': contrastDelta,
      'colorDelta': colorDelta,
    };
  }
}
