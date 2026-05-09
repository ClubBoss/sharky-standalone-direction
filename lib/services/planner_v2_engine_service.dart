import 'dart:convert';
import 'dart:io';

class PlannerV2EngineException implements IOException {
  const PlannerV2EngineException(this.message);

  final String message;

  @override
  String toString() => 'PlannerV2EngineException: $message';
}

class PlannerV2Plan {
  PlannerV2Plan({
    required this.moduleScores,
    required this.difficultyLevels,
    required this.routedPlan,
    required this.personaHintModes,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, double> moduleScores;
  final Map<String, String> difficultyLevels;
  final List<String> routedPlan;
  final Map<String, Object?> personaHintModes;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'module_scores': moduleScores,
    'difficulty_levels': difficultyLevels,
    'routed_plan': routedPlan,
    'persona_hint_modes': personaHintModes,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlannerV2EngineService {
  const PlannerV2EngineService();

  static const _inputPath = 'release/_reports/planner_v2_input_bundle.json';

  Future<PlannerV2Plan> build() async {
    final bundle = await _loadAsciiJson(_inputPath);

    final moduleData = _extractMap(bundle['module_data']);
    final personaData = _extractMap(bundle['persona_data']);
    final hintData = _extractMap(bundle['hint_data']);
    final summaryData = _extractMap(bundle['summary']);

    final adaptiveRouter = _extractMap(moduleData['adaptive_router']);
    final groups = _extractMap(adaptiveRouter['groups']);

    final moduleScores = _buildModuleScores(groups, summaryData);
    final difficultyLevels = _buildDifficultyLevels(moduleScores);
    final routedPlan = moduleScores.keys.toList()
      ..sort((a, b) => moduleScores[b]!.compareTo(moduleScores[a]!));

    final personaHintModes = _buildPersonaHintModes(personaData, hintData);

    final avgScore = moduleScores.isEmpty
        ? 0.0
        : moduleScores.values.reduce((a, b) => a + b) / moduleScores.length;
    final totalModules =
        (summaryData['module_count'] as int?) ?? moduleScores.length;

    final summary = {'module_count': totalModules, 'avg_score': avgScore};

    return PlannerV2Plan(
      moduleScores: moduleScores,
      difficultyLevels: difficultyLevels,
      routedPlan: routedPlan,
      personaHintModes: personaHintModes,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlannerV2EngineException('Missing bundle $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PlannerV2EngineException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PlannerV2EngineException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};

  Map<String, double> _buildModuleScores(
    Map<String, Object?> groups,
    Map<String, Object?> summary,
  ) {
    final plan = <String, double>{};
    final reinforcementWeight = _extractDouble(summary['avg_reinforcement']);
    groups.forEach((group, entries) {
      final weight = _groupWeight(group);
      if (entries is List) {
        for (final entry in entries.whereType<Map<String, Object?>>()) {
          final module = (entry['module'] as String?) ?? 'unknown';
          final score =
              _extractDouble(entry['score']) * weight + reinforcementWeight;
          plan[module] = score.clamp(0.0, 1.0);
        }
      }
    });
    return plan;
  }

  Map<String, String> _buildDifficultyLevels(Map<String, double> scores) {
    final levels = <String, String>{};
    scores.forEach((module, score) {
      if (score >= 0.8) {
        levels[module] = 'high';
      } else if (score >= 0.5) {
        levels[module] = 'medium';
      } else {
        levels[module] = 'low';
      }
    });
    return levels;
  }

  Map<String, Object?> _buildPersonaHintModes(
    Map<String, Object?> personaData,
    Map<String, Object?> hintData,
  ) {
    final tone = _extractMap(personaData['tone_profile']);
    final engagement = _extractMap(personaData['engagement']);
    final hintStrategy = _extractMap(personaData['hint_strategy']);
    final tier = hintData['tier'] ?? 'medium';
    final energy = _extractDouble(engagement['energy_level']);
    return {
      'tone_friendly': tone['friendly'] ?? false,
      'tone_supportive': tone['supportive'] ?? false,
      'tone_directive': tone['directive'] ?? false,
      'visual_hints': hintStrategy['visual_hints_enabled'] ?? false,
      'learning_hints': hintStrategy['learning_hints_enabled'] ?? false,
      'tier': tier,
      'energy_level': energy,
    };
  }

  double _groupWeight(String group) {
    switch (group) {
      case 'priority':
        return 1.0;
      case 'mid':
        return 0.8;
      case 'fallback':
        return 0.6;
      default:
        return 0.5;
    }
  }

  double _extractDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
