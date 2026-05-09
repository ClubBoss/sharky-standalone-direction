import 'dart:convert';
import 'dart:io';

class ExplanationEngineException implements IOException {
  const ExplanationEngineException(this.message);

  final String message;

  @override
  String toString() => 'ExplanationEngineException: $message';
}

class ExplanationEngineBundle {
  ExplanationEngineBundle({
    required this.personaOverview,
    required this.hintStrategy,
    required this.trainingOverview,
    required this.recommendedFocus,
    required this.personaSuggestions,
    required this.summary,
    required this.timestamp,
  });

  final String personaOverview;
  final String hintStrategy;
  final String trainingOverview;
  final List<String> recommendedFocus;
  final List<String> personaSuggestions;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'persona_overview': personaOverview,
    'hint_strategy': hintStrategy,
    'training_overview': trainingOverview,
    'recommended_focus': recommendedFocus,
    'persona_suggestions': personaSuggestions,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ExplanationEngineService {
  const ExplanationEngineService();

  static const _inputPath =
      'release/_reports/player_profile_context_bundle.json';

  Future<ExplanationEngineBundle> build() async {
    final bundle = await _loadAsciiJson(_inputPath);

    final persona = _extractMap(bundle['persona_profile']);
    final hint = _extractMap(bundle['hint_profile']);
    final training = _extractMap(bundle['training_profile']);
    final summary = _extractMap(bundle['summary']);

    final preferredPaths =
        (training['preferred_paths'] as List?)?.whereType<String>().toList() ??
        const [];
    final difficultyDistribution =
        (training['difficulty_distribution'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ) ??
        const {};
    final personaOverview = _buildPersonaOverview(persona);
    final hintStrategy = _buildHintStrategy(hint);
    final trainingOverview = _buildTrainingOverview(
      preferredPaths,
      difficultyDistribution,
    );
    final recommendedFocus = _selectFocusModules(
      preferredPaths,
      difficultyDistribution,
    );
    final personaSuggestions = _buildPersonaSuggestions(persona);

    final summaryMap = {
      'module_count': summary['module_count'] ?? preferredPaths.length,
    };

    return ExplanationEngineBundle(
      personaOverview: personaOverview,
      hintStrategy: hintStrategy,
      trainingOverview: trainingOverview,
      recommendedFocus: recommendedFocus,
      personaSuggestions: personaSuggestions,
      summary: summaryMap,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ExplanationEngineException('Missing bundle $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw ExplanationEngineException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw ExplanationEngineException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  String _buildPersonaOverview(Map<String, Object?> persona) {
    final tone = _extractMap(persona['tone']);
    final engagement = _extractMap(persona['engagement']);
    final energy = _extractDouble(engagement['energy_level']);
    final depth = _extractDouble(engagement['context_depth']);
    final toneParts = <String>[];
    if (tone['friendly'] == true) toneParts.add('friendly');
    if (tone['supportive'] == true) toneParts.add('supportive');
    if (tone['directive'] == true) toneParts.add('directive');
    final toneText = toneParts.isNotEmpty
        ? toneParts.join(', ')
        : 'neutral tone';
    return 'Persona tone: $toneText; energy ${energy.toStringAsFixed(2)}, depth ${depth.toStringAsFixed(2)}.';
  }

  String _buildHintStrategy(Map<String, Object?> hint) {
    final tier = hint['tier'] ?? 'medium';
    final placements = _extractMap(hint['placements']);
    final active = placements.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');
    final segment = active.isEmpty ? 'baseline hints' : active;
    return 'Hint tier: $tier; active placements: $segment.';
  }

  String _buildTrainingOverview(
    List<String> paths,
    Map<String, String> difficulty,
  ) {
    final counts = difficulty.values.fold<Map<String, int>>(
      {'high': 0, 'medium': 0, 'low': 0},
      (map, level) {
        final key = map.containsKey(level) ? level : 'medium';
        map[key] = (map[key] ?? 0) + 1;
        return map;
      },
    );
    return 'Preferred path count: ${paths.length}; difficulty distribution high:${counts['high']}, medium:${counts['medium']}, low:${counts['low']}.';
  }

  List<String> _selectFocusModules(
    List<String> paths,
    Map<String, String> difficulty,
  ) {
    final weighted = paths.map((module) {
      final level = difficulty[module] ?? 'medium';
      final weight = level == 'high'
          ? 3
          : level == 'medium'
          ? 2
          : 1;
      return MapEntry(module, weight);
    }).toList();
    weighted.sort((a, b) => b.value.compareTo(a.value));
    return weighted.map((entry) => entry.key).take(3).toList();
  }

  List<String> _buildPersonaSuggestions(Map<String, Object?> persona) {
    final tone = _extractMap(persona['tone']);
    final suggestions = <String>[];
    if (tone['friendly'] == true) {
      suggestions.add('Lead with encouraging language.');
    }
    if (tone['supportive'] == true) {
      suggestions.add('Offer reassurance around challenges.');
    }
    if (tone['directive'] == true) {
      suggestions.add('Be concise and action-oriented.');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Keep explanations neutral and informative.');
    }
    return suggestions;
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};

  double _extractDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
