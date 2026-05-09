/// Passive card vector primitives generator (Phi-43).
class CardVectorPrimitivesV1 {
  const CardVectorPrimitivesV1({
    required this.cardRenderParams,
    required this.cardLayoutMap,
  });

  final Map<String, Object> cardRenderParams;
  final Map<String, Object> cardLayoutMap;

  Map<String, Object> run() {
    final List<String> cardVecMissing = <String>[];
    if (cardRenderParams.isEmpty) cardVecMissing.add('card_render_params');
    if (cardLayoutMap.isEmpty) cardVecMissing.add('card_layout_map');

    final double cardW = cardLayoutMap['card_w'] is num
        ? (cardLayoutMap['card_w'] as num).toDouble()
        : 0.0;
    final double cardH = cardLayoutMap['card_h'] is num
        ? (cardLayoutMap['card_h'] as num).toDouble()
        : 0.0;
    if (cardW == 0.0 || cardH == 0.0) cardVecMissing.add('card_dimensions');

    double _param(String key) {
      final Object? value = cardRenderParams[key];
      return value is num ? value.toDouble() : 0.0;
    }

    final double radius = _param('radius');
    final double stroke = _param('stroke_width');
    final double pipScale = _param('pip_scale');
    final double edgeHighlight = _param('edge_accent_strength');

    final Map<String, Object> cardVecMap = <String, Object>{
      'rounded_rect': <String, double>{'radius': radius, 'stroke': stroke},
      'outline_path': <String, double>{
        'w': cardW,
        'h': cardH,
        'corner_r': radius,
      },
      'pip_box_center': <String, double>{'x': cardW * 0.5, 'y': cardH * 0.44},
      'pip_scale': pipScale,
      'edge_highlight': edgeHighlight,
    };

    final bool cardVecReady = cardVecMissing.isEmpty;

    return <String, Object>{
      'card_vec_missing': cardVecMissing,
      'card_vec_ready': cardVecReady,
      'card_vec_map': cardVecMap,
    };
  }
}
