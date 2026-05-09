class MiniAuditV2 {
  static Map<String, Object> build({required Map finalConsistencySweepV2}) {
    return <String, Object>{
      'mini_audit_v2': <String, Object>{
        'final_consistency_sweep_v2': finalConsistencySweepV2,
      },
    };
  }
}
