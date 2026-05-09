class V4IdentityGlobalQAAggregator {
  const V4IdentityGlobalQAAggregator();

  Map<String, String> export({
    Map<String, String>? chainStatus,
    Map<String, String>? completeness,
    Map<String, String>? globalChain,
    Map<String, String>? localSnapshot,
  }) {
    return {
      'v4_identity_global_qa': 'ok',
      if (chainStatus != null) ...chainStatus,
      if (completeness != null) ...completeness,
      if (globalChain != null) ...globalChain,
      if (localSnapshot != null) ...localSnapshot,
    };
  }
}
