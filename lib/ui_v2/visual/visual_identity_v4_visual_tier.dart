import 'visual_identity_v4_style_skeleton.dart';

class VisualIdentityV4VisualTier {
  final String name;
  double radiusHint;
  double shadowHint;
  double contrastHint;
  double radiusDelta;
  double shadowDelta;
  double contrastDelta;
  double colorDelta;

  VisualIdentityV4VisualTier(
    this.name, {
    this.radiusHint = 0.0,
    this.shadowHint = 0.0,
    this.contrastHint = 0.0,
    this.radiusDelta = 0.0,
    this.shadowDelta = 0.0,
    this.contrastDelta = 0.0,
    this.colorDelta = 0.0,
  });

  void applySkeleton(VisualIdentityV4StyleSkeleton s) {
    radiusHint = s.radiusHint;
    shadowHint = s.shadowHint;
    contrastHint = s.contrastHint;
    radiusDelta = s.radiusDelta;
    shadowDelta = s.shadowDelta;
    contrastDelta = s.contrastDelta;
    colorDelta = s.colorDelta;
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
