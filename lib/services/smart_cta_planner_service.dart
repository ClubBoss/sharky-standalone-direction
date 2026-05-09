import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class SmartCtaBundle {
  SmartCtaBundle({
    required this.primaryCta,
    required this.secondaryCta,
    required this.microCta,
    required this.ctaRouteHint,
    required this.ctaScore,
    required this.timestamp,
  });

  final String primaryCta;
  final String secondaryCta;
  final String microCta;
  final String ctaRouteHint;
  final double ctaScore;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'primary_cta': primaryCta,
    'secondary_cta': secondaryCta,
    'micro_cta': microCta,
    'cta_route_hint': ctaRouteHint,
    'cta_score': ctaScore,
    'timestamp': timestamp.toIso8601String(),
  };
}

class SmartCtaPlannerService {
  static const _greetingPath = 'release/_reports/persona_greeting.json';
  static const _scriptPath = 'release/_reports/adaptive_onboarding_script.json';

  const SmartCtaPlannerService();

  Future<SmartCtaBundle> run() async {
    final greeting = await _loadAsciiJson(_greetingPath);
    final script = await _loadAsciiJson(_scriptPath);

    final greetingPriority = _extractDouble(greeting, 'greeting_priority');
    final scriptPriority = _extractDouble(script, 'script_priority');
    final recommendedAction = _extractString(
      greeting,
      'recommended_first_action',
    );
    final motivationBlock = _extractString(script, 'motivation_block');
    final clarityHook = _extractString(script, 'clarity_hook');
    final primaryCta = _buildPrimaryCta(
      recommendedAction,
      greetingPriority,
      scriptPriority,
    );
    final secondaryCta = _buildSecondaryCta(motivationBlock, clarityHook);
    final microCta = _buildMicroCta(
      greeting['motivational_hint'] as String? ?? '',
    );
    final ctaRouteHint = recommendedAction;
    final ctaScore = ((greetingPriority * 0.7) + (scriptPriority * 0.3)).clamp(
      0.0,
      1.0,
    );

    return SmartCtaBundle(
      primaryCta: primaryCta,
      secondaryCta: secondaryCta,
      microCta: microCta,
      ctaRouteHint: ctaRouteHint,
      ctaScore: ctaScore,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw SmartCtaPlannerException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw SmartCtaPlannerException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw SmartCtaPlannerException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw SmartCtaPlannerException('Invalid JSON in $path: ${error.message}');
    }
  }

  String _buildPrimaryCta(
    String action,
    double greetingPriority,
    double scriptPriority,
  ) {
    final tone = greetingPriority >= 0.8 ? 'bold' : 'steady';
    final emphasis = scriptPriority >= 0.6
        ? 'with structured steps'
        : 'with gentle cues';
    return 'Primary CTA ($tone): Launch "$action" $emphasis.';
  }

  String _buildSecondaryCta(String motivation, String clarity) {
    return 'Secondary CTA: Combine ${clarity.replaceFirst('Clarity hook:', '').trim()} '
        'with ${motivation.replaceFirst('Motivation block:', '').trim()}.';
  }

  String _buildMicroCta(String motivationalHint) {
    if (motivationalHint.isEmpty) {
      return 'Micro CTA: Keep a calm, encouraging tone.';
    }
    return 'Micro CTA: $motivationalHint';
  }

  String _extractString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw SmartCtaPlannerException('$key missing or empty');
  }

  double _extractDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    throw SmartCtaPlannerException('$key missing or not numeric');
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class SmartCtaPlannerException implements Exception {
  final String message;

  SmartCtaPlannerException(this.message);

  @override
  String toString() => 'SmartCtaPlannerException: $message';
}
