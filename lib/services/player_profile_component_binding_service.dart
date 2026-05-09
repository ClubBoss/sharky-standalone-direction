import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileComponentBindingBundle {
  PlayerProfileComponentBindingBundle({
    required this.bindings,
    required this.timestamp,
  });

  final List<Map<String, Object?>> bindings;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'bindings': bindings,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileComponentBindingService {
  static const _layoutPath = 'release/_reports/player_profile_layout.json';
  static const _componentPath =
      'release/_reports/component_library_bundle.json';
  static const _designPath = 'release/_reports/visual_design_lift_spec.json';

  const PlayerProfileComponentBindingService();

  Future<PlayerProfileComponentBindingBundle> run() async {
    final layoutData = await _loadAsciiJson(_layoutPath);
    final componentData = await _loadAsciiJson(_componentPath);
    final designData = await _loadAsciiJson(_designPath);

    final layoutSections = _ensureList(layoutData['layout']);
    final components = _extractComponentPatterns(componentData['components']);
    final designTokens = _extractDesignTokens(designData['tokens']);

    final bindings = <Map<String, Object?>>[];

    for (final section in layoutSections) {
      if (section is! Map<String, Object?>) continue;
      final sectionId = section['section_id'] as String? ?? 'section';
      final layoutType = section['layout_type'] as String? ?? 'column';
      final blocks = _ensureList(section['blocks']);

      final tokens =
          designTokens[layoutType] ??
          designTokens['default'] ??
          _defaultTokens();

      for (final block in blocks) {
        if (block is! Map<String, Object?>) continue;
        final blockId = block['id'] as String? ?? '$sectionId-block';
        final spacing = block['spacing'] ?? tokens['spacing'] ?? 8;
        final radius = block['radius'] ?? tokens['radius'] ?? 6;
        final component = _inferComponent(blockId, sectionId, components);

        bindings.add(<String, Object?>{
          'block_id': blockId,
          'component': component,
          'props': <String, Object?>{
            'spacing': spacing,
            'radius': radius,
            'shadow': tokens['shadow'] ?? 'none',
            'text_style': tokens['text_style'] ?? 'body',
          },
        });
      }
    }

    return PlayerProfileComponentBindingBundle(
      bindings: bindings,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Map<String, Object?> _defaultTokens() => <String, Object?>{
    'spacing': 8,
    'radius': 6,
    'shadow': 'none',
    'text_style': 'body',
  };

  List<Map<String, String>> _extractComponentPatterns(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final patterns = <Map<String, String>>[];
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        final pattern = (entry['pattern'] as String? ?? '').toLowerCase();
        final component = entry['component'] as String? ?? '';
        if (pattern.isNotEmpty && component.isNotEmpty) {
          patterns.add({'pattern': pattern, 'component': component});
        }
      }
    }
    return patterns;
  }

  Map<String, Map<String, Object?>> _extractDesignTokens(Object? raw) {
    if (raw is! Map<String, Object?>) {
      return const {};
    }
    final tokens = <String, Map<String, Object?>>{};
    raw.forEach((key, value) {
      if (value is Map<String, Object?>) {
        tokens[key] = Map<String, Object?>.from(value);
      }
    });
    return tokens;
  }

  List<Object?> _ensureList(Object? raw) {
    if (raw is List<Object?>) return raw;
    return const [];
  }

  String _inferComponent(
    String blockId,
    String sectionId,
    List<Map<String, String>> components,
  ) {
    final lowerId = blockId.toLowerCase();
    for (final entry in components) {
      final pattern = entry['pattern'] ?? '';
      if (pattern.isNotEmpty && lowerId.contains(pattern)) {
        return entry['component'] ?? 'GenericPanel';
      }
    }
    final lowerSection = sectionId.toLowerCase();
    for (final entry in components) {
      final pattern = entry['pattern'] ?? '';
      if (pattern.isNotEmpty && lowerSection.contains(pattern)) {
        return entry['component'] ?? 'GenericPanel';
      }
    }
    return 'GenericPanel';
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileComponentBindingException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileComponentBindingException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileComponentBindingException(
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
      throw PlayerProfileComponentBindingException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileComponentBindingException implements Exception {
  final String message;

  PlayerProfileComponentBindingException(this.message);

  @override
  String toString() => 'PlayerProfileComponentBindingException: $message';
}
