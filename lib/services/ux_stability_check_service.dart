import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class UXStabilityCheckService {
  static const _designLiftPath =
      'release/_reports/visual_design_lift_spec.json';
  static const _componentUnificationPath =
      'release/_reports/component_unification_map.json';
  static const _layoutTemplatePath =
      'release/_reports/layout_template_bundle.json';
  static const _componentLibraryPath =
      'release/_reports/component_library_bundle.json';
  static const _visualCohesionPath = 'release/_reports/visual_cohesion_v3.json';
  static const _overlaySpecPath = 'release/_reports/tutorial_overlay_spec.json';
  static const _routingBundlePath =
      'release/_reports/explanation_routing_bundle.json';

  const UXStabilityCheckService();

  Future<UXStabilityResult> run() async {
    final issues = <String>[];

    final designLift = await _loadJson(
      _designLiftPath,
      'visual_design_lift_spec.json',
    );
    final componentUnification = await _loadJson(
      _componentUnificationPath,
      'component_unification_map.json',
    );
    final layoutTemplate = await _loadJson(
      _layoutTemplatePath,
      'layout_template_bundle.json',
    );
    final componentLibrary = await _loadJson(
      _componentLibraryPath,
      'component_library_bundle.json',
    );
    final visualCohesion = await _loadJson(
      _visualCohesionPath,
      'visual_cohesion_v3.json',
    );
    final overlaySpec = await _loadJson(
      _overlaySpecPath,
      'tutorial_overlay_spec.json',
    );
    final routingBundle = await _loadJson(
      _routingBundlePath,
      'explanation_routing_bundle.json',
    );

    final spacingSpec = _extractSpecMap(
      designLift,
      'spacing',
      'visual_design_lift_spec.json',
      issues,
    );
    final radiiSpec = _extractSpecMap(
      designLift,
      'radii',
      'visual_design_lift_spec.json',
      issues,
    );
    final shadowSpec = _extractSpecMap(
      designLift,
      'shadow',
      'visual_design_lift_spec.json',
      issues,
    );

    final componentPatterns = _extractComponentPatterns(
      componentUnification,
      issues,
    );
    if (componentPatterns.isEmpty) {
      issues.add(
        'component_unification_map.json: no component patterns defined',
      );
    }

    final libraryComponents = _extractComponentLibrary(
      componentLibrary,
      issues,
    );
    if (libraryComponents.isEmpty) {
      issues.add('component_library_bundle.json: no components defined');
    }

    final layoutTemplates = _extractMapList(
      layoutTemplate,
      'templates',
      'layout_template_bundle.json',
      issues,
      required: true,
    );

    if (layoutTemplates.isEmpty) {
      issues.add('layout_template_bundle.json: no templates found');
    }

    _validateLayoutTemplates(
      layoutTemplates,
      componentPatterns,
      libraryComponents,
      spacingSpec,
      radiiSpec,
      shadowSpec,
      issues,
    );

    final cohesionIndex = visualCohesion['cohesion_v3_index'];
    if (cohesionIndex is! num) {
      issues.add('visual_cohesion_v3.json: missing cohesion_v3_index');
    } else if (cohesionIndex < 0) {
      issues.add('visual_cohesion_v3.json: cohesion_v3_index is negative');
    }

    final triggers = _extractMapList(
      routingBundle,
      'triggers',
      'explanation_routing_bundle.json',
      issues,
      required: true,
    );
    final sections = _extractMapList(
      routingBundle,
      'sections',
      'explanation_routing_bundle.json',
      issues,
      required: true,
    );

    if (triggers.isEmpty) {
      issues.add('explanation_routing_bundle.json: no triggers defined');
    }
    if (sections.isEmpty) {
      issues.add('explanation_routing_bundle.json: no sections defined');
    }

    final validRoutingIds = <String>{};
    for (final trigger in triggers) {
      final id = _extractNonEmptyString(
        trigger,
        'id',
        'explanation_routing_bundle.json trigger',
        issues,
      );
      if (id != null) {
        validRoutingIds.add(id);
      }
    }
    for (final section in sections) {
      final id = _extractNonEmptyString(
        section,
        'id',
        'explanation_routing_bundle.json section',
        issues,
      );
      if (id != null) {
        validRoutingIds.add(id);
      }
    }

    final overlaySteps = _extractMapList(
      overlaySpec,
      'steps',
      'tutorial_overlay_spec.json',
      issues,
      required: true,
    );
    if (overlaySteps.isEmpty) {
      issues.add('tutorial_overlay_spec.json: no steps defined');
    }

    for (var index = 0; index < overlaySteps.length; index++) {
      final step = overlaySteps[index];
      final routingId = _extractNonEmptyString(
        step,
        'routingId',
        'tutorial_overlay_spec.json step ${index + 1}',
        issues,
      );
      if (routingId != null && !validRoutingIds.contains(routingId)) {
        issues.add(
          'tutorial_overlay_spec.json step ${index + 1}: unknown routingId $routingId',
        );
      }
    }

    final result = _buildResult(issues);
    if (!result.summary.uxStable) {
      throw UXStabilityCheckException(
        result,
        'UX stability check failed: ${issues.join(' | ')}',
      );
    }
    return result;
  }

  Future<Map<String, dynamic>> _loadJson(String path, String label) async {
    final file = File(path);
    if (!await file.exists()) {
      _throwWithIssues('Missing $label', ['Missing $path']);
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      _throwWithIssues('$label is empty', ['Empty file $path']);
    }
    if (!_isAsciiOnly(bytes)) {
      _throwWithIssues('$label is not ASCII', ['Non-ASCII content $path']);
    }
    return _decodeJson(utf8.decode(bytes), label, path);
  }

  Never _throwWithIssues(String message, List<String> issues) {
    final result = _buildResult(issues);
    throw UXStabilityCheckException(result, message);
  }

  UXStabilityResult _buildResult(List<String> issues) {
    final snapshot = List<String>.from(issues);
    final summary = UXStabilitySummary(
      uxStable: snapshot.isEmpty,
      timestamp: DateTime.now().toUtc(),
    );
    return UXStabilityResult(issues: snapshot, summary: summary);
  }

  Set<String> _extractComponentPatterns(
    Map<String, dynamic> map,
    List<String> issues,
  ) {
    final raw = map['patterns'];
    if (raw == null) {
      return {};
    }
    if (raw is Map) {
      return raw.keys.whereType<String>().toSet();
    }
    if (raw is List) {
      final patterns = <String>{};
      for (final entry in raw) {
        if (entry is String && entry.trim().isNotEmpty) {
          patterns.add(entry.trim());
        } else if (entry is Map) {
          final name = entry['name'];
          if (name is String && name.trim().isNotEmpty) {
            patterns.add(name.trim());
          }
        }
      }
      if (patterns.isEmpty) {
        issues.add(
          'component_unification_map.json: patterns list contains no valid strings',
        );
      }
      return patterns;
    }
    issues.add(
      'component_unification_map.json: patterns must be a map or list',
    );
    return {};
  }

  Set<String> _extractComponentLibrary(
    Map<String, dynamic> map,
    List<String> issues,
  ) {
    final raw = map['components'];
    if (raw is! List) {
      issues.add('component_library_bundle.json: components must be a list');
      return {};
    }
    final components = <String>{};
    for (final entry in raw) {
      if (entry is String && entry.trim().isNotEmpty) {
        components.add(entry.trim());
      } else if (entry is Map) {
        final name = entry['name'];
        if (name is String && name.trim().isNotEmpty) {
          components.add(name.trim());
        }
      }
    }
    return components;
  }

  List<Map<String, dynamic>> _extractMapList(
    Map<String, dynamic> map,
    String key,
    String file,
    List<String> issues, {
    bool required = false,
  }) {
    final raw = map[key];
    if (raw == null) {
      if (required) {
        issues.add('$file: missing $key');
      }
      return [];
    }
    if (raw is! List) {
      issues.add('$file: $key must be a list');
      return [];
    }
    final collected = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is Map) {
        collected.add(Map<String, dynamic>.from(entry));
      } else {
        issues.add('$file: $key must contain objects');
      }
    }
    return collected;
  }

  Map<String, dynamic> _decodeJson(String content, String label, String path) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map) {
        _throwWithIssues('$label must be a JSON object', [
          '$label must decode to a JSON object',
        ]);
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException catch (error) {
      _throwWithIssues('$label contains invalid JSON', [
        '$label invalid JSON: ${error.message}',
      ]);
    }
  }

  Map<String, dynamic> _extractSpecMap(
    Map<String, dynamic> map,
    String key,
    String file,
    List<String> issues,
  ) {
    final raw = map[key];
    if (raw == null) {
      issues.add('$file: missing $key definitions');
      return {};
    }
    if (raw is! Map) {
      issues.add('$file: $key must be a map');
      return {};
    }
    return Map<String, dynamic>.from(raw);
  }

  void _validateLayoutTemplates(
    List<Map<String, dynamic>> templates,
    Set<String> patterns,
    Set<String> components,
    Map<String, dynamic> spacingSpec,
    Map<String, dynamic> radiiSpec,
    Map<String, dynamic> shadowSpec,
    List<String> issues,
  ) {
    for (var index = 0; index < templates.length; index++) {
      final template = templates[index];
      final label =
          template['name'] is String && (template['name'] as String).isNotEmpty
          ? template['name'] as String
          : (template['id'] is String && (template['id'] as String).isNotEmpty
                ? template['id'] as String
                : 'template_${index + 1}');

      final referencedPatterns = <String>{};
      referencedPatterns.addAll(
        _extractStringList(
          template,
          'componentPatterns',
          'layout_template_bundle.json',
          issues,
          optional: true,
        ),
      );
      referencedPatterns.addAll(
        _extractStringList(
          template,
          'patterns',
          'layout_template_bundle.json',
          issues,
          optional: true,
        ),
      );
      final singlePattern = template['pattern'];
      if (singlePattern is String && singlePattern.trim().isNotEmpty) {
        referencedPatterns.add(singlePattern.trim());
      }
      if (referencedPatterns.isEmpty) {
        issues.add(
          'layout_template_bundle.json: $label does not reference any component patterns',
        );
      } else {
        for (final pattern in referencedPatterns) {
          if (!patterns.contains(pattern)) {
            issues.add(
              'layout_template_bundle.json: $label references unknown component pattern $pattern',
            );
          }
        }
      }

      final templateComponents = _extractStringList(
        template,
        'components',
        'layout_template_bundle.json',
        issues,
        optional: true,
      );
      for (final component in templateComponents) {
        if (!components.contains(component)) {
          issues.add(
            'layout_template_bundle.json: $label references unknown component $component',
          );
        }
      }

      _validateDesignProperty(
        label,
        template,
        'spacing',
        spacingSpec,
        'visual_design_lift_spec.json',
        issues,
      );
      _validateDesignProperty(
        label,
        template,
        'radii',
        radiiSpec,
        'visual_design_lift_spec.json',
        issues,
      );
      _validateDesignProperty(
        label,
        template,
        'shadow',
        shadowSpec,
        'visual_design_lift_spec.json',
        issues,
      );
    }
  }

  void _validateDesignProperty(
    String templateLabel,
    Map<String, dynamic> template,
    String property,
    Map<String, dynamic> spec,
    String file,
    List<String> issues,
  ) {
    if (!template.containsKey(property) || template[property] == null) {
      issues.add(
        'layout_template_bundle.json: $templateLabel missing $property',
      );
      return;
    }
    if (spec.isEmpty) {
      return;
    }
    final value = template[property];
    if (value is String) {
      if (!spec.containsKey(value)) {
        issues.add(
          'layout_template_bundle.json: $templateLabel $property "$value" not defined in $file',
        );
      }
      return;
    }
    if (value is num) {
      final matches = spec.values.any((entry) => entry == value);
      if (!matches) {
        issues.add(
          'layout_template_bundle.json: $templateLabel $property $value not defined in $file',
        );
      }
      return;
    }
    issues.add(
      'layout_template_bundle.json: $templateLabel $property must be a string or number',
    );
  }

  List<String> _extractStringList(
    Map<String, dynamic> map,
    String key,
    String file,
    List<String> issues, {
    bool optional = false,
  }) {
    final raw = map[key];
    if (raw == null) {
      if (!optional) {
        issues.add('$file: missing $key');
      }
      return [];
    }
    if (raw is! List) {
      issues.add('$file: $key must be a list');
      return [];
    }
    final collected = <String>[];
    for (final entry in raw) {
      if (entry is String && entry.trim().isNotEmpty) {
        collected.add(entry.trim());
      }
    }
    return collected;
  }

  String? _extractNonEmptyString(
    Map<String, dynamic> map,
    String key,
    String label,
    List<String> issues,
  ) {
    final raw = map[key];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    issues.add('$label: missing $key');
    return null;
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class UXStabilityResult {
  final List<String> issues;
  final UXStabilitySummary summary;

  UXStabilityResult({required this.issues, required this.summary});

  Map<String, Object?> toJson() => <String, Object?>{
    'issues': issues,
    'summary': summary.toJson(),
  };
}

class UXStabilitySummary {
  final bool uxStable;
  final DateTime timestamp;

  UXStabilitySummary({required this.uxStable, required this.timestamp});

  Map<String, Object?> toJson() => <String, Object?>{
    'ux_stable': uxStable,
    'timestamp': timestamp.toIso8601String(),
  };
}

class UXStabilityCheckException implements Exception {
  final UXStabilityResult result;
  final String message;

  UXStabilityCheckException(this.result, this.message);

  @override
  String toString() => 'UXStabilityCheckException: $message';
}
