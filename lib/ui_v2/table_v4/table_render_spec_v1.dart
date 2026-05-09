/// Passive table render spec V1 (Phi-68.0).
class TableRenderSpecV1 {
  const TableRenderSpecV1(this.tableRenderContextV1Map);

  final Object tableRenderContextV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object contextCandidate = tableRenderContextV1Map;
    final bool hasContext =
        contextCandidate is Map && contextCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasContext) missing.add('table_render_context_v1');
    final Map<String, Object> ctx = hasContext
        ? (contextCandidate as Map)['table_render_context_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> spec = <String, Object>{
      'layout': ctx['render'] is Map
          ? (ctx['render'] as Map)['layout'] ?? <Object>{}
          : <Object>{},
      'zones': ctx['render'] is Map
          ? (ctx['render'] as Map)['zones'] ?? <Object>{}
          : <Object>{},
      'actions': ctx['render'] is Map
          ? (ctx['render'] as Map)['actions'] ?? <Object>{}
          : <Object>{},
      'chips_pot': ctx['render'] is Map
          ? (ctx['render'] as Map)['chips_pot'] ?? <Object>{}
          : <Object>{},
      'highlights': ctx['render'] is Map
          ? (ctx['render'] as Map)['highlights'] ?? <Object>{}
          : <Object>{},
      'depth': ctx['render'] is Map
          ? (ctx['render'] as Map)['depth'] ?? <Object>{}
          : <Object>{},
      'tokens': ctx['render'] is Map
          ? (ctx['render'] as Map)['tokens'] ?? <Object>{}
          : <Object>{},
      'composition': ctx['render'] is Map
          ? (ctx['render'] as Map)['composition'] ?? <Object>{}
          : <Object>{},
    };
    final bool specReady = missing.isEmpty;
    return <String, Object>{
      'table_render_spec_v1': <String, Object>{
        'spec': spec,
        'spec_ready': specReady,
      },
      'readiness': specReady,
      'missing': missing,
    };
  }
}
