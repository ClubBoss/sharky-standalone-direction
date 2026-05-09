import 'dart:collection';

class TableV4DeviceFusionValidatorV1 {
  TableV4DeviceFusionValidatorV1(
    this.activationSyncPhone,
    this.activationSyncTablet,
    this.materializationPhone,
    this.materializationTablet,
    this.visualBindingPhone,
    this.visualBindingTablet,
    this.visualFullPassPhone,
    this.visualFullPassTablet,
    this.interactionEnvelopePhone,
    this.interactionEnvelopeTablet,
    this.finalVisualUnifierPhone,
    this.finalVisualUnifierTablet,
    this.finalRenderFusionPhone,
    this.finalRenderFusionTablet,
  );

  final Object activationSyncPhone;
  final Object activationSyncTablet;
  final Object materializationPhone;
  final Object materializationTablet;
  final Object visualBindingPhone;
  final Object visualBindingTablet;
  final Object visualFullPassPhone;
  final Object visualFullPassTablet;
  final Object interactionEnvelopePhone;
  final Object interactionEnvelopeTablet;
  final Object finalVisualUnifierPhone;
  final Object finalVisualUnifierTablet;
  final Object finalRenderFusionPhone;
  final Object finalRenderFusionTablet;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Map<String, Object?>> domains =
        SplayTreeMap<String, Map<String, Object?>>.from(
          <String, Map<String, Object?>>{
            'activation_sync': <String, Object?>{
              'phone': activationSyncPhone,
              'tablet': activationSyncTablet,
            },
            'final_render_fusion': <String, Object?>{
              'phone': finalRenderFusionPhone,
              'tablet': finalRenderFusionTablet,
            },
            'final_visual_unifier': <String, Object?>{
              'phone': finalVisualUnifierPhone,
              'tablet': finalVisualUnifierTablet,
            },
            'interaction_envelope': <String, Object?>{
              'phone': interactionEnvelopePhone,
              'tablet': interactionEnvelopeTablet,
            },
            'materialization': <String, Object?>{
              'phone': materializationPhone,
              'tablet': materializationTablet,
            },
            'visual_binding': <String, Object?>{
              'phone': visualBindingPhone,
              'tablet': visualBindingTablet,
            },
            'visual_full_pass': <String, Object?>{
              'phone': visualFullPassPhone,
              'tablet': visualFullPassTablet,
            },
          },
        );

    bool isReady(Object? value) =>
        value is Map && value.isNotEmpty && value['readiness'] == true;

    bool pairReady(Map<String, Object?> pair) {
      final Object? phone = pair['phone'];
      final Object? tablet = pair['tablet'];
      if (!isReady(phone) || !isReady(tablet)) {
        return false;
      }
      final Set<Object?> phoneKeys = phone is Map
          ? Set<Object?>.from(phone.keys)
          : <Object?>{};
      final Set<Object?> tabletKeys = tablet is Map
          ? Set<Object?>.from(tablet.keys) // Fixed: was 'table.keys'
          : <Object?>{};
      return phoneKeys.length == tabletKeys.length &&
          phoneKeys.containsAll(tabletKeys);
    }

    final List<String> mismatched = domains.entries
        .where((entry) => !pairReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool validatorReady = mismatched.isEmpty;

    return <String, Object>{
      'table_v4_device_fusion_validator_v1': <String, Object>{
        'domains': domains,
        'mismatched': mismatched,
        'validator_ready': validatorReady,
      },
      'readiness': validatorReady,
    };
  }
}
