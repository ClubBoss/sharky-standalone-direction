class SmartPackMetadataNormalizerV1 {
  const SmartPackMetadataNormalizerV1();

  Map<String, Object> normalizeMetadata(Map<String, Object?> rawStore) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    Map<String, Object> _normalizePack(Map<String, Object?> pack) {
      final id = pack['id']?.toString() ?? 'unknown';
      final name = pack['name']?.toString() ?? 'unnamed';
      final category = pack['category']?.toString() ?? 'general';
      final tags =
          (pack['tags'] as List<Object?>? ?? const [])
              .map((t) => t?.toString() ?? '')
              .where((t) => t.isNotEmpty && _isAscii(t))
              .toList()
            ..sort();

      final normalized = <String, Object>{
        'id': _isAscii(id) ? id : 'unknown',
        'name': _isAscii(name) ? name : 'unnamed',
        'category': _isAscii(category) ? category : 'general',
        'tags': List<String>.unmodifiable(tags),
      };
      return Map<String, Object>.unmodifiable(normalized);
    }

    const fallback = <String, Object>{
      'metadata': <String, Object>{},
      'drivers': <String>['smart_pack_metadata_safe_fallback'],
      'conflicts': <String>[],
      'ok': false,
    };

    if (rawStore.isEmpty || rawStore['available_packs'] is! List) {
      return fallback;
    }

    final drivers = <String>[];
    final conflicts = <String>[];
    final packs = <Map<String, Object>>[];
    for (final pack in rawStore['available_packs'] as List) {
      if (pack is Map<String, Object?>) {
        packs.add(_normalizePack(pack));
      } else {
        conflicts.add('invalid_pack');
      }
    }
    drivers.add('packs:${packs.length}');
    drivers.sort();
    conflicts.sort();

    final ok = conflicts.isEmpty;
    final metadata = <String, Object>{
      'packs': List<Map<String, Object>>.unmodifiable(packs),
    };
    return Map<String, Object>.unmodifiable(<String, Object>{
      'metadata': metadata,
      'drivers': List<String>.unmodifiable(drivers),
      'conflicts': List<String>.unmodifiable(conflicts),
      'ok': ok,
    });
  }
}
