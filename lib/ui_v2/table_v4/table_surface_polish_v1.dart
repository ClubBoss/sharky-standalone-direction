/// Passive polish layer for Table Composite Surface V4.
class TableSurfacePolishV1 {
  const TableSurfacePolishV1(this.v4RuntimeBundle);

  final Object v4RuntimeBundle;

  Map<String, Object> asReadOnlyMap() {
    final dynamic bundle = v4RuntimeBundle is Map ? v4RuntimeBundle : null;
    final dynamic materialization =
        bundle is Map && bundle['materialization'] is Map
        ? bundle['materialization']
        : bundle;
    final Map<dynamic, dynamic> surface =
        materialization is Map && materialization['surface'] is Map
        ? materialization['surface'] as Map<dynamic, dynamic>
        : materialization is Map &&
              materialization['surface_token'] is Map<dynamic, dynamic>
        ? materialization['surface_token'] as Map<dynamic, dynamic>
        : const <dynamic, dynamic>{};
    final Map<dynamic, dynamic> surfaceDefaults =
        materialization is Map && materialization['surface_defaults'] is Map
        ? materialization['surface_defaults'] as Map<dynamic, dynamic>
        : const <dynamic, dynamic>{};

    double _readDouble(
      Map<dynamic, dynamic> source,
      String key,
      double fallback,
    ) {
      final dynamic value = source[key];
      if (value is num) return value.toDouble();
      return fallback;
    }

    final double shadowAlpha = _readDouble(
      surface,
      'shadow_alpha',
      _readDouble(surfaceDefaults, 'shadow_alpha', 0.15),
    );
    final double edgeThickness = _readDouble(
      surface,
      'edge_thickness',
      _readDouble(surfaceDefaults, 'edge_thickness', 1.0),
    );
    final double surfaceOverlay = _readDouble(
      surface,
      'surface_overlay',
      _readDouble(surfaceDefaults, 'surface_overlay', 0.08),
    );
    final double padding = _readDouble(
      surface,
      'padding',
      _readDouble(surfaceDefaults, 'padding', 9.0),
    );
    final double radius = _readDouble(
      surface,
      'radius',
      _readDouble(surfaceDefaults, 'radius', 13.0),
    );
    final double surfaceGap = _readDouble(
      surface,
      'surface_gap',
      _readDouble(surfaceDefaults, 'surface_gap', 8.0),
    );
    final double cardGap = _readDouble(
      surface,
      'card_gap',
      _readDouble(surfaceDefaults, 'card_gap', 8.0),
    );
    final double cellDelta = _readDouble(
      surface,
      'cell_delta',
      _readDouble(surfaceDefaults, 'cell_delta', 4.0),
    );
    final double overlaySpacing = _readDouble(
      surface,
      'overlay_spacing',
      _readDouble(surfaceDefaults, 'overlay_spacing', 12.0),
    );
    return <String, Object>{
      'shadow_alpha': shadowAlpha,
      'edge_thickness': edgeThickness,
      'surface_overlay': surfaceOverlay,
      'padding': padding,
      'radius': radius,
      'surface_gap': surfaceGap,
      'card_gap': cardGap,
      'cell_delta': cellDelta,
      'overlay_spacing': overlaySpacing,
    };
  }
}
