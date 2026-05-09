import 'package:flutter/widgets.dart';

/// Passive table view shell V1 (Phi-71.0).
class TableViewShellV1 {
  const TableViewShellV1(
    this.tableViewSkeletonV1Map, {
    this.tableStateMap,
    this.seatStateMap,
    this.potStateMap,
    this.v4LabelProviderMap,
    this.v4LabelSurfaceMap,
    this.typographyInjectorMap,
    this.animationSpecMap = const <String, Object?>{},
    this.v4SpacingMap,
    this.highlightGlowSpecMap,
    this.v4WidgetLayer,
  });

  final Object tableViewSkeletonV1Map;
  final Map<String, Object>? tableStateMap;
  final Map<String, Object>? seatStateMap;
  final Map<String, Object>? potStateMap;
  final Map<String, Object>? v4LabelProviderMap;
  final Map<String, Object>? v4LabelSurfaceMap;
  final Map<String, Object?>? typographyInjectorMap;
  final Map<String, Object?> animationSpecMap;
  final Map<String, Object?>? v4SpacingMap;
  final Map<String, Object>? highlightGlowSpecMap;
  final Widget? v4WidgetLayer;

  Map<String, Object> asReadOnlyMap() {
    final Map<Object?, Object?>? rootMap = tableViewSkeletonV1Map is Map
        ? tableViewSkeletonV1Map as Map<Object?, Object?>
        : null;
    final bool hasSkeleton = rootMap?.isNotEmpty == true;
    final List<String> missing = <String>[];
    if (!hasSkeleton) missing.add('table_view_skeleton_v1');
    final Map<String, Object> skeleton = hasSkeleton
        ? rootMap!['table_view_skeleton_v1'] as Map<String, Object>? ??
              <String, Object>{}
        : <String, Object>{};
    final bool shellReady = missing.isEmpty;
    final Map<String, Object> shell = <String, Object>{
      'root': 'table_view_shell',
      'structure': skeleton,
      'metadata': <String, String>{'version': 'v1', 'type': 'table_view_shell'},
    };
    if (tableStateMap != null) {
      shell['table_state'] = tableStateMap as Object;
    }
    if (seatStateMap != null) {
      shell['seat_state'] = seatStateMap as Object;
    }
    if (potStateMap != null) {
      shell['pot_state'] = potStateMap as Object;
    }
    if (v4LabelProviderMap != null) {
      shell['v4_label_provider'] = v4LabelProviderMap as Object;
    }
    if (v4LabelSurfaceMap != null) {
      shell['v4_label_surface'] = v4LabelSurfaceMap as Object;
    }
    if (typographyInjectorMap != null) {
      shell['typography_injector'] = typographyInjectorMap as Object;
    }
    if (animationSpecMap.isNotEmpty) {
      shell['animation_spec_map'] = animationSpecMap as Object;
    }
    if (v4SpacingMap != null) {
      shell['v4_spacing_map'] = v4SpacingMap as Object;
    }
    if (highlightGlowSpecMap != null) {
      shell['highlight_glow_spec_map'] = highlightGlowSpecMap as Object;
    }
    if (v4WidgetLayer != null) {
      shell['v4_widget_layer'] = v4WidgetLayer as Object;
    }
    shell['v4_readiness'] = <String, Object>{
      'spacing_ready': _isSpacingReady,
      'typography_ready': _isTypographyReady(typographyInjectorMap),
      'glow_ready': _isGlowReady(),
      'animation_ready': _isAnimationReady(animationSpecMap),
    };
    return <String, Object>{
      'table_view_shell_v1': <String, Object>{
        'shell': shell,
        'shell_ready': shellReady,
      },
      'readiness': shellReady,
      'missing': missing,
    };
  }

  bool get _isSpacingReady => v4SpacingMap != null && v4SpacingMap!.isNotEmpty;

  bool _isTypographyReady(Map<String, Object?>? injector) {
    if (injector == null) {
      return false;
    }
    if (injector['readiness'] != true) {
      return false;
    }
    final Object? body = injector['typography_v4_injector_v1'];
    if (body is! Map<String, Object?>) {
      return false;
    }
    return body['v4_active'] == true;
  }

  bool _isGlowReady() =>
      highlightGlowSpecMap != null && highlightGlowSpecMap!.isNotEmpty;

  bool _isAnimationReady(Map<String, Object?> spec) => spec['active'] == true;
}
