import 'dart:convert';
import 'dart:io';

class ContentConsistencyException implements IOException {
  const ContentConsistencyException(this.message);

  final String message;

  @override
  String toString() => 'ContentConsistencyException: $message';
}

class ContentConsistencyResult {
  ContentConsistencyResult({
    required this.inconsistencies,
    required this.summary,
  });

  final List<String> inconsistencies;
  final Map<String, Object?> summary;
}

class ContentConsistencyPassService {
  const ContentConsistencyPassService();

  static const _paths = [
    'release/_reports/stability_snapshot_v2.json',
    'release/_reports/content_cohesion_summary.json',
    'release/_reports/content_gap_summary.json',
    'release/_reports/high_order_synthesis_summary.json',
    'release/_reports/reinforcement_planner_summary.json',
    'release/_reports/adaptive_content_router_summary.json',
    'release/_reports/adaptive_plan_harness_summary.json',
    'release/_reports/planner_v2_plan.json',
    'release/_reports/training_path_visualization.json',
  ];

  Future<ContentConsistencyResult> check() async {
    final data = <String, Map<String, Object?>>{};
    for (final path in _paths) {
      data[path] = await _loadAsciiJson(path);
    }

    final snapshotSummary = _extractMap(data[_paths[0]]!['summary']);
    final baseModuleCount = _toInt(snapshotSummary['module_count']);
    final cohesionModules = _extractModuleList(data[_paths[1]]!, 'modules');
    final gapModules = _extractModuleList(data[_paths[2]]!, 'modules');
    final synthesisModules = _extractModuleList(data[_paths[3]]!, 'modules');
    final routerModules = _extractModulesFromGroups(data[_paths[5]]!['groups']);
    final harnessModules = _extractModulesFromGroups(
      data[_paths[6]]!['groups'],
    );
    final plan = data[_paths[7]]!;
    final routedPlan = _extractStringList(plan['routed_plan']);
    final moduleScores = _extractMap(
      plan['module_scores'],
    ).map((k, v) => MapEntry(k, _toDouble(v)));
    final training = data[_paths[8]]!;
    final pathGraph = (training['path_graph'] as List?)
        ?.whereType<Map>()
        .map((edge) => '${edge['from']}->${edge['to']}')
        .toList();

    final inconsistencies = <String>[];
    if (baseModuleCount != cohesionModules.length ||
        baseModuleCount != gapModules.length ||
        baseModuleCount != routedPlan.length) {
      inconsistencies.add('Module count mismatch across core reports.');
    }

    final cohesionSet = {
      ...cohesionModules,
      ...gapModules,
      ...synthesisModules,
    };
    final routerSet = {...routerModules, ...harnessModules};
    final missingFromContent = routerSet.difference(cohesionSet);
    if (missingFromContent.isNotEmpty) {
      inconsistencies.add(
        'Router/harness modules missing from cohesion/gap (${missingFromContent.join(', ')}).',
      );
    }

    final pathEdges = pathGraph ?? [];
    for (var i = 0; i < routedPlan.length - 1; i++) {
      final edge = '${routedPlan[i]}->${routedPlan[i + 1]}';
      if (!pathEdges.contains(edge)) {
        inconsistencies.add(
          'Routed plan edge $edge missing from training path graph.',
        );
        break;
      }
    }

    if (moduleScores.values.any((score) => score < 0 || score.isNaN)) {
      inconsistencies.add('Module scores contain negative or invalid values.');
    }

    final summary = {
      'consistent': inconsistencies.isEmpty,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return ContentConsistencyResult(
      inconsistencies: inconsistencies,
      summary: summary,
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ContentConsistencyException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw ContentConsistencyException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw ContentConsistencyException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  List<String> _extractModuleList(Map<String, Object?> data, String key) =>
      (data[key] as List?)?.whereType<String>().toList() ?? [];

  Set<String> _extractModulesFromGroups(Object? value) {
    if (value is! Map) return {};
    final modules = <String>{};
    value.values.forEach((group) {
      if (group is List) {
        modules.addAll(group.whereType<String>());
      }
    });
    return modules;
  }

  List<String> _extractStringList(Object? value) =>
      (value as List?)?.whereType<String>().toList() ?? [];

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
