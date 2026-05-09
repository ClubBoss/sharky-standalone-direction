import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class LocalizationCoreBundle {
  LocalizationCoreBundle({
    required this.baseLocale,
    required this.supportedLocales,
    required this.translationMemorySeed,
    required this.glossarySeed,
    required this.timestamp,
  });

  final String baseLocale;
  final List<String> supportedLocales;
  final Map<String, String> translationMemorySeed;
  final Map<String, String> glossarySeed;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'base_locale': baseLocale,
    'supported_locales': supportedLocales,
    'translation_memory_seed': translationMemorySeed,
    'glossary_seed': glossarySeed,
    'timestamp': timestamp.toIso8601String(),
  };
}

class LocalizationCoreBootstrapService {
  static const _first3Path = 'release/_reports/first3_retention_model.json';
  static const _personaPath = 'release/_reports/persona_engine_bundle.json';

  const LocalizationCoreBootstrapService();

  Future<LocalizationCoreBundle> run() async {
    final retention = await _loadAsciiJson(_first3Path);
    final persona = await _loadAsciiJson(_personaPath);
    final greeting = await _loadOptionalAsciiJson(
      'release/_reports/persona_greeting.json',
    );
    final script = await _loadOptionalAsciiJson(
      'release/_reports/adaptive_onboarding_script.json',
    );
    final cta = await _loadOptionalAsciiJson(
      'release/_reports/smart_cta_planner.json',
    );

    final toneSummary = _toneSummary(persona['tone_profile']);
    final translationMemorySeed = <String, String>{
      'persona_tone_summary': toneSummary,
      'greeting_line': _extractStringOrDefault(
        greeting,
        'greeting_line',
        'Welcome player.',
      ),
      'micro_intro_line': _extractStringOrDefault(
        greeting,
        'micro_intro_line',
        '',
      ),
      'motivational_hint': _extractStringOrDefault(
        greeting,
        'motivational_hint',
        '',
      ),
      'recommended_first_action': _extractStringOrDefault(
        greeting,
        'recommended_first_action',
        '',
      ),
      'primary_cta': _extractStringOrDefault(cta, 'primary_cta', ''),
      'secondary_cta': _extractStringOrDefault(cta, 'secondary_cta', ''),
      'micro_cta': _extractStringOrDefault(cta, 'micro_cta', ''),
      'onboarding_intro': _extractStringOrDefault(script, 'intro_block', ''),
      'onboarding_clarity': _extractStringOrDefault(script, 'clarity_hook', ''),
      'onboarding_engagement': _extractStringOrDefault(
        script,
        'engagement_hook',
        '',
      ),
      'retention_tier': _extractStringOrDefault(
        retention,
        'retention_tier',
        'mid',
      ),
    };

    final glossarySeed = <String, String>{
      'cta': translationMemorySeed['primary_cta']!.isNotEmpty
          ? translationMemorySeed['primary_cta']!
          : 'Primary CTA engagement point',
      'persona': toneSummary,
      'onboarding': translationMemorySeed['onboarding_intro']!.isNotEmpty
          ? translationMemorySeed['onboarding_intro']!
          : 'Onboarding introduction snippet',
      'retention':
          'Tier ${translationMemorySeed['retention_tier']} retention focus',
    };

    return LocalizationCoreBundle(
      baseLocale: 'en',
      supportedLocales: const ['en', 'ru'],
      translationMemorySeed: translationMemorySeed,
      glossarySeed: glossarySeed,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LocalizationCoreBootstrapException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw LocalizationCoreBootstrapException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw LocalizationCoreBootstrapException(
        '$path contains non-ASCII bytes',
      );
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw LocalizationCoreBootstrapException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  Future<Map<String, Object?>> _loadOptionalAsciiJson(String path) async {
    try {
      return await _loadAsciiJson(path);
    } on LocalizationCoreBootstrapException {
      return const {};
    }
  }

  String _toneSummary(Object? toneProfile) {
    if (toneProfile is! Map<String, Object?>) {
      return 'balanced';
    }
    final descriptors = <String>[];
    if (toneProfile['friendly'] == true) descriptors.add('friendly');
    if (toneProfile['supportive'] == true) descriptors.add('supportive');
    if (toneProfile['directive'] == true) descriptors.add('directive');
    return descriptors.isEmpty ? 'balanced' : descriptors.join(' ');
  }

  String _extractStringOrDefault(
    Map<String, Object?> map,
    String key,
    String fallback,
  ) {
    final value = map[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class LocalizationCoreBootstrapException implements Exception {
  final String message;

  LocalizationCoreBootstrapException(this.message);

  @override
  String toString() => 'LocalizationCoreBootstrapException: $message';
}
