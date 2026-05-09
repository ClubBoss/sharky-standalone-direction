class SmartPackSurfaceV1 {
  const SmartPackSurfaceV1();

  Map<String, Object> buildSurface({
    required Map<String, Object> normalizedMetadata,
    required Map<String, Object> filters,
    required Map<String, Object> recommendations,
    required Map<String, Object> affinity,
  }) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    final metadata = normalizedMetadata['metadata'];
    final metaPacks = metadata is Map
        ? metadata['packs'] as List? ?? const []
        : const [];

    final scoreMap = <String, int>{};
    final conflicts = <String>[];
    final drivers = <String>[];
    final affinityScores =
        affinity['affinity_scores'] as Map<String, Object>? ??
        const <String, Object>{};
    for (final entry in affinityScores.entries) {
      final key = entry.key.toString();
      if (!_isAscii(key)) {
        conflicts.add('non_ascii_pack');
        continue;
      }
      if (entry.value is num) {
        final v = (entry.value as num).toInt().clamp(0, 100);
        scoreMap[key] = v;
      }
    }
    drivers.add('scores:${scoreMap.length}');

    final ids = <String>[];
    for (final pack in metaPacks) {
      if (pack is Map && pack['id'] != null) {
        final id = pack['id'].toString();
        if (_isAscii(id)) ids.add(id);
      }
    }

    ids.sort((a, b) {
      final sa = scoreMap[a] ?? 0;
      final sb = scoreMap[b] ?? 0;
      if (sa == sb) return a.compareTo(b);
      return sb.compareTo(sa);
    });

    drivers.sort();
    conflicts.sort();
    final ok = conflicts.isEmpty && scoreMap.isNotEmpty;

    return <String, Object>{
      'surface_ok': ok,
      'packs': List<String>.unmodifiable(ids),
      'scores': Map<String, int>.unmodifiable(scoreMap),
      'filters': Map<String, Object>.unmodifiable(filters),
      'drivers': List<String>.unmodifiable(drivers),
      'conflicts': List<String>.unmodifiable(conflicts),
    };
  }
}
