import 'dart:collection';

class RpgSurfaceWeightsV1 {
  const RpgSurfaceWeightsV1();

  Map<String, Object> computeForFusion(Map<String, Object?> fusedRpgState) {
    final fusion =
        fusedRpgState['fusion'] as Map<String, Object?>? ??
        const <String, Object?>{};
    final eff = (fusion['effective_power'] as num?)?.toDouble() ?? 0.0;
    final clamped = eff.clamp(0.0, 100.0);
    final table = (clamped * 0.6).clamp(0.0, 100.0);
    final holeCards = (clamped * 0.3).clamp(0.0, 100.0);
    final actionButtons = (clamped * 0.1).clamp(0.0, 100.0);
    return UnmodifiableMapView<String, Object>({
      'table_weight': table,
      'hole_cards_weight': holeCards,
      'action_buttons_weight': actionButtons,
    });
  }
}
