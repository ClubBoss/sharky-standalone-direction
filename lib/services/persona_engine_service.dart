import 'dart:convert';
import 'dart:io';

class PersonaEngineException implements IOException {
  const PersonaEngineException(this.message);

  final String message;

  @override
  String toString() => 'PersonaEngineException: $message';
}

class PersonaEngineBundle {
  PersonaEngineBundle({
    required this.friendlyTone,
    required this.supportiveTone,
    required this.directiveTone,
    required this.useVisualHints,
    required this.useLearningHints,
    required this.preferBriefPrompts,
    required this.energyLevel,
    required this.contextDepth,
    required this.layoutFocus,
    required this.timestamp,
  });

  final bool friendlyTone;
  final bool supportiveTone;
  final bool directiveTone;
  final bool useVisualHints;
  final bool useLearningHints;
  final bool preferBriefPrompts;
  final double energyLevel;
  final double contextDepth;
  final List<String> layoutFocus;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'tone_profile': {
      'friendly': friendlyTone,
      'supportive': supportiveTone,
      'directive': directiveTone,
    },
    'hint_strategy': {
      'use_visual_hints': useVisualHints,
      'use_learning_hints': useLearningHints,
      'prefer_brief_prompts': preferBriefPrompts,
    },
    'engagement_profile': {
      'energy_level': energyLevel,
      'context_depth': contextDepth,
    },
    'layout_focus': layoutFocus,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PersonaEngineService {
  const PersonaEngineService();

  static const _inputPath =
      'release/_reports/personalization_kernel_bundle.json';

  Future<PersonaEngineBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final visual = _extractVisual(data);
    final learning = _extractLearning(data);
    final uiHints = _extractUiHints(data);
    final explanation = _extractExplanation(data);
    final persona = _extractPersona(data);

    final energy = _clamp01(1.0 - persona.sharkyContextSensitivity);
    final contextDepth = _clamp01(persona.sharkyContextSensitivity);

    return PersonaEngineBundle(
      friendlyTone: persona.sharkyContextSensitivity < 0.35,
      supportiveTone: persona.sharkyContextSensitivity >= 0.35,
      directiveTone: persona.sharkyContextSensitivity > 0.70,
      useVisualHints: visual.increaseContrast || visual.reduceSpacingNoise,
      useLearningHints: learning.priorityBoost.isNotEmpty,
      preferBriefPrompts: explanation.preferBriefPrompts,
      energyLevel: energy,
      contextDepth: contextDepth,
      layoutFocus: uiHints,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PersonaEngineException(
        'Missing personalization kernel bundle at $path',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PersonaEngineException('Non-ASCII bundle at $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PersonaEngineException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  _VisualAdjustments _extractVisual(Map<String, Object?> data) {
    final adjustments = data['visual_adjustments'];
    if (adjustments is! Map<String, Object?>) {
      throw PersonaEngineException('Missing visual adjustments');
    }
    return _VisualAdjustments(
      increaseContrast: adjustments['increase_contrast'] == true,
      reduceSpacingNoise: adjustments['reduce_spacing_noise'] == true,
      suggestTokenUnification: adjustments['suggest_token_unification'] == true,
    );
  }

  _LearningAdjustments _extractLearning(Map<String, Object?> data) {
    final learning = data['learning_adjustments'];
    if (learning is! Map<String, Object?>) {
      throw PersonaEngineException('Missing learning adjustments');
    }
    return _LearningAdjustments(
      priorityBoost: _extractStringList(learning['priority_boost']),
      midAttention: _extractStringList(learning['mid_attention']),
    );
  }

  List<String> _extractUiHints(Map<String, Object?> data) {
    final hints = data['ui_style_hints'];
    if (hints is! List) {
      throw PersonaEngineException('Missing UI style hints');
    }
    return hints.whereType<String>().toList();
  }

  _ExplanationPriors _extractExplanation(Map<String, Object?> data) {
    final priors = data['explanation_priors'];
    if (priors is! Map<String, Object?>) {
      throw PersonaEngineException('Missing explanation priors');
    }
    return _ExplanationPriors(
      preferBriefPrompts: priors['prefer_brief_prompts'] == true,
    );
  }

  _PersonaBaseline _extractPersona(Map<String, Object?> data) {
    final persona = data['persona_baseline'];
    if (persona is! Map<String, Object?>) {
      throw PersonaEngineException('Missing persona baseline');
    }
    final sensitivity = _toDouble(persona['sharky_context_sensitivity']);
    return _PersonaBaseline(sharkyContextSensitivity: _clamp01(sensitivity));
  }

  List<String> _extractStringList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double _clamp01(double value) => value.clamp(0.0, 1.0);
}

class _VisualAdjustments {
  _VisualAdjustments({
    required this.increaseContrast,
    required this.reduceSpacingNoise,
    required this.suggestTokenUnification,
  });

  final bool increaseContrast;
  final bool reduceSpacingNoise;
  final bool suggestTokenUnification;
}

class _LearningAdjustments {
  _LearningAdjustments({
    required this.priorityBoost,
    required this.midAttention,
  });

  final List<String> priorityBoost;
  final List<String> midAttention;
}

class _ExplanationPriors {
  _ExplanationPriors({required this.preferBriefPrompts});

  final bool preferBriefPrompts;
}

class _PersonaBaseline {
  _PersonaBaseline({required this.sharkyContextSensitivity});

  final double sharkyContextSensitivity;
}
