import 'dart:convert';
import 'dart:io';

class ComponentUnificationMapException implements IOException {
  const ComponentUnificationMapException(this.message);

  final String message;

  @override
  String toString() => 'ComponentUnificationMapException: $message';
}

class ComponentUnificationMapBundle {
  ComponentUnificationMapBundle({
    required this.canonicalComponents,
    required this.consolidationRules,
    required this.visualRules,
    required this.timestamp,
  });

  final Map<String, Object?> canonicalComponents;
  final Map<String, Object?> consolidationRules;
  final Map<String, Object?> visualRules;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'canonical_components': canonicalComponents,
    'consolidation_rules': consolidationRules,
    'visual_rules': visualRules,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ComponentUnificationMapService {
  const ComponentUnificationMapService();

  static const _inputPath = 'release/_reports/visual_design_lift_spec.json';

  Future<ComponentUnificationMapBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final componentRules = _extractMap(data['component_rules']);
    final layoutRules = _extractMap(data['layout_rules']);
    final colorRules = _extractMap(data['color_rules']);
    final spacingRules = _extractMap(data['spacing_rules']);
    final radiiRules = _extractMap(data['radii_rules']);
    final shadowRules = _extractMap(data['shadow_rules']);

    final canonicalComponents = _deriveCanonicalComponents(componentRules);
    final consolidationRules = _deriveConsolidationRules(
      layoutRules,
      spacingRules,
      radiiRules,
      shadowRules,
    );
    final visualRules = {
      'colors': colorRules,
      'spacing': spacingRules,
      'radii': radiiRules,
      'shadows': shadowRules,
    };

    return ComponentUnificationMapBundle(
      canonicalComponents: canonicalComponents,
      consolidationRules: consolidationRules,
      visualRules: visualRules,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ComponentUnificationMapException('Missing spec $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw ComponentUnificationMapException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw ComponentUnificationMapException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    return const {};
  }

  Map<String, Object?> _deriveCanonicalComponents(
    Map<String, Object?> componentRules,
  ) {
    final preferred = _extractMap(componentRules['preferred_components']);
    Object? getFirst(String group, Object? fallback) {
      final list = preferred[group];
      if (list is List && list.isNotEmpty) {
        return list.first;
      }
      return fallback;
    }

    return {
      'buttons': getFirst('buttons', 'TextButton'),
      'cards': getFirst('cards', 'Card'),
      'inputs': getFirst('inputs', 'TextField'),
      'lists': getFirst('lists', 'ListTile'),
      'navigation': getFirst('navigation', 'AppBar'),
    };
  }

  Map<String, Object?> _deriveConsolidationRules(
    Map<String, Object?> layoutRules,
    Map<String, Object?> spacingRules,
    Map<String, Object?> radiiRules,
    Map<String, Object?> shadowRules,
  ) {
    final padding = layoutRules['padding_normalization'];
    final margin = layoutRules['margin_patterns'];
    final anomalies = layoutRules['anomalies'];
    return {
      'deprecated_variants': {
        'cards': layoutRules['anomalies'] ?? [],
        'spacing': spacingRules['padding_variants'] ?? [],
      },
      'merged_wrappers': padding is List && padding.isNotEmpty
          ? padding.sublist(0, 1)
          : ['SafeArea'],
      'spacing_radii_unification': {
        'spacing_scale': spacingRules['suggested_scale'] ?? [],
        'radii_standard': radiiRules['primary_radii'] ?? [],
      },
      'shadow_canonical_set': shadowRules['elevations'] ?? [],
      'layout_cleanup': anomalies ?? [],
      'margin_patterns': margin ?? [],
    };
  }
}
