class V4IdentityEvaluationContext {
  Map<String, String>? chainStatus;
  Map<String, String>? completeness;
  Map<String, String>? globalQA;
  Map<String, String>? integrity;
  Map<String, String>? preflightBundle;

  String? descriptor;
  String? skeleton;
  String? visualTier;
  String? surfaceTier;
  String? roleResolution;
  String? hydratedDescriptor;
  String? styleBinding;

  Map<String, String> export() {
    return {
      'v4_identity_evaluation_context': 'ok',
      if (chainStatus != null) ...chainStatus!,
      if (completeness != null) ...completeness!,
      if (globalQA != null) ...globalQA!,
      if (integrity != null) ...integrity!,
      if (preflightBundle != null) ...preflightBundle!,
      if (descriptor != null) 'descriptor': descriptor!,
      if (skeleton != null) 'skeleton': skeleton!,
      if (visualTier != null) 'visualTier': visualTier!,
      if (surfaceTier != null) 'surfaceTier': surfaceTier!,
      if (roleResolution != null) 'roleResolution': roleResolution!,
      if (hydratedDescriptor != null) 'hydratedDescriptor': hydratedDescriptor!,
      if (styleBinding != null) 'styleBinding': styleBinding!,
    };
  }
}
