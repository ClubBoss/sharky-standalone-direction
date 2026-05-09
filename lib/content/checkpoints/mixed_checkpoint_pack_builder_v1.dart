class MixedCheckpointPackBuilderV1 {
  const MixedCheckpointPackBuilderV1(
    this.packId,
    this.loaderMap,
    this.binderMap,
    this.routerMap,
  );

  final String packId;
  final Object loaderMap;
  final Object binderMap;
  final Object routerMap;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> loaded = m(loaderMap);
    final Map<String, Object> bound = m(binderMap);
    final Map<String, Object> routed = m(routerMap);
    final List<String> missing = <String>[
      if (loaded.isEmpty) 'loader',
      if (bound.isEmpty) 'binder',
      if (routed.isEmpty) 'router',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'mixed_checkpoint_pack_builder_v1': <String, Object>{
        'pack_id': packId,
        'content': <String, Object>{
          'loaded': loaded,
          'bound': bound,
          'routed': routed,
        },
        'missing': missing,
        'pack_ready': ready,
      },
      'readiness': ready,
    };
  }
}
