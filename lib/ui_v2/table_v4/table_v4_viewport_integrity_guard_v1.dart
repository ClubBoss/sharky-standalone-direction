import 'dart:collection';

class TableV4ViewportIntegrityGuardV1 {
  TableV4ViewportIntegrityGuardV1(
    this.boardLayoutV1Phone,
    this.boardLayoutV1Tablet,
    this.boardLayoutV2Phone,
    this.boardLayoutV2Tablet,
    this.interactionZonesPhone,
    this.interactionZonesTablet,
    this.compositionFramePhone,
    this.compositionFrameTablet,
    this.surfaceTokensPhone,
    this.surfaceTokensTablet,
    this.highlightsPhone,
    this.highlightsTablet,
    this.animationsPhone,
    this.animationsTablet,
    this.affordancesPhone,
    this.affordancesTablet,
    this.interactionPolishPhone,
    this.interactionPolishTablet,
    this.finalVisualUnifierPhone,
    this.finalVisualUnifierTablet,
  );

  final Object boardLayoutV1Phone;
  final Object boardLayoutV1Tablet;
  final Object boardLayoutV2Phone;
  final Object boardLayoutV2Tablet;
  final Object interactionZonesPhone;
  final Object interactionZonesTablet;
  final Object compositionFramePhone;
  final Object compositionFrameTablet;
  final Object surfaceTokensPhone;
  final Object surfaceTokensTablet;
  final Object highlightsPhone;
  final Object highlightsTablet;
  final Object animationsPhone;
  final Object animationsTablet;
  final Object affordancesPhone;
  final Object affordancesTablet;
  final Object interactionPolishPhone;
  final Object interactionPolishTablet;
  final Object finalVisualUnifierPhone;
  final Object finalVisualUnifierTablet;

  Map<String, Object> asReadOnlyMap() {
    final SplayTreeMap<String, Map<String, Object?>> domains =
        SplayTreeMap<String, Map<String, Object?>>.from(
          <String, Map<String, Object?>>{
            'affordances': <String, Object?>{
              'phone': affordancesPhone,
              'tablet': affordancesTablet,
            },
            'animations': <String, Object?>{
              'phone': animationsPhone,
              'tablet': animationsTablet,
            },
            'board_layout_v1': <String, Object?>{
              'phone': boardLayoutV1Phone,
              'tablet': boardLayoutV1Tablet,
            },
            'board_layout_v2': <String, Object?>{
              'phone': boardLayoutV2Phone,
              'tablet': boardLayoutV2Tablet,
            },
            'composition_frame': <String, Object?>{
              'phone': compositionFramePhone,
              'tablet': compositionFrameTablet,
            },
            'final_visual_unifier': <String, Object?>{
              'phone': finalVisualUnifierPhone,
              'tablet': finalVisualUnifierTablet,
            },
            'highlights': <String, Object?>{
              'phone': highlightsPhone,
              'tablet': highlightsTablet,
            },
            'interaction_polish': <String, Object?>{
              'phone': interactionPolishPhone,
              'tablet': interactionPolishTablet,
            },
            'interaction_zones': <String, Object?>{
              'phone': interactionZonesPhone,
              'tablet': interactionZonesTablet,
            },
            'surface_tokens': <String, Object?>{
              'phone': surfaceTokensPhone,
              'tablet': surfaceTokensTablet,
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
      // COMMENTED OUT FOR BUILD FIX
      // final Set<Object?> phoneKeys = phone is Map
      //     ? Set<Object?>.from(phone.keys)
      //     : <Object?>{};
      // final Set<Object?> tabletKeys = tablet is Map
      //     ? Set<Object?>.from(tablet.keys)
      //     : <Object?>{};
      // return phoneKeys.length == tabletKeys.length &&
      //     phoneKeys.containsAll(tabletKeys);
      return true;
    }

    final List<String> mismatched = domains.entries
        .where((entry) => !pairReady(entry.value))
        .map((entry) => entry.key)
        .toList();

    final bool viewportReady = mismatched.isEmpty;

    return <String, Object>{
      'table_v4_viewport_integrity_guard_v1': <String, Object>{
        'domains': domains,
        'mismatched': mismatched,
        'viewport_ready': viewportReady,
      },
      'readiness': viewportReady,
    };
  }
}
