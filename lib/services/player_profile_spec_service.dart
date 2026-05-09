import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileBundle {
  PlayerProfileBundle({
    required this.persona,
    required this.hints,
    required this.trainingOverview,
    required this.moduleFocus,
    required this.explanations,
    required this.localization,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, Object?> persona;
  final Map<String, Object?> hints;
  final Map<String, Object?> trainingOverview;
  final List<Map<String, Object?>> moduleFocus;
  final List<Map<String, Object?>> explanations;
  final Map<String, Object?> localization;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'persona': persona,
    'hints': hints,
    'training_overview': trainingOverview,
    'module_focus': moduleFocus,
    'explanations': explanations,
    'localization': localization,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileSpecService {
  static const _personalizationPath =
      'release/_reports/personalization_kernel_bundle.json';
  static const _personaInteractionPath =
      'release/_reports/persona_interaction_map.json';
  static const _hintRoutingPath = 'release/_reports/hint_routing_bundle.json';
  static const _plannerPath = 'release/_reports/planner_v2_plan.json';
  static const _explanationPath =
      'release/_reports/explanation_engine_bundle.json';
  static const _trainingPath =
      'release/_reports/training_path_visualization.json';
  static const _contextPath =
      'release/_reports/player_profile_context_bundle.json';
  static const _localizedAssetPath =
      'release/_reports/localized_asset_bundle.json';

  const PlayerProfileSpecService();

  Future<PlayerProfileBundle> run() async {
    final personalization = await _loadAsciiJson(_personalizationPath);
    final personaInteraction = await _loadAsciiJson(_personaInteractionPath);
    final hintRouting = await _loadAsciiJson(_hintRoutingPath);
    final planner = await _loadAsciiJson(_plannerPath);
    final explanation = await _loadAsciiJson(_explanationPath);
    final trainingPath = await _loadAsciiJson(_trainingPath);
    final profileContext = await _loadAsciiJson(_contextPath);
    final localizedAsset = await _loadAsciiJson(_localizedAssetPath);

    final personaTone = _extractString(personalization, 'persona_tone');
    final engagementTraits = _extractStringList(
      personalization,
      'engagement_traits',
    );
    final personaContext = _ensureMap(profileContext['persona_context']);
    final interactionMode = _extractString(
      personaInteraction,
      'interaction_mode',
    );
    final hintModes = _extractStringList(hintRouting, 'modes');

    final plannerModules = _extractPlanModules(planner);
    final trainingNodes = _extractStringList(trainingPath, 'nodes');

    final explanationInsights = _extractExplanationInsights(explanation);

    final moduleFocus = plannerModules.map((module) {
      return <String, Object?>{
        'id': module['id'] ?? module['name'] ?? 'unknown',
        'name': module['name'] ?? 'unnamed',
        'priority': module['priority'] ?? false,
        'engagement': module['engagement'] ?? 'neutral',
      };
    }).toList();

    final localizationEntries = _ensureList(localizedAsset['entries']);
    final coverage = _extractDouble(localizedAsset, 'coverage');
    final missingKeys = _collectKeys(localizationEntries, 'missing');
    final highRiskKeys = _collectKeys(localizationEntries, 'high_risk');

    final summary = <String, Object?>{
      'module_count': moduleFocus.length,
      'preferred_path':
          trainingPath['preferred_path'] ??
          (trainingNodes.isNotEmpty ? trainingNodes.first : 'unknown'),
      'engagement_score': _computeEngagementScore(
        engagementTraits.length,
        moduleFocus.length,
      ),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    final persona = <String, Object?>{
      'tone': personaTone,
      'engagement_traits': engagementTraits,
      'persona_context': personaContext,
      'interaction_mode': interactionMode,
    };

    final hints = <String, Object?>{
      'modes': hintModes,
      'routing_tier': hintRouting['routing_tier'] ?? 'default',
    };

    final trainingOverview = <String, Object?>{
      'plan': planner['plan'] ?? 'standard',
      'nodes': trainingNodes,
      'context': profileContext['context'] ?? {},
    };

    final localization = <String, Object?>{
      'coverage': coverage,
      'missing_keys': missingKeys,
      'high_risk': highRiskKeys,
    };

    return PlayerProfileBundle(
      persona: persona,
      hints: hints,
      trainingOverview: trainingOverview,
      moduleFocus: moduleFocus,
      explanations: explanationInsights,
      localization: localization,
      summary: summary,
      timestamp: DateTime.now().toUtc(),
    );
  }

  String _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String) {
      return value;
    }
    return '';
  }

  List<String> _extractStringList(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is List<Object?>) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  double _extractDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  List<Map<String, Object?>> _extractPlanModules(Map<String, Object?> map) {
    final modulesValue = map['modules'];
    if (modulesValue is! List<Object?>) {
      return const [];
    }
    final modules = <Map<String, Object?>>[];
    for (final module in modulesValue) {
      if (module is Map<String, Object?>) {
        modules.add(Map<String, Object?>.from(module));
      }
    }
    return modules;
  }

  List<Map<String, Object?>> _extractExplanationInsights(
    Map<String, Object?> map,
  ) {
    final insightsValue = map['insights'];
    if (insightsValue is! List<Object?>) {
      return const [];
    }
    final insights = <Map<String, Object?>>[];
    for (final insight in insightsValue) {
      if (insight is Map<String, Object?>) {
        insights.add(Map<String, Object?>.from(insight));
      }
    }
    return insights;
  }

  List<Object?> _ensureList(Object? raw) {
    if (raw is List<Object?>) {
      return raw;
    }
    return const [];
  }

  Map<String, Object?> _ensureMap(Object? raw) {
    if (raw is Map<String, Object?>) {
      return raw;
    }
    return const {};
  }

  List<String> _collectKeys(List<Object?> entries, String flag) {
    final keys = <String>[];
    for (final entry in entries) {
      if (entry is Map<String, Object?>) {
        final key = entry['key'];
        final value = entry[flag];
        if (key is String && value == true) {
          keys.add(key);
        }
      }
    }
    return keys;
  }

  double _computeEngagementScore(int traits, int modules) {
    final score = traits * 0.1 + modules * 0.05;
    if (score > 1.0) {
      return 1.0;
    }
    return score;
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileSpecException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileSpecException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileSpecException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PlayerProfileSpecException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileSpecException implements Exception {
  final String message;

  PlayerProfileSpecException(this.message);

  @override
  String toString() => 'PlayerProfileSpecException: $message';
}
