class V4IdentityPreviewSnapshot {
  final Map<String, dynamic> effectiveStyle;
  final Map<String, dynamic> previewEnforcement;
  final Map<String, dynamic> readiness;
  final Map<String, dynamic> chain;
  final Map<String, dynamic> completeness;
  final Map<String, dynamic> cohesion;
  final Map<String, dynamic> preflight;

  const V4IdentityPreviewSnapshot({
    required this.effectiveStyle,
    required this.previewEnforcement,
    required this.readiness,
    required this.chain,
    required this.completeness,
    required this.cohesion,
    required this.preflight,
  });

  Map<String, dynamic> export() {
    return {
      'effectiveStyle': effectiveStyle,
      'previewEnforcement': previewEnforcement,
      'readiness': readiness,
      'chain': chain,
      'completeness': completeness,
      'cohesion': cohesion,
      'preflight': preflight,
    };
  }
}
