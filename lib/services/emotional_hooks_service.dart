import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class EmotionalHooksBundle {
  EmotionalHooksBundle({
    required this.confidenceHook,
    required this.clarityHook,
    required this.engagementHook,
    required this.personaAlignmentHook,
    required this.sessionMoodScore,
    required this.hookPriority,
    required this.timestamp,
  });

  final String confidenceHook;
  final String clarityHook;
  final String engagementHook;
  final String personaAlignmentHook;
  final double sessionMoodScore;
  final double hookPriority;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'confidence_hook': confidenceHook,
    'clarity_hook': clarityHook,
    'engagement_hook': engagementHook,
    'persona_alignment_hook': personaAlignmentHook,
    'session_mood_score': sessionMoodScore,
    'hook_priority': hookPriority,
    'timestamp': timestamp.toIso8601String(),
  };
}

class EmotionalHooksService {
  static const _inputPath = 'release/_reports/pre_onboarding_intent.json';

  const EmotionalHooksService();

  Future<EmotionalHooksBundle> run() async {
    final data = await _loadAsciiJson();
    final visualIntent = _extractString(data, 'visual_intent');
    final learningIntent = _extractString(data, 'learning_intent');
    final engagementIntent = _extractString(data, 'engagement_intent');
    final routingIntent = _extractString(data, 'routing_intent');
    final onboardingPriority = _extractDouble(data, 'onboarding_priority');

    final confidenceHook = _buildConfidenceHook(visualIntent, routingIntent);
    final clarityHook = _buildClarityHook(learningIntent);
    final engagementHook = _buildEngagementHook(engagementIntent);
    final personaAlignmentHook = _buildPersonaAlignmentHook(
      visualIntent,
      engagementIntent,
    );

    final sessionMoodScore = _computeMoodScore(
      visualIntent: visualIntent,
      engagementIntent: engagementIntent,
      onboardingPriority: onboardingPriority,
    );
    final hookPriority = ((onboardingPriority * 0.6) + (sessionMoodScore * 0.4))
        .clamp(0.0, 1.0);

    return EmotionalHooksBundle(
      confidenceHook: confidenceHook,
      clarityHook: clarityHook,
      engagementHook: engagementHook,
      personaAlignmentHook: personaAlignmentHook,
      sessionMoodScore: sessionMoodScore,
      hookPriority: hookPriority,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson() async {
    final file = File(_inputPath);
    if (!await file.exists()) {
      throw EmotionalHooksException('Missing $_inputPath');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw EmotionalHooksException('Empty $_inputPath');
    }
    if (!_isAsciiOnly(bytes)) {
      throw EmotionalHooksException('$_inputPath contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw EmotionalHooksException('Invalid JSON: ${error.message}');
    }
  }

  String _buildConfidenceHook(String visualIntent, String routingIntent) =>
      'Confidence hook: lean into the $visualIntent visual cues while honoring the $routingIntent routing intent.';

  String _buildClarityHook(String learningIntent) =>
      'Clarity hook: keep focus on the $learningIntent learning path to stay grounded.';

  String _buildEngagementHook(String engagementIntent) =>
      'Engagement hook: maintain the $engagementIntent energy the user already shows.';

  String _buildPersonaAlignmentHook(
    String visualIntent,
    String engagementIntent,
  ) =>
      'Persona alignment hook: match the $visualIntent vibe with the $engagementIntent emotional tone.';

  double _computeMoodScore({
    required String visualIntent,
    required String engagementIntent,
    required double onboardingPriority,
  }) {
    final visualScore = _descriptorScore(visualIntent);
    final engagementScore = _descriptorScore(engagementIntent);
    final summary = (visualScore + engagementScore + onboardingPriority) / 3;
    return summary.clamp(0.0, 1.0);
  }

  double _descriptorScore(String text) {
    final words = text
        .split(RegExp(r'\W+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part.toLowerCase())
        .toList();
    if (words.isEmpty) return 0.5;
    final positive = words.where((word) {
      const positives = {
        'confident',
        'welcoming',
        'visual',
        'focused',
        'balanced',
        'energetic',
        'calm',
        'exploratory',
        'directive',
      };
      return positives.contains(word);
    }).length;
    return (positive / words.length).clamp(0.0, 1.0);
  }

  String _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw EmotionalHooksException('$key is missing or empty');
  }

  double _extractDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    throw EmotionalHooksException('$key is missing or not numeric');
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class EmotionalHooksException implements Exception {
  final String message;

  EmotionalHooksException(this.message);

  @override
  String toString() => 'EmotionalHooksException: $message';
}
