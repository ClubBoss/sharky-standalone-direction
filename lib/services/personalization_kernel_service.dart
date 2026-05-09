import 'dart:convert';
import 'dart:io';

class PersonalizationKernelException implements IOException {
  const PersonalizationKernelException(this.message);

  final String message;

  @override
  String toString() => 'PersonalizationKernelException: $message';
}

class PersonalizationKernelBundle {
  PersonalizationKernelBundle({
    required this.increaseContrast,
    required this.reduceSpacingNoise,
    required this.suggestTokenUnification,
    required this.priorityModules,
    required this.midModules,
    required this.personalizationRiskScore,
    required this.timestamp,
  });

  final bool increaseContrast;
  final bool reduceSpacingNoise;
  final bool suggestTokenUnification;
  final List<String> priorityModules;
  final List<String> midModules;
  final double personalizationRiskScore;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'visual_adjustments': {
      'increase_contrast': increaseContrast,
      'reduce_spacing_noise': reduceSpacingNoise,
      'suggest_token_unification': suggestTokenUnification,
    },
    'learning_adjustments': {
      'priority_boost': priorityModules,
      'mid_attention': midModules,
    },
    'ui_style_hints': const [
      'use_consistent_padding',
      'limit_nested_rows',
      'prefer_standard_radii',
    ],
    'explanation_priors': {
      'needs_more_context': personalizationRiskScore > 0.50,
      'prefer_brief_prompts': personalizationRiskScore < 0.25,
    },
    'persona_baseline': {
      'sharky_hint_style': 'friendly_minimal',
      'sharky_context_sensitivity': personalizationRiskScore,
    },
    'timestamp': timestamp.toIso8601String(),
  };
}

class PersonalizationKernelService {
  const PersonalizationKernelService();

  static const _contextPath =
      'release/_reports/personalization_context_bundle.json';

  Future<PersonalizationKernelBundle> build() async {
    final context = await _loadAsciiJson(_contextPath);

    final visual = _extractVisual(context);
    final modules = _extractLearning(context);
    final riskScore = _extractRisk(context);

    return PersonalizationKernelBundle(
      increaseContrast: visual.visualCohesionIndex < 0.70,
      reduceSpacingNoise: visual.spacingInconsistencies > 2,
      suggestTokenUnification: visual.tokenMismatches > 1,
      priorityModules: modules.priority,
      midModules: modules.mid,
      personalizationRiskScore: riskScore,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PersonalizationKernelException('Missing context bundle at $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PersonalizationKernelException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PersonalizationKernelException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  _VisualMetrics _extractVisual(Map<String, Object?> data) {
    final visual = data['visual'];
    if (visual is! Map<String, Object?>) {
      throw PersonalizationKernelException('Missing visual metrics');
    }
    return _VisualMetrics(
      visualCohesionIndex: _toDouble(visual['visual_cohesion_index']) ?? 0.0,
      tokenMismatches: _toInt(visual['token_mismatches']),
      spacingInconsistencies: _toInt(visual['spacing_inconsistencies']),
      layoutAnomalies: _toInt(visual['layout_anomalies']),
      componentDiversityScore:
          _toDouble(visual['component_diversity_score']) ?? 0.0,
    );
  }

  _LearningModules _extractLearning(Map<String, Object?> data) {
    final learning = data['learning'];
    if (learning is! Map<String, Object?>) {
      throw PersonalizationKernelException('Missing learning section');
    }
    return _LearningModules(
      priority: _extractList(learning['priority_modules']),
      mid: _extractList(learning['mid_modules']),
    );
  }

  double _extractRisk(Map<String, Object?> data) {
    final risk = data['personalization_risk_score'];
    return (_toDouble(risk) ?? 0.0).clamp(0.0, 1.0);
  }

  List<String> _extractList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  double? _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class _VisualMetrics {
  _VisualMetrics({
    required this.visualCohesionIndex,
    required this.tokenMismatches,
    required this.spacingInconsistencies,
    required this.layoutAnomalies,
    required this.componentDiversityScore,
  });

  final double visualCohesionIndex;
  final int tokenMismatches;
  final int spacingInconsistencies;
  final int layoutAnomalies;
  final double componentDiversityScore;
}

class _LearningModules {
  _LearningModules({required this.priority, required this.mid});

  final List<String> priority;
  final List<String> mid;
}
