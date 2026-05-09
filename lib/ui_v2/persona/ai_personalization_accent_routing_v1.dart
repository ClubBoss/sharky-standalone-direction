/// Passive accent routing layer for personalization (Phi-39).
class AIPersonalizationAccentRoutingV1 {
  const AIPersonalizationAccentRoutingV1(this.accentNormMap);

  final Map<String, Object> accentNormMap;

  Map<String, Object> run() {
    final List<String> accentRoutingMissing = <String>[];
    if (accentNormMap.isEmpty) accentRoutingMissing.add('accent_norm_map');

    double _readSlot(String slot) {
      final String key = 'ai_inj_$slot';
      final Object? value = accentNormMap[key];
      return value is num ? value.toDouble() : 0.0;
    }

    final Map<String, Object> accentRoutingMap = <String, Object>{
      'table_board_tint': _readSlot('table_board_tint'),
      'card_edge_tint': _readSlot('card_edge_tint'),
      'pot_glow_strength': _readSlot('pot_glow_strength'),
      'action_button_accent': _readSlot('action_button_accent'),
      'highlight_pulse': _readSlot('highlight_pulse'),
      'table_overlay_strength': _readSlot('table_overlay_strength'),
    };

    final bool accentRoutingReady = accentRoutingMissing.isEmpty;

    return <String, Object>{
      'accent_routing_missing': accentRoutingMissing,
      'accent_routing_ready': accentRoutingReady,
      'accent_routing_map': accentRoutingMap,
    };
  }
}
