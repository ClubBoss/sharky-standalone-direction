/// Passive table render context V1 (Phi-67.0).
class TableRenderContextV1 {
  const TableRenderContextV1(this.tableUIFinalCompositionV1Map);

  final Object tableUIFinalCompositionV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object finalCandidate = tableUIFinalCompositionV1Map;
    final bool hasFinal = finalCandidate is Map && finalCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasFinal) missing.add('table_ui_final_composition_v1');
    final Map<String, Object> finalMap = hasFinal
        ? (finalCandidate as Map)['table_ui_final_composition_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> compose =
        finalMap['compose'] is Map<String, Object>
        ? finalMap['compose'] as Map<String, Object>
        : <String, Object>{};
    if (compose.isEmpty) missing.add('compose');
    final Map<String, Object> render = <String, Object>{
      'layout': compose['layout'] ?? <Object>{},
      'zones': compose['interaction'] ?? <Object>{},
      'actions': compose['actions'] ?? <Object>{},
      'chips_pot': compose['chips_pot'] ?? <Object>{},
      'highlights': compose['highlights'] ?? <Object>{},
      'depth': compose['depth'] ?? <Object>{},
      'tokens': compose['tokens'] ?? <Object>{},
      'composition': compose['composition'] ?? <Object>{},
    };
    final bool renderReady = missing.isEmpty;
    return <String, Object>{
      'table_render_context_v1': <String, Object>{
        'render': render,
        'render_ready': renderReady,
      },
      'readiness': renderReady,
      'missing': missing,
    };
  }
}
