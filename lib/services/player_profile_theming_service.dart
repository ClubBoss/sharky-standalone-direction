import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileThemingBundle {
  PlayerProfileThemingBundle({required this.themes, required this.timestamp});

  final List<Map<String, Object?>> themes;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'themes': themes,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileThemingService {
  static const _bindingPath =
      'release/_reports/player_profile_component_binding.json';
  static const _tokenSummaryPath = 'release/_reports/visual_token_summary.json';
  static const _designPath = 'release/_reports/visual_design_lift_spec.json';

  const PlayerProfileThemingService();

  Future<PlayerProfileThemingBundle> run() async {
    final bindingData = await _loadAsciiJson(_bindingPath);
    final tokenSummary = await _loadAsciiJson(_tokenSummaryPath);
    final designSpec = await _loadAsciiJson(_designPath);

    final bindings = _ensureList(bindingData['bindings']);
    final colorTokens = _ensureMap(tokenSummary['color_tokens']);
    final typographyTokens = _ensureMap(tokenSummary['typography']);
    final stateOverrides = _ensureMap(designSpec['interactive_states']);

    final themes = <Map<String, Object?>>[];
    for (final binding in bindings) {
      if (binding is! Map<String, Object?>) continue;
      final blockId = binding['block_id'] as String? ?? 'block';
      final component = binding['component'] as String? ?? 'component';
      final props = _ensureMap(binding['props']);

      final colors = _resolveColors(colorTokens, component);
      final textStyle = _resolveTypography(typographyTokens, component);
      final states = _resolveStates(stateOverrides, component);
      final contrastScore = _contrastScore(
        colors['primary'] ?? '#000000',
        colors['surface'] ?? '#ffffff',
      );

      themes.add(<String, Object?>{
        'block_id': blockId,
        'component': component,
        'colors': colors,
        'text_style': {...textStyle, 'spacing': props['spacing'] ?? 0},
        'states': states,
        'contrast_score': contrastScore,
      });
    }

    return PlayerProfileThemingBundle(
      themes: themes,
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
    if (raw is List<Object?>) return raw;
    return const [];
  }

  Map<String, String> _resolveColors(
    Map<String, Object?> tokens,
    String component,
  ) {
    final componentToken = tokens[component];
    if (componentToken is Map<String, Object?>) {
      return _mapStringValues(componentToken);
    }
    final defaultToken = tokens['default'];
    if (defaultToken is Map<String, Object?>) {
      return _mapStringValues(defaultToken);
    }
    return <String, String>{
      'primary': '#000000',
      'surface': '#ffffff',
      'border': '#cccccc',
    };
  }

  Map<String, String> _mapStringValues(Map<String, Object?> input) {
    final result = <String, String>{};
    input.forEach((key, value) {
      if (value is String) {
        result[key] = value;
      }
    });
    return result;
  }

  Map<String, String> _resolveTypography(
    Map<String, Object?> tokens,
    String component,
  ) {
    final componentToken = tokens[component];
    if (componentToken is Map<String, Object?>) {
      return _mapStringValues(componentToken);
    }
    final defaultToken = tokens['default'];
    if (defaultToken is Map<String, Object?>) {
      return _mapStringValues(defaultToken);
    }
    return <String, String>{'size': '14', 'weight': '400', 'lineHeight': '20'};
  }

  Map<String, Object?> _resolveStates(
    Map<String, Object?> tokens,
    String component,
  ) {
    final specific = tokens[component];
    if (specific is Map<String, Object?>) {
      return specific;
    }
    final defaults = tokens['default'];
    if (defaults is Map<String, Object?>) {
      return defaults;
    }
    return const {'default': 'visible', 'hover': 'none', 'pressed': 'none'};
  }

  double _contrastScore(String primary, String surface) {
    final primaryValue = _colorBrightness(primary);
    final surfaceValue = _colorBrightness(surface);
    final diff = (primaryValue - surfaceValue).abs();
    return (diff / 255).clamp(0.0, 1.0);
  }

  int _colorBrightness(String hex) {
    final normalized = hex.replaceAll('#', '').padLeft(6, '0');
    try {
      final value = int.parse(normalized.substring(0, 6), radix: 16);
      final r = (value >> 16) & 0xFF;
      final g = (value >> 8) & 0xFF;
      final b = value & 0xFF;
      return ((r * 299) + (g * 587) + (b * 114)) ~/ 1000;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileThemingException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileThemingException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileThemingException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PlayerProfileThemingException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileThemingException implements Exception {
  final String message;

  PlayerProfileThemingException(this.message);

  @override
  String toString() => 'PlayerProfileThemingException: $message';
}
