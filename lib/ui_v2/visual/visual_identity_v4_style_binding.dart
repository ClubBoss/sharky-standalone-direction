import 'visual_identity_v4_style_skeleton.dart';

class VisualIdentityV4StyleBinding {
  final String tierName;
  double radiusHint;
  double shadowHint;
  double contrastHint;
  double radiusDelta;
  double shadowDelta;
  double contrastDelta;
  double colorDelta;

  VisualIdentityV4StyleBinding(
    this.tierName, {
    this.radiusHint = 0.0,
    this.shadowHint = 0.0,
    this.contrastHint = 0.0,
    this.radiusDelta = 0.0,
    this.shadowDelta = 0.0,
    this.contrastDelta = 0.0,
    this.colorDelta = 0.0,
  });

  void applyRoleResolution(VisualIdentityV4RoleResolution r) {
    radiusHint = r.radiusHint;
    shadowHint = r.shadowHint;
    contrastHint = r.contrastHint;
    radiusDelta = r.radiusDelta;
    shadowDelta = r.shadowDelta;
    contrastDelta = r.contrastDelta;
    colorDelta = r.colorDelta;
  }

  Map<String, dynamic> export() {
    return {
      'tierName': tierName,
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
