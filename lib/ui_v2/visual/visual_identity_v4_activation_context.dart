class V4IdentityActivationContext {
  final Map<String, dynamic> activationFlag;
  final Map<String, dynamic> readinessGate;
  final Map<String, dynamic> activationHandshake;
  final Map<String, dynamic> previewSnapshot;
  final Map<String, String> previewConsistency;
  final Map<String, dynamic>? readinessSynthesis;
  final Map<String, dynamic>? chainCompleteness;
  final Map<String, dynamic>? preflightBundle;
  final Map<String, dynamic>? effectiveStyle;

  const V4IdentityActivationContext({
    required this.activationFlag,
    required this.readinessGate,
    required this.activationHandshake,
    required this.previewSnapshot,
    required this.previewConsistency,
    required this.readinessSynthesis,
    required this.chainCompleteness,
    required this.preflightBundle,
    required this.effectiveStyle,
  });

  Map<String, dynamic> export() {
    return {
      'activationFlag': activationFlag,
      'readinessGate': readinessGate,
      'activationHandshake': activationHandshake,
      'previewSnapshot': previewSnapshot,
      'previewConsistency': previewConsistency,
      'readinessSynthesis': readinessSynthesis,
      'chainCompleteness': chainCompleteness,
      'preflightBundle': preflightBundle,
      'effectiveStyle': effectiveStyle,
    };
  }
}
