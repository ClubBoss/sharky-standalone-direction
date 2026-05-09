class ActionButtonsRenderSpecV1 {
  const ActionButtonsRenderSpecV1(
    this.actionButtonsRenderSkeletonV1Map,
    this.tableSurfaceTokensV1Map,
  );

  final Object actionButtonsRenderSkeletonV1Map;
  final Object tableSurfaceTokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    final Map<String, Object> skeleton =
        actionButtonsRenderSkeletonV1Map is Map &&
            (actionButtonsRenderSkeletonV1Map
                    as Map)['action_buttons_render_skeleton_v1']
                is Map
        ? m(
            (actionButtonsRenderSkeletonV1Map
                    as Map)['action_buttons_render_skeleton_v1']
                as Map,
          )
        : m(actionButtonsRenderSkeletonV1Map);
    final Map<String, Object> tokens = m(tableSurfaceTokensV1Map);
    final List<String> missing = <String>[
      if (skeleton.isEmpty) 'action_buttons_render_skeleton_v1',
      if (tokens.isEmpty) 'table_surface_tokens_v1',
    ];
    final bool ready = missing.isEmpty;
    return <String, Object>{
      'action_buttons_render_spec_v1': <String, Object>{
        'spec': <String, Object>{'layout': skeleton, 'tokens': tokens},
        'spec_ready': ready,
      },
      'readiness': ready,
      'missing': missing,
    };
  }
}
