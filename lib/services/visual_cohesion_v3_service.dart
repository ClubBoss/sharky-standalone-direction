import 'dart:convert';
import 'dart:io';

class VisualCohesionV3Exception implements IOException {
  const VisualCohesionV3Exception(this.message);

  final String message;

  @override
  String toString() => 'VisualCohesionV3Exception: $message';
}

class VisualCohesionV3Bundle {
  VisualCohesionV3Bundle({
    required this.ruleConflicts,
    required this.componentConflicts,
    required this.layoutConflicts,
    required this.missingTargets,
    required this.visualCohesionIndex,
    required this.timestamp,
  });

  final int ruleConflicts;
  final int componentConflicts;
  final int layoutConflicts;
  final int missingTargets;
  final double visualCohesionIndex;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'rule_conflicts': ruleConflicts,
    'component_conflicts': componentConflicts,
    'layout_conflicts': layoutConflicts,
    'missing_targets': missingTargets,
    'visual_cohesion_v3_index': visualCohesionIndex,
    'timestamp': timestamp.toIso8601String(),
  };
}

class VisualCohesionV3Service {
  const VisualCohesionV3Service();

  static const _paths = [
    'release/_reports/visual_design_lift_spec.json',
    'release/_reports/component_unification_map.json',
    'release/_reports/layout_template_bundle.json',
    'release/_reports/component_library_bundle.json',
    'release/_reports/design_lift_implementation_map.json',
  ];

  Future<VisualCohesionV3Bundle> evaluate() async {
    final spec = await _loadAsciiJson(_paths[0]);
    final unification = await _loadAsciiJson(_paths[1]);
    final template = await _loadAsciiJson(_paths[2]);
    final library = await _loadAsciiJson(_paths[3]);
    final implementation = await _loadAsciiJson(_paths[4]);

    final ruleConflicts = _detectRuleConflicts(spec, unification);
    final componentConflicts = _detectComponentConflicts(unification, library);
    final layoutConflicts = _detectLayoutConflicts(template, implementation);
    final missingTargets = _detectMissingTargets(library, implementation);

    final visualCohesionIndex = _computeIndex(
      ruleConflicts: ruleConflicts,
      componentConflicts: componentConflicts,
      layoutConflicts: layoutConflicts,
      missingTargets: missingTargets,
    );

    return VisualCohesionV3Bundle(
      ruleConflicts: ruleConflicts,
      componentConflicts: componentConflicts,
      layoutConflicts: layoutConflicts,
      missingTargets: missingTargets,
      visualCohesionIndex: visualCohesionIndex,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw VisualCohesionV3Exception('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw VisualCohesionV3Exception('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw VisualCohesionV3Exception('Invalid JSON structure in $path');
    }
    return decoded;
  }

  int _detectRuleConflicts(
    Map<String, Object?> spec,
    Map<String, Object?> unification,
  ) {
    final specPalette = _extractMap(spec['color_rules'])['canonical_palette'];
    final uniPalette = _extractMap(
      _extractMap(unification['visual_rules'])['colors'],
    )['canonical_palette'];
    final specColors = _extractList(specPalette);
    final uniColors = _extractList(uniPalette);
    return (specColors.toSet().difference(uniColors.toSet()).length +
        uniColors.toSet().difference(specColors.toSet()).length);
  }

  int _detectComponentConflicts(
    Map<String, Object?> unification,
    Map<String, Object?> library,
  ) {
    final uniComponents = _extractMap(unification['canonical_components']);
    final libPatterns = _extractMap(library['patterns']);
    return uniComponents.keys
        .where((key) => !libPatterns.containsKey(key))
        .length;
  }

  int _detectLayoutConflicts(
    Map<String, Object?> template,
    Map<String, Object?> implementation,
  ) {
    final templateLayouts = template['row_column_templates'];
    final implementationLayouts = implementation['layout_targets'];
    return _extractList(templateLayouts).length +
        _extractList(implementationLayouts).length;
  }

  int _detectMissingTargets(
    Map<String, Object?> library,
    Map<String, Object?> implementation,
  ) {
    final patterns = _extractMap(library['patterns']);
    final replacements = implementation['replacement_targets'];
    if (replacements is! List) return patterns.length;
    return patterns.length - replacements.length;
  }

  double _computeIndex({
    required int ruleConflicts,
    required int componentConflicts,
    required int layoutConflicts,
    required int missingTargets,
  }) {
    final adjustments =
        0.30 * (ruleConflicts / 10) +
        0.30 * (componentConflicts / 10) +
        0.25 * (layoutConflicts / 10) +
        0.15 * (missingTargets / 10);
    return (1.0 - adjustments).clamp(0.0, 1.0);
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};

  List<String> _extractList(Object? value) {
    if (value is List) return value.whereType<String>().toList();
    if (value is Map) return value.values.whereType<String>().toList();
    return [];
  }
}
