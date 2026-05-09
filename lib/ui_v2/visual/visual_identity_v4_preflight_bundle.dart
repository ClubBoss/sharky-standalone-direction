class V4IdentityPreflightBundle {
  const V4IdentityPreflightBundle();

  Map<String, String> export({Map<String, String>? envelope}) {
    return {
      'v4_identity_preflight_bundle': 'ok',
      if (envelope != null) ...envelope,
    };
  }
}
