import 'visual_identity_v4_surface_tier.dart';

class VisualIdentityV4RoleResolution {
  VisualIdentityV4RoleResolution(this.roleToSurface);

  final Map<String, String> roleToSurface;

  double radiusHint = 0.0;
  double shadowHint = 0.0;
  double contrastHint = 0.0;
  double radiusDelta = 0.0;
  double shadowDelta = 0.0;
  double contrastDelta = 0.0;
  double colorDelta = 0.0;

  String? resolve(String roleName) {
    return roleToSurface[roleName];
  }

  void applySurfaceTier(VisualIdentityV4SurfaceTier s) {
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
      'roleMappings': roleToSurface,
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
