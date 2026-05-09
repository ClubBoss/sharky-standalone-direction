/// Passive V4 visual cohesion QA (Phi-6).
class V4VisualCohesionQAV1 {
  const V4VisualCohesionQAV1({
    required this.tokenRegistry,
    required this.themeDeltas,
    required this.materialization,
    required this.surfacePolish,
    required this.activationFrame,
    required this.activationSync,
    required this.visualBinding,
    required this.visualFullMap,
  });

  final Map<String, Object> tokenRegistry;
  final Map<String, Object> themeDeltas;
  final Map<String, Object> materialization;
  final Map<String, Object> surfacePolish;
  final Map<String, Object> activationFrame;
  final Map<String, Object> activationSync;
  final Map<String, Object> visualBinding;
  final Map<String, Object> visualFullMap;

  Map<String, Object> run() {
    final List<String> missingSections = <String>[];
    if (tokenRegistry.isEmpty) missingSections.add('token_registry');
    if (themeDeltas.isEmpty) missingSections.add('theme_deltas');
    if (materialization.isEmpty) missingSections.add('materialization');
    if (surfacePolish.isEmpty) missingSections.add('surface_polish');
    if (activationFrame.isEmpty) missingSections.add('activation_frame');
    if (activationSync.isEmpty) missingSections.add('activation_sync');
    if (visualBinding.isEmpty) missingSections.add('visual_binding');
    if (visualFullMap.isEmpty) missingSections.add('visual_full_map');

    final List<String> emptyKeys = <String>[];
    void _checkEmpty(String prefix, Map<String, Object> map) {
      map.forEach((key, value) {
        if (value == '' ||
            value == [] ||
            value == <Object>[] ||
            value == <String, Object>{}) {
          emptyKeys.add('$prefix:$key');
        }
      });
    }

    _checkEmpty('token', tokenRegistry);
    _checkEmpty('theme', themeDeltas);
    _checkEmpty('mat', materialization);
    _checkEmpty('polish', surfacePolish);
    _checkEmpty('act', activationFrame);
    _checkEmpty('sync', activationSync);
    _checkEmpty('binding', visualBinding);
    _checkEmpty('full', visualFullMap);

    final List<String> conflicts = <String>[];
    void _mergeWithConflicts(
      Map<String, Object> target,
      Map<String, Object> source,
      String label,
    ) {
      source.forEach((key, value) {
        if (target.containsKey(key)) {
          final Object existing = target[key] as Object;
          final bool bothScalar =
              existing is! Map &&
              existing is! Iterable &&
              value is! Map &&
              value is! Iterable;
          if (bothScalar && existing.runtimeType != value.runtimeType) {
            conflicts.add('type_mismatch:$label:$key');
          }
        }
        target[key] = value;
      });
    }

    final Map<String, Object> visualIntegrityMap = <String, Object>{};
    _mergeWithConflicts(
      visualIntegrityMap,
      activationFrame,
      'activation_frame',
    );
    _mergeWithConflicts(visualIntegrityMap, activationSync, 'activation_sync');
    _mergeWithConflicts(visualIntegrityMap, tokenRegistry, 'token_registry');
    _mergeWithConflicts(visualIntegrityMap, themeDeltas, 'theme_deltas');
    _mergeWithConflicts(visualIntegrityMap, surfacePolish, 'surface_polish');

    final Map<String, Object> materializationSurface =
        materialization['surface'] is Map<String, Object>
        ? materialization['surface'] as Map<String, Object>
        : <String, Object>{};
    if (materializationSurface.isNotEmpty) {
      _mergeWithConflicts(
        visualIntegrityMap,
        materializationSurface,
        'materialization_surface',
      );
    }
    final Map<String, Object> materializationRest = Map<String, Object>.from(
      materialization,
    )..remove('surface');
    _mergeWithConflicts(
      visualIntegrityMap,
      materializationRest,
      'materialization',
    );
    _mergeWithConflicts(visualIntegrityMap, visualBinding, 'visual_binding');
    _mergeWithConflicts(visualIntegrityMap, visualFullMap, 'visual_full_map');

    materializationSurface.forEach((key, value) {
      if (surfacePolish.containsKey(key) &&
          surfacePolish[key].runtimeType != value.runtimeType) {
        conflicts.add('surface_conflict:$key');
      }
    });
    tokenRegistry.forEach((key, value) {
      if (themeDeltas.containsKey(key) &&
          themeDeltas[key].runtimeType != value.runtimeType) {
        conflicts.add('token_theme_conflict:$key');
      }
    });

    final bool cohesionReady =
        missingSections.isEmpty && emptyKeys.isEmpty && conflicts.isEmpty;

    return <String, Object>{
      'missing_sections': missingSections,
      'empty_keys': emptyKeys,
      'conflicts': conflicts,
      'cohesion_ready': cohesionReady,
      'visual_integrity_map': visualIntegrityMap,
    };
  }
}
