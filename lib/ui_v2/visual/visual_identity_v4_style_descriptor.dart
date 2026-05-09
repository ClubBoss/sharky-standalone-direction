class VisualIdentityV4StyleDescriptor {
  final String tierName;
  final double radiusHint;
  final double shadowHint;
  final double contrastHint;
  final double radiusDelta;
  final double shadowDelta;
  final double contrastDelta;
  final double colorDelta;

  const VisualIdentityV4StyleDescriptor(
    this.tierName, {
    this.radiusHint = 0.0,
    this.shadowHint = 0.0,
    this.contrastHint = 0.0,
    this.radiusDelta = 0.0,
    this.shadowDelta = 0.0,
    this.contrastDelta = 0.0,
    this.colorDelta = 0.0,
  });

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
