import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PersonaGreetingBundle {
  PersonaGreetingBundle({
    required this.greetingLine,
    required this.microIntroLine,
    required this.motivationalHint,
    required this.recommendedFirstAction,
    required this.greetingPriority,
    required this.timestamp,
  });

  final String greetingLine;
  final String microIntroLine;
  final String motivationalHint;
  final String recommendedFirstAction;
  final double greetingPriority;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'greeting_line': greetingLine,
    'micro_intro_line': microIntroLine,
    'motivational_hint': motivationalHint,
    'recommended_first_action': recommendedFirstAction,
    'greeting_priority': greetingPriority,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PersonaGreetingService {
  static const _scriptPath = 'release/_reports/adaptive_onboarding_script.json';
  static const _personaPath = 'release/_reports/persona_engine_bundle.json';

  const PersonaGreetingService();

  Future<PersonaGreetingBundle> run() async {
    final script = await _loadAsciiJson(_scriptPath);
    final persona = await _loadAsciiJson(_personaPath);

    final intro = _extractString(script, 'intro_block');
    final motivation = _extractString(script, 'motivation_block');
    final firstAction = _extractString(script, 'first_action_block');
    final microGuidance = _extractString(script, 'micro_guidance_block');
    final scriptPriority = _extractDouble(script, 'script_priority');

    final toneProfile = _extractMap(persona, 'tone_profile');
    final engagementProfile = _extractMap(persona, 'engagement_profile');
    final toneDescriptor = _toneDescriptor(toneProfile);

    final greetingLine = 'Hey $toneDescriptor learner, $intro';
    final microIntroLine =
        'Micro intro: ${microGuidance.replaceFirst('Micro guidance:', '').trim()}';
    final motivationalHint =
        'Motivation ${motivation.replaceFirst('Motivation block:', '').trim()}';
    final recommendedFirstAction = firstAction;

    final energy = _extractNumber(engagementProfile, 'energy_level') ?? 0.5;
    final focus = _extractNumber(engagementProfile, 'context_depth') ?? 0.5;
    final toneScore = _toneScore(toneProfile);

    final greetingPriority =
        ((scriptPriority * 0.6) + (energy + focus) * 0.2 + (toneScore * 0.2))
            .clamp(0.0, 1.0);

    return PersonaGreetingBundle(
      greetingLine: greetingLine,
      microIntroLine: microIntroLine,
      motivationalHint: motivationalHint,
      recommendedFirstAction: recommendedFirstAction,
      greetingPriority: greetingPriority,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PersonaGreetingException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PersonaGreetingException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PersonaGreetingException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PersonaGreetingException('Invalid JSON in $path: ${error.message}');
    }
  }

  String _toneDescriptor(Map<String, Object?> tone) {
    if (tone['friendly'] == true) return 'friendly';
    if (tone['supportive'] == true) return 'supportive';
    if (tone['directive'] == true) return 'directive';
    return 'balanced';
  }

  double _toneScore(Map<String, Object?> tone) {
    var score = 0.0;
    score += tone['friendly'] == true ? 0.4 : 0.0;
    score += tone['supportive'] == true ? 0.3 : 0.0;
    score += tone['directive'] == true ? 0.3 : 0.0;
    return score.clamp(0.0, 1.0);
  }

  Map<String, Object?> _extractMap(Map<String, Object?> parent, String key) {
    final value = parent[key];
    if (value is Map<String, Object?>) {
      return Map<String, Object?>.from(value);
    }
    return const {};
  }

  String _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw PersonaGreetingException('$key missing or empty');
  }

  double _extractDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    throw PersonaGreetingException('$key missing or not numeric');
  }

  double? _extractNumber(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class PersonaGreetingException implements Exception {
  final String message;

  PersonaGreetingException(this.message);

  @override
  String toString() => 'PersonaGreetingException: $message';
}
