class SmartPackDynamicFiltersV1 {
  const SmartPackDynamicFiltersV1();

  Map<String, Object> buildFilters(Map<String, Object> normalizedMetadata) {
    bool _isAscii(String s) {
      for (final code in s.runes) {
        if (code > 127) return false;
      }
      return true;
    }

    const fallback = <String, Object>{
      'filters': <String, Object>{},
      'drivers': <String>['smart_pack_filters_safe_fallback'],
      'conflicts': <String>[],
      'ok': false,
    };

    final metadata = normalizedMetadata['metadata'];
    if (metadata is! Map || metadata['packs'] is! List) return fallback;

    final byCategory = <String>{};
    final byDifficulty = <String>{};
    final byPersonaAffinity = <String>{};
    final byRpgPower = <String>{};
    final conflicts = <String>[];

    for (final pack in metadata['packs'] as List) {
      if (pack is! Map) {
        conflicts.add('invalid_pack');
        continue;
      }
      final category = pack['category']?.toString() ?? '';
      if (_isAscii(category) && category.isNotEmpty) {
        byCategory.add(category);
      } else if (category.isNotEmpty) {
        conflicts.add('non_ascii_category');
      }
      final tags = pack['tags'] is List ? pack['tags'] as List : const [];
      for (final tag in tags) {
        final s = tag.toString();
        if (!_isAscii(s)) {
          conflicts.add('non_ascii_tag');
          continue;
        }
        if (s.startsWith('difficulty:')) {
          byDifficulty.add(s.substring('difficulty:'.length));
        } else if (s.startsWith('persona:')) {
          byPersonaAffinity.add(s.substring('persona:'.length));
        } else if (s.startsWith('rpg:')) {
          byRpgPower.add(s.substring('rpg:'.length));
        }
      }
    }

    final drivers = <String>[
      'packs:${metadata['packs'] is List ? (metadata['packs'] as List).length : 0}',
    ]..sort();
    final filters = <String, Object>{
      'by_category': List<String>.unmodifiable(byCategory.toList()..sort()),
      'by_difficulty': List<String>.unmodifiable(byDifficulty.toList()..sort()),
      'by_persona_affinity': List<String>.unmodifiable(
        byPersonaAffinity.toList()..sort(),
      ),
      'by_rpg_power': List<String>.unmodifiable(byRpgPower.toList()..sort()),
    };

    conflicts.sort();
    final ok = conflicts.isEmpty;

    return <String, Object>{
      'filters': filters,
      'drivers': List<String>.unmodifiable(drivers),
      'conflicts': List<String>.unmodifiable(conflicts),
      'ok': ok,
    };
  }
}
