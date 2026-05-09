/// Passive table surface tokens V1 (Phi-58.2).
class TableSurfaceTokensV1 {
  const TableSurfaceTokensV1(this.layoutV2Map);

  final Object layoutV2Map;

  Map<String, Object> asReadOnlyMap() {
    final Object layoutCandidate = layoutV2Map;
    final bool hasLayout = layoutCandidate is Map && layoutCandidate.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasLayout) missing.add('layout_v2_map');
    final bool ready = missing.isEmpty;
    final Map<String, Object> tokens = <String, Object>{
      'spacing': <String, int>{'xs': 2, 'sm': 4, 'md': 6, 'lg': 8},
      'radius': <String, int>{'card': 4, 'slot': 6, 'board': 8},
      'color': <String, String>{
        'felt_bg': '#006644',
        'felt_bg_alt': '#004C33',
        'slot_outline': '#FFFFFF',
      },
      'alpha': <String, double>{'felt': 1.0, 'highlight': 0.12},
      'surface_flags': <String, bool>{'ready': ready},
    };
    return <String, Object>{
      'table_surface_tokens_v1': tokens,
      'readiness': ready,
      'missing': missing,
    };
  }
}
