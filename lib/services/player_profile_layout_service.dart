import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class PlayerProfileLayoutBundle {
  PlayerProfileLayoutBundle({
    required this.layout,
    required this.ordering,
    required this.timestamp,
  });

  final List<Map<String, Object?>> layout;
  final List<String> ordering;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'layout': layout,
    'ordering': ordering,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PlayerProfileLayoutService {
  static const _blueprintPath =
      'release/_reports/player_profile_blueprint.json';

  const PlayerProfileLayoutService();

  Future<PlayerProfileLayoutBundle> run() async {
    final spec = await _loadAsciiJson(_blueprintPath);

    final sections = _ensureList(spec['sections']);
    final ordering = _ensureStringList(spec['ordering']);

    final layout = <Map<String, Object?>>[];
    for (final rawSection in sections) {
      if (rawSection is! Map<String, Object?>) {
        continue;
      }
      final sectionId = rawSection['id'] as String? ?? 'section';
      final blocks = _ensureList(rawSection['blocks']);
      final blockEntries = <Map<String, Object?>>[];

      for (var index = 0; index < blocks.length; index++) {
        final rawBlock = blocks[index];
        if (rawBlock is! Map<String, Object?>) {
          continue;
        }
        final blockId =
            (rawBlock['id'] as String?) ?? '$sectionId-block-$index';
        blockEntries.add(<String, Object?>{
          'id': blockId,
          'spacing': _blockSpacing(sectionId),
          'radius': _blockRadius(sectionId),
          'style': _blockStyle(sectionId),
        });
      }

      layout.add(<String, Object?>{
        'section_id': sectionId,
        'layout_type': _layoutType(sectionId),
        'blocks': blockEntries,
      });
    }

    return PlayerProfileLayoutBundle(
      layout: layout,
      ordering: ordering,
      timestamp: DateTime.now().toUtc(),
    );
  }

  String _layoutType(String sectionId) {
    if (sectionId == 'explanations') return 'card';
    if (sectionId == 'localization') return 'list';
    return 'column';
  }

  int _blockSpacing(String sectionId) {
    if (sectionId == 'persona_overview') return 12;
    if (sectionId == 'training_focus') return 14;
    if (sectionId == 'explanations') return 16;
    return 10;
  }

  int _blockRadius(String sectionId) {
    if (sectionId == 'explanations' || sectionId == 'localization') return 10;
    return 8;
  }

  String _blockStyle(String sectionId) {
    if (sectionId == 'training_focus') return 'accent';
    return 'default';
  }

  List<Object?> _ensureList(Object? raw) {
    if (raw is List<Object?>) return raw;
    return const [];
  }

  List<String> _ensureStringList(Object? raw) {
    if (raw is List<Object?>) {
      return raw.whereType<String>().toList();
    }
    return const [];
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PlayerProfileLayoutException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PlayerProfileLayoutException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PlayerProfileLayoutException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PlayerProfileLayoutException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class PlayerProfileLayoutException implements Exception {
  final String message;

  PlayerProfileLayoutException(this.message);

  @override
  String toString() => 'PlayerProfileLayoutException: $message';
}
