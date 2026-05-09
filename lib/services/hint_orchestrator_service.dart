import 'dart:convert';
import 'dart:io';

class HintOrchestratorException implements IOException {
  const HintOrchestratorException(this.message);

  final String message;

  @override
  String toString() => 'HintOrchestratorException: $message';
}

class HintOrchestrationBundle {
  HintOrchestrationBundle({
    required this.hintEnergy,
    required this.hintDepth,
    required this.recommendedHintTypes,
    required this.toneRules,
    required this.layoutFocus,
    required this.timestamp,
  });

  final double hintEnergy;
  final double hintDepth;
  final List<String> recommendedHintTypes;
  final Map<String, Object?> toneRules;
  final List<String> layoutFocus;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'hint_energy': hintEnergy,
    'hint_depth': hintDepth,
    'recommended_hint_types': recommendedHintTypes,
    'tone_rules': toneRules,
    'layout_focus': layoutFocus,
    'timestamp': timestamp.toIso8601String(),
  };
}

class HintOrchestratorService {
  const HintOrchestratorService();

  static const _inputPath = 'release/_reports/persona_interaction_map.json';

  Future<HintOrchestrationBundle> build() async {
    final data = await _loadAsciiJson(_inputPath);

    final tone = _extractToneRules(data);
    final hints = _extractHintRules(data);
    final engagement = _extractEngagement(data);
    final layoutFocus = _extractLayoutFocus(data);

    final hintEnergy = _clamp01(engagement['energy_level'] ?? 0.0);
    final hintDepth = _clamp01(engagement['context_depth'] ?? 0.0);
    final recommended = _buildHintTypes(
      hints['visual_hints_enabled'] == true,
      hints['learning_hints_enabled'] == true,
      hints['prefer_brief_prompts'] == true,
    );

    return HintOrchestrationBundle(
      hintEnergy: hintEnergy,
      hintDepth: hintDepth,
      recommendedHintTypes: recommended,
      toneRules: tone,
      layoutFocus: layoutFocus,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw HintOrchestratorException(
        'Missing persona interaction map at $path',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw HintOrchestratorException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw HintOrchestratorException('Invalid JSON structure in $path');
    }
    return decoded;
  }

  Map<String, Object?> _extractToneRules(Map<String, Object?> data) {
    final tone = data['tone_rules'];
    if (tone is! Map<String, Object?>) {
      throw HintOrchestratorException('Missing tone rules');
    }
    return tone;
  }

  Map<String, Object?> _extractHintRules(Map<String, Object?> data) {
    final hints = data['hint_rules'];
    if (hints is! Map<String, Object?>) {
      throw HintOrchestratorException('Missing hint rules');
    }
    return hints;
  }

  Map<String, double> _extractEngagement(Map<String, Object?> data) {
    final engagement = data['engagement_rules'];
    if (engagement is! Map<String, Object?>) {
      throw HintOrchestratorException('Missing engagement rules');
    }
    return {
      'energy_level': _toDouble(engagement['energy_level']),
      'context_depth': _toDouble(engagement['context_depth']),
    };
  }

  List<String> _extractLayoutFocus(Map<String, Object?> data) {
    final focus = data['layout_focus'];
    if (focus is! List) {
      throw HintOrchestratorException('Missing layout focus');
    }
    return focus.whereType<String>().toList();
  }

  List<String> _buildHintTypes(bool visual, bool learning, bool brief) {
    final types = <String>['baseline'];
    if (visual) types.add('visual');
    if (learning) types.add('learning');
    if (brief) types.add('brief');
    return types;
  }

  double _clamp01(double value) => value.clamp(0.0, 1.0);

  double _toDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
