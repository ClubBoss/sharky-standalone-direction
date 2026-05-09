import 'dart:convert';
import 'dart:io';

class VisualCohesionFinalException implements IOException {
  const VisualCohesionFinalException(this.message);

  final String message;

  @override
  String toString() => 'VisualCohesionFinalException: $message';
}

class VisualCohesionFinalBundle {
  VisualCohesionFinalBundle({
    required this.tokenMismatches,
    required this.spacingInconsistencies,
    required this.layoutAnomalies,
    required this.componentDiversityScore,
    required this.visualCohesionIndex,
    required this.uniqueComponentCount,
    required this.timestamp,
  });

  final int tokenMismatches;
  final int spacingInconsistencies;
  final int layoutAnomalies;
  final double componentDiversityScore;
  final double visualCohesionIndex;
  final int uniqueComponentCount;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'token_mismatches': tokenMismatches,
    'spacing_inconsistencies': spacingInconsistencies,
    'layout_anomalies': layoutAnomalies,
    'component_diversity_score': componentDiversityScore,
    'unique_component_count': uniqueComponentCount,
    'visual_cohesion_index': visualCohesionIndex,
    'timestamp': timestamp.toIso8601String(),
  };
}

class VisualCohesionFinalService {
  const VisualCohesionFinalService();

  static final _requiredPaths = const [
    'release/_reports/visual_token_summary.json',
    'release/_reports/layout_cohesion_summary.json',
    'release/_reports/component_inventory_summary.json',
    'release/_reports/design_lift_blueprint.json',
  ];

  static final _hexPattern = RegExp(r'^#(?:[0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$');

  Future<VisualCohesionFinalBundle> summarize() async {
    final tokenData = await _loadAsciiJson(_requiredPaths[0]);
    final layoutData = await _loadAsciiJson(_requiredPaths[1]);
    final componentData = await _loadAsciiJson(_requiredPaths[2]);
    final blueprintData = await _loadAsciiJson(_requiredPaths[3]);

    final tokenMismatches = _countTokenMismatches(tokenData);
    final layoutAnomalies = _extractLayoutAnomalies(layoutData);
    final definedSpacing = _collectSpacingValues(tokenData);
    final layoutSpacing = _collectLayoutSpacing(layoutData);
    final spacingInconsistencies = _countSpacingInconsistencies(
      definedSpacing,
      layoutSpacing,
    );
    final uniqueComponents = _collectComponentNames(componentData);
    final componentDiversityScore = _computeComponentDiversityScore(
      uniqueComponents.length,
    );
    final visualCohesionIndex = _computeVisualCohesionIndex(
      tokenMismatches: tokenMismatches,
      spacingInconsistencies: spacingInconsistencies,
      layoutAnomalies: layoutAnomalies,
      componentDiversityScore: componentDiversityScore,
    );

    _validateBlueprint(blueprintData);

    return VisualCohesionFinalBundle(
      tokenMismatches: tokenMismatches,
      spacingInconsistencies: spacingInconsistencies,
      layoutAnomalies: layoutAnomalies,
      componentDiversityScore: componentDiversityScore,
      visualCohesionIndex: visualCohesionIndex,
      uniqueComponentCount: uniqueComponents.length,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw VisualCohesionFinalException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw VisualCohesionFinalException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw VisualCohesionFinalException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  int _countTokenMismatches(Map<String, Object?> data) {
    final variants = <String, Set<String>>{};

    void collect(Object? value, String context) {
      if (value is String && _hexPattern.hasMatch(value)) {
        final normalized = context.toLowerCase();
        variants.putIfAbsent(normalized, () => {}).add(value.toUpperCase());
        return;
      }
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          collect(value[i], '$context[$i]');
        }
      } else if (value is Map) {
        for (final entry in value.entries) {
          collect(entry.value, '$context.${entry.key}');
        }
      }
    }

    collect(data, 'tokens');

    return variants.values.fold<int>(
      0,
      (sum, set) => sum + (set.length > 1 ? set.length - 1 : 0),
    );
  }

  Set<double> _collectSpacingValues(Map<String, Object?> data) {
    final values = <double>{};
    void collect(Object? value, String key) {
      if (value is num && _isSpacingKey(key)) {
        values.add(value.toDouble());
      } else if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null && _isSpacingKey(key)) {
          values.add(parsed);
        }
      } else if (value is List) {
        for (final element in value) {
          collect(element, key);
        }
      } else if (value is Map<String, Object?>) {
        for (final entry in value.entries) {
          collect(entry.value, entry.key);
        }
      }
    }

    for (final entry in data.entries) {
      collect(entry.value, entry.key);
    }
    return values;
  }

  bool _isSpacingKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('spacing') ||
        lower.contains('gap') ||
        lower.contains('space');
  }

  Set<double> _collectLayoutSpacing(Map<String, Object?> data) {
    final stats = data['stats'];
    if (stats is! Map) return {};
    final values = <double>{};
    for (final entry in stats.entries) {
      _extractNumericValues(entry.value, values);
    }
    return values;
  }

  void _extractNumericValues(Object? value, Set<double> accumulator) {
    if (value is num) {
      accumulator.add(value.toDouble());
      return;
    }
    if (value is List) {
      for (final element in value) {
        _extractNumericValues(element, accumulator);
      }
    } else if (value is Map) {
      for (final entry in value.entries) {
        _extractNumericValues(entry.value, accumulator);
      }
    }
  }

  int _countSpacingInconsistencies(Set<double> defined, Set<double> layout) {
    if (layout.isEmpty) return 0;
    if (defined.isEmpty) {
      return layout.length;
    }
    return layout.where((value) => !defined.contains(value)).length;
  }

  int _extractLayoutAnomalies(Map<String, Object?> data) {
    final anomalies = data['anomalies'];
    if (anomalies is List) {
      return anomalies.length;
    }
    return 0;
  }

  Set<String> _collectComponentNames(Map<String, Object?> componentJson) {
    final components = componentJson['components'];
    if (components is! Map) {
      throw VisualCohesionFinalException('Missing components data');
    }
    final names = <String>{};
    for (final entry in components.entries) {
      final list = entry.value;
      if (list is List) {
        for (final item in list) {
          if (item is String) {
            names.add(item);
          }
        }
      }
    }
    return names;
  }

  void _validateBlueprint(Map<String, Object?> blueprint) {
    if (!blueprint.containsKey('design_priority') ||
        !blueprint.containsKey('timestamp')) {
      throw VisualCohesionFinalException(
        'Design blueprint missing required fields',
      );
    }
  }

  double _computeComponentDiversityScore(int count) =>
      (count / 40).clamp(0.0, 1.0);

  double _computeVisualCohesionIndex({
    required int tokenMismatches,
    required int spacingInconsistencies,
    required int layoutAnomalies,
    required double componentDiversityScore,
  }) {
    final base = 1.0;
    final adjustments =
        0.30 * (tokenMismatches / 10) +
        0.30 * (spacingInconsistencies / 10) +
        0.25 * (layoutAnomalies / 10) +
        0.15 * componentDiversityScore;
    return (base - adjustments).clamp(0.0, 1.0).toDouble();
  }
}
