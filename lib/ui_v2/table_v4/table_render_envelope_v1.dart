/// Passive table render envelope V1 (Phi-69.0).
class TableRenderEnvelopeV1 {
  const TableRenderEnvelopeV1(this.tableRenderSpecV1Map);

  final Object tableRenderSpecV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object specCandidate = tableRenderSpecV1Map;
    final bool hasSpec = specCandidate is Map && specCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasSpec) missing.add('table_render_spec_v1');
    final Map<String, Object> spec = hasSpec
        ? (specCandidate as Map)['table_render_spec_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final bool envelopeReady = missing.isEmpty;
    return <String, Object>{
      'table_render_envelope_v1': <String, Object>{
        'envelope': <String, Object>{
          'spec': spec,
          'metadata': <String, String>{
            'version': 'v1',
            'type': 'table_render_envelope',
          },
        },
        'envelope_ready': envelopeReady,
      },
      'readiness': envelopeReady,
      'missing': missing,
    };
  }
}
