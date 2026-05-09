import 'dart:convert';
import 'dart:io';

class PlayerProfileBootstrapException implements IOException {
  const PlayerProfileBootstrapException(this.message);

  final String message;

  @override
  String toString() => 'PlayerProfileBootstrapException: $message';
}

class PlayerProfileContextBundle {
  PlayerProfileContextBundle({
    required this.personaProfile,
    required this.hintProfile,
    required this.trainingProfile,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, Object?> personaProfile;
  final Map<String, Object?> hintProfile;
  final Map<String, Object?> trainingProfile;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'persona_profile': personaProfile,
    'hint_profile': hintProfile,
    'training_profile': trainingProfile,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileBootstrapService {
  const PlayerProfileBootstrapService();

  static const _paths = [
    'release/_reports/persona_engine_bundle.json',
    'release/_reports/persona_interaction_map.json',
    'release/_reports/hint_routing_bundle.json',
    'release/_reports/planner_v2_plan.json',
  ];

  Future<PlayerProfileContextBundle> build() async {
    final engine = await _loadAsciiJson(_paths[0]);
    final interaction = await _loadAsciiJson(_paths[1]);
    final hintRouting = await _loadAsciiJson(_paths[2]);
    final planner = await _loadAsciiJson(_paths[3]);

    final personaProfile = _extractPersonaProfile(engine, interaction);
    final hintProfile = _extractHintProfile(hintRouting);
    final trainingProfile = _extractTrainingProfile(planner);

    final summary = {
      'module_count': trainingProfile['module_count'] ?? 0,
      'avg_difficulty': trainingProfile['avg_difficulty'] ?? 0.0,
    };

    return PlayerProfileContextBundle(
      personaProfile: personaProfile,
      hintProfile: hintProfile,
      trainingProfile: trainingProfile,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileBootstrapException('Missing report $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PlayerProfileBootstrapException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PlayerProfileBootstrapException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractPersonaProfile(
    Map<String, Object?> engine,
    Map<String, Object?> interaction,
  ) {
    return {
      'tone': _extractMap(engine['persona_baseline']),
      'engagement': _extractMap(engine['engagement_profile']),
      'interaction_priority': interaction['interaction_priority'] ?? 'medium',
    };
  }

  Map<String, Object?> _extractHintProfile(Map<String, Object?> hintRouting) =>
      {
        'tier': hintRouting['tier'] ?? 'medium',
        'placements': hintRouting['placement_candidates'] ?? {},
      };

  Map<String, Object?> _extractTrainingProfile(Map<String, Object?> planner) {
    final moduleCount = (planner['summary'] as Map?)?['module_count'];
    final modules = (planner['routed_plan'] as List?)
        ?.whereType<String>()
        .toList();
    final difficulty =
        (planner['difficulty_levels'] as Map?)?.map(
          (key, value) =>
              MapEntry(key.toString(), value?.toString() ?? 'medium'),
        ) ??
        {};
    return {
      'preferred_paths': modules ?? [],
      'difficulty_distribution': difficulty,
      'module_count': moduleCount ?? modules?.length ?? 0,
      'avg_difficulty': _averageDifficulty(difficulty),
    };
  }

  double _averageDifficulty(Map<String, String> distribution) {
    if (distribution.isEmpty) return 0.0;
    final weights = {'high': 0.9, 'medium': 0.6, 'low': 0.3};
    final total = distribution.values.fold<double>(
      0.0,
      (sum, level) => sum + (weights[level] ?? 0.5),
    );
    return total / distribution.length;
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? value : const {};
}
