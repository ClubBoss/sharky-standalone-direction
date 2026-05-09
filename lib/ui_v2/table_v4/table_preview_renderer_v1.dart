/// Passive table preview renderer V1 (Phi-57.8).
class TablePreviewRendererV1 {
  const TablePreviewRendererV1(
    this.orchestratorMap,
    this.boardLayoutMap,
    this.cardLayoutMap,
  );

  final Object orchestratorMap;
  final Object boardLayoutMap;
  final Object cardLayoutMap;

  Map<String, Object> asReadOnlyMap() {
    final Object orchestratorCandidate = orchestratorMap;
    final Object boardLayoutCandidate = boardLayoutMap;
    final Object cardLayoutCandidate = cardLayoutMap;
    final bool hasOrchestrator =
        orchestratorCandidate is Map && orchestratorCandidate.isNotEmpty;
    final bool hasBoard =
        boardLayoutCandidate is Map && boardLayoutCandidate.isNotEmpty;
    final bool hasCard =
        cardLayoutCandidate is Map && cardLayoutCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasOrchestrator) missing.add('orchestrator');
    if (!hasBoard) missing.add('board_layout');
    if (!hasCard) missing.add('card_layout');

    final Map<String, Object> preview = <String, Object>{
      'sample_face': hasOrchestrator
          ? (((orchestratorCandidate as Map)['render_orchestrator']
                    as Map?)?['face'] ??
                <Object>{})
          : <Object>{},
      'sample_back': hasOrchestrator
          ? (((orchestratorCandidate as Map)['render_orchestrator']
                    as Map?)?['back'] ??
                <Object>{})
          : <Object>{},
      'sample_frame': hasBoard
          ? (boardLayoutCandidate as Map)['board'] ?? <Object>{}
          : <Object>{},
      'card_rect': hasCard
          ? (((cardLayoutCandidate as Map)['layout'] as Map?)?['rect'] ??
                <Object>{})
          : <Object>{},
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'preview': preview,
      'readiness': readiness,
      'missing': missing,
    };
  }
}
