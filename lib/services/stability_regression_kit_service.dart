import 'dart:convert';
import 'dart:io';

class StabilityRegressionException implements IOException {
  const StabilityRegressionException(this.message);

  final String message;

  @override
  String toString() => 'StabilityRegressionException: $message';
}

class StabilityRegressionResult {
  StabilityRegressionResult({
    required this.healthDrop,
    required this.plannerInvalid,
    required this.routingInvalid,
    required this.overlayInvalid,
    required this.summary,
    required this.timestamp,
  });

  final bool healthDrop;
  final bool plannerInvalid;
  final bool routingInvalid;
  final bool overlayInvalid;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'health_drop': healthDrop,
    'planner_invalid': plannerInvalid,
    'routing_invalid': routingInvalid,
    'overlay_invalid': overlayInvalid,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class StabilityRegressionKitService {
  const StabilityRegressionKitService();

  static const _paths = [
    'release/_reports/stability_snapshot_v2.json',
    'release/_reports/planner_v2_plan.json',
    'release/_reports/explanation_routing_bundle.json',
    'release/_reports/tutorial_overlay_spec.json',
  ];

  Future<StabilityRegressionResult> run() async {
    final snapshot = await _loadAsciiJson(_paths[0]);
    final plan = await _loadAsciiJson(_paths[1]);
    final routing = await _loadAsciiJson(_paths[2]);
    final overlay = await _loadAsciiJson(_paths[3]);

    final baselineHealth =
        _extractMap(snapshot['summary'])['health_score'] ?? 0.0;
    final newHealth = _recomputeHealth(snapshot);
    final healthDrop = newHealth < (baselineHealth as num) * 0.95;

    final plannerInvalid = !_validatePlanner(plan);
    final routingInvalid = !_validateRouting(routing);
    final overlayInvalid = !_validateOverlay(overlay);

    final summary = {
      'regression_detected':
          healthDrop || plannerInvalid || routingInvalid || overlayInvalid,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return StabilityRegressionResult(
      healthDrop: healthDrop,
      plannerInvalid: plannerInvalid,
      routingInvalid: routingInvalid,
      overlayInvalid: overlayInvalid,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StabilityRegressionException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw StabilityRegressionException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw StabilityRegressionException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  double _recomputeHealth(Map<String, Object?> snapshot) {
    final content = _extractMap(snapshot['content_metrics']);
    final planner = _extractMap(snapshot['planner_metrics']);
    final visual = _extractMap(snapshot['visual_metrics']);

    return _computeHealthScore(
      _toDouble(content['cohesion_score']),
      _toDouble(planner['avg_priority']),
      _toDouble(planner['avg_reinforcement']),
      _toDouble(visual['visual_cohesion_v3']),
    );
  }

  bool _validatePlanner(Map<String, Object?> plan) {
    return plan.containsKey('module_scores') &&
        plan.containsKey('difficulty_levels') &&
        plan.containsKey('routed_plan') &&
        plan.containsKey('summary');
  }

  bool _validateRouting(Map<String, Object?> routing) {
    final map = _extractMap(routing['routing_map']);
    final triggers = _extractMap(routing['triggers']);
    return map.containsKey('header') &&
        map.containsKey('hint') &&
        triggers.containsKey('on_profile_open') &&
        triggers.containsKey('after_summary_scroll');
  }

  bool _validateOverlay(Map<String, Object?> overlay) {
    final flow = overlay['overlay_flow'];
    if (flow is! Map) return false;
    final steps = flow['steps'];
    if (steps is! List) return false;
    final ids = steps
        .whereType<Map>()
        .map((step) => step['id'])
        .whereType<String>()
        .toSet();
    return ids.containsAll([
      'header',
      'hint',
      'training',
      'focus',
      'suggestions',
    ]);
  }

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};

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
