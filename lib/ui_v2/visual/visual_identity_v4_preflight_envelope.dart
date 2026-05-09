class V4IdentityPreflightEnvelope {
  const V4IdentityPreflightEnvelope();

  Map<String, String> export({Map<String, String>? manifest}) {
    return {
      'v4_identity_preflight_envelope': 'ok',
      if (manifest != null) ...manifest,
    };
  }
}
