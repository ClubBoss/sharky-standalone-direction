import 'dart:convert';
import 'dart:io';

class ReinforcementPlan {
  ReinforcementPlan({
    required this.module,
    required this.priorityScore,
    required this.reinforcementScore,
    required this.severityFlag,
  });

  final String module;
  final double priorityScore;
  final double reinforcementScore;
  final String severityFlag;

  Map<String, Object?> toJson() => {
    'module': module,
    'priority_score': priorityScore,
    'reinforcement_score': reinforcementScore,
    'severity_flag': severityFlag,
  };
}

class ReinforcementPlannerService {
  const ReinforcementPlannerService();

  Future<List<ReinforcementPlan>> plan() async {
    final summary = await _loadJson(
      'release/_reports/review_loop_integrator_summary.json',
    );
    final bundles = <Map<String, dynamic>>[];
    if (summary['bundles'] is List) {
      for (final entry in summary['bundles'] as List) {
        if (entry is Map<String, dynamic> && entry['module'] is String) {
          bundles.add(entry);
        }
      }
    }
    final plans = <ReinforcementPlan>[];
    for (final bundle in bundles) {
      final module = bundle['module'] as String;
      final priority = _toDouble(bundle['priority_score']) ?? 0.0;
      final reinforcement = (priority * 1.25).clamp(0.0, 1.0);
      final severity = _severityFlag(reinforcement);
      plans.add(
        ReinforcementPlan(
          module: module,
          priorityScore: priority,
          reinforcementScore: reinforcement,
          severityFlag: severity,
        ),
      );
    }
    plans.sort((a, b) => b.reinforcementScore.compareTo(a.reinforcementScore));
    return plans;
  }

  Future<Map<String, Object?>> _loadJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing reinforcement input: $path');
    }
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) {
      throw StateError('Non-ASCII input: $path');
    }
    try {
      final decoded = json.decode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
      throw StateError('Expected JSON object: $path');
    } catch (error) {
      throw StateError('Invalid JSON ($path): $error');
    }
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _severityFlag(double score) {
    if (score >= 0.75) return 'high';
    if (score >= 0.40) return 'medium';
    return 'low';
  }

  bool _isAscii(List<int> bytes) =>
      bytes.every((byte) => byte >= 0 && byte <= 127);
}
