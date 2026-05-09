import 'dart:convert';
import 'dart:io';

class UniversalQASnapshotException implements IOException {
  const UniversalQASnapshotException(this.message);

  final String message;

  @override
  String toString() => 'UniversalQASnapshotException: $message';
}

class UniversalQASnapshotBundle {
  UniversalQASnapshotBundle({
    required this.contentMetrics,
    required this.plannerMetrics,
    required this.visualMetrics,
    required this.personaMetrics,
    required this.hintMetrics,
    required this.trainingPathMetrics,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, Object?> contentMetrics;
  final Map<String, Object?> plannerMetrics;
  final Map<String, Object?> visualMetrics;
  final Map<String, Object?> personaMetrics;
  final Map<String, Object?> hintMetrics;
  final Map<String, Object?> trainingPathMetrics;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'content_metrics': contentMetrics,
    'planner_metrics': plannerMetrics,
    'visual_metrics': visualMetrics,
    'persona_metrics': personaMetrics,
    'hint_metrics': hintMetrics,
    'training_path_metrics': trainingPathMetrics,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class UniversalQASnapshotService {
  const UniversalQASnapshotService();

  static const _paths = [
    'release/_reports/content_cohesion_summary.json',
    'release/_reports/content_gap_summary.json',
    'release/_reports/high_order_synthesis_summary.json',
    'release/_reports/review_loop_integrator_summary.json',
    'release/_reports/reinforcement_planner_summary.json',
    'release/_reports/adaptive_content_router_summary.json',
    'release/_reports/adaptive_plan_harness_summary.json',
    'release/_reports/planner_v2_input_bundle.json',
    'release/_reports/planner_v2_plan.json',
    'release/_reports/training_path_visualization.json',
    'release/_reports/visual_design_lift_spec.json',
    'release/_reports/component_unification_map.json',
    'release/_reports/layout_template_bundle.json',
    'release/_reports/component_library_bundle.json',
    'release/_reports/design_lift_implementation_map.json',
    'release/_reports/visual_cohesion_v3.json',
    'release/_reports/persona_engine_bundle.json',
    'release/_reports/persona_interaction_map.json',
    'release/_reports/hint_routing_bundle.json',
    'release/_reports/player_profile_context_bundle.json',
    'release/_reports/explanation_engine_bundle.json',
    'release/_reports/player_profile_screen_spec.json',
    'release/_reports/explanation_routing_bundle.json',
    'release/_reports/tutorial_overlay_spec.json',
  ];

  Future<UniversalQASnapshotBundle> capture() async {
    final loaded = <String, Map<String, Object?>>{};
    for (final path in _paths) {
      loaded[path] = await _loadAsciiJson(path);
    }

    final contentMetrics = {
      'cohesion_score': _valueFromKeys(loaded[_paths[0]]!, [
        'score',
        'cohesion_score',
      ]),
      'gap_warn': _valueFromKeys(loaded[_paths[1]]!, ['warnings', 'gap_count']),
      'synthesis_score': _valueFromKeys(loaded[_paths[2]]!, [
        'score',
        'index',
        'high_order_index',
      ]),
    };

    final plannerMetrics = {
      'module_count': _valueFromMap(loaded[_paths[8]]!, [
        'summary',
        'module_count',
      ]),
      'avg_priority': _valueFromKeys(loaded[_paths[3]]!, [
        'avg_priority',
        'priority_score',
      ]),
      'avg_reinforcement': _valueFromKeys(loaded[_paths[4]]!, [
        'reinforcement_score',
        'avg_reinforcement',
      ]),
    };

    final visualMetrics = {
      'visual_cohesion_v3': _valueFromKeys(loaded[_paths[15]]!, [
        'visual_cohesion_v3_index',
      ]),
      'layout_rules': (loaded[_paths[12]]!['stats'] ?? {'count': 0}),
    };

    final personaMetrics = {
      'tone': loaded[_paths[16]]!['persona_baseline'] ?? {},
      'engagement': loaded[_paths[16]]!['engagement_profile'] ?? {},
      'interaction_priority':
          loaded[_paths[17]]!['interaction_priority'] ?? 'medium',
    };

    final hintMetrics = {
      'tier': loaded[_paths[18]]!['tier'] ?? 'medium',
      'placements': loaded[_paths[18]]!['placement_candidates'] ?? {},
    };

    final trainingPathMetrics = {
      'path_nodes': loaded[_paths[9]]!['path_nodes'] ?? [],
      'priority_count': _valueFromKeys(loaded[_paths[9]]!, [
        'summary',
        'priority_count',
      ]),
    };

    final healthScore = _computeHealthScore(
      _toDouble(contentMetrics['cohesion_score']),
      _toDouble(plannerMetrics['avg_priority']),
      _toDouble(plannerMetrics['avg_reinforcement']),
      _toDouble(visualMetrics['visual_cohesion_v3']),
    );

    final summary = {
      'health_score': healthScore,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return UniversalQASnapshotBundle(
      contentMetrics: contentMetrics,
      plannerMetrics: plannerMetrics,
      visualMetrics: visualMetrics,
      personaMetrics: personaMetrics,
      hintMetrics: hintMetrics,
      trainingPathMetrics: trainingPathMetrics,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw UniversalQASnapshotException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw UniversalQASnapshotException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw UniversalQASnapshotException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  double _valueFromKeys(Map<String, Object?> data, List<String> keys) {
    for (final key in keys) {
      final value = _extractNested(data, key);
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return 0.0;
  }

  double _valueFromMap(Map<String, Object?> data, List<String> path) {
    Object? current = data;
    for (final segment in path) {
      if (current is Map<String, Object?> && current.containsKey(segment)) {
        current = current[segment];
      } else {
        return 0.0;
      }
    }
    if (current is num) return current.toDouble();
    if (current is String) return double.tryParse(current) ?? 0.0;
    return 0.0;
  }

  Object? _extractNested(Map<String, Object?> data, String key) {
    if (data.containsKey(key)) return data[key];
    for (final value in data.values) {
      if (value is Map<String, Object?>) {
        final nested = _extractNested(value, key);
        if (nested != 0.0) return nested;
      }
    }
    return 0.0;
  }

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double _computeHealthScore(
    double cohesion,
    double priority,
    double reinforcement,
    double visualIndex,
  ) {
    final normalizers = [cohesion, priority, reinforcement, visualIndex];
    final normalized = normalizers
        .map((value) => value.clamp(0.0, 1.0))
        .fold<double>(0.0, (sum, element) => sum + element);
    return (normalized / normalizers.length).clamp(0.0, 1.0);
  }
}
