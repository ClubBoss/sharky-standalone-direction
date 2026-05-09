/// Passive Table UI final composition bridge V1 (Phi-66.0).
class TableUIFinalCompositionV1 {
  const TableUIFinalCompositionV1(this.tableUIHandoffV1Map);

  final Object tableUIHandoffV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Object handoffCandidate = tableUIHandoffV1Map;
    final bool hasHandoff =
        handoffCandidate is Map && handoffCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasHandoff) missing.add('table_ui_handoff_v1');
    final Map<String, Object> handoff = hasHandoff
        ? (handoffCandidate as Map)['table_ui_handoff_v1']
                  as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final Map<String, Object> compose = <String, Object>{
      'layout': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['layout'] ?? <Object>{}
          : <Object>{},
      'composition': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['composition'] ?? <Object>{}
          : <Object>{},
      'interaction': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['interaction'] ?? <Object>{}
          : <Object>{},
      'actions': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['actions'] ?? <Object>{}
          : <Object>{},
      'chips_pot': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['chips_pot'] ?? <Object>{}
          : <Object>{},
      'highlights': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['highlights'] ?? <Object>{}
          : <Object>{},
      'depth': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['depth'] ?? <Object>{}
          : <Object>{},
      'tokens': handoff['geometry'] is Map
          ? (handoff['geometry'] as Map)['tokens'] ?? <Object>{}
          : <Object>{},
    };
    final bool finalReady = missing.isEmpty;
    return <String, Object>{
      'table_ui_final_composition_v1': <String, Object>{
        'compose': compose,
        'final_ready': finalReady,
      },
      'readiness': finalReady,
      'missing': missing,
    };
  }
}
