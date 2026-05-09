import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileBlueprintBundle {
  PlayerProfileBlueprintBundle({
    required this.sections,
    required this.ordering,
    required this.summary,
    required this.timestamp,
  });

  final List<Map<String, Object?>> sections;
  final List<String> ordering;
  final Map<String, Object?> summary;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'sections': sections,
    'ordering': ordering,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileBlueprintService {
  static const _specPath = 'release/_reports/player_profile_spec.json';

  const PlayerProfileBlueprintService();

  Future<PlayerProfileBlueprintBundle> run() async {
    final spec = await _loadAsciiJson(_specPath);

    final persona = _ensureMap(spec['persona']);
    final hints = _ensureMap(spec['hints']);
    final trainingOverview = _ensureMap(spec['training_overview']);
    final moduleFocus = _ensureList(spec['module_focus']);
    final explanations = _ensureList(spec['explanations']);
    final localization = _ensureMap(spec['localization']);
    final summary = _ensureMap(spec['summary']);

    final sections = <Map<String, Object?>>[
      {
        'id': 'persona_overview',
        'title': 'Persona',
        'blocks': [
          {
            'tone': persona['tone'] ?? '',
            'traits': persona['engagement_traits'] ?? const [],
            'interaction_mode': persona['interaction_mode'] ?? '',
          },
          {
            'context': persona['persona_context'] ?? const {},
            'preferred_hint_mode': hints['modes'] ?? const [],
          },
        ],
      },
      {
        'id': 'training_focus',
        'title': 'Training Focus',
        'blocks': [
          {
            'overview': trainingOverview['plan'] ?? 'standard',
            'nodes': trainingOverview['nodes'] ?? const [],
          },
          {
            'modules': moduleFocus,
            'preferred_path': summary['preferred_path'] ?? '',
          },
        ],
      },
      {
        'id': 'explanations',
        'title': 'Insights',
        'blocks': explanations.map((entry) {
          final map = _ensureMap(entry);
          return {
            'id': map['id'] ?? map['title'] ?? 'insight',
            'title': map['title'] ?? 'Insight',
            'detail': map['detail'] ?? '',
          };
        }).toList(),
      },
      {
        'id': 'localization',
        'title': 'Localization Status',
        'blocks': [
          {
            'coverage': localization['coverage'] ?? 0.0,
            'missing_keys': localization['missing_keys'] ?? const [],
            'high_risk': localization['high_risk'] ?? const [],
          },
        ],
      },
    ];

    return PlayerProfileBlueprintBundle(
      sections: sections,
      ordering: const [
        'persona_overview',
        'training_focus',
        'explanations',
        'localization',
      ],
      summary: {
        'module_count': moduleFocus.length,
        'engagement_score': summary['engagement_score'] ?? 0.0,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
      timestamp: DateTime.now().toUtc(),
    );
  }

  Map<String, Object?> _ensureMap(Object? raw) {
    if (raw is Map<String, Object?>) {
      return raw;
    }
    return const {};
  }

  List<Object?> _ensureList(Object? raw) {
    if (raw is List<Object?>) {
      return raw;
    }
    return const [];
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileBlueprintException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileBlueprintException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileBlueprintException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PlayerProfileBlueprintException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileBlueprintException implements Exception {
  final String message;

  PlayerProfileBlueprintException(this.message);

  @override
  String toString() => 'PlayerProfileBlueprintException: $message';
}
