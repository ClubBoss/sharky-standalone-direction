import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileRenderTreeBundle {
  PlayerProfileRenderTreeBundle({
    required this.screen,
    required this.timestamp,
  });

  final Map<String, Object?> screen;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'screen': screen,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileScreenRendererService {
  static const _assemblyPath =
      'release/_reports/player_profile_ui_assembly.json';

  const PlayerProfileScreenRendererService();

  Future<PlayerProfileRenderTreeBundle> run() async {
    final assembly = await _loadAsciiJson(_assemblyPath);
    final sections = _ensureList(assembly['sections']);
    final ordering = _ensureList(
      assembly['ordering'],
    ).whereType<String>().toList();

    final renderSections = <Map<String, Object?>>[];
    for (final section in sections) {
      if (section is! Map<String, Object?>) {
        continue;
      }
      final sectionId = section['section_id'] as String? ?? 'section';
      final layoutType = section['layout_type'] as String? ?? 'column';
      final nodes = _ensureList(section['nodes']);
      final renderNodes = <Map<String, Object?>>[];
      for (final node in nodes) {
        if (node is! Map<String, Object?>) {
          continue;
        }
        final blockId = node['block_id'] as String? ?? 'block';
        final component = node['component'] ?? 'component';
        final props = _ensureMap(node['props']);
        final theme = _ensureMap(node['theme']);
        renderNodes.add(<String, Object?>{
          'node_id': blockId,
          'component': component,
          'layout_type': layoutType,
          'props': props,
          'theme': theme,
          'children': const [],
        });
      }
      renderSections.add(<String, Object?>{
        'section_id': sectionId,
        'layout_type': layoutType,
        'nodes': renderNodes,
      });
    }

    final screen = <String, Object?>{
      'sections': renderSections,
      'ordering': ordering,
    };

    return PlayerProfileRenderTreeBundle(
      screen: screen,
      timestamp: DateTime.now().toUtc(),
    );
  }

  List<Object?> _ensureList(Object? raw) {
    if (raw is List<Object?>) {
      return raw;
    }
    return const [];
  }

  Map<String, Object?> _ensureMap(Object? raw) {
    if (raw is Map<String, Object?>) {
      return raw;
    }
    return const {};
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileScreenRendererException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileScreenRendererException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileScreenRendererException(
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
      throw PlayerProfileScreenRendererException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileScreenRendererException implements Exception {
  final String message;

  PlayerProfileScreenRendererException(this.message);

  @override
  String toString() => 'PlayerProfileScreenRendererException: $message';
}
