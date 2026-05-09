class TableInteractionFinalizerV4 {
  const TableInteractionFinalizerV4(this.tableInteractionEnvelopeV4Map);

  final Object tableInteractionEnvelopeV4Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> envelope =
        tableInteractionEnvelopeV4Map is Map &&
            (tableInteractionEnvelopeV4Map
                    as Map)['table_interaction_envelope_v4']
                is Map
        ? (tableInteractionEnvelopeV4Map
                  as Map)['table_interaction_envelope_v4']
              as Map<String, Object>
        : <String, Object>{};
    final bool ready = envelope['interaction_ready'] == true;
    final List<String> missing = <String>[
      if (!ready) 'table_interaction_envelope_v4',
    ];
    return <String, Object>{
      'table_interaction_finalizer_v4': <String, Object>{
        'final_interaction': ready ? envelope : <String, Object>{},
        'ready': ready,
        'missing': missing,
      },
      'readiness': ready,
    };
  }
}
