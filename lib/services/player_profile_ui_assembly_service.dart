import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileUIAssemblyBundle {
  PlayerProfileUIAssemblyBundle({
    required this.sections,
    required this.ordering,
    required this.timestamp,
  });

  final List<Map<String, Object?>> sections;
  final List<String> ordering;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'sections': sections,
    'ordering': ordering,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileUIAssemblyService {
  static const _layoutPath = 'release/_reports/player_profile_layout.json';
  static const _bindingPath =
      'release/_reports/player_profile_component_binding.json';
  static const _themingPath = 'release/_reports/player_profile_theming.json';

  const PlayerProfileUIAssemblyService();

  Future<PlayerProfileUIAssemblyBundle> run() async {
    final layoutData = await _loadAsciiJson(_layoutPath);
    final bindingData = await _loadAsciiJson(_bindingPath);
    final themingData = await _loadAsciiJson(_themingPath);

    final layoutSections = _ensureList(layoutData['layout']);
    final ordering = _ensureList(
      layoutData['ordering'],
    ).whereType<String>().toList();
    final bindingEntries = _ensureList(bindingData['bindings']);
    final themingEntries = _ensureList(themingData['themes']);

    final bindingMap = <String, Map<String, Object?>>{};
    for (final entry in bindingEntries) {
      if (entry is Map<String, Object?>) {
        final blockId = entry['block_id'];
        if (blockId is String) {
          bindingMap[blockId] = entry;
        }
      }
    }

    final themingMap = <String, Map<String, Object?>>{};
    for (final entry in themingEntries) {
      if (entry is Map<String, Object?>) {
        final blockId = entry['block_id'];
        if (blockId is String) {
          themingMap[blockId] = entry;
        }
      }
    }

    final sections = <Map<String, Object?>>[];
    for (final rawSection in layoutSections) {
      if (rawSection is! Map<String, Object?>) {
        continue;
      }
      final sectionId = rawSection['section_id'] as String? ?? 'section';
      final layoutType = rawSection['layout_type'] as String? ?? 'column';
      final blocks = _ensureList(rawSection['blocks']);
      final nodes = <Map<String, Object?>>[];
      for (final rawBlock in blocks) {
        if (rawBlock is! Map<String, Object?>) {
          continue;
        }
        final blockId = rawBlock['id'] as String? ?? 'block';
        final binding = bindingMap[blockId] ?? {};
        final props = _ensureMap(binding['props']);
        final component = binding['component'] ?? 'component';
        final theming = themingMap[blockId] ?? {};
        nodes.add(<String, Object?>{
          'block_id': blockId,
          'component': component,
          'props': props,
          'theme': theming,
          'layout_type': layoutType,
        });
      }
      sections.add(<String, Object?>{
        'section_id': sectionId,
        'layout_type': layoutType,
        'nodes': nodes,
      });
    }

    return PlayerProfileUIAssemblyBundle(
      sections: sections,
      ordering: ordering,
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
      throw PlayerProfileUIAssemblyException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileUIAssemblyException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileUIAssemblyException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PlayerProfileUIAssemblyException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileUIAssemblyException implements Exception {
  final String message;

  PlayerProfileUIAssemblyException(this.message);

  @override
  String toString() => 'PlayerProfileUIAssemblyException: $message';
}
