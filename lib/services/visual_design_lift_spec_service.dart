import 'dart:convert';
import 'dart:io';

class VisualDesignLiftSpecException implements IOException {
  const VisualDesignLiftSpecException(this.message);

  final String message;

  @override
  String toString() => 'VisualDesignLiftSpecException: $message';
}

class VisualDesignLiftSpecBundle {
  VisualDesignLiftSpecBundle({
    required this.colorRules,
    required this.spacingRules,
    required this.radiiRules,
    required this.shadowRules,
    required this.layoutRules,
    required this.componentRules,
    required this.hintIntegration,
    required this.riskSummary,
    required this.timestamp,
  });

  final Map<String, Object?> colorRules;
  final Map<String, Object?> spacingRules;
  final Map<String, Object?> radiiRules;
  final Map<String, Object?> shadowRules;
  final Map<String, Object?> layoutRules;
  final Map<String, Object?> componentRules;
  final Map<String, Object?> hintIntegration;
  final Map<String, Object?> riskSummary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'color_rules': colorRules,
    'spacing_rules': spacingRules,
    'radii_rules': radiiRules,
    'shadow_rules': shadowRules,
    'layout_rules': layoutRules,
    'component_rules': componentRules,
    'hint_integration': hintIntegration,
    'risk_summary': riskSummary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class VisualDesignLiftSpecService {
  const VisualDesignLiftSpecService();

  static const _paths = [
    'release/_reports/visual_token_summary.json',
    'release/_reports/layout_cohesion_summary.json',
    'release/_reports/component_inventory_summary.json',
    'release/_reports/design_lift_blueprint.json',
    'release/_reports/visual_cohesion_final.json',
    'release/_reports/hint_routing_bundle.json',
  ];

  Future<VisualDesignLiftSpecBundle> build() async {
    final tokenData = await _loadAsciiJson(_paths[0]);
    final layoutData = await _loadAsciiJson(_paths[1]);
    final componentData = await _loadAsciiJson(_paths[2]);
    final blueprintData = await _loadAsciiJson(_paths[3]);
    final cohesionData = await _loadAsciiJson(_paths[4]);
    final hintData = await _loadAsciiJson(_paths[5]);

    final colorRules = _deriveColorRules(tokenData, blueprintData);
    final spacingRules = _deriveSpacingRules(layoutData);
    final radiiRules = _deriveRadiiRules(layoutData, tokenData);
    final shadowRules = _deriveShadowRules(layoutData, blueprintData);
    final layoutRules = _deriveLayoutRules(layoutData);
    final componentRules = _deriveComponentRules(componentData);
    final hintIntegration = _deriveHintIntegration(hintData);
    final riskSummary = {
      'visual_cohesion_index': _extractVisualIndex(cohesionData),
    };

    return VisualDesignLiftSpecBundle(
      colorRules: colorRules,
      spacingRules: spacingRules,
      radiiRules: radiiRules,
      shadowRules: shadowRules,
      layoutRules: layoutRules,
      componentRules: componentRules,
      hintIntegration: hintIntegration,
      riskSummary: riskSummary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw VisualDesignLiftSpecException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw VisualDesignLiftSpecException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw VisualDesignLiftSpecException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _deriveColorRules(
    Map<String, Object?> tokenData,
    Map<String, Object?> blueprint,
  ) {
    final palette = _extractStringList(tokenData['palette']);
    final fallbackColors = _extractStringList(blueprint['preferred_colors']);
    final canonical = <String>[...palette.take(4), ...fallbackColors.take(4)];
    return {
      'canonical_palette': canonical.isNotEmpty ? canonical : const ['#000000'],
      'inconsistencies': tokenData['mismatches'] ?? 0,
    };
  }

  Map<String, Object?> _deriveSpacingRules(Map<String, Object?> layoutData) {
    final stats = layoutData['stats'];
    final numbers = <double>{};
    if (stats is Map) {
      for (final entry in stats.entries) {
        _collectNumbers(entry.value, numbers);
      }
    }
    final scale = numbers.toList()..sort();
    final scaleValues = scale.take(5).toList();
    return {
      'suggested_scale': scaleValues.isNotEmpty
          ? scaleValues
          : const [4.0, 8.0, 12.0],
      'padding_variants': stats is Map ? stats['padding'] ?? [] : const [],
    };
  }

  Map<String, Object?> _deriveRadiiRules(
    Map<String, Object?> layoutData,
    Map<String, Object?> tokenData,
  ) {
    final radii = _extractStringList(layoutData['radii']);
    final designRadii = _extractStringList(tokenData['radius_tokens']);
    return {
      'primary_radii': radii.isNotEmpty ? radii.take(3).toList() : ['4', '8'],
      'token_based_radii': designRadii,
    };
  }

  Map<String, Object?> _deriveShadowRules(
    Map<String, Object?> layoutData,
    Map<String, Object?> blueprint,
  ) {
    final elevations = _extractStringList(layoutData['elevation_levels']);
    final coreShadows = _extractStringList(blueprint['core_directives']);
    return {
      'elevations': elevations.isNotEmpty
          ? elevations
          : ['low', 'medium', 'high'],
      'shadow_focus': coreShadows,
    };
  }

  Map<String, Object?> _deriveLayoutRules(Map<String, Object?> layoutData) {
    final anomalies = layoutData['anomalies'];
    final stats = layoutData['stats'];
    final statsMap = stats is Map ? stats : {};
    return {
      'padding_normalization': statsMap['padding'] ?? [],
      'margin_patterns': statsMap['margin'] ?? [],
      'anomalies': anomalies ?? [],
    };
  }

  Map<String, Object?> _deriveComponentRules(
    Map<String, Object?> componentData,
  ) {
    final components = componentData['components'];
    final mapping = <String, List<String>>{};
    if (components is Map) {
      for (final entry in components.entries) {
        final list = (entry.value as List<dynamic>?)
            ?.whereType<String>()
            .take(3)
            .toList();
        mapping[entry.key] = list ?? [];
      }
    }
    return {
      'preferred_components': mapping,
      'counts': componentData['counts'] ?? {},
    };
  }

  Map<String, Object?> _deriveHintIntegration(Map<String, Object?> hintData) {
    return {
      'tier': hintData['tier'] ?? 'medium',
      'layout_focus': hintData['layout_focus'] ?? [],
      'placement': hintData['placement_candidates'] ?? {},
    };
  }

  double _extractVisualIndex(Map<String, Object?> data) =>
      (_extractNumber(data['visual_cohesion_index']) ?? 0.0);

  double? _extractNumber(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  List<String> _extractStringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  void _collectNumbers(Object? value, Set<double> accumulator) {
    if (value is num) {
      accumulator.add(value.toDouble());
      return;
    }
    if (value is List) {
      for (final element in value) {
        _collectNumbers(element, accumulator);
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        _collectNumbers(entry.value, accumulator);
      }
    }
  }
}
