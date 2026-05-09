import 'dart:convert';
import 'dart:io';

class PlayerProfileScreenAssemblyException implements IOException {
  const PlayerProfileScreenAssemblyException(this.message);

  final String message;

  @override
  String toString() => 'PlayerProfileScreenAssemblyException: $message';
}

class PlayerProfileScreenSpec {
  PlayerProfileScreenSpec({
    required this.sections,
    required this.summary,
    required this.timestamp,
  });

  final Map<String, Object?> sections;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
    'sections': sections,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileScreenAssemblyService {
  const PlayerProfileScreenAssemblyService();

  static const _inputPath = 'release/_reports/explanation_engine_bundle.json';

  Future<PlayerProfileScreenSpec> build() async {
    final bundle = await _loadAsciiJson(_inputPath);

    final persona = bundle['persona_overview'];
    final hint = bundle['hint_strategy'];
    final training = bundle['training_overview'];
    final focus = (bundle['recommended_focus'] as List?)
        ?.whereType<String>()
        .toList();
    final suggestions = (bundle['persona_suggestions'] as List?)
        ?.whereType<String>()
        .toList();
    final summary = (bundle['summary'] as Map?)?.cast<String, Object?>() ?? {};

    return PlayerProfileScreenSpec(
      sections: {
        'header_section': persona ?? 'Persona summary unavailable.',
        'hint_section': hint ?? 'Hint strategy unavailable.',
        'training_section': training ?? 'Training overview unavailable.',
        'focus_section': focus ?? [],
        'suggestions_section': suggestions ?? [],
      },
      summary: {'module_count': summary['module_count'] ?? 0},
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileScreenAssemblyException('Missing bundle $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.any((value) => value > 127)) {
      throw PlayerProfileScreenAssemblyException('Non-ASCII content in $path');
    }
    final decoded = json.decode(latin1.decode(bytes));
    if (decoded is! Map<String, Object?>) {
      throw PlayerProfileScreenAssemblyException(
        'Invalid JSON structure in $path',
      );
    }
    return decoded;
  }
}
