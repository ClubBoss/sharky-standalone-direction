import 'dart:convert';
import 'dart:io';

class PersonalizationReadinessBridgeException implements IOException {
  const PersonalizationReadinessBridgeException(this.message);

  final String message;

  @override
  String toString() => 'PersonalizationReadinessBridgeException: $message';
}

class PersonalizationContextBundle {
  PersonalizationContextBundle({
    required this.visualCohesionIndex,
    required this.tokenMismatches,
    required this.spacingInconsistencies,
    required this.layoutAnomalies,
    required this.componentDiversityScore,
    required this.priorityModules,
    required this.midModules,
    required this.fallbackModules,
    required this.allModules,
    required this.personalizationRiskScore,
    required this.timestamp,
  });

  final double visualCohesionIndex;
  final int tokenMismatches;
  final int spacingInconsistencies;
  final int layoutAnomalies;
  final double componentDiversityScore;
  final List<String> priorityModules;
  final List<String> midModules;
  final List<String> fallbackModules;
  final List<String> allModules;
  final double personalizationRiskScore;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'visual': {
      'visual_cohesion_index': visualCohesionIndex,
      'token_mismatches': tokenMismatches,
      'spacing_inconsistencies': spacingInconsistencies,
      'layout_anomalies': layoutAnomalies,
      'component_diversity_score': componentDiversityScore,
    },
    'learning': {
      'priority_modules': priorityModules,
      'mid_modules': midModules,
      'fallback_modules': fallbackModules,
      'all_modules': allModules,
    },
    'personalization_risk_score': personalizationRiskScore,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PersonalizationReadinessBridgeService {
  const PersonalizationReadinessBridgeService();

  static const _visualPath = 'release/_reports/visual_cohesion_final.json';
  static const _adaptivePath =
      'release/_reports/adaptive_plan_harness_summary.json';

  Future<PersonalizationContextBundle> build() async {
    final visual = await _loadAsciiJson(_visualPath);
    final adaptive = await _loadAsciiJson(_adaptivePath);

    final visualMetrics = _extractVisualMetrics(visual);
    final moduleGroups = _extractModuleGroups(adaptive);

    final riskScore = _computeRiskScore(
      visualIndex: visualMetrics.visualCohesionIndex,
      priorityCount: moduleGroups.priority.length,
      total: moduleGroups.all.length,
    );

    return PersonalizationContextBundle(
      visualCohesionIndex: visualMetrics.visualCohesionIndex,
      tokenMismatches: visualMetrics.tokenMismatches,
      spacingInconsistencies: visualMetrics.spacingInconsistencies,
      layoutAnomalies: visualMetrics.layoutAnomalies,
      componentDiversityScore: visualMetrics.componentDiversityScore,
      priorityModules: List.unmodifiable(moduleGroups.priority),
      midModules: List.unmodifiable(moduleGroups.mid),
      fallbackModules: List.unmodifiable(moduleGroups.fallback),
      allModules: List.unmodifiable(moduleGroups.all),
      personalizationRiskScore: riskScore,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PersonalizationReadinessBridgeException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PersonalizationReadinessBridgeException(
        'Non-ASCII content in $path',
      );
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PersonalizationReadinessBridgeException(
        'Invalid JSON structure in $path',
      );
    }
    return decoded;
  }

  _VisualMetrics _extractVisualMetrics(Map<String, Object?> data) {
    final visualSection = data['visual'];
    if (visualSection is! Map<String, Object?>) {
      throw PersonalizationReadinessBridgeException('Visual metrics missing');
    }
    final visualIndex =
        _toDouble(visualSection['visual_cohesion_index']) ??
        _toDouble(data['visual_cohesion_index']);
    final diversity =
        _toDouble(visualSection['component_diversity_score']) ?? 0.0;
    if (visualIndex == null) {
      throw PersonalizationReadinessBridgeException(
        'Missing visual cohesion index',
      );
    }
    return _VisualMetrics(
      visualCohesionIndex: visualIndex,
      tokenMismatches: _toInt(visualSection['token_mismatches']),
      spacingInconsistencies: _toInt(visualSection['spacing_inconsistencies']),
      layoutAnomalies: _toInt(visualSection['layout_anomalies']),
      componentDiversityScore: diversity,
    );
  }

  _ModuleGroups _extractModuleGroups(Map<String, Object?> data) {
    final learning = data['groups'];
    if (learning is! Map<String, Object?>) {
      throw PersonalizationReadinessBridgeException('Learning groups missing');
    }
    return _ModuleGroups(
      priority: _extractModuleNames(learning['priority']),
      mid: _extractModuleNames(learning['mid']),
      fallback: _extractModuleNames(learning['fallback']),
      all: _extractModuleNames(learning['all']),
    );
  }

  List<String> _extractModuleNames(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, Object?>>()
        .map((entry) => entry['module'])
        .whereType<String>()
        .toList();
  }

  double _computeRiskScore({
    required double visualIndex,
    required int priorityCount,
    required int total,
  }) {
    final priorityRatio = total == 0
        ? priorityCount.toDouble()
        : priorityCount / total;
    final risk = (1 - visualIndex) * 0.5 + (priorityRatio) * 0.5;
    return risk.clamp(0.0, 1.0);
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

class _ModuleGroups {
  _ModuleGroups({
    required this.priority,
    required this.mid,
    required this.fallback,
    required this.all,
  });

  final List<String> priority;
  final List<String> mid;
  final List<String> fallback;
  final List<String> all;
}
