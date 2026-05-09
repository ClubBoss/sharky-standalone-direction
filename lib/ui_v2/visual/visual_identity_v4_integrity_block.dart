class V4IdentityIntegrityBlock {
  const V4IdentityIntegrityBlock();

  Map<String, String> export({
    bool chainValidatorPresent = false,
    bool chainCompletenessPresent = false,
    bool globalChainExportPresent = false,
    bool globalQAAggregatorPresent = false,
    bool localSnapshotPresent = false,
  }) {
    return {
      'v4_identity_integrity': 'ok',
      'chain_validator': chainValidatorPresent ? 'ok' : 'missing',
      'chain_completeness': chainCompletenessPresent ? 'ok' : 'missing',
      'global_chain_export': globalChainExportPresent ? 'ok' : 'missing',
      'global_qa_aggregator': globalQAAggregatorPresent ? 'ok' : 'missing',
      'local_snapshot': localSnapshotPresent ? 'ok' : 'missing',
    };
  }
}
