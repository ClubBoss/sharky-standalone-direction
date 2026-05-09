import 'dart:convert';
import 'dart:io';

class PlannerRecommendation {
  PlannerRecommendation({
    required this.module,
    required this.score,
    required this.severity,
    required this.group,
  });

  final String module;
  final double score;
  final String severity;
  final String group;

  Map<String, Object?> toJson() => {
    'module': module,
    'score': score,
    'severity': severity,
    'group': group,
  };
}

class PlannerBridgeService {
  const PlannerBridgeService();

  Future<Map<String, List<PlannerRecommendation>>> build() async {
    final summary = await _loadJson(
      'release/_reports/adaptive_content_router_summary.json',
    );
    final groups = <String, List<PlannerRecommendation>>{
      'priority': [],
      'mid': [],
      'fallback': [],
      'all': [],
    };
    final data = summary['groups'] as Map<String, dynamic>? ?? {};
    for (final group in ['priority', 'mid', 'fallback']) {
      final entries = (data[group] as List<dynamic>? ?? []);
      for (final entry in entries) {
        if (entry is Map<String, dynamic>) {
          final module = entry['module'] as String? ?? 'unknown';
          final score = _toDouble(entry['reinforcement_score']) ?? 0.0;
          final severity = entry['severity_flag'] as String? ?? 'low';
          final rec = PlannerRecommendation(
            module: module,
            score: score,
            severity: severity,
            group: group,
          );
          groups[group]!.add(rec);
          groups['all']!.add(rec);
        }
      }
    }
    return groups;
  }

  Future<Map<String, Object?>> _loadJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing planner input: $path');
    }
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) {
      throw StateError('Non-ASCII file: $path');
    }
    try {
      final decoded = json.decode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
      throw StateError('Expected JSON object: $path');
    } catch (error) {
      throw StateError('JSON error ($path): $error');
    }
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _isAscii(List<int> bytes) =>
      bytes.every((byte) => byte >= 0 && byte <= 127);
}
