class V4IdentityGlobalChainExport {
  const V4IdentityGlobalChainExport();

  Map<String, String> export({
    required Map<String, String> chainStatus,
    required Map<String, String> completeness,
  }) {
    return {'v4_global_chain_export': 'ok', ...chainStatus, ...completeness};
  }
}
