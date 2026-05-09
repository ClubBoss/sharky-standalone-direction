class V4IdentityPreflightDigest {
  const V4IdentityPreflightDigest();

  Map<String, String> export({
    Map<String, String>? chainStatus,
    Map<String, String>? completeness,
    Map<String, String>? globalChain,
    Map<String, String>? globalQA,
    Map<String, String>? integrity,
    Map<String, String>? localSnapshot,
  }) {
    return {
      'v4_identity_preflight_digest': 'ok',
      if (chainStatus != null) ...chainStatus,
      if (completeness != null) ...completeness,
      if (globalChain != null) ...globalChain,
      if (globalQA != null) ...globalQA,
      if (integrity != null) ...integrity,
      if (localSnapshot != null) ...localSnapshot,
    };
  }
}
