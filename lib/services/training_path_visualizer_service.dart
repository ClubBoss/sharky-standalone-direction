import 'dart:convert';
import 'dart:io';

class TrainingPathVisualizerException implements IOException {
  const TrainingPathVisualizerException(this.message);

  final String message;

  @override
  String toString() => 'TrainingPathVisualizerException: $message';
}

class TrainingPathVisualization {
  TrainingPathVisualization({
    required this.pathNodes,
    required this.groupedPaths,
    required this.pathGraph,
    required this.summary,
    required this.timestamp,
  });

  final List<Map<String, Object?>> pathNodes;
  final Map<String, List<String>> groupedPaths;
  final List<Map<String, String>> pathGraph;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'path_nodes': pathNodes,
    'grouped_paths': groupedPaths,
    'path_graph': pathGraph,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class TrainingPathVisualizerService {
  const TrainingPathVisualizerService();

  static const _inputPath = 'release/_reports/planner_v2_plan.json';

  Future<TrainingPathVisualization> build() async {
    final bundle = await _loadAsciiJson(_inputPath);

    final moduleScores = _extractDoubleMap(bundle['module_scores']);
    final difficultyLevels = _extractStringMap(bundle['difficulty_levels']);
    final routedPlan = _extractStringList(bundle['routed_plan']);
    final personaHintModes = _extractMap(bundle['persona_hint_modes']);
    final summaryData = _extractMap(bundle['summary']);

    final pathNodes = _buildPathNodes(
      routedPlan,
      moduleScores,
      difficultyLevels,
      personaHintModes,
    );
    final groupedPaths = _buildGroupedPaths(difficultyLevels);
    final pathGraph = _buildPathGraph(routedPlan);
    final summary = {
      'module_count': pathNodes.length,
      'priority_count': groupedPaths['priority']?.length ?? 0,
      'avg_score': summaryData['avg_score'] ?? 0.0,
    };

    return TrainingPathVisualization(
      pathNodes: pathNodes,
      groupedPaths: groupedPaths,
      pathGraph: pathGraph,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw TrainingPathVisualizerException('Missing bundle $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw TrainingPathVisualizerException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw TrainingPathVisualizerException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  List<Map<String, Object?>> _buildPathNodes(
    List<String> modules,
    Map<String, double> scores,
    Map<String, String> difficulties,
    Map<String, Object?> personaHintModes,
  ) {
    final hintMode = personaHintModes.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join(',');
    return [
      for (final module in modules)
        {
          'module': module,
          'score': scores[module] ?? 0.0,
          'difficulty': difficulties[module] ?? 'medium',
          'hint_mode': hintMode,
        },
    ];
  }

  Map<String, List<String>> _buildGroupedPaths(
    Map<String, String> difficultyLevels,
  ) {
    final groups = <String, List<String>>{
      'priority': [],
      'medium': [],
      'fallback': [],
    };
    difficultyLevels.forEach((module, level) {
      final key = level == 'high'
          ? 'priority'
          : (level == 'medium' ? 'medium' : 'fallback');
      groups[key]?.add(module);
    });
    return groups;
  }

  List<Map<String, String>> _buildPathGraph(List<String> routedPlan) {
    final graph = <Map<String, String>>[];
    for (var i = 0; i < routedPlan.length - 1; i++) {
      graph.add({'from': routedPlan[i], 'to': routedPlan[i + 1]});
    }
    return graph;
  }

  Map<String, double> _extractDoubleMap(Object? value) {
    final result = <String, double>{};
    if (value is Map) {
      value.forEach((key, val) {
        final doubleVal = _toDouble(val);
        result[key.toString()] = doubleVal;
      });
    }
    return result;
  }

  Map<String, String> _extractStringMap(Object? value) {
    final result = <String, String>{};
    if (value is Map) {
      value.forEach((key, val) {
        result[key.toString()] = val?.toString() ?? 'medium';
      });
    }
    return result;
  }

  List<String> _extractStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
