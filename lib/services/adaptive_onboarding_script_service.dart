import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class AdaptiveOnboardingScriptBundle {
  AdaptiveOnboardingScriptBundle({
    required this.introBlock,
    required this.motivationBlock,
    required this.firstActionBlock,
    required this.microGuidanceBlock,
    required this.scriptPriority,
    required this.timestamp,
  });

  final String introBlock;
  final String motivationBlock;
  final String firstActionBlock;
  final String microGuidanceBlock;
  final double scriptPriority;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'intro_block': introBlock,
    'motivation_block': motivationBlock,
    'first_action_block': firstActionBlock,
    'micro_guidance_block': microGuidanceBlock,
    'script_priority': scriptPriority,
    'timestamp': timestamp.toIso8601String(),
  };
}

class AdaptiveOnboardingScriptService {
  static const _inputPath = 'release/_reports/emotional_hooks_map.json';

  const AdaptiveOnboardingScriptService();

  Future<AdaptiveOnboardingScriptBundle> run() async {
    final data = await _loadAsciiJson();
    final confidence = _extractString(data, 'confidence_hook');
    final clarity = _extractString(data, 'clarity_hook');
    final engagement = _extractString(data, 'engagement_hook');
    final personaAlignment = _extractString(data, 'persona_alignment_hook');
    final sessionMood = _extractDouble(data, 'session_mood_score');
    final hookPriority = _extractDouble(data, 'hook_priority');

    final introBlock = _buildIntroBlock(confidence, clarity, engagement);
    final motivationBlock = _buildMotivationBlock(personaAlignment, confidence);
    final firstActionBlock = _buildFirstActionBlock(hookPriority);
    final microGuidanceBlock = _buildMicroGuidanceBlock(clarity, engagement);
    final scriptPriority = ((hookPriority * 0.7) + (sessionMood * 0.3)).clamp(
      0.0,
      1.0,
    );

    return AdaptiveOnboardingScriptBundle(
      introBlock: introBlock,
      motivationBlock: motivationBlock,
      firstActionBlock: firstActionBlock,
      microGuidanceBlock: microGuidanceBlock,
      scriptPriority: scriptPriority,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson() async {
    final file = File(_inputPath);
    if (!await file.exists()) {
      throw AdaptiveOnboardingScriptException('Missing $_inputPath');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw AdaptiveOnboardingScriptException('Empty $_inputPath');
    }
    if (!_isAsciiOnly(bytes)) {
      throw AdaptiveOnboardingScriptException(
        '$_inputPath contains non-ASCII bytes',
      );
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw AdaptiveOnboardingScriptException('Invalid JSON: ${error.message}');
    }
  }

  String _buildIntroBlock(
    String confidence,
    String clarity,
    String engagement,
  ) {
    return 'Intro: $confidence ${clarity.replaceFirst('Clarity hook:', 'Keep it clear by')} '
        'and $engagement';
  }

  String _buildMotivationBlock(String personaAlignment, String confidence) {
    return 'Motivation: $personaAlignment Elevated by $confidence';
  }

  String _buildFirstActionBlock(double priority) {
    if (priority >= 0.8) {
      return 'First action: Lead with an ambitious drill to match this momentum.';
    }
    if (priority >= 0.5) {
      return 'First action: Offer a structured challenge to keep the energy steady.';
    }
    return 'First action: Start with a reinforced review to build confidence.';
  }

  String _buildMicroGuidanceBlock(String clarity, String engagement) {
    return 'Micro guidance: Remind them that $clarity while staying $engagement';
  }

  String _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw AdaptiveOnboardingScriptException('$key is missing or empty');
  }

  double _extractDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    throw AdaptiveOnboardingScriptException('$key is missing or not numeric');
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class AdaptiveOnboardingScriptException implements Exception {
  final String message;

  AdaptiveOnboardingScriptException(this.message);

  @override
  String toString() => 'AdaptiveOnboardingScriptException: $message';
}
