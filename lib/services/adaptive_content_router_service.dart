import 'dart:convert';
import 'dart:io';

class RoutedModule {
  RoutedModule({
    required this.module,
    required this.reinforcementScore,
    required this.severityFlag,
    required this.routeGroup,
  });

  final String module;
  final double reinforcementScore;
  final String severityFlag;
  final String routeGroup;

  Map<String, Object?> toJson() => {
    'module': module,
    'reinforcement_score': reinforcementScore,
    'severity_flag': severityFlag,
    'route_group': routeGroup,
  };
}

class AdaptiveContentRouterService {
  const AdaptiveContentRouterService();

  Future<Map<String, List<RoutedModule>>> route() async {
    final summary = await _loadJson(
      'release/_reports/reinforcement_planner_summary.json',
    );
    final plans = <Map<String, dynamic>>[];
    if (summary['plans'] is List) {
      for (final entry in summary['plans'] as List) {
        if (entry is Map<String, dynamic>) {
          plans.add(entry);
        }
      }
    }

    final groups = <String, List<RoutedModule>>{
      'priority': [],
      'mid': [],
      'fallback': [],
    };

    for (final plan in plans) {
      final module = plan['module'] as String? ?? 'unknown';
      final reinforcement = _toDouble(plan['reinforcement_score']) ?? 0.0;
      final severity = plan['severity_flag'] as String? ?? 'low';
      final routeGroup = _determineGroup(reinforcement);
      groups[routeGroup]!.add(
        RoutedModule(
          module: module,
          reinforcementScore: reinforcement,
          severityFlag: severity,
          routeGroup: routeGroup,
        ),
      );
    }

    for (final list in groups.values) {
      list.sort((a, b) => b.reinforcementScore.compareTo(a.reinforcementScore));
    }

    return groups;
  }

  String _determineGroup(double score) {
    if (score >= 0.75) return 'priority';
    if (score >= 0.40) return 'mid';
    return 'fallback';
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<Map<String, Object?>> _loadJson(String path) async {
    final file = File(path);
    if (!await file.exists()) throw StateError('Missing file: $path');
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) {
      throw StateError('Non-ASCII content: $path');
    }
    try {
      final decoded = json.decode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
      throw StateError('Expected JSON object: $path');
    } catch (error) {
      throw StateError('JSON parse failed ($path): $error');
    }
  }

  bool _isAscii(List<int> bytes) =>
      bytes.every((byte) => byte >= 0 && byte <= 127);
}
