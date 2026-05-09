class VisualIdentityV4RoleResolution {
  double radiusHint = 0.0;
  double shadowHint = 0.0;
  double contrastHint = 0.0;
  double radiusDelta = 0.0;
  double shadowDelta = 0.0;
  double contrastDelta = 0.0;
  double colorDelta = 0.0;
}

class VisualIdentityV4StyleDescriptor {
  double radiusHint = 0.0;
  double shadowHint = 0.0;
  double contrastHint = 0.0;
  double radiusDelta = 0.0;
  double shadowDelta = 0.0;
  double contrastDelta = 0.0;
  double colorDelta = 0.0;
}

class VisualIdentityV4VisualTier {}

class VisualIdentityV4StyleSkeleton {
  final String tierName;
  double radiusHint;
  double shadowHint;
  double contrastHint;
  double radiusDelta;
  double shadowDelta;
  double contrastDelta;
  double colorDelta;
  double unifiedRadius;
  double unifiedShadow;
  double unifiedContrast;
  double unifiedColor;

  VisualIdentityV4StyleSkeleton(
    this.tierName, {
    this.radiusHint = 0.0,
    this.shadowHint = 0.0,
    this.contrastHint = 0.0,
    this.radiusDelta = 0.0,
    this.shadowDelta = 0.0,
    this.contrastDelta = 0.0,
    this.colorDelta = 0.0,
    this.unifiedRadius = 0.0,
    this.unifiedShadow = 0.0,
    this.unifiedContrast = 0.0,
    this.unifiedColor = 0.0,
  });

  void applyDescriptor(VisualIdentityV4StyleDescriptor d) {
    radiusHint = d.radiusHint;
    shadowHint = d.shadowHint;
    contrastHint = d.contrastHint;
    radiusDelta = d.radiusDelta;
    shadowDelta = d.shadowDelta;
    contrastDelta = d.contrastDelta;
    colorDelta = d.colorDelta;
    unifiedRadius = radiusDelta;
    unifiedShadow = shadowDelta;
    unifiedContrast = contrastDelta;
    unifiedColor = colorDelta;
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
      'unifiedRadius': unifiedRadius,
      'unifiedShadow': unifiedShadow,
      'unifiedContrast': unifiedContrast,
      'unifiedColor': unifiedColor,
    };
  }
}
