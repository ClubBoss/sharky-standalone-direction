import 'dart:convert';
import 'dart:io';

class AdaptivePlanEntry {
  AdaptivePlanEntry({
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

class AdaptivePlanHarnessService {
  const AdaptivePlanHarnessService();

  Future<Map<String, List<AdaptivePlanEntry>>> build() async {
    final summary = await _loadJson(
      'release/_reports/planner_bridge_summary.json',
    );
    final groups = <String, List<AdaptivePlanEntry>>{
      'priority': [],
      'mid': [],
      'fallback': [],
      'all': [],
    };
    final data = summary['groups'] as Map<String, dynamic>? ?? {};
    for (final group in ['priority', 'mid', 'fallback']) {
      final entries = (data[group] as List<dynamic>? ?? []);
      for (final item in entries) {
        if (item is Map<String, dynamic>) {
          final module = item['module'] as String? ?? 'unknown';
          final score = _toDouble(item['score']) ?? 0.0;
          final severity = item['severity'] as String? ?? 'low';
          final entry = AdaptivePlanEntry(
            module: module,
            score: score,
            severity: severity,
            group: group,
          );
          groups[group]!.add(entry);
          groups['all']!.add(entry);
        }
      }
    }
    return groups;
  }

  Future<Map<String, Object?>> _loadJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw StateError('Missing planner bridge file: $path');
    }
    final bytes = await file.readAsBytes();
    if (!_isAscii(bytes)) {
      throw StateError('Non-ASCII file: $path');
    }
    try {
      final decoded = json.decode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
      throw StateError('Expected JSON object at $path');
    } catch (error) {
      throw StateError('JSON parse error ($path): $error');
    }
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _isAscii(List<int> bytes) => bytes.every((b) => b >= 0 && b <= 127);
}
