class TableBoardAdaptiveLayoutV4BridgeV1 {
  const TableBoardAdaptiveLayoutV4BridgeV1(
    this.tableBoardAdaptiveLayoutV1Map,
    this.tableBoardAdaptiveLayoutV2Map,
    this.tableCompositionFrameV1Map,
    this.tableSurfaceTokensV1Map,
  );

  final Object tableBoardAdaptiveLayoutV1Map;
  final Object tableBoardAdaptiveLayoutV2Map;
  final Object tableCompositionFrameV1Map;
  final Object tableSurfaceTokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Map<String, Object> v) => v['readiness'] == true;
    final Map<String, Map<String, Object>> domains =
        <String, Map<String, Object>>{
          'composition': m(tableCompositionFrameV1Map),
          'layout_v1': m(tableBoardAdaptiveLayoutV1Map),
          'layout_v2': m(tableBoardAdaptiveLayoutV2Map),
          'tokens': m(tableSurfaceTokensV1Map),
        };
    final List<String> missing = domains.entries
        .where((entry) => entry.value.isEmpty || !ready(entry.value))
        .map((entry) => entry.key)
        .toList();
    final bool layoutReady =
        ready(domains['layout_v1']!) && ready(domains['layout_v2']!);
    final bool allReady = layoutReady && missing.isEmpty;
    return <String, Object>{
      'table_board_adaptive_layout_v4': <String, Object>{
        'domains': domains,
        'missing': missing,
        'layout_ready': allReady,
      },
      'readiness': allReady,
    };
  }
}
