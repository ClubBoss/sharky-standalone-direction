class V4IdentityPreflightManifest {
  const V4IdentityPreflightManifest();

  Map<String, String> export({
    Map<String, String>? digest,
    String? descriptor,
    String? skeleton,
    String? visualTier,
    String? surfaceTier,
    String? roleResolution,
    String? hydratedDescriptor,
    String? styleBinding,
  }) {
    return {
      'v4_identity_preflight_manifest': 'ok',
      if (digest != null) ...digest,
      if (descriptor != null) 'descriptor': descriptor,
      if (skeleton != null) 'skeleton': skeleton,
      if (visualTier != null) 'visualTier': visualTier,
      if (surfaceTier != null) 'surfaceTier': surfaceTier,
      if (roleResolution != null) 'roleResolution': roleResolution,
      if (hydratedDescriptor != null) 'hydratedDescriptor': hydratedDescriptor,
      if (styleBinding != null) 'styleBinding': styleBinding,
    };
  }
}
