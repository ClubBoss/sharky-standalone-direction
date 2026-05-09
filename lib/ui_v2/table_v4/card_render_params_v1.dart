/// Passive card render parameters for Table V4 (Phi-42).
class CardRenderParamsV1 {
  const CardRenderParamsV1({
    required this.cardLayoutMap,
    required this.accentRoutingMap,
  });

  final Map<String, Object> cardLayoutMap;
  final Map<String, Object> accentRoutingMap;

  Map<String, Object> run() {
    final List<String> cardParamsMissing = <String>[];
    if (cardLayoutMap.isEmpty) cardParamsMissing.add('card_layout_map');
    if (accentRoutingMap.isEmpty) cardParamsMissing.add('accent_routing_map');

    final double cardW = cardLayoutMap['card_w'] is num
        ? (cardLayoutMap['card_w'] as num).toDouble()
        : 0.0;
    final double cardH = cardLayoutMap['card_h'] is num
        ? (cardLayoutMap['card_h'] as num).toDouble()
        : 0.0;
    if (cardW == 0.0 || cardH == 0.0) cardParamsMissing.add('card_dimensions');

    final Map<String, Object> safeZone =
        cardLayoutMap['card_safe_zone'] is Map<String, Object>
        ? cardLayoutMap['card_safe_zone'] as Map<String, Object>
        : <String, Object>{};
    final double safeDx = safeZone['dx'] is num
        ? (safeZone['dx'] as num).toDouble()
        : 0.0;
    final double safeDy = safeZone['dy'] is num
        ? (safeZone['dy'] as num).toDouble()
        : 0.0;

    double _accent(String key) {
      final Object? value = accentRoutingMap[key];
      return value is num ? value.toDouble() : 0.0;
    }

    final Map<String, Object> cardParamsMap = <String, Object>{
      'radius': cardW * 0.12,
      'stroke_width': cardW * 0.025,
      'pip_scale': 0.82,
      'edge_accent_strength': _accent('card_edge_tint'),
      'face_tint_strength': _accent('card_edge_tint'),
      'safe_dx': safeDx,
      'safe_dy': safeDy,
    };

    final bool cardParamsReady = cardParamsMissing.isEmpty;

    return <String, Object>{
      'card_params_missing': cardParamsMissing,
      'card_params_ready': cardParamsReady,
      'card_params_map': cardParamsMap,
    };
  }
}
