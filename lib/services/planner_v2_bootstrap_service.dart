import 'dart:convert';
import 'dart:io';

class PlannerV2BootstrapException implements IOException {
  const PlannerV2BootstrapException(this.message);

  final String message;

  @override
  String toString() => 'PlannerV2BootstrapException: $message';
}

class PlannerV2InputBundle {
  PlannerV2InputBundle({
    required this.moduleData,
    required this.personaData,
    required this.hintData,
    required this.reinforcementData,
    required this.adaptiveData,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, Object?> moduleData;
  final Map<String, Object?> personaData;
  final Map<String, Object?> hintData;
  final Map<String, Object?> reinforcementData;
  final Map<String, Object?> adaptiveData;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'module_data': moduleData,
    'persona_data': personaData,
    'hint_data': hintData,
    'reinforcement_data': reinforcementData,
    'adaptive_data': adaptiveData,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlannerV2BootstrapService {
  const PlannerV2BootstrapService();

  static const _paths = [
    'release/_reports/content_cohesion_summary.json',
    'release/_reports/content_gap_summary.json',
    'release/_reports/high_order_synthesis_summary.json',
    'release/_reports/review_loop_integrator_summary.json',
    'release/_reports/reinforcement_planner_summary.json',
    'release/_reports/adaptive_content_router_summary.json',
    'release/_reports/adaptive_plan_harness_summary.json',
    'release/_reports/persona_interaction_map.json',
    'release/_reports/hint_routing_bundle.json',
  ];

  Future<PlannerV2InputBundle> build() async {
    final cohesion = await _loadAsciiJson(_paths[0]);
    final gap = await _loadAsciiJson(_paths[1]);
    final synthesis = await _loadAsciiJson(_paths[2]);
    final reviewLoop = await _loadAsciiJson(_paths[3]);
    final reinforcement = await _loadAsciiJson(_paths[4]);
    final router = await _loadAsciiJson(_paths[5]);
    final adaptivePlan = await _loadAsciiJson(_paths[6]);
    final persona = await _loadAsciiJson(_paths[7]);
    final hintRouting = await _loadAsciiJson(_paths[8]);

    final reviewLoopMap = _extractMap(reviewLoop);
    final reinforcementMap = _extractMap(reinforcement);
    final adaptiveMap = _extractMap(adaptivePlan);
    final adaptiveGroups = adaptiveMap['groups'];
    final moduleCount =
        (adaptivePlan['module_count'] as int?) ??
        (adaptiveGroups is Map
            ? (adaptiveGroups['all'] as List?)?.length ?? 0
            : 0);
    final avgPriority = _extractDouble(
      reviewLoopMap['avg_priority'] ?? reviewLoopMap['priority_score'],
    );
    final avgReinforcement = _extractDouble(
      reinforcementMap['reinforcement_score'] ??
          reinforcementMap['avg_reinforcement'],
    );

    final moduleData = {
      'content_cohesion': cohesion,
      'content_gap': gap,
      'high_order_synthesis': synthesis,
      'review_loop': reviewLoop,
      'adaptive_router': router,
    };
    final personaData = {
      'tone_profile': persona['tone_profile'],
      'hint_strategy': persona['hint_rules'],
      'engagement': persona['engagement_rules'],
    };
    final hintData = {
      'tier': hintRouting['tier'],
      'placement_candidates': hintRouting['placement_candidates'],
      'layout_focus': hintRouting['layout_focus'],
    };
    final reinforcementData = reinforcement;
    final adaptiveData = adaptivePlan;
    final summary = {
      'module_count': moduleCount,
      'avg_priority': avgPriority,
      'avg_reinforcement': avgReinforcement,
    };

    return PlannerV2InputBundle(
      moduleData: moduleData,
      personaData: personaData,
      hintData: hintData,
      reinforcementData: reinforcementData,
      adaptiveData: adaptiveData,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlannerV2BootstrapException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PlannerV2BootstrapException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PlannerV2BootstrapException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  double _extractDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, Object?> _extractMap(Object? value) {
    if (value is Map<String, Object?>) return value;
    return const {};
  }
}
