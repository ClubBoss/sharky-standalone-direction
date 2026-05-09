/// Passive completeness auditor for V4TokenRegistry.
class V4TokenRegistryCompletenessV1 {
  const V4TokenRegistryCompletenessV1(this.tokenRegistry);

  final Map<String, Object> tokenRegistry;

  Map<String, Object> run() {
    final List<String> expected = <String>[
      'colors',
      'font_body',
      'font_title',
      'scale_body',
      'scale_title',
      'letter_spacing_body',
      'letter_spacing_title',
      'debug',
    ];
    final List<String> missingKeys = expected
        .where((k) => !tokenRegistry.containsKey(k))
        .toList();
    final List<String> emptyValues = <String>[];
    final List<String> invalidShapes = <String>[];

    for (final String key in expected) {
      final Object? value = tokenRegistry[key];
      if (value == null ||
          (value is Map && value.isEmpty) ||
          (value is Iterable && value.isEmpty) ||
          (value is String && value.isEmpty)) {
        emptyValues.add(key);
      } else if (!(value is Map ||
          value is String ||
          value is num ||
          value is bool)) {
        invalidShapes.add(key);
      }
    }

    final bool registryReady =
        missingKeys.isEmpty && emptyValues.isEmpty && invalidShapes.isEmpty;

    return <String, Object>{
      'has_tokens': tokenRegistry.isNotEmpty,
      'missing_keys': missingKeys,
      'empty_values': emptyValues,
      'invalid_shapes': invalidShapes,
      'registry_ready': registryReady,
    };
  }
}
