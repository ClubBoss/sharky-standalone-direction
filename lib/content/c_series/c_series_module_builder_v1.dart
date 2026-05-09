class CSeriesModuleBuilderV1 {
  const CSeriesModuleBuilderV1();

  static const List<String> _requiredKeys = <String>[
    'schema_version',
    'module_id',
    'title',
    'theory',
    'drills',
    'recaps',
    'checkpoints',
    'diagnostics',
    'ready',
  ];

  Map<String, Object> buildModule(
    Map<String, Object> templateMap,
    Map<String, Object> partialMap,
  ) {
    final Map<String, Object> merged = <String, Object>{};
    for (final String key in templateMap.keys) {
      merged[key] = templateMap[key]!;
    }
    for (final MapEntry<String, Object> entry in partialMap.entries) {
      merged[entry.key] = entry.value;
    }
    merged['schema_version'] = 'v1';
    merged['ready'] = false;
    for (final String key in _requiredKeys) {
      if (!merged.containsKey(key) || merged[key] == null) {
        merged[key] = templateMap[key] ?? _fallbackValue(key);
      }
    }
    merged['diagnostics'] = 'module_builder_v1';
    return Map<String, Object>.unmodifiable(merged);
  }

  Map<String, Object> validateMerged(
    Map<String, Object> merged,
    Map<String, Object> schemaReport,
  ) {
    final List<String> missing =
        _requiredKeys.where((key) => !merged.containsKey(key)).toList()..sort();
    final Set<String> allowed = <String>{..._requiredKeys};
    if (schemaReport.containsKey('extra_fields') &&
        schemaReport['extra_fields'] is List<Object>) {
      for (final Object entry in schemaReport['extra_fields'] as List<Object>) {
        if (entry is String) {
          allowed.add(entry);
        }
      }
    }
    final List<String> extra =
        merged.keys.where((key) => !allowed.contains(key)).toList()..sort();
    return <String, Object>{
      'schema_version': 'v1',
      'valid': missing.isEmpty && extra.isEmpty,
      'missing_fields': missing,
      'extra_fields': extra,
    };
  }

  static Object _fallbackValue(String key) {
    if (key == 'ready') {
      return false;
    }
    if (key == 'schema_version') {
      return 'v1';
    }
    if (key == 'diagnostics') {
      return 'module_builder_v1';
    }
    if (key == 'module_id') {
      return '<unset>';
    }
    return const <Object>[];
  }
}
