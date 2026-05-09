/// Passive chips and pot geometry V1 (Phi-61.0).
class ChipsPotGeometryV1 {
  const ChipsPotGeometryV1(
    this.layoutV2Map,
    this.compositionFrameV1Map,
    this.tokensV1Map,
  );

  final Object layoutV2Map;
  final Object compositionFrameV1Map;
  final Object tokensV1Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<dynamic, dynamic>? layoutSource = layoutV2Map is Map
        ? layoutV2Map as Map<dynamic, dynamic>
        : null;
    final Map<dynamic, dynamic>? compositionSource =
        compositionFrameV1Map is Map
        ? compositionFrameV1Map as Map<dynamic, dynamic>
        : null;
    final Map<dynamic, dynamic>? tokensSource = tokensV1Map is Map
        ? tokensV1Map as Map<dynamic, dynamic>
        : null;
    final bool hasLayout = layoutSource != null && layoutSource.isNotEmpty;
    final bool hasComposition =
        compositionSource != null && compositionSource.isNotEmpty;
    final bool hasTokens = tokensSource != null && tokensSource.isNotEmpty;
    final List<String> missing = <String>[];
    if (!hasLayout) missing.add('layout_v2_map');
    if (!hasComposition) missing.add('composition_frame_v1');
    if (!hasTokens) missing.add('tokens_v1_map');

    final Map<String, Object> boardLayout;
    if (layoutSource != null && layoutSource.isNotEmpty) {
      boardLayout = _asStringObjectMap(
        layoutSource['board_adaptive_layout_v2'],
      );
    } else {
      boardLayout = <String, Object>{};
    }
    final Map<String, Object> composition;
    if (compositionSource != null && compositionSource.isNotEmpty) {
      composition = _asStringObjectMap(
        compositionSource['table_composition_frame_v1'],
      );
    } else {
      composition = <String, Object>{};
    }
    final Map<String, Object> tokens;
    if (tokensSource != null && tokensSource.isNotEmpty) {
      tokens = _asStringObjectMap(tokensSource['table_surface_tokens_v1']);
    } else {
      tokens = <String, Object>{};
    }
    final Map<String, Object> spacing = hasTokens
        ? _asStringObjectMap(tokens['spacing'])
        : <String, Object>{};

    final Map<String, Object> potRect =
        (boardLayout['breakpoints'] as Map?)?['regular']
            as Map<String, Object>? ??
        (composition['slots'] as Map?)?['center_zone']
            as Map<String, Object>? ??
        <String, Object>{};

    Map<String, Object> _stackRect(String key) {
      return <String, Object>{
        'rect': potRect,
        'ready': potRect.isNotEmpty,
        'id': key,
      };
    }

    final Map<String, Object> geometry = <String, Object>{
      'pot_zone': <String, Object>{
        'rect': potRect,
        'ready': potRect.isNotEmpty,
      },
      'hero_stack': _stackRect('hero'),
      'villain_stack': _stackRect('villain'),
      'stack_spacing': spacing,
      'safe_regions': boardLayout['breakpoints'] ?? <Object>{},
      'ready': missing.isEmpty,
    };
    final bool readiness = missing.isEmpty;
    return <String, Object>{
      'chips_pot_geometry_v1': geometry,
      'readiness': readiness,
      'missing': missing,
    };
  }
}

Map<String, Object> _asStringObjectMap(Object? value) {
  if (value is Map) return Map<String, Object>.from(value);
  return <String, Object>{};
}
