import 'dart:convert';
import 'dart:io';

class PersonaInteractionMapException implements IOException {
  const PersonaInteractionMapException(this.message);

  final String message;

  @override
  String toString() => 'PersonaInteractionMapException: $message';
}

class PersonaInteractionMapBundle {
  PersonaInteractionMapBundle({
    required this.useFriendly,
    required this.useSupportive,
    required this.useDirective,
    required this.useVisualHints,
    required this.useLearningHints,
    required this.preferBriefPrompts,
    required this.energyLevel,
    required this.contextDepth,
    required this.layoutFocus,
    required this.interactionPriority,
    required this.timestamp,
  });

  final bool useFriendly;
  final bool useSupportive;
  final bool useDirective;
  final bool useVisualHints;
  final bool useLearningHints;
  final bool preferBriefPrompts;
  final double energyLevel;
  final double contextDepth;
  final List<String> layoutFocus;
  final String interactionPriority;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'tone_rules': {
      'use_friendly': useFriendly,
      'use_supportive': useSupportive,
      'use_directive': useDirective,
    },
    'hint_rules': {
      'visual_hints_enabled': useVisualHints,
      'learning_hints_enabled': useLearningHints,
      'prefer_brief_prompts': preferBriefPrompts,
    },
    'engagement_rules': {
      'energy_level': energyLevel,
      'context_depth': contextDepth,
    },
    'layout_focus': layoutFocus,
    'interaction_priority': interactionPriority,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PersonaInteractionMapService {
  const PersonaInteractionMapService();

  static const _inputPath = 'release/_reports/persona_engine_bundle.json';

  Future<PersonaInteractionMapBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final tone = _extractToneRules(data);
    final hints = _extractHintRules(data);
    final engagement = _extractEngagement(data);
    final layoutFocus = _extractLayoutFocus(data);

    final interactionPriority = engagement.energyLevel > 0.6
        ? 'high'
        : 'medium';

    return PersonaInteractionMapBundle(
      useFriendly: tone.friendly,
      useSupportive: tone.supportive,
      useDirective: tone.directive,
      useVisualHints: hints.useVisualHints,
      useLearningHints: hints.useLearningHints,
      preferBriefPrompts: hints.preferBriefPrompts,
      energyLevel: engagement.energyLevel,
      contextDepth: engagement.contextDepth,
      layoutFocus: layoutFocus,
      interactionPriority: interactionPriority,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PersonaInteractionMapException(
        'Missing personalization kernel bundle at $path',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PersonaInteractionMapException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PersonaInteractionMapException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  _ToneRules _extractToneRules(Map<String, Object?> data) {
    final tone = data['tone_profile'];
    if (tone is! Map<String, Object?>) {
      throw PersonaInteractionMapException('Missing tone profile');
    }
    return _ToneRules(
      friendly: tone['friendly'] == true,
      supportive: tone['supportive'] == true,
      directive: tone['directive'] == true,
    );
  }

  _HintRules _extractHintRules(Map<String, Object?> data) {
    final hints = data['hint_strategy'];
    if (hints is! Map<String, Object?>) {
      throw PersonaInteractionMapException('Missing hint strategy');
    }
    return _HintRules(
      useVisualHints: hints['use_visual_hints'] == true,
      useLearningHints: hints['use_learning_hints'] == true,
      preferBriefPrompts: hints['prefer_brief_prompts'] == true,
    );
  }

  _EngagementRules _extractEngagement(Map<String, Object?> data) {
    final engagement = data['engagement_profile'];
    if (engagement is! Map<String, Object?>) {
      throw PersonaInteractionMapException('Missing engagement profile');
    }
    return _EngagementRules(
      energyLevel: _toDouble(engagement['energy_level']).clamp(0.0, 1.0),
      contextDepth: _toDouble(engagement['context_depth']).clamp(0.0, 1.0),
    );
  }

  List<String> _extractLayoutFocus(Map<String, Object?> data) {
    final focus = data['layout_focus'];
    if (focus is! List) {
      throw PersonaInteractionMapException('Missing layout focus');
    }
    return focus.whereType<String>().toList();
  }

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class _ToneRules {
  _ToneRules({
    required this.friendly,
    required this.supportive,
    required this.directive,
  });

  final bool friendly;
  final bool supportive;
  final bool directive;
}

class _HintRules {
  _HintRules({
    required this.useVisualHints,
    required this.useLearningHints,
    required this.preferBriefPrompts,
  });

  final bool useVisualHints;
  final bool useLearningHints;
  final bool preferBriefPrompts;
}

class _EngagementRules {
  _EngagementRules({required this.energyLevel, required this.contextDepth});

  final double energyLevel;
  final double contextDepth;
}
