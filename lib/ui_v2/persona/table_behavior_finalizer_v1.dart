class TableBehaviorFinalizerV1 {
  const TableBehaviorFinalizerV1(this.behaviorEnvelopeV1Map);

  final Object behaviorEnvelopeV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object> envelope =
        behaviorEnvelopeV1Map is Map &&
            (behaviorEnvelopeV1Map as Map).isNotEmpty
        ? behaviorEnvelopeV1Map as Map<String, Object>
        : <String, Object>{};
    final bool envelopeReady =
        (envelope as Map).isNotEmpty &&
        ((envelope['envelope_ready'] == true) ||
            (envelope['table_behavior_envelope_v1'] is Map &&
                (envelope['table_behavior_envelope_v1']
                        as Map<dynamic, dynamic>)['envelope_ready'] ==
                    true));
    final bool ready = envelopeReady;
    final List<String> missing = <String>[
      if (envelope.isEmpty) 'table_behavior_envelope_v1',
      if (!ready) 'table_behavior_finalizer_v1',
    ];
    return <String, Object>{
      'table_behavior_finalizer_v1': <String, Object>{
        'final_behavior': envelope,
        'final_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
