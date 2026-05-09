class V4IdentityReadinessGate {
  final Map<String, dynamic> readiness;
  final Map<String, String> previewConsistency;
  final Map<String, dynamic> completeness;
  final Map<String, dynamic> chain;
  final Map<String, dynamic> preflight;

  const V4IdentityReadinessGate({
    required this.readiness,
    required this.previewConsistency,
    required this.completeness,
    required this.chain,
    required this.preflight,
  });

  Map<String, dynamic> evaluate() {
    final previewOk = previewConsistency.values.every((v) => v == 'ok');
    final chainOk = readiness['status'] == 'ok';
    final ready = previewOk && chainOk;
    return {
      'ready': ready,
      'reason': ready ? 'all checks passed' : 'preview or readiness incomplete',
    };
  }
}
