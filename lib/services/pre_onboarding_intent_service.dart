import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PreOnboardingIntentBundle {
  PreOnboardingIntentBundle({
    required this.visualIntent,
    required this.learningIntent,
    required this.engagementIntent,
    required this.routingIntent,
    required this.onboardingPriority,
    required this.timestamp,
  });

  final String visualIntent;
  final String learningIntent;
  final String engagementIntent;
  final String routingIntent;
  final double onboardingPriority;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'visual_intent': visualIntent,
    'learning_intent': learningIntent,
    'engagement_intent': engagementIntent,
    'routing_intent': routingIntent,
    'onboarding_priority': onboardingPriority,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PreOnboardingIntentService {
  static const _finalManifest =
      'release/_reports/final_stability_manifest.json';
  static const _plannerPlan = 'release/_reports/planner_v2_plan.json';
  static const _personaBundle = 'release/_reports/persona_engine_bundle.json';
  static const _hintBundle = 'release/_reports/hint_routing_bundle.json';

  const PreOnboardingIntentService();

  Future<PreOnboardingIntentBundle> run() async {
    final finalManifest = await _loadAsciiJson(_finalManifest);
    final planner = await _loadAsciiJson(_plannerPlan);
    final persona = await _loadAsciiJson(_personaBundle);
    final hint = await _loadAsciiJson(_hintBundle);

    final safetyPass = _extractBool(finalManifest, 'summary', 'safety_pass');
    final tone = _extractMap(persona, 'tone_profile');
    final hintStrategy = _extractMap(persona, 'hint_strategy');
    final engagement = _extractMap(persona, 'engagement_profile');
    final layoutFocus = _extractStringList(persona, 'layout_focus');
    final difficulty = _extractMap(planner, 'difficulty_levels');
    final summary = _extractMap(planner, 'summary');
    final avgScore = _extractNumber(summary, 'avg_score') ?? 0.5;
    final tier = _extractString(hint, 'tier') ?? 'medium';

    final visualIntent = _buildVisualIntent(tone, hintStrategy, layoutFocus);
    final learningIntent = _buildLearningIntent(difficulty);
    final engagementIntent = _buildEngagementIntent(engagement);
    final routingIntent = tier;
    final onboardingPriority = _buildPriority(
      safetyPass: safetyPass,
      avgScore: avgScore,
      hintTier: tier,
    );

    return PreOnboardingIntentBundle(
      visualIntent: visualIntent,
      learningIntent: learningIntent,
      engagementIntent: engagementIntent,
      routingIntent: routingIntent,
      onboardingPriority: onboardingPriority,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PreOnboardingIntentException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PreOnboardingIntentException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PreOnboardingIntentException('Non-ASCII content in $path');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PreOnboardingIntentException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  String _buildVisualIntent(
    Map<String, Object?> tone,
    Map<String, Object?> hints,
    List<String> focus,
  ) {
    final descriptors = <String>[];
    if (tone['friendly'] == true) descriptors.add('welcoming');
    if (tone['directive'] == true) descriptors.add('confident');
    if (hints['use_visual_hints'] == true) descriptors.add('visual');
    if (focus.isNotEmpty) {
      descriptors.add(focus.first);
    }
    return descriptors.isEmpty ? 'balanced' : descriptors.join(' ');
  }

  String _buildLearningIntent(Map<String, Object?> difficulty) {
    final counts = <String, int>{'high': 0, 'medium': 0, 'low': 0};
    difficulty.forEach((_, value) {
      final tier = value?.toString().toLowerCase();
      if (tier != null && counts.containsKey(tier)) {
        counts[tier] = counts[tier]! + 1;
      }
    });
    final winner = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return winner.first.value == 0 ? 'balanced' : winner.first.key;
  }

  String _buildEngagementIntent(Map<String, Object?> engagement) {
    final energy = _extractNumber(engagement, 'energy_level') ?? 0.5;
    final depth = _extractNumber(engagement, 'context_depth') ?? 0.5;
    final energyDescriptor = energy >= 0.7 ? 'energetic' : 'calm';
    final depthDescriptor = depth >= 0.6 ? 'exploratory' : 'focused';
    return '$energyDescriptor $depthDescriptor';
  }

  double _buildPriority({
    required bool safetyPass,
    required double avgScore,
    required String hintTier,
  }) {
    var priority = 0.4;
    priority += safetyPass ? 0.3 : -0.2;
    priority += (avgScore - 0.5) * 0.6;
    switch (hintTier) {
      case 'high':
        priority += 0.1;
        break;
      case 'low':
        priority -= 0.1;
        break;
    }
    return priority.clamp(0.0, 1.0);
  }

  bool _extractBool(Map<String, Object?> parent, String parentKey, String key) {
    final section = parent[parentKey];
    if (section is! Map<String, Object?>) {
      throw PreOnboardingIntentException('$parentKey must be an object');
    }
    final value = section[key];
    if (value is bool) {
      return value;
    }
    throw PreOnboardingIntentException('$parentKey.$key must be a boolean');
  }

  double? _extractNumber(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is num) return value.toDouble();
    return null;
  }

  String? _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return null;
  }

  List<String> _extractStringList(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  Map<String, Object?> _extractMap(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is Map<String, Object?>) {
      return Map<String, Object?>.from(value);
    }
    return const {};
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class PreOnboardingIntentException implements Exception {
  final String message;

  PreOnboardingIntentException(this.message);

  @override
  String toString() => 'PreOnboardingIntentException: $message';
}
